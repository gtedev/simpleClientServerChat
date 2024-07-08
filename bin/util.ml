open Unix

let get_server_socket_address () =
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in

  ADDR_INET (server_address, server_port)

let send_message client_socket message = 
  let message_bytes = Bytes.of_string message in
  let message_length = Bytes.length message_bytes in
  send client_socket message_bytes 0 message_length []

let handle_receive_messages client_socket ~receive_from onDisconnected () =
  let rec receive_messages () =
    let message_buffer = Bytes.create 1024 in
    match recv client_socket message_buffer 0 1024 [] with
    | 0 ->
        onDisconnected ()
    | bytes_read ->
        let client_message = Bytes.sub_string message_buffer 0 bytes_read in

        match client_message with
        | client_message when client_message = "ACK" -> 
              print_endline ("Message received !");
              receive_messages ()
        | client_message when client_message <> "ACK" -> 
            let _ = send_message client_socket "ACK" in
            print_endline (receive_from ^ ": " ^ client_message);
            receive_messages ()
        | _ -> 
          receive_messages ();
  in
  receive_messages ()

let read_line_with_timeout timeout =
  let stdin_fd = descr_of_in_channel In_channel.stdin in
  let ready_read, _, _ = select [ stdin_fd ] [] [] timeout in
  if List.mem stdin_fd ready_read then Some (input_line In_channel.stdin)
  else None

let handle_send_messages client_socket ~sender isConnected () =
  while isConnected () do
    match read_line_with_timeout 1.0 with
    | Some message ->   
        let message_bytes = Bytes.of_string message in
        let message_length = Bytes.length message_bytes in
        let response = send client_socket message_bytes 0 message_length [] in
        
        if response = 0 then  
          print_endline ("Failed to send the message to Server")
        else
          print_endline (sender ^ "sent message succefully");
          print_endline (sender ^ ": " ^ message);

    | None -> ()
  done
