open Types

(* [state] is the type serving as the main game state. It can only
   be changed after verfying the commands received from the
   clients.

   [state] contains values:
   * row_col_rooms (room_id)
   * map_matrix of the rooms
   * location of characters/objects
   * inventory
   * chat

   [state] has functions:
   * do_command
   * diff
   * save
*)
type t
type log

val do_command : Command.command -> t -> t
(* [diff] takes in two verified commands to make up a log record to send
   to the clients. *)
val diff : Command.command -> Command.command -> log
val save : t -> unit
