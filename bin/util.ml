open Unix
open Types

let get_server_socket_address () =
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in

  ADDR_INET (server_address, server_port)

(* Function to send a message to a socket destination and receive response *)
let send_message client_fd message pseudo =
  let message_bytes = Bytes.of_string message in

  (* Send message to the server *)
  let _ = send client_fd message_bytes 0 (Bytes.length message_bytes) [] in
  print_endline (pseudo ^ ": " ^ message)

let handle_receive_messages client_fd (ReceiveFrom from) onDisconnected () =
  (* Continuously receive messages from the client *)
  let rec receive_messages () =
    let message_buffer = Bytes.create 1024 in
    match recv client_fd message_buffer 0 1024 [] with
    | 0_ ->
        (* Connection closed by the client *)
        onDisconnected ()
    | bytes_read ->
        let client_message = Bytes.sub_string message_buffer 0 bytes_read in
        print_endline (from ^ ": " ^ client_message);
        receive_messages ()
  in
  receive_messages ()

let read_line_with_timeout timeout =
  let stdin_fd = descr_of_in_channel In_channel.stdin in
  let ready_read, _, _ = select [ stdin_fd ] [] [] timeout in
  if List.mem stdin_fd ready_read then Some (input_line In_channel.stdin)
  else None

let handle_send_messages client_fd (SendTo send_to) isConnected () =
  while isConnected () do
    match read_line_with_timeout 1.0 with
    | Some message -> send_message client_fd message send_to
    | None -> ()
  done
