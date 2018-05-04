open Helper

type direction = Up | Down | Left | Right

type command = | Go of direction | Message of string | Take | Drop of string | Enter

type character = {id : int; direction : direction}

type movable = {id : string}

type storable = {id : string}

type immovable = {id : string}

type exit = {id : string; mutable is_open : bool; to_room : string * int * int}

type keyloc = {id : string; key : string; 
  mutable is_solved : bool; exit_effect : (string * int * int) list; immovable_effect : (string * int * int) list}

type tile = {
  mutable ch : character option;
  mutable mov : movable option;
  mutable store : storable option;
  mutable immov : immovable option;
  mutable ex : exit option;
  mutable kl : keyloc option;
}

type room = {
  id : string;
  mutable tiles : tile array array;
  rows : int;
  cols : int
}

type message = {
  id : int;
  message : string
}

type t = {
  roommap : (string, room) Hashtbl.t;
  mutable pl1_loc : string * int * int;
  mutable pl2_loc : string * int * int;
  mutable pl1_inv : string list;
  mutable pl2_inv : string list;
  mutable chat : message list
}

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

(* [read] reading a string and returns a state *)
val read : string -> t
