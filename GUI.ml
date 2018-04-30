open Js_of_ocaml
open Js_of_ocaml_lwt

module Html = Dom_html
let js = Js.string
let document = Html.document

let fail = fun _ -> assert false

type location = {x : int ref; y : int ref}

let start () = 
  let body = Js.Opt.get (document##getElementById (js"body")) fail in 

    let div = Html.createDiv document in 
    div##style##cssText <- js "margin-bottom:20px;";

    let td_style = js"padding: 0; width: 20px; height: 20px;" in

    let replace_child p n =
    Js.Opt.iter (p##firstChild) (fun c -> Dom.removeChild p c);
    Dom.appendChild p n in

    let gametable = Html.createTable document in
      gametable##style##cssText <- js "border-collapse:collapse;line-height: 0; opacity: 1; \
                                      margin-left:auto; margin-right:auto; background-color: black; tabindex= 1 ";
      for y = 0 to 10 do
        let tr = gametable##insertRow (-1) in
        for x = 0 to 24 do
          let td = tr##insertCell (-1) in
          td##style##cssText <- td_style;
          let img = Html.createImg document in
          begin match x mod 2 with 
          | 0 -> img##src <- js "sprites/boulder.png" 
          | _ -> img##src <- js "sprites/grass.png"
          end;
          Dom.appendChild td img;
          Dom.appendChild tr td
        done ;
        Dom.appendChild gametable tr
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

    let input = Html.createInput document in 
    input##defaultValue <- js "";
    input##size <- 50;
    let enterhandler = (fun ev ->  
    match ev##keyCode with 
    13 ->  textArea##value <- (textArea##value)##concat_3((js "\n"),(input##value),(js "\n"));
            textArea##scrollTop <- textArea##scrollHeight;
            input##value <- js ""
    | _ -> ()) in
    input##onkeydown <- Html.handler (fun ev -> enterhandler ev; Js.bool true);

    let currentloc = {x = ref 0; y = ref 0} in

    let gamehandler = (fun ev -> 
    (match ev##keyCode with 
    32 -> let row = Js.Opt.get (gametable##rows##item(!(currentloc.y))) fail in 
          let elt = Js.Opt.get (row##cells##item(!(currentloc.x))) fail in 
          let tempimg = Js.Opt.get (elt##firstChild) fail in 
          elt##removeChild(tempimg);
          let img = Html.createImg document in 
            (if (!(currentloc.x) mod 2) = 0 then 
              img##src <- js "sprites/grass.png"
            else img##src <- js "sprites/boulder.png"); 
            Dom.appendChild elt img;
            currentloc.x := !(currentloc.x) + 1; 
            if !(currentloc.x) = 25 then (currentloc.y := !(currentloc.y) + 1; currentloc.x := 0) else ()
    | _ -> ()); Js.bool true) in 
    document##onkeydown <- Html.handler gamehandler;

    let inputdiv = Html.createDiv document in 
    let outputdiv = Html.createDiv document in 
    Dom.appendChild inputdiv input;
    Dom.appendChild outputdiv textArea;
    Dom.appendChild div gametable;
    Dom.appendChild chat outputdiv;
    Dom.appendChild chat inputdiv;
    (*chat##style##cssText <- js "float : left;";*)
    Dom.appendChild div2 chat;
    body##style##cssText <- js"font-family: sans-serif; text-align: center; background-color: #e8e8e8;";
    Dom.appendChild body div;
    Dom.appendChild body div2

let _ = start ()