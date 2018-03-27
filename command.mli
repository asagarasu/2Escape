(* [command] represents a command input by a player. *)

type command =
| Go of {u:bool; d:bool; l:bool; r:bool}
| Take of string
| Drop of string


(* [parse str] is the command that represents player input [str].
 * requires: [str] is one of the commands forms described in the
 *   assignment writeup. *)
val parse : string -> command
