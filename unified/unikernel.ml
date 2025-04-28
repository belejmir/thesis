open Lwt.Infix

(* Define the HTTP server callback *)
let server_callback _conn req body =
  let uri = Cohttp.Request.uri req in
  let method_ = Cohttp.Request.meth req in
  Logs.info (fun f ->
      f "Received %s request for %s"
        (Cohttp.Code.string_of_method method_)
        (Uri.to_string uri));
  
  body |> Cohttp_lwt.Body.to_string >>= fun body_str ->
  let hashed_body = Digestif.SHA256.digest_string body_str |> Digestif.SHA256.to_hex in
  let response_body = "This will be hashed-> " ^ body_str in
  Logs.info ~src:Logs.default (fun f -> f "Response Body: %s" response_body);
  Logs.info ~src:Logs.default (fun f -> f "Hashed body: %s" hashed_body);
  let headers = Cohttp.Header.init_with "Content-Type" "text/plain" in
  let response = Cohttp.Response.make ~status:`OK ~headers () in
  Lwt.return (response, Cohttp_lwt.Body.of_string hashed_body)
  (*Cohttp_lwt.Server.respond_string ~status:`OK ~body:response_body ()*)


(* Main module using Cohttp *)
module Main (S : Tcpip.Stack.V4V6) = struct
  module Conduit = Conduit_mirage.TCP(S)
  module Server = Cohttp_mirage.Server.Make(Conduit)
    (* Start the HTTP server *)
  let start stack =
    let port = 8080 in
    Logs.info (fun f -> f "Starting MirageOS HTTP server on port %d" port);
    let callback = server_callback in
    let mode : Conduit_mirage.server = `TCP port in
    let server = Server.make ~callback () in

    Server.listen stack mode server
end
