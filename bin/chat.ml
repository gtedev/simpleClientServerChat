open Lwt.Infix
open Lwt_io

let buffer_size = 1024
let server_address = "127.0.0.1"
let server_port = 50000

(** Setup the formatter to allow the use of stylished text in Console with Spectrum.*)
let setup_console_formatter () = Spectrum.prepare_ppf Format.std_formatter ()

let get_server_socket_config () =
  let socket = Lwt_unix.socket PF_INET SOCK_STREAM 0 in

  (socket, server_address, server_port)

let addr_inet server_address server_port =
  Lwt_unix.ADDR_INET (Unix.inet_addr_of_string server_address, server_port)

let log_title message =
  Spectrum.Simple.printf "@{<bold,teal>%s@}\n" message;
  Lwt.return_unit

let print_chat_message client_name body =
  Spectrum.Simple.printf "@{<bold, fuchsia>%s@} @{<white>%s@}\n"
    (client_name ^ ": ") body;
  Lwt.return_unit

let log_info message =
  Spectrum.Simple.printf "@{<italic,teal>%s@}\n" ("==> LOG: " ^ message);
  Lwt.return_unit

let send sock message =
  let bytes = Bytes.of_string (message ^ "\n") in
  let length = Bytes.length bytes in
  Lwt_unix.send sock bytes 0 length []

(** Recursively waiting for receiving messages from the given socket
  @param sock Socket to receive messages from.
  @param client_name The name used as sender of the ACK message.
*)
let rec receive_messages_from_socket sock client_name =
  let buffer = Bytes.create buffer_size in
  Lwt_unix.recv sock buffer 0 buffer_size [] >>= fun bytes_length ->
  if bytes_length = 0 then log_info "Connection closed..."
  else
    let message = Bytes.sub_string buffer 0 bytes_length in

    (message |> Message.to_payload_opt |> function
     | Some (SEND { sender; body; timestamp }) ->
         (* If we receive a SEND, means a "normal message", we are sending back an ACK message *)
         (* For simplicity. let's pretend it takes 1 second to process the msg, so we would see
            the time reflected in the roundtrip time.
         *)
         Thread.delay 1.0;

         print_chat_message sender body >>= fun () ->
         "[ACK] Message received by: " ^ client_name
         |> Message.create_ack client_name timestamp
         |> Message.to_string |> send sock
         >>= fun _ -> Lwt.return_unit
     | Some (ACK payload) ->
         (* If we receive an ACK, compute the roundtrip time and log it*)
         let roundtrip__message =
           payload.timestamp
           |> Option.map (fun t ->
                  (Unix.time () -. t |> string_of_float) ^ " seconde(s)")
           |> Option.value ~default:"Unknown"
         in
         log_info (payload.body ^ " - Roundtrip time: " ^ roundtrip__message)
     | _ -> Lwt.return_unit)
    >>= fun () -> receive_messages_from_socket sock client_name

(** Recursively waiting for inputs from the keyboard 
to send messages on the given socket
@param sock Socket to send messages on.
@param client_name The name used as sender of the message.
*)
let rec send_messages_to_socket sock client_name =
  Lwt_io.read_line_opt stdin >>= function
  | Some input ->
      let timestamp = Some (Unix.time ()) in
      input
      |> Message.create_send client_name timestamp
      |> Message.to_string |> send sock
      >>= fun _ ->
      print_chat_message client_name input >>= fun _ ->
      send_messages_to_socket sock client_name
  | None -> Lwt_unix.close sock

(** Start a bidirectionnal chat with the given socket.
  The function handles setting up sending and receiving events.
  @param sock Socket from which it sends and receives messages
*)
let start_chat sock ~client_name () =
  setup_console_formatter ();

  let send_job = send_messages_to_socket sock client_name in
  let receive_job = receive_messages_from_socket sock client_name in

  (* With Lwt.pick, it ensures one job stops if the other stops earlier*)
  (* For example, it means if recv gets a closed connection notification, Lwt will try to cancel send job*)
  Lwt.catch
    (fun _ -> Lwt.pick [ send_job; receive_job ])
    (fun exn -> Lwt_io.printf "Exception: %s\n" (Printexc.to_string exn))
