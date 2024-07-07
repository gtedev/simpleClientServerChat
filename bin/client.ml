open Unix
(* open Util *)

let initiate () =
  (* Create a socket for the client *)
  let client_fd = socket PF_INET SOCK_STREAM 0 in
  
  (* Connect to the server *)
  let server_address = inet_addr_of_string "127.0.0.1" in
  let server_port = 8080 in
  let server_sockaddr = ADDR_INET (server_address, server_port) in
  connect client_fd server_sockaddr;
    
  while true do
      let t1 = Thread.create (Util.handle_receive_messages client_fd "server") () in
      let t2 = Thread.create (Util.handle_send_messages (dup client_fd) "client") () in
      Thread.join t1;
      Thread.join t2;
  done;
  
  (* Close the client socket *)
  close client_fd
