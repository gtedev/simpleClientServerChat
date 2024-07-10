open Lwt
open Lwt.Infix
open Lwt_unix
open Lwt_io
open Chat

(** Wait for incoming clients, accept them then, engage a chat on the accepted client socket
    @param server_sock Server socket.
*)
let wait_incoming_connections server_sock () =
  let rec accept_connections () =
    accept server_sock >>= fun (client_sock, _) ->
    async (fun () ->
        printl "Client accepted...\n"
        >>= start_chat client_sock ~client_name:"Serveur");

    accept_connections ()
  in

  accept_connections ()

let main () =
  let _ = printl "=========== Server ===========\n\n\n" in
  let server_sock, sockaddr = get_server_socket_config () in
  setsockopt server_sock SO_REUSEADDR true;

  bind server_sock sockaddr >>= fun () ->
  listen server_sock 1;

  printl "Server listening on port 9000..."
  >>= wait_incoming_connections server_sock

let initiate () = Lwt_main.run (main ())
