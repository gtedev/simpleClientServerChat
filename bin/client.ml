open Unix

let initiate () =
  let client_socket = socket PF_INET SOCK_STREAM 0 in
  let server_socket_address = Util.get_server_socket_address () in

  connect client_socket server_socket_address;

  let mutex = Mutex.create () in
  let status : int ref = ref 1 in

  let onDisconnected () =
    Mutex.lock mutex;
    status := 0;
    Mutex.unlock mutex;
    print_endline "Lost connection with the Server..."
  in

  let isConnected () = !status = 1 in

  while isConnected () do
    let t1 =
      Thread.create
        (Util.handle_receive_messages client_socket "server" onDisconnected)
        ()
    in
    let t2 =
      Thread.create
        (Util.handle_send_messages (dup client_socket) "client" isConnected)
        ()
    in
    Thread.join t1;
    Thread.join t2
  done;

  (* Close the client socket *)
  close client_socket
