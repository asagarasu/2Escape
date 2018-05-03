open Js_of_ocaml
open Js_of_ocaml_lwt
open Helper 

module Html = Dom_html
let js = Js.string
let document = Html.document

(* Helper function to offer alternative if element isn't found *)
let fail = fun _ -> assert false

let td_style = js"padding: 0; width: 20px; height: 20px;"

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
  if bool_opt tile.immov = true then (access_opt tile.immov).id  else
  if bool_opt tile.ex = true then 
    let is_open = (access_opt tile.ex).is_open in 
    (if is_open then "exitopen" else "exitclosed") else
  "empty"

(**
 * Matches the name of a string to the img sprite
 * 
 * requires: [name] is a valid sprite
 * returns: an image string to be drawn
 *)
let match_name (name : string) : Js.js_string Js.t = 
  js ("sprites/" ^ name ^ ".png")

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
 * Helper method to update the GUI based on log 
 *
 * requires: gametable is a valid table and chatArea is a valid chatArea
 * effects: redraws the GUI based on [log]
 *)
let update_gui gametable chatArea (log : State.log') : unit = 
  re_draw_whole gametable log;
  receive_message chatArea log

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
  | 88 -> Some (State.Drop "item1")
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

(* Start temporary stuff for prototype working without client/server *)
(* Temporary method to send a movement command and have something happen no client/server *)
let send_movement_temp tbl chat state ev : unit = 
  match key_direction ev with 
  | Some c -> update_gui tbl chat (fst (State.do_command 1 c state))
  | None -> ()

(* Temporary method to send a text command and have something happen no client/server *)
let send_message_temp tbl chat state input ev : unit = 
  match ev##keyCode with 
  | 13 -> let c = State.Message (Js.to_string input##value) in 
          input##value <- js "";
          update_gui tbl chat (fst (State.do_command 1 c state))
  | _ -> Html.stopPropagation ev

(* example log test case for GUI*)
let (emptytile : State.tile) = {ch = None; mov = None; 
  store = None; immov = None; ex = None; kl = None}

let (log1 : State.log') = {room_id = "example"; rows = 2; cols = 2; 
  change = [{row = 0; col = 0; newtile = emptytile}; 
    {row = 1; col = 0; newtile = emptytile};
  {row = 0; col = 1; newtile = emptytile}; 
    {row = 1; col = 1; newtile = emptytile}]; 
  inv_change = {add = []; remove = []};
  chat = Some {id = 1; message = "hi"}}

let (player1tile : State.tile) = {ch = Some {id = 1; direction = State.Up}; 
  mov = None; store = None; immov = None; ex = None; kl = None}
let (player2tile : State.tile) = {ch = Some {id = 2; direction = State.Up}; 
  mov = None; store = None; immov = None; ex = None; kl = None}

let get_emptytile () : State.tile = {ch = None; mov = None; 
  store = None; immov = None; ex = None; kl = None}

let (itemtile : State.tile) = {ch = None; mov = None; 
  store = Some {id = "item1"}; immov = None; ex = None; kl = None}

let (movtile : State.tile) = {ch = None; mov = Some {id = "mov1"}; immov = None; 
  store = None; ex = None; kl = None}

let (kltile : State.tile) = {ch = None; mov = None; immov = None;
  store = None; ex = None; kl = Some {id = "kl1"; key = "item1"; 
    is_solved = false; exit_effect = [("room1", 7, 6)]; immovable_effect = []}}

let (exittile: State.tile) = {ch = None; mov = None; immov = None;
  store = None; ex = Some {is_open = false; to_room = ("room1", 9, 0)}; kl = None}

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
    arr.(6).(7) <- exittile;
    arr);
  rows = 10; 
  cols = 10
}

(* example states*)
let (emptystate : State.t) = {
  roommap = (let map = (Hashtbl.create 1) in Hashtbl.add map "room1" room1; map);
  pl1_loc = ("room1", 0, 0);
  pl2_loc = ("room1", 4, 4);
  pl1_inv = [];
  pl2_inv = [];
  chat = []
}

(* end temporary stuff *)

(* Main method to start the javascript *)
let start () = 
  let body = Js.Opt.get (document##getElementById (js "body")) fail in
  
  let gamediv = Html.createDiv document in 
    gamediv##style##cssText <- js "margin-bottom:20px;";

  let gametable = Html.createTable document in 
    gametable##style##cssText <- js 
    "border-collapse:collapse;line-height: 0; opacity: 1; \
    margin-left:auto; margin-right:auto; background-color: yellow; tabindex= 1 ";
  
  let chatdiv = Html.createDiv document in 

  let chatscreen = Html.createTextarea document in 
    chatscreen##defaultValue <- js 
      "This is your chat box, use it to talk with the other person!\n";
    chatscreen##cols <- 49;
    chatscreen##rows <- 10;
    chatscreen##readOnly <- Js.bool true;
    chatscreen##style##cssText <- js "resize: none";

  update_gui gametable chatscreen (State.logify 1 emptystate);

  let chatinput = Html.createInput document in
    chatinput##defaultValue <- js "";
    chatinput##size <- 50;
    chatinput##onkeydown <- Html.handler (fun ev -> 
      send_message_temp gametable chatscreen emptystate chatinput ev; Js.bool true);

  let chatinputdiv = Html.createDiv document in 
    Dom.appendChild chatinputdiv chatinput;

  let chatoutputdiv = Html.createDiv document in 
    Dom.appendChild chatoutputdiv chatscreen;

  document##onkeydown <- Html.handler (fun ev -> 
    send_movement_temp gametable chatscreen emptystate ev; Js.bool true);

  Dom.appendChild gamediv gametable;
  Dom.appendChild chatdiv chatoutputdiv;
  Dom.appendChild chatdiv chatinputdiv;
  body##style##cssText <- js "font-family: 
    sans-serif; text-align: center; background-color: #e8e8e8;";
  Dom.appendChild body gamediv;
  Dom.appendChild body chatdiv

let _ = start ()
