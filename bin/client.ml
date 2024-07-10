open Lwt.Infix
open Lwt_unix
open Lwt_io
open Chat

let main client_name =
  let _ = printl "=========== Client ===========\n\n\n" in
  let server_sock, server_addr, server_port = get_server_socket_config () in
  let sockaddr = addr_inet server_addr server_port in

  connect server_sock sockaddr
  >>= (fun () -> printl ("Connection to server on " ^ server_addr))
  >>= start_chat server_sock ~client_name

let initiate ~client_name = Lwt_main.run (main client_name)
