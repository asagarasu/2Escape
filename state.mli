open Types

(* [state] is the type serving as the main game state. It can only
   be changed after verfying the commands received from the
   clients.

   [state] contains values:
   * row_col_rooms (room_id)
   * map_matrix of the rooms
   * location of characters/objects
   * inventory
   * chart

   [state] has functions:
   * update_state
   * diff : state -> command -> command -> log
*)


type t

val do_command: Command.command -> t -> t

val save: string -> unit

val update_state:
