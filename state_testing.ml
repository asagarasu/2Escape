open Helper

type direction = Up | Down | Left | Right

type character = {id : int; direction : direction}

type movable = {id : string}

type storable = {id : string}

type immovable = {id : string}

type exit = {is_open : bool; to_room : string}

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
  mutable tiles : tile list list;
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

let create_empty_log (id : string) (r : int) (c : int) : log = {room_id = id; rows = r; cols = c; change = []}

let create_emptylogs (st : t) : log * log = 
  let p1_room = Hashtbl.find st.roommap (fst_third st.pl1_loc) in
  let p2_room = Hashtbl.find st.roommap (fst_third st.pl2_loc) in
  (create_empty_log (fst_third st.pl1_loc) p1_room.rows p1_room.cols), 
    (create_empty_log (fst_third st.pl2_loc) p2_room.rows p2_room.cols)

let do_command (playerid : int) (comm : Command.command) (st : t) : log * log = 
  let curr_room_string = if playerid = 1 then fst_third st.pl1_loc else fst_third st.pl2_loc in
  let curr_player_x = if playerid = 1 then snd_third st.pl1_loc else snd_third st.pl2_loc in 
  let curr_player_y = if playerid = 1 then thd_third st.pl1_loc else thd_third st.pl2_loc in 
  let curr_room = Hashtbl.find st.roommap curr_room_string in 

  match comm with 
  | Go Left -> (
    match access_ll curr_player_y (curr_player_x - 1) curr_room.tiles with 
    | Some tile1 -> 
      if bool_opt tile1.ch then create_emptylogs st
      else if bool_opt tile1.immov then create_emptylogs st
      else failwith "U"
    | None -> create_emptylogs st
  )
  | _ -> failwith "Unimplemented"


let save (st : t) (file : string) = 
  failwith "Unimplemented"

