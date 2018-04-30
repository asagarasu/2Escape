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

let match_name (name : string) : Js.js_string Js.t = 
  js ("sprites/" ^ name ^ ".png")

let replace_child p n =
  Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
  Dom.appendChild p n

let replace_table_elt document tbl (entry : State.entry) : unit = 
  let row = Js.Opt.get tbl##rows##item(entry.row) fail in 
  let elt = Js.Opt.get row##cells##item(entry.col) fail in 
  let img = Html.createImg document in 
    img##src <- match_name (get_dominant entry.newtile);
    replace_child elt img

let re_draw_whole tbl (log : State.log) : string =  
  failwith "Unimplemented"

let start _ = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in
  
  let gamediv = Html.createDiv document in 
    gamediv##style##cssText <- js "margin-bottom:20px;";