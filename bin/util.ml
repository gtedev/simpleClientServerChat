  open Unix


  (* type ClientStatus =
  | Connected
  | Disconnecteda *)

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
  
  let handle_receive_messages client_fd pseudo status updateClientStatus =
      fun () ->
           (* Continuously receive messages from the client *)
           let rec receive_messages () =
            (* let myStatus = !status; *)
            let message_buffer = Bytes.create 1024 in
            match recv client_fd message_buffer 0 1024 [], !status with
            | 0, _ ->  (* Connection closed by the client *)
                  updateClientStatus 0;
                  print_endline "Client disconnected";
                  (* receive_messages () *)
            | bytes_read, 1 ->
                  let client_message = Bytes.sub_string message_buffer 0 bytes_read in
                  print_endline (pseudo ^ ": " ^ client_message);
                  receive_messages ()
            |_, _ -> ()
           in
           receive_messages ()
 
  let handle_send_messages client_fd pseudo status =
      fun () ->
           while true && (status = 1) do
                let message = read_line () in   
                send_message client_fd message pseudo
           done