open Lwt.Infix
open Lwt_io
(* open Lwt_unix *)

module ServerConfig = struct
  let buffer_size = 1024
  let server_address = Unix.inet_addr_loopback
  let server_port = 9000

  let socket_config () =
    let sockaddr = Lwt_unix.ADDR_INET (server_address, server_port) in
    let socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in

    (socket, sockaddr)
end

open  ServerConfig

let rec receive_messages client_sock =
  let buffer = Bytes.create buffer_size in
  Lwt_unix.recv client_sock buffer 0 buffer_size [] >>= fun bytes_read ->
  if bytes_read = 0 then printl "Server closed the connection."
  else
    let message = Bytes.sub_string buffer 0 bytes_read in
    printl ("Received: " ^ message) >>= fun () -> receive_messages client_sock

let rec send_messages client_sock =
  Lwt_io.read_line_opt stdin >>= function
  | Some message ->
      let message_bytes = Bytes.of_string (message ^ "\n") in
      Lwt_unix.send client_sock message_bytes 0 (Bytes.length message_bytes) []
      >>= fun _ -> send_messages client_sock
  | None -> Lwt_unix.close client_sock

(** Start a bidirectionnal chat with the given socket.
  The function handles setting up sending and receiving events.
  @param client_sock Client socket.
*)
let start_chat client_sock () =
  let send_task = send_messages client_sock in
  let receive_task = receive_messages client_sock in

  (* Wait for both tasks to complete *)
  Lwt.join [ send_task; receive_task ]

