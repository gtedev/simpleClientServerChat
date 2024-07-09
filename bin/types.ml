type connection_status = Connected | Disconnected
type message_payload = { from : string; body : string }
type message = SEND of message_payload | ACK of message_payload
