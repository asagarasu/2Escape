open Helper

type direction = Up | Down | Left | Right

type command = | Go of direction | Message of string

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

type log = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list;
  chat : message option
}

let create_empty_logs (rm1 : room) (rm2 : room) : log * log =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols; change = []; chat = None},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols; change = []; chat = None})

let create_log (rm : room) (entry_l : entry list) : log =  {room_id = rm.id; rows = rm.rows; cols = rm.rows; change = entry_l; chat = None}

let update_room (sendroom : room) (changedroom : room) (entries : entry list) : log = 
  if sendroom = changedroom then 
    {room_id = sendroom.id; rows = sendroom.rows; cols = sendroom.cols; change = entries; chat = None}
  else 
    {room_id = sendroom.id; rows = sendroom.rows; cols = sendroom.cols; change = []; chat = None}

let update_chat (room1 : room) (room2 : room) (id : int) (message : string) : log * log = 
  {room_id = room1.id; rows = room1.rows; cols = room1.cols; change = []; chat = Some {id = id; message = message}},
  {room_id = room2.id; rows = room2.rows; cols = room2.cols; change = []; chat = Some {id = id; message = message}}

let direct (d:direction) : int * int = match d with
  | Left -> (-1,0)
  | Right -> (1,0)
  | Up -> (0,1)
  | Down -> (0,-1)

let do_command (playerid : int) (comm : command) (st : t) : log * log =
  let room1_string = fst_third st.pl1_loc in
  let room2_string = fst_third st.pl1_loc in
  let room1 = Hashtbl.find st.roommap room1_string in 
  let room2 = Hashtbl.find st.roommap room2_string in 
  let curr_player_x = if playerid = 1 then snd_third st.pl1_loc else snd_third st.pl2_loc in
  let curr_player_y = if playerid = 1 then thd_third st.pl1_loc else thd_third st.pl2_loc in
  let curr_room = if playerid = 1 then room1 else room2 in

  match comm with
  | Go d ->
    let pair = direct d in
    let next_player_y = curr_player_y + fst pair in
    let next_player_x = curr_player_x + fst pair in
    (
    try
      let oldtile = curr_room.tiles.(curr_player_y).(curr_player_x) in
      let newtile = curr_room.tiles.(next_player_y).(next_player_x) in 
        if bool_opt newtile.ch then create_empty_logs room1 room2
        else if bool_opt newtile.immov then create_empty_logs room1 room2
        else 
          begin 
            newtile.ch <- Some { id = playerid ; direction = d };
            oldtile.ch <- None;
            let entry_l = [{ row = next_player_x ; col = next_player_y ; newtile = newtile; };
                          { row = curr_player_x ; col = curr_player_y ; newtile = oldtile; }] in
            (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
          end
    with 
       Invalid_argument _ -> create_empty_logs room1 room2
    )
  | Message s -> update_chat room1 room2 playerid s
  | _ -> failwith "Unimplemented"

let save (st : t) (file : string) =
  failwith "Unimplemented"
