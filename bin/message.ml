type message_payload = {
  from : string;
  body : string;
  timestamp : float option;
}

type t = SEND of message_payload | ACK of message_payload

let separator = '|'
let join_with_pipe = String.concat (separator |> String.make 1)
let create_send from timestamp body = SEND { from; body; timestamp }
let create_ack from timestamp body = ACK { from; body; timestamp }

module Float = struct
  let to_string_or_default (value : float option) =
    value |> Option.map string_of_float |> Option.value ~default:""
end

let toString = function
  | SEND { from; body; timestamp } ->
      [ "SEND"; from; body; Float.to_string_or_default timestamp ]
      |> join_with_pipe
  | ACK { from; body; timestamp } ->
      [ "ACK"; from; body; Float.to_string_or_default timestamp ]
      |> join_with_pipe

let toPayload messageString =
  let params =
    String.split_on_char separator messageString |> List.map Base.String.strip
  in
  match params with
  | [ "SEND"; from; body; timestamp ] ->
      Some (SEND { from; body; timestamp = float_of_string_opt timestamp })
  | [ "ACK"; from; body; timestamp ] ->
      Some (ACK { from; body; timestamp = float_of_string_opt timestamp })
  | _ -> None
