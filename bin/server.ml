open Unix
(* open Util *)


let initiate () =
  let server_fd = socket PF_INET SOCK_STREAM 0 in
  let server_sockaddr = Util.get_server_socket_address() in

  bind server_fd server_sockaddr;
  
  (* Listen for incoming connections *)
  listen server_fd 1;
  print_endline "Server is listening...";
  
  (* Accept connections and handle them in an infinite loop *)
  while true do
    let client_fd, client_sockaddr = accept server_fd in
    let client_address = match client_sockaddr with
      | ADDR_INET (addr, _) -> addr
      | _ -> failwith "Unexpected client address type"
    in

    (* let mutex = Mutex.create () in
    let status: int ref = ref 1 in

    let updateStatus (statusVal: int)  =
      Mutex.lock mutex;
      status:= statusVal;
      Mutex.unlock mutex;
      ()
    in *)

    print_endline ("Connection accepted from: " ^ string_of_inet_addr client_address);

    (* Handle client communication *)
    let handleClient () = 

      let mutex = Mutex.create () in
      let status: int ref = ref 1 in

      let onDisconnected ()  =
        Mutex.lock mutex;
        status:= 0;
        Mutex.unlock mutex;
        print_endline "Client disconnected...";
      in

      let isConnected () =
         !status = 1
      in

      let t1 = Thread.create (Util.handle_receive_messages client_fd "client" onDisconnected) () in
      let t2 = Thread.create (Util.handle_send_messages (dup client_fd) "server" isConnected) () in
      Thread.join t1;
      Thread.join t2;
      ()
    in
    
    let t3 = Thread.create (handleClient) () in
    Thread.join t3;
    
  done;
  
  (* Close the server socket (though this line will never be reached) *)
  close server_fd
