let () =
  match Sys.argv with
  | [| _; "c" |] -> Client.initiate ~client_name:"Unknown" (* c for client *)
  | [| _; "c"; client_name |] -> Client.initiate ~client_name (* c for client with 3rd parameter being the client name *)
  | [| _; "s" |] -> Server.initiate () (* s for serveur *)
  | _ -> Printf.printf "No option given, or appropriate options"
