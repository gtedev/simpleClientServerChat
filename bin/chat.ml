open Lwt.Infix
open Lwt_io

module ServerConfig = struct
  let buffer_size = 1024
  let server_address = Unix.inet_addr_loopback
  let server_port = 9000

  let socket_config () =
    let sockaddr = Lwt_unix.ADDR_INET (server_address, server_port) in
    let socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in

    (socket, sockaddr)
end

open ServerConfig

let print_chat_message from body = printl (from ^ ": " ^ body)

let send client_sock message =
  let bytes = Bytes.of_string (message ^ "\n") in
  let length = Bytes.length bytes in
  Lwt_unix.send client_sock bytes 0 length []

let rec receive_messages client_sock client_name =
  let buffer = Bytes.create buffer_size in
  Lwt_unix.recv client_sock buffer 0 buffer_size [] >>= fun bytes_read ->
  if bytes_read = 0 then printl "Connection closed..."
  else
    let message = Bytes.sub_string buffer 0 bytes_read |> Message.toPayload in

    match message with
    | Some (SEND { from; body; timestamp_sent }) ->
        (* For simplicity. let's pretend it takes 1s to process the msg *)
        Thread.delay 1.0;

        print_chat_message from body >>= fun () ->
        "[ACK] Message successfully reveived and processed by: " ^ client_name
        |> Message.create_ack client_name timestamp_sent
        |> Message.toString |> send client_sock
        >>= fun _ -> receive_messages client_sock client_name
    | Some (ACK payload) ->
        let roundtrip_time_message =
          match payload.timestamp_sent with
          | Some timestamp_sent ->
              let roundtripTime =
                (Unix.time ()) -. timestamp_sent
              in
              (roundtripTime |> string_of_float) ^ " seconde(s)"
          | None -> "Unknown"
        in
        printl (payload.body ^ " - Roundtrip time: " ^ roundtrip_time_message)
        >>= fun () -> receive_messages client_sock client_name
    | _ -> receive_messages client_sock client_name

let rec send_messages client_sock client_name =
  Lwt_io.read_line_opt stdin >>= function
  | Some message ->
      let timestamp_sent = Some (Unix.time ()) in
      message
      |> Message.create_send client_name timestamp_sent
      |> Message.toString |> send client_sock
      >>= fun _ ->
      print_chat_message client_name message >>= fun _ ->
      send_messages client_sock client_name
  | None -> Lwt_unix.close client_sock

(** Start a bidirectionnal chat with the given socket.
  The function handles setting up sending and receiving events.
  @param client_sock Client socket.
*)
let start_chat client_sock ~client_name () =
  let send_job = send_messages client_sock client_name in
  let receive_job = receive_messages client_sock client_name in

  (* With pick, it ensures one task stops if the other stops before*)
  Lwt.pick [ send_job; receive_job ]
