open Js_of_ocaml
open Js_of_ocaml_lwt

module Html = Dom_html
let js = Js.string
let document = Html.document

let fail = fun _ -> assert false

type location = {x : int ref; y : int ref}

let load_association_sprites = 
  failwith "Create the document"

let match_name name = 
  failwith "Create the document and we can do this"

let replace_child p n =
  Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
  Dom.appendChild p n

let re_draw_whole gtbl state.log 

let start _ = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in
  
  let gamediv = Html.createDiv document in 
    gamediv##style##cssText <- js "margin-bottom:20px;";