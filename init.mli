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

(* [state] is the default state of the game *)
val state : t
