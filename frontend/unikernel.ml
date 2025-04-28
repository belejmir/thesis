open Lwt.Infix

(*192.168.254.11*)
let target_host = "http://192.168.254.11"
let target_port = 8081


(* Main module using Cohttp *)
module Main
        (Pclock : Mirage_clock.PCLOCK)
        (Conduit : Conduit_mirage.S)
        (Resolver : Resolver_mirage.S)
        (Stack : Tcpip.Stack.V4V6) = struct
                
  module Client = Cohttp_mirage.Client.Make(Pclock)(Resolver)(Conduit)
  module Server = Cohttp_mirage.Server.Make(Conduit)
  (*Define the forwarding logic*)
  let forward_request uri body resolver conduit =   
    let target_uri = Uri.of_string target_host in  
    let target_uri = Uri.with_port target_uri (Some target_port) in
    let target_uri = Uri.with_path target_uri (Uri.path uri ) in
    Logs.info ~src:Logs.default (fun f -> f "Forwarding to %s" (Uri.to_string target_uri));
    let headers = Cohttp.Header.init () in
    let body = Cohttp_lwt.Body.of_string body in

    let ctx = Client.ctx resolver conduit in 

    Client.post ~ctx ~headers ~body target_uri >>= fun (resp, resp_body) ->
    Cohttp_lwt.Body.to_string resp_body >|= fun body_str ->
    Logs.info ~src:Logs.default (fun f -> f "Received response from %s" (Uri.to_string target_uri));
    (resp, body_str)


  (* Define the HTTP server callback *)
  let server_callback _conn req body resolver conduit =
    let uri = Cohttp.Request.uri req in
    let method_ = Cohttp.Request.meth req in
    Logs.info (fun f ->
            f "Received %s request for %s"
            (Cohttp.Code.string_of_method method_)
            (Uri.to_string uri));
    Cohttp_lwt.Body.to_string body >>= fun body_str ->
    let response_body = "This will be hashed-> " ^ body_str in
    Logs.info ~src:Logs.default (fun f -> f "Response Body: %s" response_body);
    (*forward_request uri body_str resolver conduit >>= fun (response, response_body) ->
    Logs.info ~src:Logs.default (fun f -> f "Response body from forwared request: %s" response_body);*)
    
        
    let headers = Cohttp.Header.init_with "Content-Type" "text/plain" in
    let response = Cohttp.Response.make ~status:`OK ~headers () in 
    Lwt.return (response, Cohttp_lwt.Body.of_string response_body)


    (* Start the HTTP server *)
  let start _pclock _conduit _resolver stack =
    Logs.info (fun f -> f "Before port");
    let port = 8080 in
    Logs.info (fun f -> f "Defined port");
    Logs.info (fun f -> f "Starting MirageOS HTTP server on port %d" port);
    let callback _conn req body = server_callback _conn req body _resolver _conduit in
    let mode : Conduit_mirage.server = `TCP port in
    let server = Server.make ~callback () in

    Server.listen stack mode server
end
