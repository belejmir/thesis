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
  Logs.info ~src:Logs.default (fun f -> f "Received payload: %s" body_str);
  let hashed_body = Digestif.SHA256.digest_string body_str |> Digestif.SHA256.to_hex in
  Logs.info ~src:Logs.default (fun f -> f "Hashed body: %s" hashed_body);


  let headers = Cohttp.Header.init_with "Content-Type" "text/plain" in
  let headers = Cohttp.Header.add headers "Access-Control-Allow-Origin" "*" in
  let content_len = string_of_int (String.length hashed_body) in
  let headers = Cohttp.Header.add headers "Content-length" content_len in
  let response = Cohttp.Response.make ~status:`OK ~headers () in
  Lwt.return (response, Cohttp_lwt.Body.of_string hashed_body)


(* Main module using Cohttp *)
module Main (S : Tcpip.Stack.V4V6) = struct
  module Conduit = Conduit_mirage.TCP(S)
  module Server = Cohttp_mirage.Server.Make(Conduit)
    (* Start the HTTP server *)
  let start stack =
    let port = 8081 in
    Logs.info ~src:Logs.default (fun f -> f "Starting MirageOS HTTP server on port %d" port);
    let callback = server_callback in
    let mode : Conduit_mirage.server = `TCP port in
    let server = Server.make ~callback () in

    Server.listen stack mode server
end

