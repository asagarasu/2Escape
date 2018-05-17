open Js_of_ocaml
open Js_of_ocaml_lwt
open Helper 

module Html = Dom_html
module Sock = WebSockets

let js = Js.string

let document = Html.document

(* Helper function to offer alternative if element isn't found *)
let fail = fun _ -> assert false

(* Instantiate all GUI parts*)
let body = Js.Opt.get (document##getElementById (js "body")) fail

let gamediv = Html.createDiv document

let gametable = Html.createTable document

let invdiv = Html.createDiv document

let chatdiv = Html.createDiv document

let invtable = Html.createTable document

let chatscreen = Html.createTextarea document

let chatinput = Html.createInput document

let chatinputdiv = Html.createDiv document

let chatoutputdiv = Html.createDiv document

let (cutscene : Cutscene.t ref) = ref Cutscene.empty

let cutscene_canvas = Html.createCanvas document

let cutscene_context = cutscene_canvas##getContext(Html._2d_)

let inv1 = Html.createImg document 

let inv2 = Html.createImg document 

let inv3 = Html.createImg document

let inventory : string list ref = ref []

let startloc = ref 0

let websocket = ref (jsnew Sock.webSocket (js "ws:someshit"))

let inputIP = access_opt (Html.getElementById_coerce "inputIP" Html.CoerceTo.input)

let inputPlayerID = access_opt (Html.getElementById_coerce "inputPlayerID" Html.CoerceTo.input)

let enterButton = access_opt (Html.getElementById_coerce "enterButton" Html.CoerceTo.button)

let startButton = access_opt (Html.getElementById_coerce "startButton" Html.CoerceTo.button)

let startDiv = Js.Opt.get (document##getElementById (js "startDiv")) fail

let id = ref 0

(*End creating all GUI/HTML  parts*)

(*Various helper functions at a high level *)
let td_style = js"padding: 0; width: 20px; height: 20px;"

let string_of_direction (dir : State.direction) : string = 
  match dir with 
  | Up -> "up"
  | Down -> "down"
  | Left -> "left"
  | Right -> "right"

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

(*End various helper functions *)

(*Start functions for interacting with GUI*)

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
    ^ string_of_int (access_opt tile.ch).id  
    ^ "/" ^ string_of_direction (access_opt tile.ch).direction
    else
  if bool_opt tile.kl = true then (access_opt tile.kl).id 
    ^ "/" ^ string_of_bool (access_opt tile.kl).is_solved else
  if bool_opt tile.mov = true then (access_opt tile.mov).id else
  if bool_opt tile.store = true then (access_opt tile.store).id else
  if bool_opt tile.rt = true then (access_opt tile.rt).id ^  "/" 
    ^ string_of_direction (access_opt tile.rt).rotate else 
  if bool_opt tile.immov = true then (access_opt tile.immov).id  else
  if bool_opt tile.ex = true then 
    let is_open = (access_opt tile.ex).is_open in 
    (if is_open then (access_opt tile.ex).id ^ "/open" else (access_opt tile.ex).id ^ "/closed") else
  "empty"

(**
 * Matches the name of a string to the img sprite
 * 
 * requires: [name] is a valid sprite
 * returns: an image string to be drawn
 *)
let match_name (name : string) : Js.js_string Js.t = 
  js ("sprites/" ^ name ^ ".png")

(*Helper function to redraw the inventory *)
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
  
(* Helper function to click right in inventory *)
let clickright _ : unit = 
  if !startloc = 0 then () 
  else startloc := !startloc - 1; redraw_inv ()

(* Helper function to click left in inventory *)
let clickleft _ : unit = 
  if !startloc = List.length (!inventory) - 1 then ()
  else startloc := !startloc + 1; redraw_inv ()

(* Function to redraw the inventory based on a log *)
let redraw_inv_log (log : State.log') : unit = 
    if List.length log.inv_change.add > 0 then 
      begin
        if List.mem (List.nth log.inv_change.add 0) !inventory then
          ()
        else 
          begin
            (if List.length !inventory > 0 then startloc := !startloc + List.length log.inv_change.add else ());
            inventory := log.inv_change.add @ !inventory;
            redraw_inv ()
          end
      end
    else if List.length log.inv_change.remove > 0 then 
      begin
        let removeditem = (List.nth log.inv_change.remove 0) in 
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
 * Reassigns a picture in [tbl] to the new picture in [entry]
 *
 * requires : [entry] has [row] and [col] within the bounds for [tbl]
 * returns : unit ()
 * effects : [tbl]'s picture is redrawn (if precondition is met)
 *)
let replace_table_elt (entry : State.entry) : unit = 
  let row = Js.Opt.get gametable##rows##item(entry.row) fail in 
  let elt = Js.Opt.get row##cells##item(entry.col) fail in 
    elt##style##backgroundImage <- js ("url(sprites/empty.png)");
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
let re_draw_whole (log : State.log') : unit =  
  gametable##style##opacity <- Js.def (js "0");
  let tbl_rows = gametable##rows##length in
  let tbl_cols = if tbl_rows = 0 then 0 else
    (Js.Opt.get (gametable##rows##item(0)) fail)##cells##length in 
  
  if tbl_rows = log.rows && tbl_cols = log.cols then 
  List.iter (replace_table_elt) log.change
  else 
    begin
      for i = 1 to tbl_rows 
        do 
          gametable##deleteRow(0)
        done;
      for y = 1 to log.rows do
        let tr = gametable##insertRow (-1) in
          for x = 1 to log.cols do 
            let td = tr##insertCell (-1) in
            td##style##cssText <- td_style;
            Dom.appendChild tr td
          done;
          Dom.appendChild gametable tr
        done;
        List.iter (replace_table_elt) log.change
    end;
    gametable##style##opacity <- Js.def (js "1")

let toCutscene () : unit = 
  replace_child gamediv cutscene_canvas

let fromCutscene () : unit = 
  replace_child gamediv gametable

(**
 * Helper method to update chat based on log 
 * 
 * requires: [chatArea] is a [Js.textArea Js.t] that has the chat
 *           [log] is a valid [State.log']
 * effects: the chat is in [log] is appended to [chatArea]
 *)
  let receive_message (log : State.log') : unit = 
    match log.chat with 
    | Some message -> chatscreen##value 
        <- chatscreen##value##concat(js ("\nPlayer" ^ string_of_int message.id 
          ^ " : " ^ message.message));
        chatscreen##scrollTop <- chatscreen##scrollHeight; ()
    | None -> ()

(**
 * Helper method send a message command 
 *
 * requires: input is a valid textInput, ev is a valid event
 * effects: sends a message with the info in [input] to the client
            if key is enter key. Otherwise event is ignored
 * notes: TODO
 *)
let send_message ev : unit =
   match ev##keyCode with 
    | 13 -> let command = State.Message (Js.to_string chatinput##value) in 
            chatinput##value <- js "";
            !websocket##send (js (Yojson.Basic.to_string 
              (Json_parser.tojsonsentcommand {id = !id; command = command})))
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
 *)
let send_movement ev : unit = 
  let keydirection = key_direction ev
  in 
    match keydirection with 
    | None -> ()
    | Some command -> !websocket##send 
      (js (Yojson.Basic.to_string (Json_parser.tojsonsentcommand {id = !id; command = command})))

(**
 * Helper method to update the GUI based on log 
 *
 * requires: gametable is a valid table and chatArea is a valid chatArea
 * effects: redraws the GUI based on [log]
 *)
let update_gui (log : State.log') : unit = 
  re_draw_whole log;
  receive_message log;
  redraw_inv_log log

let nextScene () : unit = 
  let values = Cutscene.read !cutscene in 
  cutscene := (fst values);
  match (snd values) with 
    | None -> fromCutscene (); 
              document##onkeydown <- Html.handler (fun ev -> send_movement ev; Js.bool true)
    | Some (x, y) -> 
      let img = Html.createImg document in  
        cutscene_context##clearRect(0.0, 0.0, float_of_int cutscene_canvas##width, float_of_int cutscene_canvas##height);
        img##onload <- Html.handler (fun _ -> cutscene_context##drawImage(img, 0.0, 0.0); Js.bool true);
        img##src <- match_name x

let nextSceneHandler ev : unit = 
    match ev##keyCode with 
    | 32 -> nextScene ()
    | _ -> Html.stopPropagation ev

let recieve_log (log : State.log') : unit = 
  update_gui log; 
  if bool_opt log.cutscene then 
    begin 
      Dom.removeChild gamediv gametable;
      toCutscene ();
      cutscene := access_opt log.cutscene;
      nextScene ();
      document##onkeydown <- Html.handler (fun ev -> nextSceneHandler ev; Js.bool true)
    end
  else 
    ()

let instantiate_game () : unit = 
  Dom.appendChild chatinputdiv chatinput;

  Dom.appendChild chatoutputdiv chatscreen;

  document##onkeydown <- Html.handler (fun ev -> 
    send_movement ev; Js.bool true);

  Dom.appendChild gamediv gametable;
  Dom.appendChild chatdiv chatoutputdiv;
  Dom.appendChild chatdiv chatinputdiv;
  Dom.appendChild invdiv invtable;
  Dom.removeChild body startDiv;
  Dom.appendChild body gamediv;
  Dom.appendChild body invdiv;
  Dom.appendChild body chatdiv

let send_init () : unit = 
  !websocket##send (js "init")

(* Main method to start the javascript *)
let start () = 
  Dom.removeChild startDiv startButton;
  cutscene_canvas##width <- 1000;
  cutscene_canvas##height <- 550;

  enterButton##onclick <- Html.handler (
    fun ev ->  
    if Js.to_string inputPlayerID##value <> "1" && Js.to_string inputPlayerID##value <> "2" then 
      begin
        Js.bool true
      end
    else 
      begin
        id := int_of_string (Js.to_string inputPlayerID##value);
        websocket := jsnew Sock.webSocket (inputIP##value);
        !websocket##onmessage <- Dom.handler (fun message -> 
          let parsedlogs = Json_parser.parsepairlog (Yojson.Basic.from_string (Js.to_string message##data)) in 
          if !id = 1 then recieve_log parsedlogs.first else recieve_log parsedlogs.second; 
          Js.bool true
          );
        inputPlayerID##readOnly <- Js.bool true;
        inputPlayerID##placeholder <- inputPlayerID##value;
        inputPlayerID##value <- js "";
        inputIP##readOnly <- Js.bool true;
        inputIP##placeholder <- inputIP##value;
        inputIP##value <- js "";
        startButton##onclick <- Html.handler (
          fun ev -> instantiate_game ();
          send_init ();
          Js.bool true
        );
        Dom.removeChild startDiv enterButton;
        Dom.appendChild startDiv startButton;
        Js.bool true
      end
  );

  body##style##cssText <- js "font-family: 
    sans-serif; text-align: center; background-image: url(sprites/opening.png);";
  gamediv##style##cssText <- js "margin-bottom:20px;";
  gametable##style##cssText <- js 
    "border-collapse:collapse;line-height: 0; opacity: 1; \
    margin-left:auto; margin-right:auto; background-color: #F0F8FF; tabindex= 1 ";

  invdiv##style##cssText <- js "margin-bottom:20px;";
   
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
     | 3 -> td##style##cssText <- js "padding: 0; width: 20px; height: 20px; background-color: black"; inv2
     | 4 -> inv3 
     | 5 -> rarrow) in 
      Dom.appendChild td image;
  done;
  redraw_inv ();

  invtable##style##opacity <- Js.def (js "1"); 
 
  chatscreen##defaultValue <- js ("This is your chat box, use it to talk with the other person!\n" ^
    "\nControls: z for picking up items, x for dropping them, space for entering exits and cutscenes!\n");
  chatscreen##cols <- 49;
  chatscreen##rows <- 10;
  chatscreen##readOnly <- Js.bool true;
  chatscreen##style##cssText <- js "resize: none";

  chatinput##defaultValue <- js "";
  chatinput##size <- 50;
  chatinput##onkeydown <- Html.handler (fun ev -> 
    send_message ev; Js.bool true);
  
  startDiv##style##backgroundImage <- js ("url(sprites/opening.png)");
  startDiv##style##backgroundRepeat <- js "no-repeat";
  startDiv##style##backgroundPosition <- js "center top";
  startDiv##style##height <- js "100%"


let _ = start ()
