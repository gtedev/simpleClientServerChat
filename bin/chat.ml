open Lwt.Infix
open Lwt_io
(* open Spectrum *)
let buffer_size = 1024
let server_address = "127.0.0.1"
let server_port = 50000

let get_server_socket_config () =
  let socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in

  (socket, server_address, server_port)

let addr_inet server_address server_port =
  Lwt_unix.ADDR_INET (Unix.inet_addr_of_string server_address, server_port)

let log_title message =
    Spectrum.prepare_ppf Format.std_formatter (); (* prints to stdout *)
    Spectrum.Simple.printf "@{<bold,teal>%s@}\n" message;
    Lwt.return_unit

let print_chat_message client_name body =
  Spectrum.prepare_ppf Format.std_formatter (); (* prints to stdout *)
  Spectrum.Simple.printf "@{<bold, fuchsia>%s@} @{<white>%s@}\n" (client_name ^ ": ") body;
  Lwt.return_unit

let log_info message =
  Spectrum.prepare_ppf Format.std_formatter (); (* prints to stdout *)
  Spectrum.Simple.printf "@{<italic,teal>%s@}\n" ("==> LOG: " ^ message);
  Lwt.return_unit

let send (client : Lwt_unix.file_descr) message =
  let bytes = Bytes.of_string (message ^ "\n") in
  let length = Bytes.length bytes in
  Lwt_unix.send client bytes 0 length []

let rec receive_messages_from_socket sock client_name =
  let buffer = Bytes.create buffer_size in
  Lwt_unix.recv sock buffer 0 buffer_size [] >>= fun bytes_length ->
  if bytes_length = 0 then log_info "Connection closed..."
  else
    let message = Bytes.sub_string buffer 0 bytes_length in

    message |> Message.toPayload |> function
    | Some (SEND { sender; body; timestamp }) ->
        (* For simplicity. let's pretend it takes 1s to process the msg *)
        Thread.delay 1.0;

        print_chat_message sender body >>= fun () ->
        "[ACK] Message received by: " ^ client_name
        |> Message.create_ack client_name timestamp
        |> Message.toString |> send sock
        >>= fun _ -> receive_messages_from_socket sock client_name
    | Some (ACK payload) ->
        let roundtrip__message =
          payload.timestamp
          |> Option.map (fun t ->
                 (Unix.time () -. t |> string_of_float) ^ " seconde(s)")
          |> Option.value ~default:"Unknown"
        in
        log_info (payload.body ^ " - Roundtrip time: " ^ roundtrip__message)
        >>= fun () -> receive_messages_from_socket sock client_name
    | _ -> receive_messages_from_socket sock client_name

let rec send_messages_to_socket sock client_name =
  Lwt_io.read_line_opt stdin >>= function
  | Some input ->
      let timestamp = Some (Unix.time ()) in
      input
      |> Message.create_send client_name timestamp
      |> Message.toString |> send sock
      >>= fun _ ->
      print_chat_message client_name input >>= fun _ ->
      send_messages_to_socket sock client_name
  | None -> Lwt_unix.close sock

(** Start a bidirectionnal chat with the given socket.
  The function handles setting up sending and receiving events.
  @param sock Socket from which it sends and receives messages
*)
let start_chat sock ~client_name () =
  let send_job = send_messages_to_socket sock client_name in
  let receive_job = receive_messages_from_socket sock client_name in

  (* With pick, it ensures one task stops if the other stops before*)
  Lwt.pick [ send_job; receive_job ]
