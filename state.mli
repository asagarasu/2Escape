open Helper

type direction = Up | Down | Left | Right

type command = | Go of direction
               
type character = {id : int; direction : direction}

type movable = {id : string}

type storable = {id : string}

type immovable = {id : string}

type exit = {is_open : bool; to_room : string * int * int}

type keyloc = {id : string; is_solved : bool; exit_effect : string * int * int; immovable_effect : string * int * int}

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

type t = {
  roommap : (string, room) Hashtbl.t;
  mutable pl1_loc : string * int * int;
  mutable pl2_loc : string * int * int;
  mutable pl1_inv : string list;
  mutable pl2_inv : string list
}

type entry = {
  row : int;
  col : int;
  newtile : tile;
}

type log = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list
}

(* do_command takes a command generates the logs to send out to players one and two
 *
 * returns: the logs [log1, log2], where log1 is a short summary of player 1's changes
 *           and [log2] is a short summary of player 2's changes
 * effects: the state is changed accordingly
 *)
val do_command : int -> command -> t -> log * log

(* [save] takes in the current state and save to a json string *)
val save : t -> string -> unit
