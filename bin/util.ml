  open Unix

  (* Function to send a message to a socket destination and receive response *)
  let send_message client_fd message pseudo =
    (* Convert message to bytes *)
    let message_bytes = Bytes.of_string message in
    
    (* Send message to the server *)
    let _ = send client_fd message_bytes 0 (Bytes.length message_bytes) [] in
    print_endline (pseudo ^ ": " ^ message)
  
    (* Receive response from the server *)
    (* let response_buffer = Bytes.create 1024 in
    let bytes_received = recv client_fd response_buffer 0 1024 [] in
    let server_response = Bytes.sub_string response_buffer 0 bytes_received in
    print_endline ("Client: " ^ server_response) *)
    (* () *)


  let handle_receive_messages client_fd pseudo =
      fun () ->
           (* Continuously receive messages from the client *)
           let rec receive_messages () =
           let message_buffer = Bytes.create 1024 in
           match recv client_fd message_buffer 0 1024 [] with
           | 0 ->  (* Connection closed by the client *)
                print_endline "Client disconnected"
           | bytes_read ->
                let client_message = Bytes.sub_string message_buffer 0 bytes_read in
                print_endline (pseudo ^ ": " ^ client_message);
 
                (* Send response back to client *)
                (* let response = read_line () in *)
                (* let response = "Message received" in *)
                (* let response_bytes = Bytes.of_string response in *)
                (* let _ = send client_fd response_bytes 0 (Bytes.length response_bytes) [] in *)
 
                (* Continue to receive more messages *)
                receive_messages ()
           in
           receive_messages ();
 
           (* Close the client socket *)
           close client_fd
 
  let handle_send_messages client_fd pseudo =
      fun () ->
           while true do
                let message = read_line () in   
                send_message client_fd message pseudo
           done;
   
           ()