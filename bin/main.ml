let () =
  match Sys.argv with
  | [| _; "c" |] -> Client.initiate ()
  | [| _; "s" |] -> Server.initiate ()
  | _ -> Printf.printf "No option given, or appropriate options"
