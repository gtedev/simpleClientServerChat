let () =
  match Sys.argv with
  | [| _; "c" |] -> Client.initiate None
  | [| _; "c"; clientName |] -> Client.initiate (Some clientName)
  | [| _; "s" |] -> Server.initiate ()
  | _ -> Printf.printf "No option given, or appropriate options"
