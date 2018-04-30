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

let create_empty_logs (rm1 : room) (rm2 : room) : log * log =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols; change = []},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols; change = []})

let create_log rm entry_l : log =  {room_id = rm.id; rows = rm.rows; cols = rm.rows; change = entry_l;}

let direct (d:direction) : int * int = match d with
  | Left -> (-1,0)
  | Right -> (1,0)
  | Up -> (0,1)
  | Down -> (0,-1)

let do_command (playerid : int) (comm : command) (st : t) : log * log =
  let curr_room_string = if playerid = 1 then fst_third st.pl1_loc else fst_third st.pl2_loc in
  let other_room_string = if playerid <> 1 then fst_third st.pl1_loc else fst_third st.pl2_loc in
  let curr_player_x = if playerid = 1 then snd_third st.pl1_loc else snd_third st.pl2_loc in
  let curr_player_y = if playerid = 1 then thd_third st.pl1_loc else thd_third st.pl2_loc in
  let curr_room = Hashtbl.find st.roommap curr_room_string in
  let other_room = Hashtbl.find st.roommap other_room_string in

  match comm with
  | Go d ->
    let pair = direct d in
    let next_player_y = curr_player_y + fst pair in
    let next_player_x = curr_player_x + fst pair in
    (
    match access_ll next_player_y next_player_x curr_room.tiles with
    | Some tile1 ->
      if bool_opt tile1.ch then create_empty_logs curr_room other_room
      else if bool_opt tile1.immov then create_empty_logs curr_room other_room
      else
        let curr_player =
          (match access_ll curr_player_y curr_player_x curr_room.tiles with
           | Some tile -> tile
           | None -> failwith "")
        in
        tile1.ch <- Some { id = playerid ; direction = d };
        curr_player.ch <- None;
        let entry_l = [{ row = next_player_x ; col = next_player_y ; newtile = tile1; };
                       { row = curr_player_x ; col = curr_player_y ; newtile = curr_player; }]
        in
        ({room_id = curr_room.id; rows = curr_room.rows; cols = curr_room.rows; change = entry_l;},
         {room_id = other_room.id; rows = other_room.rows; cols = other_room.rows; change = [];})
    | None -> create_empty_logs curr_room other_room
  )

let save (st : t) (file : string) =
  failwith "Unimplemented"
