open Lwt.Infix
open Lwt_unix
open Util2

let main () =
  let client_sock, sockaddr = get_server_socket_config () in

  connect client_sock sockaddr
  >>= log_console "Connection server success !"
  >>= start_chat client_sock

let initiate () = Lwt_main.run (main ())
