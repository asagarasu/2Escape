open Js_of_ocaml
open Js_of_ocaml_lwt

module Html = Dom_html
let js = Js.string
let document = Html.document

let fail = fun _ -> assert false

let failint = fun _ -> 0

let start () = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in 
  
  let div = Html.createDiv document in 
  div##style##cssText <- js "margin-bottom:20px;";
  (*div##style##cssText <- js "";*)
  (*div##style##cssText <- js "float : left;";*)

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
        begin match x mod 2 with 
        | 0 -> img##src <- js "boulder.png" 
        | _ -> img##src <- js "grass.png"
        end;
        Dom.appendChild td img;
        Dom.appendChild tr td
      done ;
      Dom.appendChild m tr
    done;

    let div2 = Html.createDiv document in 
    div2##style##cssText <- js "border-collapse:collapse;line-height: 0; opacity: 1; margin: auto;";
    let textArea = Html.createTextarea document in 

    let chat = Html.createDiv document in 
    textArea##defaultValue <- js "This is your chat box, use it to talk with the other person!\n";
    textArea##cols <- 49;
    textArea##rows <- 10;
    textArea##readOnly <- Js.bool true;
    textArea##style##cssText <- js "resize: none";

    let input = Html.createInput ~_type: (js "text") ~name: (js "sample") document in 
    input##defaultValue <- js "";
    input##size <- 50;
    let handler1 = (fun ev ->  
    match ev##keyCode with 
    13 ->  textArea##value <- (textArea##value)##concat_3((js "\n"),(input##value),(js "\n"));
           textArea##scrollTop <- textArea##scrollHeight;
           input##value <- js ""
    | _ -> ()) in
    input##onkeydown <- Html.handler (fun ev -> handler1 ev; Js.bool true);

    let inputdiv = Html.createDiv document in 
    let outputdiv = Html.createDiv document in 
    Dom.appendChild inputdiv input;
    Dom.appendChild outputdiv textArea;
    Dom.appendChild div m;
    Dom.appendChild chat outputdiv;
    Dom.appendChild chat inputdiv;
    (*chat##style##cssText <- js "float : left;";*)
    Dom.appendChild div2 chat;
    body##style##cssText <- js"font-family: sans-serif; text-align: center; background-color: #e8e8e8;";
    Dom.appendChild body div;
    Dom.appendChild body div2

let _ = start ()