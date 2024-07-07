open Unix
(* open Util *)

(* let handle_client_messages client_fd =
     fun () ->
          (* Continuously receive messages from the client *)
          let rec receive_messages () =
          let message_buffer = Bytes.create 1024 in
          match recv client_fd message_buffer 0 1024 [] with
          | 0 ->  (* Connection closed by the client *)
               print_endline "Client disconnected"
          | bytes_read ->
               let client_message = Bytes.sub_string message_buffer 0 bytes_read in
               print_endline ("Received from client: " ^ client_message);

               (* Send response back to client *)
               let response = read_line () in
               (* let response = "Message received" in *)
               let response_bytes = Bytes.of_string response in
               let _ = send client_fd response_bytes 0 (Bytes.length response_bytes) [] in

               (* Continue to receive more messages *)
               receive_messages ()
          in
          receive_messages ();

          (* Close the client socket *)
          close client_fd

  let handle_server_send_messages client_fd =
     fun () ->
          while true do
               let message = read_line () in   
               Util.send_message client_fd message
          done;
  
          () *)

let initiate () =
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
  
  (* Accept connections and handle them in an infinite loop *)
  while true do
    let client_fd, client_sockaddr = accept server_fd in
    let client_address = match client_sockaddr with
      | ADDR_INET (addr, _) -> addr
      | _ -> failwith "Unexpected client address type"
    in
    print_endline ("Connection accepted from: " ^ string_of_inet_addr client_address);

    (* let mutex = Mutex.create() *)
    
    (* Handle client communication *)
    let t1 = Thread.create (Util.handle_receive_messages client_fd "client") () in
    let t2 = Thread.create (Util.handle_send_messages client_fd "server") () in
    Thread.join t1;
    Thread.join t2;
  done;
  
  (* Close the server socket (though this line will never be reached) *)
  close server_fd
