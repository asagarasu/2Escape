(* type of server. input channels and outputchannel *)
type t = in_channel list * out_channel

(**
 * Create a server based on port number [port]
 *
 * requires: [port] is a valid server number
 * effects: a server is created on port [port]
 *)
val create_server: int -> unit