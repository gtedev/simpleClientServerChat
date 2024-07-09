let () =
  match Sys.argv with
  | [| _; "c" |] -> Client2.initiate () (* c for client *)
  | [| _; "s" |] -> Server2.initiate () (* s for serveur *)
  | _ -> Printf.printf "No option given, or appropriate options"
