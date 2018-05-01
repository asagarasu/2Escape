open Helper

type direction = Up | Down | Left | Right

type command = | Go of direction | Message of string | Take | Drop of string

type character = {id : int; direction : direction}

type movable = {id : string}

type storable = {id : string}

type immovable = {id : string}

type exit = {mutable is_open : bool; to_room : string * int * int}

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

type log' = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list;
  chat : message option
}

let empty_keyloc = {
  id = "";
  is_solved = true;
  exit_effect = ("",-1,-1);
  immovable_effect = ("",-1,-1);
}

let create_empty_logs (rm1 : room) (rm2 : room) : log' * log' =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols; change = []; chat = None},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols; change = []; chat = None})

let create_log (rm : room) (entry_l : entry list) : log' =  {room_id = rm.id; rows = rm.rows; cols = rm.rows; change = entry_l; chat = None}

let update_room (sendroom : room) (changedroom : room) (entries : entry list) : log' = 
  if sendroom = changedroom then 
    {room_id = sendroom.id; rows = sendroom.rows; cols = sendroom.cols; change = entries; chat = None}
  else 
    {room_id = sendroom.id; rows = sendroom.rows; cols = sendroom.cols; change = []; chat = None}

let update_chat (room1 : room) (room2 : room) (id : int) (message : string) : log' * log' = 
  {room_id = room1.id; rows = room1.rows; cols = room1.cols; change = []; chat = Some {id = id; message = message}},
  {room_id = room2.id; rows = room2.rows; cols = room2.cols; change = []; chat = Some {id = id; message = message}}

let direct (d:direction) : int * int = match d with
  | Left -> (-1,0)
  | Right -> (1,0)
  | Up -> (0,-1)
  | Down -> (0,1)

let check_keyloc (keyloc:keyloc option) (item: string) st (r1:string) (r2:string) : 'a option =
    let k_l = (match keyloc with | Some a -> a | None -> empty_keyloc ) in
    if k_l.id = item
    then
      match k_l.exit_effect, k_l.immovable_effect with
      | ("",_,_) , (a1,x1,y1)  ->
        let r = Hashtbl.find st.roommap a1 in
        let tile = r.tiles.(y1).(x1) in
        tile.immov <- None;
        if a1 = r1 || a1 = r2
        then Some (a1,{row = x1 ; col = y1 ; newtile = tile;})
        else None
      | (a2,x2,y2) , ("",_,_) ->
        let r = Hashtbl.find st.roommap a2 in
        let tile = r.tiles.(y2).(x2) in
        (match tile.ex with
         | Some ex ->
           ex.is_open <- true;
           if a2 = r1 || a2 = r2
           then Some (a2,{row = x2 ; col = y2 ; newtile = tile;})
           else None
         | None -> None
        )
      | _ , _  -> None
    else None

let do_command (playerid : int) (comm : command) (st : t) : log' * log' =
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
    let next_player_y = curr_player_y + snd pair in
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
            let entry_l = [{ row = next_player_y ; col = next_player_x ; newtile = newtile; };
                          { row = curr_player_y ; col = curr_player_x ; newtile = oldtile; }] in
            (if playerid = 1 then st.pl1_loc <- room1_string, next_player_x, next_player_y else
            st.pl2_loc <- room2_string, next_player_x, next_player_y);
            (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
          end
    with
       Invalid_argument _ -> create_empty_logs room1 room2
  )
  | Take -> (
    try
      let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
      (match tile.mov with
       | Some item ->
         tile.store <- None;
         (if playerid = 1 then st.pl1_inv <- item.id::st.pl1_inv
          else st.pl2_inv <- item.id::st.pl2_inv);
         let entry_l = [{ row = curr_player_x ; col = curr_player_y ; newtile = tile; }]
         in
         (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
       | None -> create_empty_logs room1 room2)
    with
      Invalid_argument _ -> create_empty_logs room1 room2
  )
  | Drop n ->
    let inv = if playerid = 1 then st.pl1_inv else st.pl2_inv in
    if List.mem n inv then
      (
        try
          let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
          (
            match tile.store with
            | Some s -> create_empty_logs room1 room2
            | None ->
              (tile.store <- Some {id = n};
               (if playerid = 1
                then st.pl1_inv <- List.filter (fun x -> x <> n) st.pl1_inv
                else st.pl2_inv <- List.filter (fun x -> x <> n) st.pl2_inv);
               let entry_l = [{row = curr_player_x ; col = curr_player_y ; newtile = tile;}] in
               match check_keyloc tile.kl n st room1_string room2_string with
               | Some (r,e) ->
                 if r = room1.id then
                   let entry_l' = e::entry_l in
                   (update_room room1 curr_room entry_l', update_room room2 curr_room entry_l)
                 else if r = room2.id then
                   (update_room room1 curr_room entry_l, update_room room2 room2 [e])
                 else
                   (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
               | None ->
                 (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
              )
          )
        with
          Invalid_argument _ -> create_empty_logs room1 room2
      )
    else create_empty_logs room1 room2
  | Message s -> update_chat room1 room2 playerid s
  | _ -> failwith "Unimplemented"

let logify (playerid : int) (st : t) : log' = 
  let room1_string = fst_third st.pl1_loc in
  let room1 = Hashtbl.find st.roommap room1_string in
  let entrymap = (Array.mapi (fun (y : int) (row : tile array) -> 
          Array.mapi (fun (x : int) (t : tile) -> 
            {row = y; col = x; newtile = t}
          ) row
        ) room1.tiles) in
  let entryarrlist = (Array.map Array.to_list entrymap) in
  let entrylistlist = Array.to_list entryarrlist in
  let entrylist = List.flatten entrylistlist in 
  {
    room_id = room1_string;
    rows = room1.rows;
    cols = room1.cols;
    change = entrylist;
    chat = None
  }
  
let save (st : t) (file : string) =
  failwith "Unimplemented"
