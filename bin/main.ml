let () =
  match Sys.argv with
  | [| _; "c" |] -> Client.initiate () (* c for client *)
  | [| _; "s" |] -> Server.initiate () (* s for serveur *)
  | _ -> Printf.printf "No option given, or appropriate options"
