open Mirage



(* Network stack configuration *)
let stack = generic_stackv4v6 default_network

open Mirage

(* Main unikernel module *)
let main = 
        main 
        ~packages:[package "cohttp-mirage"]
        "Unikernel.Main"
        (pclock @-> conduit @-> resolver @-> stackv4v6 @-> job)

let () =
  register "frontend-server" [ main $ default_posix_clock $ conduit_direct stack $ resolver_dns stack $ stack ]
