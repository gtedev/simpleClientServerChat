open Unix

let initiate () =
  (* Create a socket for the client *)
  let client_fd = socket PF_INET SOCK_STREAM 0 in
  
  (* Connect to the server *)
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in
  let server_sockaddr = ADDR_INET (server_address, server_port) in
  connect client_fd server_sockaddr;
  
  (* Function to send a message to the server and receive response *)
  let send_message message =
    (* Convert message to bytes *)
    let message_bytes = Bytes.of_string message in
    
    (* Send message to the server *)
    let _ = send client_fd message_bytes 0 (Bytes.length message_bytes) [] in
    print_endline ("Sent to server: " ^ message);
  
    (* Receive response from the server *)
    let response_buffer = Bytes.create 1024 in
    let bytes_received = recv client_fd response_buffer 0 1024 [] in
    let server_response = Bytes.sub_string response_buffer 0 bytes_received in
    print_endline ("Received from server: " ^ server_response)
  in
  
  while true do
      let message = read_line () in   
      send_message message
  done;
  
  (* Close the client socket *)
  close client_fd
