open Js_of_ocaml
open Js_of_ocaml_lwt

module Html = Dom_html
let js = Js.string
let document = Html.document


let fail = fun _ -> assert false

let main () = 
  let gui = Js.Opt.get (Html.document##getElementById (js "gui")) fail in 
    let canvas = Html.createCanvas document in
    canvas##width <- 1000;
    canvas##height <- 1000;
    Dom.appendChild gui canvas;
    let context = canvas##getContext (Html._2d_) in
      let img = Html.createImg document in
      img##src <- js "cat.png";
      context##drawImage ((img), (500.), (500.))

let _ = main ()