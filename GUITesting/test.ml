open Js_of_ocaml
open Js_of_ocaml_lwt

module Html = Dom_html
let js = Js.string
let document = Html.document

let fail = fun _ -> assert false

let start () = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in 
  
  let div = Html.createDiv document in 
  (*div##style##cssText <- js "";*)

  let style =
    js "border-collapse:collapse;line-height: 0; opacity: 1; margin-left:auto; margin-right:auto; background-color: black" in

  let td_style = js"padding: 0; width: 20px; height: 20px;" in

  let replace_child p n =
    Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
    Dom.appendChild p n in

  let m = Html.createTable document in
    m##style##cssText <- style;
    for y = 0 to 10 do
      let tr = m##insertRow (-1) in
      for x = 0 to 24 do
        let td = tr##insertCell (-1) in
        td##style##cssText <- td_style;
        let img = Html.createImg document in
        img##src <- js "boulder.png";
        Dom.appendChild td img;
        Dom.appendChild tr td
      done ;
      Dom.appendChild m tr
    done;
    Dom.appendChild div m;
    body##style##cssText <- js"font-family: sans-serif; text-align: center; background-color: #e8e8e8;";
    Dom.appendChild body div

let _ = start ()