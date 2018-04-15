open Types

type t

val do_command: Command.command -> t -> t

val save: string -> unit