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

type entry = {
  row : int;
  col : int;
  newval : string;
}

type log = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list
}

(* [do_command] takes in a command and the current state and update the state *)
let do_command com st1 = 
  failwith "Unimplemented"

(* [diff] takes in two verified commands to make up a log record to send
   to the clients. *)
let diff st1 st2 = 
  failwith "Unimplemented"

(* [save] takes in the current state and save to a json string *)
let save st1 filename = 
  failwith "Unimplemented"
