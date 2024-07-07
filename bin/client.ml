open Unix
(* open Util *)


let initiate () =
  let client_fd = socket PF_INET SOCK_STREAM 0 in
  let server_sockaddr = Util.get_server_socket_address() in
  
  connect client_fd server_sockaddr;
    
  let mutex = Mutex.create () in
  let status: int ref = ref 1 in

  let updateStatus statusVal  =
          Mutex.lock mutex;
          status:= statusVal;
          Mutex.unlock mutex;
  in

  while true do
      let t1 = Thread.create (Util.handle_receive_messages client_fd "server" status updateStatus) () in
      let t2 = Thread.create (Util.handle_send_messages (dup client_fd) "client" !status) () in
      Thread.join t1;
      Thread.join t2;
  done;
  
  (* Close the client socket *)
  close client_fd
