open Types

type t

type item = Types.storable

type trick = Types.movable

type character = Types.character

type objects = | Item of item | Trick of trick | Character of character

type dirction = | Left | Right | Up | Down

type command =
| Go of dirction
| Take of item
| Drop of item
| Move of trick * dirction

let makeLog p comd =
  let current = (Character.get_canvas_loc p) in
  (match comd with
   | Go a ->
     let update =
       (match a with
        | Left -> (-1,0) | Right -> (1,0)
        | Up -> (0,1)    | Down -> (0,-1)
       )
     in
     [(fst current, snd current, Character p,false);
      (fst update + fst current, snd update + snd current, Character p,true)]
   | Take b -> [(fst current, snd current, Item b, false)]
   | Drop c -> [(fst current, snd current, Item c, true)]
   | Move (d,e) ->
     let trick_current = (Movable.get_canvas_loc d) in
     let update =
       (match e with
        | Left -> (-1,0) | Right -> (1,0)
        | Up -> (0,1)    | Down -> (0,-1)
       )
     in
     [(fst trick_current, snd trick_current, Trick d, false);
      (fst update + fst trick_current,
       snd update + snd trick_current, Trick d, true)]
  )

type log = {
  (* timestamp: int; *)
  row : int;
  rol : int;
  diff : ( int * int * objects * bool ) list;
  text : Types.textMessage
}

module type Log = sig
  type t
  val get_timestamp : t -> int
  val get_row : t -> int
  val get_rol : t -> int
  val get_diff : t -> ( int * int * objects * bool ) list
  val get_text : t -> Types.textMessage
end

module Log = struct
  type t = log
  (* let get_timestamp t = t.timestamp *)
  let get_row t = t.row
  let get_rol t = t.rol
  let get_diff t = t.diff
  let get_text t = t.text
end
