open Lwt.Infix
open Lwt_unix
open Lwt_io
open Chat

let main client_name =
  let _ = printl "=========== Client ===========\n\n\n" in
  let server_sock, sockaddr = get_server_socket_config () in

  connect server_sock sockaddr >>= fun () ->
  printl "Connection server successfully to !"
  >>= start_chat server_sock ~client_name

let initiate ~client_name = Lwt_main.run (main client_name)
