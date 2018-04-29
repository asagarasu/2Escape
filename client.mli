type t

val create_client: unit -> unit = <fun>

val send_command: Command.t -> t -> unit

val receive_state: t -> State.t