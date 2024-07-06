open Unix

let initiate () =
   print_endline "Launching Chat server...";
  (* Create a socket for the server *)
  let server_fd = socket PF_INET SOCK_STREAM 0 in
  
  (* Bind the socket to an address and port *)
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in
  let server_sockaddr = ADDR_INET (server_address, server_port) in
  bind server_fd server_sockaddr;
  
  (* Listen for incoming connections *)
  listen server_fd 5;
  print_endline "Server is listening...";
  
  (* Accept connections and handle them *)
  while true do
    let client_fd, _ = accept server_fd in
    (* print_endline ("Connection accepted from: " ^ string_of_inet_addr client_addr); *)

    (* Read client's message *)
    let message_buffer = Bytes.create 1024 in
    let bytes_read = read client_fd message_buffer 0 1024 in
    let client_message = Bytes.sub_string message_buffer 0 bytes_read in
    print_endline ("Received from client: " ^ client_message);

    (* Send response back to client *)
    let response = "Hello, client!" in
    let _ = send client_fd (Bytes.of_string response)  0 (String.length response) [] in
    close client_fd;
  done;
  
  (* Close the server socket *)
  close server_fd
