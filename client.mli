type t

val create_client: Unix.file_descr -> Unix.file_descr -> t

val send_command: Command.t -> t -> unit

val receive_state: t -> State.t