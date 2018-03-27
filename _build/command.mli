(* [command] represents a command input by a player. *)

type command =
| Go of {u : bool; r : bool; l : bool; d : bool}
| Take of string
| Drop of string


