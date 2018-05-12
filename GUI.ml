open Js_of_ocaml
open Js_of_ocaml_lwt
open Helper 

module Html = Dom_html
let js = Js.string
let document = Html.document

(* Helper function to offer alternative if element isn't found *)
let fail = fun _ -> assert false

let td_style = js"padding: 0; width: 20px; height: 20px;"

let string_of_direction (dir : State.direction) : string = 
  match dir with 
  | Up -> "up"
  | Down -> "down"
  | Left -> "left"
  | Right -> "right"

(** 
 * Gets the string of the item to display. 
 * The precedence for display is as follows:
 * 
 * Character > KeyLoc > Exits > Movables > 
 * Storables > Immovables > Empty
 *
 * requires: [tile] is a [State.tile]
 * returns: the string
 *)
let get_dominant (tile: State.tile) : string = 
  if bool_opt tile.ch = true then "player" 
    ^ string_of_int (access_opt tile.ch).id else
  if bool_opt tile.kl = true then (access_opt tile.kl).id 
    ^ "_" ^ string_of_bool (access_opt tile.kl).is_solved else
  if bool_opt tile.mov = true then (access_opt tile.mov).id else
  if bool_opt tile.store = true then (access_opt tile.store).id else
  if bool_opt tile.rt = true then (access_opt tile.rt).id ^  "_" 
    ^ string_of_direction (access_opt tile.rt).rotate else 
  if bool_opt tile.immov = true then (access_opt tile.immov).id  else
  if bool_opt tile.ex = true then 
    let is_open = (access_opt tile.ex).is_open in 
    (if is_open then (access_opt tile.ex).id ^ "_open" else (access_opt tile.ex).id ^ "_closed") else
  "empty"

(**
 * Matches the name of a string to the img sprite
 * 
 * requires: [name] is a valid sprite
 * returns: an image string to be drawn
 *)
let match_name (name : string) : Js.js_string Js.t = 
  js ("sprites/" ^ name ^ ".png")

let inventory : string list ref = ref []

let startloc = ref 0

let inv1 = Html.createImg document 

let inv2 = Html.createImg document 

let inv3 = Html.createImg document

let redraw_inv _ : unit = 
  inv1##src <- 
    (try
      match_name (List.nth (!inventory) (!startloc + 1)) 
    with Invalid_argument _ -> match_name "invempty"
    | Failure _ -> match_name "invempty");
  inv2##src <- 
    (try
    match_name (List.nth (!inventory) (!startloc)) 
  with Invalid_argument _ -> match_name "invempty"
  | Failure _ -> match_name "invempty");
  inv3##src <- 
    (try
      match_name (List.nth (!inventory) (!startloc - 1)) 
    with Invalid_argument _ -> match_name "invempty"
    | Failure _ -> match_name "invempty")
  
let clickright _ : unit = 
  if !startloc = 0 then () 
  else startloc := !startloc - 1; redraw_inv ()

let clickleft _ : unit = 
  if !startloc = List.length (!inventory) - 1 then ()
  else startloc := !startloc + 1; redraw_inv ()

let redraw_inv_log (log : State.log') : unit = 
    if bool_opt log.inv_change.add then 
      begin
        (if List.length !inventory > 0 then startloc := !startloc + 1 else ());
        inventory := (access_opt log.inv_change.add) :: !inventory;
        redraw_inv ()
      end
    else if bool_opt log.inv_change.remove then 
      begin
        let removeditem = (access_opt log.inv_change.remove) in 
        let index = find_index ((=) removeditem) !inventory in 
          if index <= !startloc then
            begin
              (if !startloc > 0 then startloc := !startloc - 1 else ());
              inventory := List.filter (fun a -> a <> removeditem) !inventory;
              redraw_inv ()
            end 
          else 
            begin 
              inventory := List.filter (fun a -> a <> removeditem) !inventory;
              redraw_inv ()
            end
      end
    else ()

(**
 * Helper method to replace the child of a parent 
 * 
 * requires: [p] is a parent node, [n] is a child node
 * returns: a unit ()
 * effects: [p]'s node's are replaced by [n]. If none, then 
 *          [n] is just appended
 *)
let replace_child p n =
  Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
  Dom.appendChild p n

(**
 * Reassigns a picture in [tbl] to the new picture in [entry]
 *
 * requires : [entry] has [row] and [col] within the bounds for [tbl]
 * returns : unit ()
 * effects : [tbl]'s picture is redrawn (if precondition is met)
 *)
let replace_table_elt tbl (entry : State.entry) : unit = 
  let row = Js.Opt.get tbl##rows##item(entry.row) fail in 
  let elt = Js.Opt.get row##cells##item(entry.col) fail in 
  let img = Html.createImg document in 
    img##src <- match_name (get_dominant entry.newtile);
    replace_child elt img

(**
 * Reassigns pictures to the whole table [tbl] based on [log] 
 *
 * requires: [tbl] is the g
 * returns: unit ()
 * effects: reassigns the various entries in [tbl] by their 
 *          new pictures from [log]
 *)
let re_draw_whole tbl (log : State.log') : unit =  
  tbl##style##opacity <- Js.def (js "0");
  let tbl_rows = tbl##rows##length in
  let tbl_cols = if tbl_rows = 0 then 0 else
    (Js.Opt.get (tbl##rows##item(0)) fail)##cells##length in 
  
  if tbl_rows = log.rows && tbl_cols = log.cols then 
  List.iter (replace_table_elt tbl) log.change
  else 
    begin
      for i = 1 to tbl_rows 
        do 
          tbl##deleteRow(0)
        done;
      for y = 1 to log.rows do
        let tr = tbl##insertRow (-1) in
          for x = 1 to log.cols do 
            let td = tr##insertCell (-1) in
            td##style##cssText <- td_style;
            Dom.appendChild tr td
          done;
          Dom.appendChild tbl tr
        done;
        List.iter (replace_table_elt tbl) log.change
    end;
    tbl##style##opacity <- Js.def (js "1")

let (cutscene : Cutscene.t ref) = ref Cutscene.empty

let gametbl = ref (Html.createTable document)

let isCutscreen = ref false

let cutscene_canvas = Html.createCanvas document

let cutscene_context = cutscene_canvas##getContext(Html._2d_)

let toCutscene divNode : unit = 
  replace_child divNode cutscene_canvas

let fromCutscene divNode tbl : unit = 
  replace_child divNode tbl

              
(**
 * Helper method to update chat based on log 
 * 
 * requires: [chatArea] is a [Js.textArea Js.t] that has the chat
 *           [log] is a valid [State.log']
 * effects: the chat is in [log] is appended to [chatArea]
 *)
  let receive_message chatArea (log : State.log') : unit = 
    match log.chat with 
    | Some message -> chatArea##value 
        <- chatArea##value##concat(js ("\nPlayer" ^ string_of_int message.id 
          ^ " : " ^ message.message));
        chatArea##scrollTop <- chatArea##scrollHeight; ()
    | None -> ()

(**
 * Helper method send a message command 
 *
 * requires: input is a valid textInput, ev is a valid event
 * effects: sends a message with the info in [input] to the client
            if key is enter key. Otherwise event is ignored
 * notes: TODO
 *)
let send_message input ev : unit = match ev##keyCode with 
    | 13 -> let command = State.Message (Js.to_string input##value) in 
            input##value <- js "";
            ignore "Send Message to client TODO"; 
            ()
    | _ -> Html.stopPropagation ev

(** 
 * Helper method to get a movement command by arrow key 
 * 
 * requires: [ev] is a valid keyEvent
 * returns: a command associated with [ev], otherwise nothing
 *)
let key_direction ev : State.command option = 
  match ev##keyCode with 
  | 37 -> Some (State.Go State.Left)
  | 38 -> Some (State.Go State.Up)
  | 39 -> Some (State.Go State.Right)
  | 40 -> Some (State.Go State.Down)
  | 90 -> Some State.Take
  | 88 -> (match List.nth_opt !inventory !startloc with
            | Some x -> Some (State.Drop x)
            | None -> None
          )
  | 32 -> Some State.Enter
  | _ -> None 

(**
 * Helper method to send a movement command to client 
 *
 * requires: [ev] is a valid keyEvent
 * effects: a command associated with [ev] is sent to the client
 * Notes: TODO
 *)
let send_movement ev : unit = 
  let keydirection = match ev##keyCode with 
    | 37 -> State.Go State.Left
    | 38 -> State.Go State.Up
    | 39 -> State.Go State.Right
    | 40 -> State.Go State.Down
    | 90 -> State.Take
    | 88 -> State.Drop "item1"
    | _ -> failwith "Unimplemented"
  in 
    ignore "send message to client TODO"

(**
 * Helper method to update the GUI based on log 
 *
 * requires: gametable is a valid table and chatArea is a valid chatArea
 * effects: redraws the GUI based on [log]
 *)
let rec update_gui gametable chatArea divNode (log : State.log') : unit = 
  re_draw_whole gametable log;
  receive_message chatArea log;
  redraw_inv_log log;
  if bool_opt log.cutscene then 
    begin 
      isCutscreen := true;
      gametbl := gametable;
      toCutscene divNode;
      cutscene := access_opt log.cutscene;
      nextScene divNode;
      document##onkeydown <- Html.handler (fun ev -> nextSceneHandler divNode ev; Js.bool true)
    end
  else 
    ()

and nextScene divNode : unit = 
  let values = Cutscene.read !cutscene in 
  cutscene := (fst values);
  match (snd values) with 
    | None -> isCutscreen := false; fromCutscene divNode !gametbl; document##onkeydown <- Html.handler (fun ev -> 
              send_movement_temp gametable chatscreen emptystate gamediv ev; Js.bool true)
    | Some (x, y) -> 
      let img = Html.createImg document in 
        img##onload <- Html.handler (fun _ -> cutscene_context##drawImage(img, 0.0, 0.0); Js.bool true);
        img##src <- js (x ^ ".png")

and nextSceneHandler divNode ev : unit = 
    match ev##keyCode with 
    | 32 -> nextScene divNode
    | _ -> Html.stopPropagation ev

(* Start temporary stuff for prototype working without client/server *)
(* Temporary method to send a movement command and have something happen no client/server *)
and send_movement_temp tbl chat state  divNode ev : unit = 
  match key_direction ev with 
  | Some c -> update_gui tbl chat divNode (fst (State.do_command 1 c state))
  | None -> ()

(* Temporary method to send a text command and have something happen no client/server *)
and send_message_temp tbl chat state input divNode ev : unit = 
  match ev##keyCode with 
  | 13 -> let c = State.Message (Js.to_string input##value) in 
          input##value <- js "";
          update_gui tbl chat divNode (fst (State.do_command 1 c state))
  | _ -> Html.stopPropagation ev


(* example log test case for GUI*)
let (emptytile : State.tile) = {ch = None; mov = None; 
  store = None; immov = None; ex = None; kl = None; rt = None}

let (log1 : State.log') = {room_id = "example"; rows = 2; cols = 2; 
  change = [{row = 0; col = 0; newtile = emptytile}; 
    {row = 1; col = 0; newtile = emptytile};
  {row = 0; col = 1; newtile = emptytile}; 
    {row = 1; col = 1; newtile = emptytile}]; 
  inv_change = {add = None; remove = None};
  chat = Some {id = 1; message = "hi"};
  cutscene = None}

let (player1tile : State.tile) = {ch = Some {id = 1; direction = State.Up}; 
  mov = None; store = None; immov = None; ex = None; kl = None; rt = None}
let (player2tile : State.tile) = {ch = Some {id = 2; direction = State.Up}; 
  mov = None; store = None; immov = None; ex = None; kl = None; rt = None}

let get_emptytile () : State.tile = {ch = None; mov = None; 
  store = None; immov = None; ex = None; kl = None; rt = None}

let (itemtile : State.tile) = {ch = None; mov = None; 
  store = Some {id = "item1"}; immov = None; ex = None; kl = None; rt = None}

let (itemtile2 : State.tile) = {ch = None; mov = None; 
store = Some {id = "item2"}; immov = None; ex = None; kl = None; rt = None}

let (itemtile3 : State.tile) = {ch = None; mov = None; 
store = Some {id = "item3"}; immov = None; ex = None; kl = None; rt = None}

let (itemtile4 : State.tile) = {ch = None; mov = None; 
store = Some {id = "item4"}; immov = None; ex = None; kl = None; rt = None}

let (itemtile5 : State.tile) = {ch = None; mov = None; 
store = Some {id = "item5"}; immov = None; ex = None; kl = None; rt = None}

let (movtile : State.tile) = {ch = None; mov = Some {id = "mov1"}; immov = None; 
  store = None; ex = None; kl = None; rt = None}

let (kltile : State.tile) = {ch = None; mov = None; immov = None;
  store = None; ex = None; kl = Some {id = "kl1"; key = "item1"; 
    is_solved = false; exit_effect = [("room1", 7, 6)]; immovable_effect = [
      ("room1", 6, 6); ("room1", 8, 5); ("room1", 7, 5); ("room1", 6, 5)
    ]}; rt = None}

let samplecutscene = Cutscene.create ["sprites/test"] ["hi"]

let (exittile1: State.tile) = {ch = None; mov = None; immov = None;
  store = None; ex = Some {id = "exit"; is_open = false; to_room = ("room2", 0, 0); cscene = Some samplecutscene}; kl = None;
  rt = None}

let (exittile2 : State.tile) = {ch = None; mov = None; immov = None;
  store = None; ex = Some {id = "exit"; is_open = true; to_room = ("room1", 9, 0); cscene = None}; kl = None;
  rt = None}

let (movtile2 : State.tile) = {ch = None; mov = Some {id = "mov1"}; immov = None; 
  store = None; ex = None; kl = None; rt = None}

let createwalltile () : State.tile = {ch = None; mov = None; immov = Some {id = "wall"};
  store = None; ex = None; kl = None; rt = None}

let (rotatetile : State.tile) = {ch = None; mov = None; immov = None; store = None;
  ex = None; kl = None; rt = Some {id = "rotate"; rotate = State.Right; correct = State.Down; 
  exit_effect = [("room1", 7, 6)]; immovable_effect = [
    ("room1", 6, 6); ("room1", 8, 5); ("room1", 7, 5); ("room1", 6, 5)
  ]}}

let (room1 : State.room) = {
  id = "room1"; 
  tiles = (let arr = Array.make_matrix 10 10 emptytile in 
    for y = 0 to 9 do
      for x = 0 to 9 do
        arr.(y).(x) <- get_emptytile ()
      done
    done;
    arr.(0).(0) <- player1tile;
    arr.(4).(4) <- player2tile;
    arr.(2).(2) <- itemtile;
    arr.(3).(3) <- movtile;
    arr.(2).(1) <- kltile;
    arr.(6).(7) <- exittile1;
    arr.(5).(8) <- createwalltile ();
    arr.(5).(7) <- createwalltile ();
    arr.(5).(6) <- createwalltile ();
    arr.(6).(6) <- createwalltile ();
    arr.(6).(8) <- createwalltile ();
    arr.(7).(8) <- createwalltile ();
    arr.(7).(7) <- createwalltile ();
    arr.(7).(6) <- createwalltile ();
    arr.(1).(2) <- itemtile2;
    arr.(7).(1) <- itemtile3;
    arr.(7).(2) <- itemtile4;
    arr.(8).(1) <- itemtile5;
    arr.(5).(5) <- rotatetile;
    arr);
  rows = 10; 
  cols = 10
}

let (room2 : State.room) = {
  id = "room2";
  tiles = (let arr = Array.make_matrix 20 20 emptytile in 
  for y = 0 to 19 do
    for x = 0 to 19 do
      arr.(y).(x) <- get_emptytile ()
    done
  done;
  arr.(10).(10) <- exittile2;
  arr.(5).(5) <- movtile2;
  arr);
  rows = 20;
  cols = 20
}

(* example states*)
let (emptystate : State.t) = {
  roommap = (let map = (Hashtbl.create 1) in 
    Hashtbl.add map "room1" room1; 
    Hashtbl.add map "room2" room2;
    map);
  pl1_loc = ("room1", 0, 0);
  pl2_loc = ("room1", 4, 4);
  pl1_inv = [];
  pl2_inv = [];
  chat = []
}

(* end temporary stuff *) 

(* Main method to start the javascript *)
let start () = 
  cutscene_canvas##width <- 1000;
  cutscene_canvas##height <- 500;

  let body = Js.Opt.get (document##getElementById (js "body")) fail in
  
  let gamediv = Html.createDiv document in 
    gamediv##style##cssText <- js "margin-bottom:20px;";

  let gametable = Html.createTable document in 
    gametable##style##cssText <- js 
    "border-collapse:collapse;line-height: 0; opacity: 1; \
    margin-left:auto; margin-right:auto; background-color: #F0F8FF; tabindex= 1 ";

  let invdiv = Html.createDiv document in 
    invdiv##style##cssText <- js "margin-bottom:20px;";
  
  let invtable = Html.createTable document in 
    invtable##style##cssText <- js 
    "border-collapse:collapse;line-height: 0; opacity: 1; \
    margin-left:auto; margin-right:auto; background-color: black; tabindex= 1 ";
  let larrow = Html.createImg document in larrow##src <- js "sprites/larrow.png";
  larrow##onclick <- Html.handler (fun _ -> clickleft (); Js.bool true);
  let rarrow = Html.createImg document in rarrow##src <- js "sprites/rarrow.png"; 
  rarrow##onclick <- Html.handler (fun _ -> clickright (); Js.bool true); 
  let tr = invtable##insertRow (-1) in 
  for x = 1 to 5 do 
    let td = tr##insertCell (-1) in
    td##style##cssText <- td_style;
    Dom.appendChild tr td;
    let image = (match x with 
     | 1 -> larrow
     | 2 -> inv1
     | 3 -> td##style##cssText <- js "padding: 0; width: 20px; height: 20px; background-color: white"; inv2
     | 4 -> inv3 
     | 5 -> rarrow) in 
      Dom.appendChild td image;
  done;
  redraw_inv ();

  invtable##style##opacity <- Js.def (js "1");
  
  let chatdiv = Html.createDiv document in 

  let chatscreen = Html.createTextarea document in 
    chatscreen##defaultValue <- js 
      "This is your chat box, use it to talk with the other person!\n";
    chatscreen##cols <- 49;
    chatscreen##rows <- 10;
    chatscreen##readOnly <- Js.bool true;
    chatscreen##style##cssText <- js "resize: none";

  update_gui gametable chatscreen gamediv (State.logify 1 emptystate);

  let chatinput = Html.createInput document in
    chatinput##defaultValue <- js "";
    chatinput##size <- 50;
    chatinput##onkeydown <- Html.handler (fun ev -> 
      send_message_temp gametable chatscreen emptystate chatinput gamediv ev; Js.bool true);

  let chatinputdiv = Html.createDiv document in 
    Dom.appendChild chatinputdiv chatinput;

  let chatoutputdiv = Html.createDiv document in 
    Dom.appendChild chatoutputdiv chatscreen;

  document##onkeydown <- Html.handler (fun ev -> 
    send_movement_temp gametable chatscreen emptystate gamediv ev; Js.bool true);

  Dom.appendChild gamediv gametable;
  Dom.appendChild chatdiv chatoutputdiv;
  Dom.appendChild chatdiv chatinputdiv;
  Dom.appendChild invdiv invtable;
  body##style##cssText <- js "font-family: 
    sans-serif; text-align: center; background-color: #e8e8e8;";
  Dom.appendChild body gamediv;
  Dom.appendChild body invdiv;
  Dom.appendChild body chatdiv

let _ = start ()
