(* Commands *)

(* Direction character can move *)
type direction = Up | Down | Left | Right

(* Various commands the player can make to affect the state/chat *)
type command =
  | Go of direction
  | Message of string
  | Take
  | Drop of string
  | Enter

(* State *)
(* character type detailing the number and direction of the character *)
type character = {id : int; direction : direction}

(* type representing a movable object *)
type movable = {id : string}

(* type representing a storable object *)
type storable = {id : string}

(* type representing an immovable object *)
type immovable = {id : string}

(* type representing an exit in the room, to_room is (room name, x, y) *)
type exit = {
  id : string;
  mutable is_open : bool;
  to_room : string * int * int
}

(* type representing a location for a key
 * exit_effect are (room name, col, row)
 * immovable_effect are (room name, col, row)
*)
type keyloc = {
  id : string;
  key : string;
  mutable is_solved : bool;
  exit_effect : (string * int * int) list;
  immovable_effect : (string * int * int) list
}

(* type representing a tile in the room *)
type tile = {
  mutable ch : character option;
  mutable mov : movable option;
  mutable store : storable option;
  mutable immov : immovable option;
  mutable ex : exit option;
  mutable kl : keyloc option;
}

(* type representing a room in the state *)
type room = {
  id : string;
  mutable tiles : tile array array;
  rows : int;
  cols : int
}

(* type representing a message in the state *)
type message = {
  id : int;
  message : string
}

(* type representing a state *)
type t = {
  roommap : (string, room) Hashtbl.t;
  mutable pl1_loc : string * int * int ;
  mutable pl2_loc : string * int * int ;
  mutable pl1_inv : string list;
  mutable pl2_inv : string list;
  mutable chat : message list
}

let air_keyloc = {
  id = "air_loc";
  key = "air_key";
  is_solved = false;
  exit_effect = [];
  immovable_effect = [];
}

let air_to_gears = { id = "air_to_gears"; is_open = true; to_room = ("gears",-1,-1) }

let air_to_study = { id = "air_to_study"; is_open = true; to_room = ("study",1,3) }

let air =
  {id = "air";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = Some {id = "air_key"}; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_topleft"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_topright"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_bottomleft"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_bottomright"}; ex = None; kl = Some air_keyloc};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some air_to_gears; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some air_to_study; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
     |];
   rows = 5; cols = 6}

let study_to_air = { id = "study_to_air"; is_open = true; to_room = ("air",5,2) }

let study_to_basement = { id = "study_to_basement"; is_open = true; to_room = ("basement",-1,-1) }

let study_to_hall = { id = "study_to_hall"; is_open = true; to_room = ("hall",-1,-1) }

let study =
  {id = "study";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_air; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];

       [|{ch = None; mov = None; store = None; immov = Some {id = "desk_top"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_basement; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_hall; kl = None}|];

       [|{ch = None; mov = None; store = None; immov =  Some {id = "desk_bottom"}; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
     |];
   rows = 5; cols = 6}

let roommap =
  let table = Hashtbl.create 10 in
  Hashtbl.add table "air" air;
  Hashtbl.add table "study" study;
  table

let state =
  {roommap = roommap;
   pl1_loc = ("test", 0, 0); pl2_loc = ("test", 1, 1);
   pl1_inv = []; pl2_inv = ["good"];
   chat = [{id = 2; message = "no"}; {id = 1; message = "yes"}]}
