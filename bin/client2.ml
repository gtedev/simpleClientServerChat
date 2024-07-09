open Lwt.Infix
open Lwt_unix
open Lwt_io
open Chat

let main () =
  let server_sock, sockaddr = ServerConfig.socket_config () in

  connect server_sock sockaddr >>= fun () ->
  printl "Connection server success !"
  >>= start_chat server_sock ~client_name:"Client"

let initiate () = Lwt_main.run (main ())
