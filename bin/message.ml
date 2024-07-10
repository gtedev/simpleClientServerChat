type message_payload = {
  sender : string;
  body : string;
  timestamp : float option;
}

type t = SEND of message_payload | ACK of message_payload

let separator = '|'
let join_with_pipe = String.concat (separator |> String.make 1)
let create_send sender timestamp body = SEND { sender; body; timestamp }
let create_ack sender timestamp body = ACK { sender; body; timestamp }

module Float = struct
  let to_string_or_default (value : float option) =
    value |> Option.map string_of_float |> Option.value ~default:""
end

let toString = function
  | SEND { sender; body; timestamp } ->
      [ "SEND"; sender; body; Float.to_string_or_default timestamp ]
      |> join_with_pipe
  | ACK { sender; body; timestamp } ->
      [ "ACK"; sender; body; Float.to_string_or_default timestamp ]
      |> join_with_pipe

let toPayload messageString =
  let params =
    String.split_on_char separator messageString |> List.map Base.String.strip
  in
  match params with
  | [ "SEND"; sender; body; timestamp ] ->
      Some (SEND { sender; body; timestamp = float_of_string_opt timestamp })
  | [ "ACK"; sender; body; timestamp ] ->
      Some (ACK { sender; body; timestamp = float_of_string_opt timestamp })
  | _ -> None
