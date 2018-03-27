(* [command] represents a command input by a player. *)

type command =
| Go of string
| Take of string
| Drop of string
| Quit
| Look
| Inv
| Click
| Unknown

(* [parse str] is the command that represents player input [str].
 * requires: [str] is one of the commands forms described in the
 *   assignment writeup. *)
val parse : string -> command
