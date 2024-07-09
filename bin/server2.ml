open Lwt.Infix
open Util2
open Lwt_unix

let wait_incoming_connections  server_sock = 
  fun () ->
    (* Function to accept client connections and handle them *)
    let rec accept_connections () =
      Lwt_unix.accept server_sock >>= fun (client_sock, _) ->
      Lwt.async (fun () ->
        Lwt_io.printf "Client connected.\n" >>=  start_chat client_sock 
      );
      accept_connections ()
    in
  
    accept_connections ()

(* Main server function *)
let main () =
  let server_sock, _ = get_server_socket_config () in

  setsockopt server_sock SO_REUSEADDR true;
  listen server_sock 10;

  log_console  "Server listening on port 8080..." ()
  >>= wait_incoming_connections server_sock

let initiate() =
  Lwt_main.run (main ())
