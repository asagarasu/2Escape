type t

(**create the client. need to manually type in the 
 *IP address of the server to be connected*)
val create_client: unit -> unit = <fun>

(**send the command to the server*)
val send_command: Command.t -> t -> unit

(**receive the changed state from the server*)
val receive_state: t -> State.t