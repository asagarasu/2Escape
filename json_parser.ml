open Helper
open State
open Yojson.Basic.Util
open Yojson.Basic

type pairlog' = {first : log'; second : log'}

type sentcommand = {id : int; command : command}


let option_map (x : 'a option) (func : 'a -> 'b) : 'b option = 
  match x with 
  | Some y -> Some (func y)
  | None -> None

let parse_string j = 
  match j with `String s -> s
  | _ -> failwith "not a string"

let parsedirection j =
  match j |> parse_string  with
   | "left" -> Left
   | "right" -> Right
   | "up" -> Up
   | "down" -> Down
   | _ -> failwith "json is not a direction" 

let tojsondirection d = 
  match d with 
  | Left -> `String "left"
  | Right -> `String "right"
  | Up -> `String "up"
  | Down -> `String "down"

let parsecommand j = 
  match j |> to_list with
  | `String "go" :: tl :: []-> Go (parsedirection tl)
  | `String "message" :: tl :: [] -> Message (parse_string tl)
  | `String "take" :: [] -> Take
  | `String "drop" :: tl :: [] -> Drop (parse_string tl)
  | `String "enter" :: [] -> Enter
  | _ -> failwith "json is not a command"

let tojsoncommand c = 
  match c with 
  | Go d -> `List [`String "go"; tojsondirection d]
  | Message s -> `List [`String "message"; `String s]
  | Take -> `List [`String "take"]
  | Drop s -> `List [`String "drop"; `String s]
  | Enter -> `List [`String "enter"]

let parsecharacter j : State.character = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  let direction = List.assoc_opt "direction" assoc in 
  match id, direction with 
    | Some a, Some b -> 
        {id = a |> to_int; direction = b |> parsedirection}
    | _ -> failwith "not a character"

let tojsoncharacter (ch : State.character) = 
  `Assoc [("id", `Int ch.id); 
    ("direction", tojsondirection ch.direction)]

let parsemovable j : State.movable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not a movable"

let tojsonmovable (m : State.movable) = 
  `Assoc [("id", `String m.id)]

let parsestorable j : State.storable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not a storable"

let tojsonstorable (st : State.storable) = 
  `Assoc [("id", `String st.id)]

let parseimmovable j : State.immovable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not an immovable"

let tojsonimmovable (im : State.immovable) = 
  `Assoc [("id", `String im.id)]

let parsestringpair l = 
  match l |> to_list with 
    [] -> failwith "not a pair"
    | hd :: [] -> failwith "not a pair"
    | hd :: tl :: [] -> (parse_string hd, parse_string tl)
    | _ -> failwith "not a pair"

let tojsonstringpair (a, b) = 
  `List [`String a; `String b]

let parsecutscene j : Cutscene.t = 
  j |> to_list |> List.map parsestringpair

let tojsoncutscene (c : Cutscene.t) = 
  `List (List.map tojsonstringpair c)

let parseexit j = 
  let assoc = to_assoc j in 
  let id = List.assoc "id" assoc in 
  let is_open = List.assoc "is_open" assoc in 
  let to_room = List.assoc "to_room" assoc in 
  let cscene = List.assoc_opt "cscene" assoc in 
  {
    id = id |> parse_string;
    is_open = is_open |> to_bool;
    to_room = 
    (
      List.nth (to_room |> to_list) 0 |> parse_string,
      List.nth (to_room |> to_list) 1 |> to_int,
      List.nth (to_room |> to_list) 2 |> to_int
    );
    cscene = option_map cscene parsecutscene 
  }

let tojsonexit (e : exit) = 
  if bool_opt e.cscene then 
  `Assoc [
    ("id", `String e.id);
    ("is_open", `Bool e.is_open);
    ("to_room", `List ((fun (a, b, c) -> 
      [`String a; `Int b; `Int c]) e.to_room));
    ("cscene", tojsoncutscene (access_opt e.cscene))
  ] else `Assoc [
    ("id", `String e.id);
    ("is_open", `Bool e.is_open);
    ("to_room", `List ((fun (a, b, c) -> 
      [`String a; `Int b; `Int c]) e.to_room));
  ] 


let parsethree j = 
  match j |> to_list with 
  | f :: s :: t :: [] -> 
    (parse_string f, 
    to_int s,
    to_int t
    )
  | _ -> failwith "Not a triple"

let tojsonthree (a, b, c) = 
  `List [`String a; `Int b; `Int c]

let parselistthree j = 
  j |> to_list |> List.map parsethree

let tojsonlistthree l = 
  `List (l |> List.map tojsonthree)

let parsekeyloc j = 
  let assoc = to_assoc j in 
  let id = List.assoc "id" assoc in 
  let key = List.assoc "key" assoc in 
  let is_solved = List.assoc "is_solved" assoc in 
  let exit_effect = List.assoc "exit_effect" assoc in 
  let immovable_effect = List.assoc "immovable_effect" assoc in 
  {
    id = id |> parse_string;
    key = key |> parse_string;
    is_solved = is_solved |> to_bool;
    exit_effect = exit_effect |> parselistthree;
    immovable_effect = immovable_effect |> parselistthree
  }

let tojsonkeyloc (kl : State.keyloc) = 
  `Assoc [
    ("id", `String kl.id);
    ("key", `String kl.key);
    ("is_solved", `Bool kl.is_solved);
    ("exit_effect", tojsonlistthree kl.exit_effect);
    ("immovable_effect", tojsonlistthree kl.immovable_effect)
  ]

let parserotatable j = 
  let assoc = to_assoc j in 
  let id = List.assoc "id" assoc in 
  let rotate = List.assoc "rotate" assoc in 
  let correct = List.assoc "correct" assoc in 
  let exit_effect = List.assoc "exit_effect" assoc in 
  let immovable_effect = List.assoc "immovable_effect" assoc in 
  {
    id = id |> parse_string;
    rotate = rotate |> parsedirection;
    correct = correct |> parsedirection;
    exit_effect = exit_effect |> parselistthree;
    immovable_effect = immovable_effect |> parselistthree
  }

let tojsonrotatable (rot : rotatable) = 
  `Assoc [
    ("id", `String rot.id);
    ("rotate", tojsondirection rot.rotate);
    ("correct", tojsondirection rot.correct);
    ("exit_effect", tojsonlistthree rot.exit_effect);
    ("immovable_effect", tojsonlistthree rot.immovable_effect)
  ]

let parsetile j = 
  let assoc = to_assoc j in 
  let ch = List.assoc_opt "ch" assoc in 
  let mov = List.assoc_opt "mov" assoc in 
  let store = List.assoc_opt "store" assoc in 
  let immov = List.assoc_opt "immov" assoc in 
  let ex = List.assoc_opt "ex" assoc in 
  let kl = List.assoc_opt "kl" assoc in 
  let rt = List.assoc_opt "rt" assoc in 
  {
    ch = option_map ch parsecharacter;
    mov = option_map mov parsemovable;
    store = option_map store parsestorable;
    immov = option_map immov parseimmovable;
    ex = option_map ex parseexit;
    kl = option_map kl parsekeyloc;
    rt = option_map rt parserotatable
  }

let tojsontile (t : State.tile) = 
  let smallest : (string * json) list ref = ref [] in 
  if bool_opt t.rt then smallest := ("rt",
    tojsonrotatable (access_opt t.rt)) :: !smallest else ();
  if bool_opt t.kl then smallest := ("kl",
    tojsonkeyloc (access_opt t.kl)) :: !smallest else ();
  if bool_opt t.ex then smallest := ("ex",
    tojsonexit (access_opt t.ex)) :: !smallest else ();
  if bool_opt t.immov then smallest := ("immov",
    tojsonimmovable (access_opt t.immov)) :: !smallest else ();
  if bool_opt t.store then smallest := ("store", 
    tojsonstorable (access_opt t.store)) :: !smallest else ();
  if bool_opt t.mov then smallest := ("mov",
    tojsonmovable (access_opt t.mov)) :: !smallest else ();
  if bool_opt t.ch then smallest := ("ch", 
    tojsoncharacter (access_opt t.ch)) :: !smallest else ();
  `Assoc !smallest

let parsemessage j = 
  let assoc = to_assoc j in 
  let id = List.assoc "id" assoc in 
  let message = List.assoc "message" assoc in 
  {
    id = id |> to_int;
    message = message |> parse_string
  }

let tojsonmessage (m : message) = 
  `Assoc[("id", `Int m.id); ("message", `String m.message)]

let parseentry j = 
  let assoc = to_assoc j in 
  let row = List.assoc "row" assoc in 
  let col = List.assoc "col" assoc in 
  let newtile = List.assoc "newtile" assoc in 
  {
    row = row |> to_int;
    col = col |> to_int;
    newtile = newtile |> parsetile
  }

let tojsonentry e = 
  `Assoc[
    ("row", `Int e.row); ("col", `Int e.col); 
    ("newtile", tojsontile e.newtile)
  ]

let parseinvchange j = 
  let assoc = to_assoc j in 
  let add = List.assoc "add" assoc in 
  let remove = List.assoc "remove" assoc in 
  {
    add = add |> to_list |> List.map parse_string;
    remove = remove |> to_list |> List.map parse_string
  }

let tojsoninvchange ic= 
  `Assoc[
    ("add", `List (List.map (fun str -> `String str) ic.add));
    ("remove", `List (List.map (fun str -> `String str) ic.remove))
  ]

let parselog j = 
  let assoc = to_assoc j in 
  let room_id = List.assoc "room_id" assoc in 
  let rows = List.assoc "rows" assoc in 
  let cols = List.assoc "cols" assoc in 
  let change = List.assoc "change" assoc in 
  let inv_change = List.assoc "inv_change" assoc in 
  let chat = List.assoc_opt "chat" assoc in 
  let cutscene = List.assoc_opt "cutscene" assoc in 
  {
    room_id = room_id |> parse_string;
    rows = rows |> to_int;
    cols = cols |> to_int;
    change = change |> to_list |> List.map parseentry;
    inv_change = inv_change |> parseinvchange;
    chat = option_map chat parsemessage;
    cutscene = option_map cutscene parsecutscene
  }

let tojsonlog l = 
  let smallest = ref [
    ("room_id", `String l.room_id);
    ("rows", `Int l.rows);
    ("cols", `Int l.cols);
    ("change", `List (l.change |> List.map tojsonentry));
    ("inv_change", tojsoninvchange l.inv_change);
  ] in 
  if bool_opt l.chat then smallest := !smallest @
  [("chat", tojsonmessage (access_opt l.chat))] else ();
  if bool_opt l.cutscene then smallest := !smallest @
  [("inv_change", tojsoncutscene (access_opt l.cutscene))] else ();
  `Assoc !smallest

let parsepairlog p_j =
  let f = p_j |> member "first" |> parselog in
  let s = p_j |> member "second" |> parselog in
  {first = f ; second = s}

let tojsonpairlog p_l =
  let f = tojsonlog p_l.first in
  let s = tojsonlog p_l.second in
  `Assoc [("first", f); ("second",s)]

let parsesentcommand (j : json) = 
  let id = j |> member "id" |> to_int in 
  let command = j |> member "command" |> parsecommand in 
  {id = id; command = command}

let tojsonsentcommand (sc : sentcommand) = 
  `Assoc [("id", `Int sc.id); ("command", tojsoncommand sc.command)]
