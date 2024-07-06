open Unix

let initiate () =
  (* Create a socket for the client *)
  let client_fd = socket PF_INET SOCK_STREAM 0 in
  
  (* Connect to the server *)
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in
  let server_sockaddr = ADDR_INET (server_address, server_port) in
  connect client_fd server_sockaddr;
  
  (* Send message to the server *)
  let message = "Hello, server!" in
  let _ = send client_fd (Bytes.of_string message) 0 (String.length message) [] in
  print_endline ("Sent to server: " ^ message);

  (* Receive response from the server *)
  let response_buffer = Bytes.create 1024 in
  let bytes_received = read client_fd response_buffer 0 1024 in
  let server_response = Bytes.sub_string response_buffer 0 bytes_received in
  print_endline ("Received from server: " ^ server_response);

  (* Close the client socket *)
  close client_fd