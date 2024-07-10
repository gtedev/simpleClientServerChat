open Lwt
open Lwt.Infix
open Lwt_unix
open Chat

(** Wait for incoming clients, accept them then, engage a chat on the accepted client socket
    @param server_sock Server socket.
*)
let wait_incoming_connections server_sock () =
  let rec accept_connections () =
    accept server_sock >>= fun (client_sock, _) ->
    async (fun () ->
        log_info "1 new client has joined the chat...\n"
        >>= start_chat client_sock ~client_name:"Server");

    accept_connections ()
  in

  accept_connections ()

let main () =
  let _ = log_title "=========== Server ===========\n\n" in
  let server_sock, server_addr, server_port = get_server_socket_config () in
  let sockaddr = addr_inet server_addr server_port in

  setsockopt server_sock SO_REUSEADDR true;

  bind server_sock sockaddr >>= fun () ->
  listen server_sock 1;

  log_info
    ("Server listening on address " ^ server_addr ^ ", port "
    ^ (server_port |> string_of_int)
    ^ "...")
  >>= fun _ -> log_info "Waiting for incoming clients to connect..."
  >>= wait_incoming_connections server_sock

let initiate () = Lwt_main.run (main ())
