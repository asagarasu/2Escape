type t

val create_client: Unix.file_descr -> t

val send_command: Command.t -> unit

val receive_state: unit -> State.t