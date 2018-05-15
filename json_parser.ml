open Helper
open State
open Yojson.Basic.Util
open Yojson.Basic

(*A pair of log data structure*)
type pairlog' = {first : log'; second : log'}

(*A command with attached id*)
type sentcommand = {id : int; command : command}

(**
 * Helper method to apply a map to an option
 * 
 * returns: [Some (func x)] if [Some x], else [None]
 *)
let option_map (x : 'a option) (func : 'a -> 'b) : 'b option = 
  match x with 
  | Some y -> Some (func y)
  | None -> None

(**
 * Helper method to parse a json `String object since
 * to_string gives extra quotes
 *
 * requires: [j] is [`String s]
 * returns: [s] if [`String s]
 * raises: [Failure "not a string"] if precondition not met
 *)
let parse_string j = 
  match j with `String s -> s
  | _ -> failwith "not a string"

(**
 * Parses a direction
 *
 * requires: [j] is [`String {left, right, up, down}]
 * returns: corresponding direction
 * raises [Failure "json is not a direction"] if precondition not met
 *)
let parsedirection j =
  match j |> parse_string  with
   | "left" -> Left
   | "right" -> Right
   | "up" -> Up
   | "down" -> Down
   | _ -> failwith "json is not a direction" 

(**
 * Sends a direction to a json
 *
 * returns: [`String sd] where [sd] is the lowercase string
 *          of the direction
 *)
let tojsondirection d = 
  match d with 
  | Left -> `String "left"
  | Right -> `String "right"
  | Up -> `String "up"
  | Down -> `String "down"

(**
 * Parses a command. Format is [order; extrastuff if applicable]
 *
 * requires:  j is a [`List l] where l satsifies the above format
 * returns: The corresponding command
 * raises: [Failure "json is not a command"] if precondition not met
 *)
let parsecommand j = 
  match j |> to_list with
  | `String "go" :: tl :: []-> Go (parsedirection tl)
  | `String "message" :: tl :: [] -> Message (parse_string tl)
  | `String "take" :: [] -> Take
  | `String "drop" :: tl :: [] -> Drop (parse_string tl)
  | `String "enter" :: [] -> Enter
  | _ -> failwith "json is not a command"

(** 
 * Sends a command to a json. Format is [order; extrastuff if applicable]
 *
 * returns: a [`List l] where l follows the above format
 *)
let tojsoncommand c = 
  match c with 
  | Go d -> `List [`String "go"; tojsondirection d]
  | Message s -> `List [`String "message"; `String s]
  | Take -> `List [`String "take"]
  | Drop s -> `List [`String "drop"; `String s]
  | Enter -> `List [`String "enter"]

(**
 * Parses a character 
 *
 * requires: [j] is an association list with correct mappings
 * returns: a [ch] with same information as j
 * raises: [Failure "not a character"] if not a character
 *)
let parsecharacter j : State.character = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  let direction = List.assoc_opt "direction" assoc in 
  match id, direction with 
    | Some a, Some b -> 
        {id = a |> to_int; direction = b |> parsedirection}
    | _ -> failwith "not a character"

(**
 * Sends a character to a json
 *
 * returns: an [`Assoc mapping], where mapping is a correct json mapping
 *          of the character fields
 *)
let tojsoncharacter (ch : State.character) = 
  `Assoc [("id", `Int ch.id); 
    ("direction", tojsondirection ch.direction)]

(**
 * Parses a movable from a json. 
 *
 * requires: j is an [`Assoc] with a mpaaing to the movable field(s)
 * returns: a movable with the field(s) parsesd
 * raises: [Failure "not a movable"] if precondition not met
 *)
let parsemovable j : State.movable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not a movable"

(**
 * Sends a movable to a json
 *
 * returns: an [`Assoc] with mapping to the json movable field(s) 
 *)
let tojsonmovable (m : State.movable) = 
  `Assoc [("id", `String m.id)]

(**
 * Parses a storable from a json
 * 
 * requires: j is an [`Assoc] with mapping to the storable field(s)
 * returns: a storable with the field(s) parsed
 * raises: [Failure "not a storable"] if precondition not met 
 *)
let parsestorable j : State.storable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not a storable"

(**
 * Sends a storable to a json
 *
 * returns: an [`Assoc] with mapping to the json storable fields
 *)
let tojsonstorable (st : State.storable) = 
  `Assoc [("id", `String st.id)]

(**
 * Parses an immovable
 *
 * requires: j is an [`Assoc] with mapping to the immovable fields
 * returns: an immovable with fields parsed
 * raises: [Failure "not an immovable"] if precondition not met 
 *)
let parseimmovable j : State.immovable = 
  let assoc = to_assoc j in 
  let id = List.assoc_opt "id" assoc in 
  match id with 
  | Some a -> {id = a |> parse_string}
  | _ -> failwith "not an immovable"

(**
 * Sends an immovable to a json
 * 
 * returns: an [`Assoc] with mapping to the json immovable fields
 *)
let tojsonimmovable (im : State.immovable) = 
  `Assoc [("id", `String im.id)]

(**
 * Helper method to parse a string pair from a list
 *
 * requires: l is `List [`String a; `String b]
 * returns: (a,b)
 * raises: [Failure "not a pair"] if precondition not met
 *)
let parsestringpair l = 
  match l |> to_list with 
    [] -> failwith "not a pair"
    | hd :: [] -> failwith "not a pair"
    | hd :: tl :: [] -> (parse_string hd, parse_string tl)
    | _ -> failwith "not a pair"

(**
 * Helper method to send a pair to a json list
 *
 * returns `List [`String a; `String b]
 *)
let tojsonstringpair (a, b) = 
  `List [`String a; `String b]

(** 
 * Parses a Cutscene
 *
 * requires: j is a `List [`List[`String a; `String b], ...]
 * returns: the cutscene
 *)
let parsecutscene j : Cutscene.t = 
  j |> to_list |> List.map parsestringpair

(** 
 * Sends a json to a cutscene
 *
 * returns: a `List [`List[`String a; `String b], ...]
 *)
let tojsoncutscene (c : Cutscene.t) = 
  `List (List.map tojsonstringpair c)

(** 
 * Parses an exit
 *
 * requires: j is an [`Assoc] with mapping to json exit fields
 * returns: an exit
 * raises: a Failure if precondition not met
 *)
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

(** 
 * Sends an exit to a json
 *
 * returns: an [`Assoc] with mapping to json exit fields
 *)
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

(**
 * Helper method to parse triple of string * int * int
 *
 * requries: j is [`List [`String f, `Int s, `Int t]]
 * returns (f, s, t) 
 *)
let parsethree j = 
  match j |> to_list with 
  | f :: s :: t :: [] -> 
    (parse_string f, 
    to_int s,
    to_int t
    )
  | _ -> failwith "Not a triple"

(** 
 * Helper method to send (a,b,c) to json
 *
 * returns ([`List [`String a, `Int b, `Int c]])
 *)
let tojsonthree (a, b, c) = 
  `List [`String a; `Int b; `Int c]

(**
 * Parses a list of triples
 *
 * returns: the json list of the parsed list of triples
 *)
let parselistthree j = 
  j |> to_list |> List.map parsethree

(** 
 * Sends a list of triples to json
 *
 * returns: a list of json triples
 *)
let tojsonlistthree l = 
  `List (l |> List.map tojsonthree)

(**
 * Parses a keyloc
 *
 * requires: keyloc is an [`Assoc] with mapping to json keyloc fields
 * returns: a keyloc with the parsed fields
 * raises: Failure if precondition not met
 *)
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

(** 
 * Sends a keyloc to a json
 *
 * returns: an [`Assoc] with the json keyloc mapping
 *)
let tojsonkeyloc (kl : State.keyloc) = 
  `Assoc [
    ("id", `String kl.id);
    ("key", `String kl.key);
    ("is_solved", `Bool kl.is_solved);
    ("exit_effect", tojsonlistthree kl.exit_effect);
    ("immovable_effect", tojsonlistthree kl.immovable_effect)
  ]

(**
 * Parses a rotatable 
 *
 * requires: j is an [`Assoc] with rotatable mapping
 * returns: rotatable
 * raises: Failure if precondition not met
 *)
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

(**
 * Sends a rotatable to a json
 *
 * returns: an [`Assoc] with rotatable mapping
 *)
let tojsonrotatable (rot : rotatable) = 
  `Assoc [
    ("id", `String rot.id);
    ("rotate", tojsondirection rot.rotate);
    ("correct", tojsondirection rot.correct);
    ("exit_effect", tojsonlistthree rot.exit_effect);
    ("immovable_effect", tojsonlistthree rot.immovable_effect)
  ]

(**
 * Parses a tile. Some fields may be empty
 *
 * returns: a tile with as many mapping extracted as possible
 *)
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

(** 
 * Sends a tile to a json. None fields are ignored
 *
 * returns: an [`Assoc] with mapping to [Some] fields
 *)
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

(**
 * Parses a message
 *
 * requires: [`Assoc] with message mapping
 * returns: parsed message
 * raises: Failure if precondition broken
 *)
let parsemessage j = 
  let assoc = to_assoc j in 
  let id = List.assoc "id" assoc in 
  let message = List.assoc "message" assoc in 
  {
    id = id |> to_int;
    message = message |> parse_string
  }

(**
 * Sends a message to a json
 * 
 * returns: [`Assoc] with message mapping
 *)
let tojsonmessage (m : message) = 
  `Assoc[("id", `Int m.id); ("message", `String m.message)]

(**
 * Parses an entry from a json
 *
 * requires: [`Assoc] with entry mapping
 * returns: parsed entry
 * raises: Failure if precondition broken 
 *)
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

(**
 * Sends an entry to a json
 * 
 * returns: [`Assoc] with entry mapping
 *)
let tojsonentry e = 
  `Assoc[
    ("row", `Int e.row); ("col", `Int e.col); 
    ("newtile", tojsontile e.newtile)
  ]

(**
 * Parses an inv_change from a json
 *
 * requires: [`Assoc] with invchange mapping
 * returns: parsed inv_change
 * raises: Failure if precond broken
 *)
let parseinvchange j = 
  let assoc = to_assoc j in 
  let add = List.assoc "add" assoc in 
  let remove = List.assoc "remove" assoc in 
  {
    add = add |> to_list |> List.map parse_string;
    remove = remove |> to_list |> List.map parse_string
  }

(**
 * Sends an inv_change to a json
 *
 * returns: an [`Assoc] with invchange mapping
 *)
let tojsoninvchange ic= 
  `Assoc[
    ("add", `List (List.map (fun str -> `String str) ic.add));
    ("remove", `List (List.map (fun str -> `String str) ic.remove))
  ]

(** 
 * Parses a log
 *
 * requires: j is an [`Assoc] with log mapping
 * returns: parsed log
 * raises: Failure if precond broken
 *)
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

(**
 * Sends a log to a json
 *
 * returns: an [`Assoc] with log mapping
 *)
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

(**
 * Parses a pair of logs
 *
 * requires: an [`Assoc] with pairlog' mapping
 * returns: the parsed pairlog'
 * raises: Failure if precond broken
 *)
let parsepairlog p_j =
  let f = p_j |> member "first" |> parselog in
  let s = p_j |> member "second" |> parselog in
  {first = f ; second = s}

(**
 * Sends a pairlog to a json
 * 
 * returns: an [`Assoc] with pairlog' mapping
 *)
let tojsonpairlog p_l =
  let f = tojsonlog p_l.first in
  let s = tojsonlog p_l.second in
  `Assoc [("first", f); ("second",s)]

(**
 * Parses a sentcommand
 *
 * requires: an [`Assoc] with sentcommand mapping
 * returns: the parsed sentcommand
 * raises: Failure if precond broken 
 *)
let parsesentcommand (j : json) = 
  let id = j |> member "id" |> to_int in 
  let command = j |> member "command" |> parsecommand in 
  {id = id; command = command}

(**
 * Sends a sentcommand to a json
 * 
 * returns: an [`Assoc] with sentcommand mapping
 *)
let tojsonsentcommand (sc : sentcommand) = 
  `Assoc [("id", `Int sc.id); ("command", tojsoncommand sc.command)]
