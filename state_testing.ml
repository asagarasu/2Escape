open Helper

type direction = Up | Down | Left | Right

type character = {id : int; direction : direction}

type movable = {id : string}

type storable = {id : string}

type immovable = {id : string}

type exit = {mutable is_open : bool; to_room : string}

type keyloc = {
  id : string;
  mutable is_solved : bool;
  exit_effect : string * int * int;
  immovable_effect : string * int * int;
}

type command =
| Go of direction
| Take
| Drop of storable

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

let empty_keyloc = {
  id = "";
  is_solved = true;
  exit_effect = ("",-1,-1);
  immovable_effect = ("",-1,-1);
}

let create_empty_logs (rm1 : room) (rm2 : room) : log * log =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols; change = []},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols; change = []})

let create_log rm entry_l : log = {
  room_id = rm.id;
  rows = rm.rows;
  cols = rm.rows;
  change = entry_l;
}

let direct (d:direction) : int * int = match d with
  | Left -> (-1,0)
  | Right -> (1,0)
  | Up -> (0,1)
  | Down -> (0,-1)

let check_keyloc keyloc (item:storable) st (r1:string) (r2:string) : 'a option =
  let k_l = (match keyloc with | Some a -> a | None -> empty_keyloc ) in
  if k_l.id = item.id
  then
    match k_l.exit_effect, k_l.immovable_effect with
    | ("",_,_) , (a1,x1,y1)  ->
      let r = Hashtbl.find st.roommap a1 in
      let tile_opt = access_ll y1 x1 r.tiles in
      (match tile_opt with
       | Some tile ->
         tile.immov <- None;
         if a1 = r1 || a1 = r2
         then Some (a1,{row = x1 ; col = y1 ; newtile = tile;})
         else None
       | None -> None
      );
    | (a2,x2,y2) , ("",_,_) ->
      let r = Hashtbl.find st.roommap a2 in
      let tile_opt = access_ll y2 x2 r.tiles in
      (match tile_opt with
       | Some tile ->
         (match tile.ex with
          | Some ex ->
            ex.is_open <- true;
            if a2 = r1 || a2 = r2
            then Some (a2,{row = x2 ; col = y2 ; newtile = tile;})
            else None
          | None -> None
         )
       | None -> None
      )
    | _ , _  -> None
  else None


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
    | Some tile ->
      if bool_opt tile.ch then create_empty_logs curr_room other_room
      else if bool_opt tile.immov then create_empty_logs curr_room other_room
      else
        let curr_player =
          (match access_ll curr_player_y curr_player_x curr_room.tiles with
           | Some tile -> tile
           | None -> failwith "")
        in
        tile.ch <- Some { id = playerid ; direction = d };
        curr_player.ch <- None;
        let entry_l = [{ row = next_player_x ; col = next_player_y ; newtile = tile; };
                       { row = curr_player_x ; col = curr_player_y ; newtile = curr_player; }]
        in
        ({room_id = curr_room.id; rows = curr_room.rows; cols = curr_room.rows; change = entry_l;},
         {room_id = other_room.id; rows = other_room.rows; cols = other_room.rows; change = [];})
    | None -> create_empty_logs curr_room other_room
  )
  | Take -> (
      match access_ll curr_player_y curr_player_x curr_room.tiles with
      | Some tile -> (
          match tile.store with
          | Some s ->
            (tile.store <- None;
             (if playerid = 1 then st.pl1_inv <- s.id::st.pl1_inv
              else st.pl2_inv <- s.id::st.pl2_inv);
             let entry_l = [{ row = curr_player_x ; col = curr_player_y ; newtile = tile; }]
               in
               ({room_id = curr_room.id; rows = curr_room.rows;
                 cols = curr_room.rows; change = entry_l;},
                {room_id = other_room.id; rows = other_room.rows;
                 cols = other_room.rows; change = [];}))
          | None -> create_empty_logs curr_room other_room
        )
      | None -> create_empty_logs curr_room other_room
    )
  | Drop n ->
    let inv = if playerid = 1 then st.pl1_inv else st.pl2_inv in
    if List.mem n.id inv then
    (
      match access_ll curr_player_y curr_player_x curr_room.tiles with
      | Some tile ->
        (
          match tile.store with
          | Some s -> create_empty_logs curr_room other_room
          | None ->
            (tile.store <- Some n;
             (if playerid = 1
              then st.pl1_inv <- List.filter (fun x -> x <> n.id) st.pl1_inv
              else st.pl2_inv <- List.filter (fun x -> x <> n.id) st.pl2_inv);
             let entry_l = [{row = curr_player_x ; col = curr_player_y ; newtile = tile;}] in
             match check_keyloc tile.kl n st curr_room_string other_room_string with
             | Some (r,e) ->
               if r = curr_room.id then
                 let entry_l' = e::entry_l in
                 ({room_id = curr_room.id; rows = curr_room.rows;
                   cols = curr_room.rows; change = entry_l';},
                  {room_id = other_room.id; rows = other_room.rows;
                   cols = other_room.rows; change = [];})
               else
                 ({room_id = curr_room.id; rows = curr_room.rows;
                   cols = curr_room.rows; change = entry_l;},
                  {room_id = other_room.id; rows = other_room.rows;
                   cols = other_room.rows; change = [];})
             | None ->
             ({room_id = curr_room.id; rows = curr_room.rows;
               cols = curr_room.rows; change = entry_l;},
              {room_id = other_room.id; rows = other_room.rows;
               cols = other_room.rows; change = [];})
            )
        )
      | None -> create_empty_logs curr_room other_room
)
else create_empty_logs curr_room other_room

let save (st : t) (file : string) =
  failwith "Unimplemented"
