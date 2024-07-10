let () =
  match Sys.argv with
  | [| _; "s" |] -> Server.initiate () (* s for serveur *)
  | [| _; "c" |] -> Client.initiate ~client_name:"Unknown" (* c for client *)
  | [| _; "c"; client_name |] -> Client.initiate ~client_name
  | _ -> Printf.printf "No option given, or appropriate options"
