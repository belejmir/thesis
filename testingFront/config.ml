open Mirage

(* Main unikernel module *)
let main = main ~packages:[package "cohttp-mirage"] "Unikernel.Main" (stackv4v6 @-> job)
(* Network stack configuration *)
let stack = generic_stackv4v6 default_network

let () =
  register "http-server" [ main $ stack ]

