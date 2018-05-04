(* type of client, input channel and output channel are the two channels at work *)
type t = in_channel * out_channel

(**
 * Creates the client hooked up to [ip]
 *
 * effects: Creates a client. 
 *)
val create_client: string -> unit

(**
 * Sends a command to a server in string form
 *
 * requires: [comm] is a valid command
 *           [cl] is a valid client connected to the server
 * effects: [comm] is turned into a string and sent to the server
 *)
val send_command: State.command -> t -> unit

(**
 * Receives a State.log' from a server
 *
 * requires : [cl] is a valid client connected to the server, 
 *            the string sent over is a json of type [State.log'
 * returns: a [state] that is sent (in string form) from the server
 *)
val receive_state: t -> State.log' option