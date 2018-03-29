val keypress : Dom_html.keyboardEvent Js.t -> bool Js.t

val keylift : Dom_html.keyboardEvent Js.t -> bool Js.t

val mouseclick_down : Dom_html.mouseEvent Js.t -> bool Js.t

val mouseclick_up : Dom_html.mouse_button Js.t -> bool Js.t

val play_game : Dom_html.canvasRenderingContext2D Js.t -> unit()