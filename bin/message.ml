type message_payload = {
  from : string;
  body : string;
  timestamp_sent : float option;
}

type t = SEND of message_payload | ACK of message_payload

let separator = '|'
let join_with_pipe = String.concat (separator |> String.make 1)
let create_send from timestamp_sent body = SEND { from; body; timestamp_sent }
let create_ack from timestamp_sent body = ACK { from; body; timestamp_sent }

module Float = struct
  let to_string_or_default (value : float option) =
    value
    |> Option.map string_of_float 
    |> Option.value ~default:""
end

let toString message =
  match message with
  | SEND { from; body; timestamp_sent } ->
      [ "SEND"; from; body; Float.to_string_or_default timestamp_sent ]
      |> join_with_pipe
  | ACK { from; body; timestamp_sent } ->
      [ "ACK"; from; body; Float.to_string_or_default timestamp_sent ]
      |> join_with_pipe

let toPayload messageString =
  let params =
    String.split_on_char separator messageString |> List.map Base.String.strip
  in
  match params with
  | [ "SEND"; from; body; timestamp_sent ] ->
      Some
        (SEND
           { from; body; timestamp_sent = float_of_string_opt timestamp_sent })
  | [ "ACK"; from; body; timestamp_sent ] ->
      Some
        (ACK { from; body; timestamp_sent = float_of_string_opt timestamp_sent })
  | _ -> None
