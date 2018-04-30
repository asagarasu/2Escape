open Js_of_ocaml
open Js_of_ocaml_lwt

open Helper 

module Html = Dom_html
let js = Js.string
let document = Html.document

let fail = fun _ -> assert false

type location = {x : int ref; y : int ref}

let load_association_sprites = 
  failwith "Create the document"

(* Gets the image to show from a tile *)
let get_dominant (tile: State.tile) : string = 
  if bool_opt tile.ch = true then "player " ^ string_of_int (access_opt tile.ch).id else
  if bool_opt tile.mov = true then (access_opt tile.mov).id else
  if bool_opt tile.store = true then (access_opt tile.store).id else
  if bool_opt tile.immov = true then (access_opt tile.immov).id else
  if bool_opt tile.ex = true then 
    let is_open = (access_opt tile.ex).is_open in 
    (if is_open then "exit open" else "exit closed") else
  if bool_opt tile.kl = true then (access_opt tile.kl).id else
  "empty"

(* Matches the name to a sprite *)
let match_name (name : string) : Js.js_string Js.t = 
  js ("sprites/" ^ name ^ ".png")

(* Helper method to replace the child of a parent *)
let replace_child p n =
  Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
  Dom.appendChild p n

(* Replaces the table element based on an entry *)
let replace_table_elt tbl (entry : State.entry) : unit = 
  let row = Js.Opt.get tbl##rows##item(entry.row) fail in 
  let elt = Js.Opt.get row##cells##item(entry.col) fail in 
  let img = Html.createImg document in 
    img##src <- match_name (get_dominant entry.newtile);
    replace_child elt img

let td_style = js"padding: 0; width: 20px; height: 20px;"

(* Redraws the whold table based on a log *)
let re_draw_whole tbl (log : State.log) : unit =  
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
    end

(* Helper method to update chat based on log *)
  let receive_message chatArea (log : State.log) : unit = 
    match log.chat with 
    | Some message -> chatArea##value <- chatArea##value##concat(js ("\nPlayer" ^ string_of_int message.id ^ " : " ^ message.message));
                      chatArea##scrollTop <- chatArea##scrollHeight;
    | None -> ()

(* Helper method to update the GUI based on log *)
let update_gui gametable chatArea (log : State.log) : unit = 
  re_draw_whole gametable log;
  receive_message chatArea log

(* Helper method send a string command *)
let send_message input ev : unit = match ev##keyCode with 
    | 13 -> let command = State.Message (Js.to_string input##value) in 
            input##value <- js "";
            failwith "Send Message to client TODO"
    | _ -> ()

(* Helper method to send a movement command*)
let send_movement ev : unit = 
  let keydirection = match ev##keyCode with 
    | 37 -> State.Go State.Left
    | 38 -> State.Go State.Up
    | 39 -> State.Go State.Right
    | 40 -> State.Go State.Down
  in 
    failwith "Send Movement to client TODO"

(* Start method *)
let start _ = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in
  
  let gamediv = Html.createDiv document in 
    gamediv##style##cssText <- js "margin-bottom:20px;";

  let gametable = Html.createTable document in 
    gametable##style##cssText <- js "border-collapse:collapse;line-height: 0; opacity: 1; \
    margin-left:auto; margin-right:auto; background-color: black; tabindex= 1 ";
  
  let chatdiv = Html.createDiv document in 
    chatdiv##style##cssText <- js "border-collapse:collapse;line-height: 0; opacity: 1; margin: auto;";

  let chatscreen = Html.createTextarea document in 
    chatscreen##defaultValue <- js "This is your chat box, use it to talk with the other person!\n";
    chatscreen##cols <- 49;
    chatscreen##rows <- 10;
    chatscreen##readOnly <- Js.bool true;
    chatscreen##style##cssText <- js "resize: none";

  let chatinput = Html.createInput document in
    chatinput##defaultValue <- js "";
    chatinput##size <- 50;
