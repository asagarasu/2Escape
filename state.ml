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
type exit = {id : string;
  mutable is_open : bool;
  to_room : string * int * int;
  cscene : Cutscene.t option}

(* type representing a location for a key
 * exit_effect are (room name, col, row)
 * immovable_effect are (room name, col, row)
*)
type keyloc = {id : string; key : string; mutable is_solved : bool;
  exit_effect : (string * int * int) list; immovable_effect : (string * int * int) list}

(* type representing a rotatable object *)
type rotatable = {id : string; mutable rotate : direction; correct : direction;
    exit_effect : (string * int * int) list; immovable_effect : (string * int * int) list}

let next_dir (d : direction) : direction =
  match d with
  | Up -> Left
  | Down -> Right
  | Left -> Down
  | Right -> Up

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

(* Entry in a log *)
type entry = {
  row : int;
  col : int;
  newtile : tile;
}

(* Type representing inventory changes *)
type invchange = {
  add : string list;
  remove : string list
}

(* type representing a log of information to pass to client*)
type log' = {
  room_id : string;
  rows : int;
  cols : int;
  change : entry list;
  inv_change : invchange;
  chat : message option;
  cutscene : Cutscene.t option
}

(**
 * Helper method to create two empty logs
 *
 * requires: [rm1] and [rm2] are valid rooms
 * returns: two emtpy logs with the room information
 *)
let create_empty_logs (rm1 : room) (rm2 : room) : log' * log' =
  ({room_id = rm1.id; rows = rm1.rows; cols = rm1.cols;
    change = []; inv_change = {add = []; remove = []}; chat = None;
    cutscene = None},
   {room_id = rm2.id; rows = rm2.rows; cols = rm2.cols;
    change = []; inv_change = {add = []; remove = []}; chat = None;
    cutscene = None})

(**
 * Helper method to create a log based on a list of changed entries in room
 *
 * requires: [rm1] and [rm2] are valid rooms, [entry_l] is a valid entry list
 * returns: a [log'] with the information slotted in
 *)
let create_log (rm : room) (entry_l : entry list) : log' =
  {room_id = rm.id; rows = rm.rows; cols = rm.rows;
   change = entry_l; inv_change = {add = []; remove = []}; chat = None;
   cutscene = None}

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
     inv_change = {add = []; remove = []};
     chat = None;
     cutscene = None}
  else
    {
      room_id = sendroom.id;
      rows = sendroom.rows;
      cols = sendroom.cols;
      change = [];
      inv_change = {add = []; remove = []};
      chat = None;
      cutscene = None
    }

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
    begin
      {
        room_id = (fst logs).room_id;
        rows = (fst logs).rows;
        cols = (fst logs).cols;
        change = (fst logs).change;
        inv_change = {add = [item]; remove = []};
        chat = (fst logs).chat;
        cutscene = None
      }, (snd logs)
    end
  else
    begin 
      (fst logs),
      {
        room_id = (snd logs).room_id;
        rows = (snd logs).rows;
        cols = (snd logs).cols;
        change = (snd logs).change;
        inv_change = {add = [item]; remove = []};
        chat = (snd logs).chat;
        cutscene = None
      }
    end

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
    {
      room_id = (fst logs).room_id;
      rows = (fst logs).rows;
      cols = (fst logs).cols;
      change = (fst logs).change;
      inv_change = {add = [];remove = [item]};
      chat = (fst logs).chat;
      cutscene = None
    }, (snd logs)
  else
    (fst logs),
    {
        room_id = (snd logs).room_id;
        rows = (snd logs).rows;
        cols = (snd logs).cols;
        change = (snd logs).change;
        inv_change = {add = [];remove = [item]};
        chat = (snd logs).chat;
        cutscene = None
    }

(**
 * Helper method to add a cutscene to a log
 *
 *)
let add_cutscene (log : log') (cutscene : Cutscene.t) : log' =
  {
    room_id = log.room_id;
    rows = log.rows;
    cols = log.cols;
    change = log.change;
    inv_change = log.inv_change;
    chat = log.chat;
    cutscene = Some cutscene
  }

(**
 * Helper method to update the chat
 *
 * requires: [room1] [room2] [id] and [message] are valid rooms, int and string
 * returns: a [log' * log'] of the updated chat
 *)
let update_chat (room1 : room) (room2 : room) (id : int) (message : string) : log' * log' =
  {
    room_id = room1.id;
    rows = room1.rows;
    cols = room1.cols;
    change = [];
    inv_change = {add = []; remove = []};
    chat = Some {id = id; message = message};
    cutscene = None
  },
  {
    room_id = room2.id;
    rows = room2.rows;
    cols = room2.cols;
    change = [];
    inv_change = {add = []; remove = []};
    chat = Some {id = id; message = message};
    cutscene = None
  }

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
  let room_string = if playerid = 1 then fst_third st.pl1_loc 
    else fst_third st.pl2_loc in
  let room = Hashtbl.find st.roommap room_string in
  let entrymap = (Array.mapi (fun (y : int) (row : tile array) ->
          Array.mapi (fun (x : int) (t : tile) ->
            {row = y; col = x; newtile = t}
          ) row
        ) room.tiles) in
  let entryarrlist = (Array.map Array.to_list entrymap) in
  let entrylistlist = Array.to_list entryarrlist in
  let entrylist = List.flatten entrylistlist in
  let invchange = [] in 
  {
    room_id = room_string;
    rows = room.rows;
    cols = room.cols;
    change = entrylist;
    inv_change = {add = invchange; remove = []};
    chat = None;
    cutscene = None
  }

(**
 * Helper method to load a game's state from scatch based on the player's id
 *
 * requires: playerid is 1 or 2, st is a valid state
 * returns: a log' representation of player [playerid]'s state with inventory
 *)
let logifyfull (playerid : int) (st : t) : log' =
  let room_string = if playerid = 1 then fst_third st.pl1_loc 
    else fst_third st.pl2_loc in
  let room1 = Hashtbl.find st.roommap room_string in
  let entrymap = (Array.mapi (fun (y : int) (row : tile array) ->
          Array.mapi (fun (x : int) (t : tile) ->
            {row = y; col = x; newtile = t}
          ) row
        ) room1.tiles) in
  let entryarrlist = (Array.map Array.to_list entrymap) in
  let entrylistlist = Array.to_list entryarrlist in
  let entrylist = List.flatten entrylistlist in
  let invchange = if playerid = 1 then st.pl1_inv else st.pl2_inv in 
  {
    room_id = room_string;
    rows = room1.rows;
    cols = room1.cols;
    change = entrylist;
    inv_change = {add = invchange; remove = []};
    chat = None;
    cutscene = None
  }

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
  let room2_string = fst_third st.pl2_loc in
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
        else if bool_opt newtile.immov then
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
        else if bool_opt newtile.rt then

          begin
            let rot = access_opt newtile.rt in
            if rot.rotate = rot.correct then create_empty_logs room1 room2
            else
              begin
               rot.rotate <- next_dir rot.rotate;
               if rot.rotate = rot.correct then
                begin
                  List.iter (fun ex_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third ex_effect) in
                  let alteredrow = thd_third ex_effect in
                  let alteredcol = snd_third ex_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  (access_opt alteredtile.ex).is_open <- not (access_opt alteredtile.ex).is_open) rot.exit_effect;
                List.iter(fun imm_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third imm_effect) in
                  let alteredrow = thd_third imm_effect in
                  let alteredcol = snd_third imm_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  alteredtile.immov <- None) rot.immovable_effect;
                  logify 1 st, logify 2 st
                end
               else
                begin
                  let entry_l = [{row = next_player_y; col = next_player_x; newtile = newtile}] in
                  (update_room room1 curr_room entry_l, update_room room2 curr_room entry_l)
                end
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
                List.iter (fun ex_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third ex_effect) in
                  let alteredrow = thd_third ex_effect in
                  let alteredcol = snd_third ex_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  (access_opt alteredtile.ex).is_open <- not (access_opt alteredtile.ex).is_open) kl.exit_effect;
                List.iter(fun imm_effect ->
                  let alteredroom = Hashtbl.find st.roommap (fst_third imm_effect) in
                  let alteredrow = thd_third imm_effect in
                  let alteredcol = snd_third imm_effect in
                  let alteredtile = alteredroom.tiles.(alteredrow).(alteredcol) in
                  alteredtile.immov <- None) kl.immovable_effect;
                  (if playerid = 1 then st.pl1_inv <- List.filter (fun x -> x <> item) st.pl1_inv
                  else st.pl2_inv <- List.filter (fun x -> x <> item) st.pl2_inv);
                drop_item_logs (logify 1 st, logify 2 st) playerid item
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
                  || bool_opt newroom_tile.immov then
                  create_empty_logs room1 room2
                else
                  begin
                    tile.ch <- None;
                    newroom_tile.ch <- Some {id = playerid; direction = Down};
                    (if playerid = 1 then 
                      st.pl1_loc <- newroom_string, newroom_x, newroom_y 
                      else
                      st.pl2_loc <- newroom_string, newroom_x, newroom_y);
                    if bool_opt exit.cscene then 
                      (if playerid = 1 then add_cutscene (logify 1 st) (access_opt exit.cscene), logify 2 st
                      else logify 1 st, add_cutscene (logify 2 st) (access_opt exit.cscene))
                    else 
                      (logify 1 st, logify 2 st)
                  end
            end
          else
            create_empty_logs room1 room2
        end
  else create_empty_logs room1 room2
