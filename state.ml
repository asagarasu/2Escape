open Helper
open Yojson
open Yojson.Basic.Util

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
type exit = {id : string; mutable is_open : bool; to_room : string * int * int}

(* type representing a location for a key
 * exit_effect are (room name, col, row)
 * immovable_effect are (room name, col, row)
*)
type keyloc = {id : string;
               key : string;
               mutable is_solved : bool;
               exit_effect : (string * int * int) list;
               immovable_effect : (string * int * int) list}

(* type representing a rotatable object *)
type rotatable = {id : string; rotate : int}

(* type representing a tile in the room *)
type tile = {
  mutable ch : character option;
  mutable mov : movable option;
  mutable store : storable option;
  mutable immov : immovable option;
  mutable ex : exit option;
  mutable kl : keyloc option;
  mutable rt : rotatable option;
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

type entry = {
  row : int;
  col : int;
  newtile : tile;
}

(* Type representing inventory changes *)
type invchange = {
  add : string option;
  remove : string option
}

(* type representing a log of information to pass to client*)
type log' = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list;
  inv_change : invchange;
  chat : message option
}

(**
 * Helper method to create two empty logs
 *
 * requires: [rm1] and [rm2] are valid rooms
 * returns: two emtpy logs with the room information
 *)
let create_empty_logs (rm1 : room) (rm2 : room) : log' * log' =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols;
    change = []; inv_change = {add = None; remove = None}; chat = None},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols;
    change = []; inv_change = {add = None; remove = None}; chat = None})

(**
 * Helper method to create a log based on a list of changed entries in room
 *
 * requires: [rm1] and [rm2] are valid rooms, [entry_l] is a valid entry list
 * returns: a [log'] with the information slotted in
 *)
let create_log (rm : room) (entry_l : entry list) : log' =
  {room_id = rm.id; rows = rm.rows; cols = rm.rows;
   change = entry_l; inv_change = {add = None; remove = None}; chat = None}

(**
 * Helper method to update a room by a new room iff it is the correct room to update
 *
 * requires: [sendroom] is the room that sent, [changedroom] is the room that is changed
 *           [entries] is a valid entries list
 * returns: a [log'] of any possible changes
 *)
let update_room (sendroom : room) (changedroom : room) (entries : entry list) : log' =
  if sendroom.id = changedroom.id then
    {room_id = sendroom.id;
     rows = sendroom.rows;
     cols = sendroom.cols;
     change = entries;
     inv_change = {add = None; remove = None};
     chat = None}
  else
    {room_id = sendroom.id;
     rows = sendroom.rows;
     cols = sendroom.cols;
     change = [];
     inv_change = {add = None; remove = None};
     chat = None}

(**
 * Helper method to update a log based on [playerid] adding an [item]
 * to their inventory
 *
 * requires: [logs] is a log pair [playerid] is one or two, and
 *           [item] is a string
 * returns: an updated log pair when adding [item] to player [playerid's] inventory
 *)
let add_item_logs (logs: log' * log') (playerid : int) (item : string) : log' * log' =
  if playerid = 1 then
    {room_id = (fst logs).room_id;
     rows = (fst logs).rows;
     cols = (fst logs).cols;
     change = (fst logs).change;
     inv_change = {add = Some item; remove = None};
     chat = (fst logs).chat}, (snd logs)
  else
    (fst logs), {room_id = (snd logs).room_id;
                 rows = (snd logs).rows;
                 cols = (snd logs).cols;
                 change = (snd logs).change;
                 inv_change = {add = Some item;remove = None};
                 chat = (snd logs).chat}

(**
 * Helper method to update a log based on [playerid] dropping an [item]
 * from their inventory
 *
 * requires: [logs] is a log pair [playerid] is one or two, and
 *           [item] is a string
 * returns: an updated log pair when removing [item] from player [playerid]'s inventory
 *)
let drop_item_logs (logs: log' * log') (playerid : int) (item : string) : log' * log' =
  if playerid = 1 then
    {room_id = (fst logs).room_id;
     rows = (fst logs).rows;
     cols = (fst logs).cols;
     change = (fst logs).change;
     inv_change = {add = None;remove = Some item};
     chat = (fst logs).chat}, (snd logs)
  else
    (fst logs), {room_id = (snd logs).room_id;
                 rows = (snd logs).rows;
                 cols = (snd logs).cols;
                 change = (snd logs).change;
                 inv_change = {add = None;remove = Some item};
                 chat = (snd logs).chat}
(**
 * Helper method to update the chat
 *
 * requires: [room1] [room2] [id] and [message] are valid rooms, int and string
 * returns: a [log' * log'] of the updated chat
 *)
let update_chat (room1 : room) (room2 : room) (id : int) (message : string) : log' * log' =
  {room_id = room1.id; rows = room1.rows; cols = room1.cols; change = [];
    inv_change = {add = None; remove = None}; chat = Some {id = id; message = message}},
  {room_id = room2.id; rows = room2.rows; cols = room2.cols; change = [];
    inv_change = {add = None; remove = None}; chat = Some {id = id; message = message}}

(**
 * Helper method to get the direction vector of each command.Arg
 * Up is -1 because we are dealing with javascript tables
 *
 * requires: d is a direction
 * returns: the vector (pm 1, 0) or (0, pm 1), depending on direction
 *)
let direct (d:direction) : int * int = match d with
  | Left -> (-1,0)
  | Right -> (1,0)
  | Up -> (0,-1)
  | Down -> (0,1)

(**
 * Helper method to convert all of a state into a log' based on the player's id
 *
 * requires: playerid is 1 or 2, st is a valid state
 * returns: a log' representation of player [playerid]'s state
 *)
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
    inv_change = {add = None; remove = None};
    chat = None
  }

    (*
let update_rt (rt:rotatable) : rotatable =
  let id_stem = String.sub rt.id 1 (String.length rt.id -1) in
  match rt.id with
  | id_stem ^ "1" -> *)



(**
 * Method to do a player command based on the player's id
 * command, and the current state
 *
 * requires: playerid is 1 or 2, everything else is valid
 * returns: a [log' * log'] of changes to be sent to players 1 and 2
 * effects: [st] is effected by the command and is changed accordingly
 *)
let do_command (playerid : int) (comm : command) (st : t) : log' * log' =
  let room1_string = fst_third st.pl1_loc in
  let room2_string = fst_third st.pl1_loc in
  let room1 = Hashtbl.find st.roommap room1_string in
  let room2 = Hashtbl.find st.roommap room2_string in
  let curr_player_x = if playerid = 1 then snd_third st.pl1_loc else snd_third st.pl2_loc in
  let curr_player_y = if playerid = 1 then thd_third st.pl1_loc else thd_third st.pl2_loc in
  let curr_room = if playerid = 1 then room1 else room2 in
  let other_room = if playerid = 1 then room2 else room1 in
  let curr_room_id = curr_room.id in
  let other_room_id = other_room.id in

  match comm with
  | Go d ->
    let pair = direct d in
    let next_player_y = curr_player_y + snd pair in
    let next_player_x = curr_player_x + fst pair in
    (
    try
      let oldtile = curr_room.tiles.(curr_player_y).(curr_player_x) in
      let newtile = curr_room.tiles.(next_player_y).(next_player_x) in
        if bool_opt newtile.ch then
          begin
            oldtile.ch <- Some { id = playerid ; direction = d };
            let entry_l = [{row = curr_player_y; col = curr_player_x; newtile = oldtile}] in
            (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
          end
        else if bool_opt newtile.immov || bool_opt newtile.rt then
          begin
            oldtile.ch <- Some { id = playerid ; direction = d };
            let entry_l = [{row = curr_player_y; col = curr_player_x; newtile = oldtile}] in
            (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
          end
        else if bool_opt newtile.mov then
          begin
            let mov_y = next_player_y + snd pair in
            let mov_x = next_player_x + fst pair in
            let mov_tile = curr_room.tiles.(mov_y).(mov_x) in
            if mov_tile = {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None} then
              begin
                mov_tile.mov <- newtile.mov;
                newtile.mov <- None;
                newtile.ch <- Some { id = playerid ; direction = d };
                oldtile.ch <- None;
                (if playerid = 1
                 then st.pl1_loc <- room1_string, next_player_x, next_player_y
                 else st.pl2_loc <- room2_string, next_player_x, next_player_y);
                let entry_l =
                  [{row = curr_player_y; col = curr_player_x; newtile = oldtile};
                  {row = next_player_y; col = next_player_x; newtile = newtile};
                  {row = mov_y; col = mov_x; newtile = mov_tile}
                  ]
                in
                (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
              end
            else
              begin
                oldtile.ch <- Some { id = playerid ; direction = d };
                let entry_l =
                  [{row = curr_player_y; col = curr_player_x; newtile = oldtile}]
                in
                (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
              end
          end
        else
          begin
            newtile.ch <- Some { id = playerid ; direction = d };
            oldtile.ch <- None;
            let entry_l = [{row = next_player_y ; col = next_player_x ; newtile = newtile; };
                           { row = curr_player_y ; col = curr_player_x ; newtile = oldtile; }]
            in
            (if playerid = 1
             then st.pl1_loc <- room1_string, next_player_x, next_player_y
             else st.pl2_loc <- room2_string, next_player_x, next_player_y);
            (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
          end
          (*TODO other things*)
    with
       Invalid_argument _ ->
        let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
          tile.ch <- Some { id = playerid ; direction = d };
          let entry_l = [{row = curr_player_y; col = curr_player_x; newtile = tile}] in
          (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
  )
  | Take ->
    let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
    (match tile.store with
      | Some item ->
          begin
            match tile.kl with
            | Some _ -> create_empty_logs room1 room2
            | None ->
              begin
                tile.store <- None;
                (if playerid = 1 then st.pl1_inv <- item.id :: st.pl1_inv
                else st.pl2_inv <- item.id :: st.pl2_inv);
                let entry_l = [{ row = curr_player_y ; col = curr_player_x ; newtile = tile }]
                in
                add_item_logs
                  (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
                  playerid item.id
              end
          end
      | None -> create_empty_logs room1 room2)
  | Drop item ->
    let inv = if playerid = 1 then st.pl1_inv else st.pl2_inv in
    let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
    if List.mem item inv then
      begin
        if bool_opt tile.store then create_empty_logs room1 room2
        else if bool_opt tile.ex then create_empty_logs room1 room2
        else if bool_opt tile.kl then
          begin
            let kl = access_opt tile.kl in
            if kl.key = item then
              begin
                tile.store <- Some {id = item};
                kl.is_solved <- true;
                let stentryl =
                  match room1_string, room2_string with
                  | a, b when a = curr_room_id && b = curr_room_id ->
                    [{ row = curr_player_y; col = curr_player_x; newtile = tile}],
                    [{ row = curr_player_y; col = curr_player_x; newtile = tile}]
                  | a, _ when a = curr_room_id ->
                    [{ row = curr_player_y; col = curr_player_x; newtile = tile}], []
                  | _, a when a = curr_room_id ->
                    [], [{ row = curr_player_y; col = curr_player_x; newtile = tile}]
                  | _ -> [], []
                 in
                let changedExitsEntries = List.fold_left (fun curr_entries ex_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third ex_effect) in
                  let alteredrow = thd_third ex_effect in
                  let alteredcol = snd_third ex_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  (access_opt alteredtile.ex).is_open <- not (access_opt alteredtile.ex).is_open;
                  match room1_string, room2_string with
                  | a, b when a = room1_string && b = room2_string ->
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (fst curr_entries),
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (snd curr_entries)
                  | a, _ when a = room1_string ->
                  { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (fst curr_entries),
                    (snd curr_entries)
                  | _, a when a = room2_string ->
                    (fst curr_entries),
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (snd curr_entries)
                  | _ -> curr_entries) stentryl kl.exit_effect in
                let allEntries = List.fold_left (fun curr_entries imm_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third imm_effect) in
                  let alteredrow = thd_third imm_effect in
                  let alteredcol = snd_third imm_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  alteredtile.immov <- None;
                  match room1_string, room2_string with
                  | a, b when a = room1_string && b = room2_string ->
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (fst curr_entries),
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (snd curr_entries)
                  | a, _ when a = room1_string ->
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (fst curr_entries),
                    snd curr_entries
                  | _, a when a = room2_string ->
                    fst curr_entries,
                    { row = alteredrow; col = alteredcol; newtile = alteredtile} :: (snd curr_entries)
                  | _ -> curr_entries) changedExitsEntries kl.immovable_effect in
                  (if playerid = 1 then st.pl1_inv <- List.filter (fun x -> x <> item) st.pl1_inv
                  else st.pl2_inv <- List.filter (fun x -> x <> item) st.pl2_inv);
                drop_item_logs (create_log room1 (fst allEntries), create_log room2 (snd allEntries)) playerid item
              end
            else create_empty_logs room1 room2
          end
        else
          begin
            tile.store <- Some {id = item};
            (if playerid = 1 then st.pl1_inv <- List.filter (fun x -> x <> item) st.pl1_inv
            else st.pl2_inv <- List.filter (fun x -> x <> item) st.pl2_inv);
            let entry_l = [{ row = curr_player_y; col = curr_player_x; newtile = tile}] in
            drop_item_logs (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l) playerid item
          end
      end
    else create_empty_logs room1 room2
  | Message s -> st.chat <- { id = playerid ; message = s }::st.chat ;
    update_chat room1 room2 playerid s
  | Enter ->
    let tile = curr_room.tiles.(curr_player_y).(curr_player_x) in
      if bool_opt tile.ex then
        begin
          let exit = access_opt tile.ex in
          if (exit).is_open then
            begin
              let newroom_string = fst_third exit.to_room in
              let newroom = Hashtbl.find st.roommap newroom_string in
              let newroom_y = thd_third exit.to_room in
              let newroom_x = snd_third exit.to_room in
              let newroom_tile = newroom.tiles.(newroom_y).(newroom_x) in
                if bool_opt newroom_tile.ch || bool_opt newroom_tile.mov
                  || bool_opt newroom_tile.immov || bool_opt newroom_tile.ex then
                  create_empty_logs room1 room2
                else
                  begin
                    tile.ch <- None;
                    newroom_tile.ch <- Some {id = playerid; direction = Down};
                    (if playerid = 1 then st.pl1_loc <- newroom_string, newroom_x, newroom_y else
                      st.pl2_loc <- newroom_string, newroom_x, newroom_y);
                    let curr_player_log = logify playerid st in
                    let other_player_entries =
                      (match other_room_id with
                       | x when x = curr_room_id ->
                         [{row = curr_player_y; col = curr_player_x; newtile = tile}]
                       | x when x = newroom_string ->
                         [{row = newroom_y; col = newroom_x; newtile = newroom_tile}]
                       | _ -> []
                      ) in
                    (if playerid = 1 then curr_player_log, create_log room2 other_player_entries
                    else create_log room2 other_player_entries, curr_player_log)
                  end
            end
          else
            create_empty_logs room1 room2
        end
  else create_empty_logs room1 room2

(** Save a game : Converting state to json **)

(* Helper method to turn a [ch] to a json*)
let ch_to_json (t:character) =
  let id = `Int t.id in
  let direction =
    `String (match t.direction with | Up -> "up" | Down -> "down"
                                    | Right -> "right" | Left -> "left" )
  in
  `List [id;direction]

(* Helper method to turn a [ex] into a json*)
let ex_to_json (t:exit) =
  let id = `String t.id in
  let is_open = `Bool t.is_open in
  let triple = t.to_room in
  let to_room = `List [`String (fst_third triple);
                       `Int (snd_third triple);
                       `Int (thd_third triple)] in
  `Assoc [("id", id); ("is_open",is_open);("to_room",to_room)]

(* Helper method to turn a [kl] to a json *)
let kl_to_json (t:keyloc) =
  let id = `String t.id in
  let key = `String t.key in
  let is_solved = `Bool t.is_solved in
  let exit_effect = `List (List.map (fun exeffect ->
                    `List [`String (fst_third exeffect);
                       `Int (snd_third exeffect);
                       `Int (thd_third exeffect)]) t.exit_effect) in
  let immovable_effect = `List (List.map (fun immeffect ->
                    `List [`String (fst_third immeffect);
                       `Int (snd_third immeffect);
                       `Int (thd_third immeffect)]) t.immovable_effect) in
  `Assoc [("id",id); ("key",key); ("is_solved",is_solved);
          ("exit_effect",exit_effect);("immovable_effect",immovable_effect)]

(* Helper method to turn a [tile] into a json *)
let tile_to_json (t:tile) =
  let ch = match t.ch with | None -> `List [] | Some a -> ch_to_json a in
  let mov = match t.mov with | None -> `String "" | Some a -> `String a.id in
  let store = match t.store with | None -> `String "" | Some a -> `String a.id in
  let immov = match t.immov with | None -> `String "" | Some a -> `String a.id in
  let ex = match t.ex with | None -> `String "" | Some a -> ex_to_json a in
  let kl = match t.kl with | None -> `String "" | Some a -> kl_to_json a in
  let rt = match t.rt with | None -> `String "" | Some a -> `String a.id in
  `Assoc [("ch",ch);("mov",mov);("store",store);("immov",immov);("ex",ex);("kl",kl);("rt",rt)]

(* Helper method to turn a [room] into a json *)
let room_to_json (t:room) =
  let id = `String t.id in
  let rows = `Int t.rows in
  let cols = `Int t.cols in
  let tll = Array.to_list (Array.map Array.to_list t.tiles) in
  let tiles = `List (List.rev (List.map (fun x -> `List (List.map tile_to_json x)) tll)) in
  `Assoc [("id",id);("tiles",tiles);("rows",rows);("cols",cols)]

(* Helper method to turn a [message] into a json *)
let chat_to_json (t:message) =
  let id = `Int t.id in
  let message = `String t.message in
  `Assoc [("id",id);("message",message)]

(* Helper method to turn a [state.t] into a json *)
let state_to_json (t:t) =
  let roommap = `List (Hashtbl.fold (fun k v acc -> (room_to_json v)::acc) t.roommap []) in
  let loc1_triple = t.pl1_loc in
  let pl1_loc = `List [`String (fst_third loc1_triple);
                       `Int (snd_third loc1_triple);
                       `Int (thd_third loc1_triple)] in
  let loc2_triple = t.pl2_loc in
  let pl2_loc = `List [`String (fst_third loc2_triple);
                       `Int (snd_third loc2_triple);
                       `Int (thd_third loc2_triple)] in
  let pl1_inv = `List (List.map (fun x -> `String x) t.pl1_inv) in
  let pl2_inv = `List (List.map (fun x -> `String x) t.pl2_inv) in
  let chat = `List (List.map chat_to_json t.chat) in
  `Assoc [("roommap",roommap);("pl1_loc",pl1_loc);("pl2_loc",pl2_loc);
          ("pl1_inv",pl1_inv);("pl2_inv",pl2_inv);("chat",chat);]

(* Helper method to turn a state into a file *)
let save (st : t) (file : string) = Yojson.Basic.to_file file (state_to_json st)



(** Load a game : Converting json to state **)
(* Helper method to read of [ch] from a json *)
let ch_of_json j =
  let ch_id = List.nth j 0 |> to_int in
  let ch_di =
    (match List.nth j 1 |> to_string with
     | "up" -> Up | "down" -> Down | "right" -> Right | "left" -> Left | _ -> Up )
  in
  Some { id = ch_id ; direction = ch_di }

(* Helper method to read an [ex] from a json *)
let ex_of_json j =
  let trl =  List.nth j 3 |> to_list in
  Some {
    id = List.nth j 1 |> to_string;
    is_open = List.nth j 2 |> to_bool;
    to_room = (List.nth trl 0 |> to_string , List.nth trl 1 |> to_int, List.nth trl 2 |> to_int);
  }

(* Helper method to read a [kl] from a json *)
let kl_of_json j =
  let eel = j |> member "exit_effect" |> to_list in
  let iel = j |> member "immovable_effect" |> to_list in
  Some {
    id = j |> member "id" |> to_string;
    key = j |> member "key" |> to_string;
    is_solved = j |> member "is_solved" |> to_bool;
    exit_effect = List.map (fun exiteffect ->
      let exittriple = exiteffect |> to_list in
      List.nth exittriple 0 |> to_string, List.nth exittriple 1 |> to_int, List.nth exittriple 2 |> to_int) eel;
    immovable_effect = List.map (fun immeffect ->
      let immtriple = immeffect |> to_list in
      List.nth immtriple 0 |> to_string, List.nth immtriple 1 |> to_int, List.nth immtriple 2 |> to_int) iel;
  }

(* Helper method to read a [rotatable] from a json*)
let rt_of_json j =
  Some {
    id = j |> member "id" |> to_string;
    rotate = j |> member "rotate" |> to_int
  }

(* Helper method to read a [tile] from a json *)
let tile_of_json j =
  let ch_s = j |> member "ch" |> to_list in
  let mov_s = j |> member "mov" |> to_string in
  let store_s = j |> member "store" |> to_string in
  let immov_s = j |> member "immov" |> to_string in
  let ex_s = j |> member "ex" |> to_list in
  let kl_s = j |> member "kl" |> to_string in
  let rt_s = j |> member "rt" |> to_string in
  {
    ch = if ch_s = [] then None else ch_of_json ch_s;
    mov = if mov_s = "" then None else Some { id = mov_s };
    store = if store_s = "" then None else Some { id = store_s };
    immov = if immov_s = "" then None else Some { id = immov_s };
    ex = if ex_s = [] then None else ex_of_json ex_s;
    kl = if kl_s = "" then None else j |> member "kl" |> kl_of_json;
    rt = if rt_s = "" then None else Some { id = rt_s };
  }

(* Helper method to read a [tiles] list from a json *)
let rec make_tiles_list (l : 'a list) (matrix : tile list list) : tile list list =
  match l with
  | h::t -> make_tiles_list t [(List.map tile_of_json (to_list h))]@matrix
  | [] -> matrix

(* Helper method to read a [room] from a json *)
let room_of_json j =
  let tl = j |> member "tiles" |> to_list in
  let tll =  make_tiles_list tl [] in
  {
    id = j |> member "id" |> to_string;
    rows = j |> member "rows" |> to_int;
    cols = j |> member "cols" |> to_int;
    tiles = Array.of_list (List.map Array.of_list tll);
  }

(* Helper method to create a Hashtbl from parsed rooms *)
let rooms_of_json rooms :(string, room) Hashtbl.t =
  let parsed_rooms = List.map room_of_json rooms in
  let r_hashtb : (string, room) Hashtbl.t = Hashtbl.create (List.length parsed_rooms) in
  let hash (r:room) = Hashtbl.add r_hashtb r.id r in
  List.iter hash parsed_rooms; r_hashtb

(* Helper method to get chat from a json *)
let chat_of_json j = {
  id = j |> member "id" |> to_int;
  message = j |> member "message" |> to_string;
}

(* Helper method to get the state of a json *)
let state_of_json j =
  let loc1 = j |> member "pl1_loc" |> to_list in
  let loc2 = j |> member "pl2_loc" |> to_list in
  {
    roommap = j |> member "roommap" |> to_list |> rooms_of_json;
    pl1_loc = (List.nth loc1 0 |> to_string, List.nth loc1 1 |> to_int, List.nth loc1 2 |> to_int);
    pl2_loc = (List.nth loc2 0 |> to_string, List.nth loc2 1 |> to_int, List.nth loc2 2 |> to_int);
    pl1_inv = j |> member "pl1_inv" |> to_list |> List.map to_string;
    pl2_inv = j |> member "pl2_inv" |> to_list |> List.map to_string;
    chat = j |> member "chat" |> to_list |> List.map chat_of_json;
  }

(* Helper method to get the state of a json *)
let load (file : string) : t =
  let j = Yojson.Basic.from_file file in
  state_of_json j
