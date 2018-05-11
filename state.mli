open Helper
open Init

type direction = Init.direction

type command = Init.command

type character = Init.character

type movable = Init.movable

type storable = Init.storable

type immovable = Init.immovable

type exit = Init.exit

type keyloc = Init.keyloc

type tile = Init.tile

type room = Init.room

type message = Init.message

type t = Init.t

type entry = {
  row : int;
  col : int;
  newtile : tile;
}

type invchange = {
  add : string option;
  remove : string option
}


type log' = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list;
  inv_change : invchange;
  chat : message option
}

(**
 * do_command takes a command generates the logs to send out to players one and two
 *
 * returns: the logs [log1, log2], where log1 is a short summary of player 1's changes
 *           and [log2] is a short summary of player 2's changes
 * effects: the state is changed accordingly
 *)
val do_command : int -> command -> t -> log' * log'

(**
 * logify intial state creates a [log] of the initial state for initialization purposes
 * with player id [playerid]
 *
 * returns: the [log] of the state [st]
 *)
val logify : int -> t -> log'

(* [save] takes in the current state and save to a json string at file loc [file] *)
val save : t -> string -> unit

(* [load] reading a string and returns a state *)
val load : string -> t

(* [start] is the initial state of the game *)
val start : t
