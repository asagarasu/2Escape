open Helper
open State
open Yojson
open Yojson.Basic.Util

type pairlog' = {first : log'; second : log'}


let parselog (j:Yojson.Basic.json) : log' =

  let room_id = j |> member "room_id" |> to_string in
  let rows = j |> member "rows" |> to_int in
  let cols = j |> member "cols" |> to_int in
  let change = j |> member "change" |> to_list in
  let inv_change = j |> member "inv_change" in
  let chat = j |> member "chat" |> to_list in
  let cscene = j |> member "cutscene" |> to_list in

  let parse_direction d =
    (match d with
     | "left" -> Left
     | "right" -> Right
     | "up" -> Up
     | "down" -> Down
     | b -> Up )
  in

  let parse_ch ch =
    if ch = [] then None
    else
      let id = List.nth ch 0 |> to_int in
      let direction = List.nth ch 0 |> to_string |> parse_direction in
      Some { id = id ; direction = direction }
  in

  let parse_mov mov : movable option =
    if mov = "" then None
    else
      Some { id = mov }
  in

  let parse_store store : storable option =
    if store = "" then None
    else
      Some { id = store }
  in

  let parse_immov immov : immovable option =
    if immov = "" then None
    else
      Some { id = immov }
  in


  let parse_to_room tr =
    (List.nth tr 0|> to_string, List.nth tr 1|> to_int, List.nth tr 2|> to_int)
  in

  let parse_cscene c =
    if c = [] then None
    else
      Some (List.map
              (fun a ->
                 let l = to_list a in
                 (List.nth l 0 |> to_string, List.nth l 1 |> to_string) ) c)
  in

  let parse_ex ex =
    if ex = [] then None
    else
      let id = List.nth ex 0 |> to_string in
      let is_open = List.nth ex 1 |> to_bool in
      let to_room = List.nth ex 2 |> to_list |> parse_to_room in
      let cscene = List.nth ex 3 |> to_list |> parse_cscene in
      Some {id = id; is_open = is_open; to_room = to_room; cscene = cscene}
  in

  let parse_effect e =
    if e = [] then []
    else
      List.map
        (fun a ->
           let l = to_list a in
           (List.nth l 0 |> to_string, List.nth l 1 |> to_int, List.nth l 2 |> to_int) ) e
  in

  let parse_kl kl =
    if kl = [] then None
    else
      let id = List.nth kl 0 |> to_string in
      let key = List.nth kl 1 |> to_string in
      let is_solved = List.nth kl 2 |> to_bool in
      let exit_effect = List.nth kl 3 |> to_list |> parse_effect in
      let immovable_effect = List.nth kl 4 |> to_list |> parse_effect in
      Some {id = id; key = key; is_solved = is_solved;
            exit_effect = exit_effect; immovable_effect = immovable_effect}
  in

  let parse_rt rt =
    if rt = [] then None
    else
      let id = List.nth rt 0 |> to_string in
      let rotate = List.nth rt 1 |> to_string |> parse_direction in
      let correct = List.nth rt 2 |> to_string |> parse_direction in
      let exit_effect = List.nth rt 3 |> to_list |> parse_effect in
      let immovable_effect = List.nth rt 4 |> to_list |> parse_effect in
      Some {id = id; rotate = rotate; correct = correct;
            exit_effect = exit_effect; immovable_effect = immovable_effect}
  in

  let parse_newtile t : tile =
    let ch = t |> member "ch" |> to_list |> parse_ch in
    let mov = t |> member "mov" |> to_string |> parse_mov in
    let store = t |> member "store" |> to_string |> parse_store in
    let immov = t |> member "immov" |> to_string |> parse_immov in
    let ex = t |> member "ex" |> to_list |> parse_ex in
    let kl = t |> member "kl" |> to_list |> parse_kl in
    let rt = t |> member "rt" |> to_list |> parse_rt in
    {ch = ch; mov = mov; store = store; immov = immov; ex = ex; kl = kl; rt = rt}
  in

  let parse_change c =
    if change = [] then []
    else List.map (fun a ->
        let row = a |> member "row" |> to_int in
        let col = a |> member "col" |> to_int in
        let newtile = a |> member "newtile" |> parse_newtile in
        { row = row ; col = col ; newtile = newtile }
      ) c
  in

  let parse_string a = if a = "" then None else Some a in

  let parse_inv_change i :invchange =
           let add = i |> member "add" |> to_string |> parse_string in
           let remove = i |> member "remove" |> to_string |> parse_string in
           { add = add ; remove = remove }
  in

  let parse_chat c =
    if c = [] then None
    else
      let id = List.nth c 0 |> to_int in
      let message = List.nth c 1 |> to_string in
      Some { id = id ; message = message }
  in

    {
    room_id = room_id;
    rows = rows;
    cols = cols;
    change = parse_change change;
    inv_change = parse_inv_change inv_change;
    chat = parse_chat chat;
    cutscene = parse_cscene cscene;
  }



let tojsonlog (l:log') : json =

  let mkdir d = (match d with | Left -> "left" | Right -> "right" | Up -> "up" | Down -> "down" ) in

  let effect e =
    let raw = List.fold_left
      (fun acc a -> (`List [`String (fst_third a);`Int (snd_third a);`Int (thd_third a)]) :: acc) [] e
    in
    List.rev raw
  in

  let rotate (r:rotatable) =
    `List [`String r.id ; `String (mkdir r.rotate) ; `String (mkdir r.correct) ;
           `List (effect r.exit_effect) ; `List (effect r.immovable_effect) ]
  in

  let loc (k:keyloc) =
    `List [`String k.id; `String k.key ;  `Bool k.is_solved ;
           `List (effect k.exit_effect); `List (effect k.immovable_effect)]
  in

  let scene (c:Cutscene.t option) =
    if bool_opt c
    then
      let opt = (match c with | Some a -> a | None -> []) in
      let raw = List.fold_left
          (fun acc a -> `List [ `String (fst a) ; `String (snd a) ] :: acc ) [] opt
      in
      List.rev raw
    else []
  in

  let ch_line t =
    if bool_opt t.ch
    then
      let opt = (match t.ch with | Some a -> a | None -> {id = 1; direction = Up}) in
      `List [`Int opt.id ; `String (mkdir opt.direction) ]
    else `List []
  in

  let mov_line t =
    if bool_opt t.mov
    then
      let opt = (match t.mov with | Some a -> a | None -> {id = ""}) in
      `String opt.id
    else `String ""
  in

  let store_line t =
    if bool_opt t.store
    then
      let opt = (match t.store with | Some a -> a | None -> {id = ""}) in
      `String opt.id
    else `String ""
  in

  let immov_line t =
    if bool_opt t.immov
    then
      let opt = (match t.immov with | Some a -> a | None -> {id = ""}) in
      `String opt.id
    else `String ""
  in

  let ex_line t =
    if bool_opt t.ex
    then
      let opt =
        (match t.ex with
         | Some a -> a
         | None ->
           {id = ""; is_open = false ; to_room = ("",-1,-1) ; cscene = None})
      in
      `List [`String opt.id ; `Bool opt.is_open ;
               `List [ `String (fst_third opt.to_room) ; `Int (snd_third opt.to_room) ; `Int (thd_third opt.to_room) ];
               `List (scene opt.cscene)]
    else `List []
  in

  let kl_line t =
    if bool_opt t.kl
    then
      let opt =
        (match t.kl with
         | Some a -> a
         | None ->
           {id = "";key = "";is_solved = false;exit_effect = [];immovable_effect = []})
      in loc opt
    else `List []
  in

  let rt_line t =
    if bool_opt t.rt
    then
      let opt =
        (match t.rt with
         | Some a -> a
         | None ->
           {id = ""; rotate = Up ; correct = Up;exit_effect = []; immovable_effect = []})
      in rotate opt
    else `List []
  in

  let tile t = `Assoc [("ch",ch_line t); ("mov",mov_line t); ("store",store_line t);
                       ("immov",immov_line t); ("ex",ex_line t); ("kl",kl_line t); ("rt",rt_line t)]
  in

  let change ch =
    if ch <> []
    then
      let raw = List.fold_left
          (fun acc a -> `Assoc [("row",`Int a.row);("col",`Int a.col);("newtile",tile a.newtile)] :: acc ) [] ch
      in
      List.rev raw
    else []
  in

  let inven i  =
    (match i.add, i.remove with
     | Some b, Some c -> `List [ `String b ; `String c ]
     | Some d, None -> `List [ `String d ; `String "" ]
     | None, Some e -> `List [ `String "" ; `String e ]
     | None, None -> `List [ `String "" ; `String "" ]
    )
  in

  let chat_line cha =
    if bool_opt cha
    then
      let opt =
        (match cha with
         | Some a -> a
         | None -> {id = 1; message = ""})
      in
      `List [ `Int opt.id ; `String opt.message ]
    else `List []
  in

  `Assoc [("room_id", `String l.room_id); ("rows", `Int l.rows);
          ("cols", `Int l.cols); ("change", `List (change l.change));
          ("inv_change", inven l.inv_change); ("chat", chat_line l.chat);
          ("cutscene", `List (scene l.cutscene))]

let parsepairlog = failwith "TODO"

let tojsonpairlog = failwith "TODO"

let parsecommand (j:json):command =
  match j with
  | `String "take" -> Take
  | `String "enter" -> Enter
  | `String a ->
    if String.contains a ' '
    then let slice = String.index a ' ' in
      let head = String.sub a 0 slice in
      let tail = String.sub a (slice + 1) (String.length a - slice - 1) in
      (match head with
       | "drop" -> Drop tail
       | "message" -> Message tail
       | "go" ->
         let d = (match tail with
             | "left" -> Left
             | "right" -> Right
             | "up" -> Up
             | "down" -> Down
             | b -> Up ) in
         Go d
       | c -> Take)
    else Take
  | _ -> Take

let tojsoncommand (cmd:command):json =
  match cmd with
  | Take -> `String "take"
  | Enter -> `String "enter"
  | Drop a -> `String ("drop "^a)
  | Go d ->
    let direct = (match d with
        | Left -> "left"
        | Right -> "right"
        | Up -> "up"
        | Down -> "down")
    in
    `String ("go "^direct)
  | Message m -> `String ("message "^m)
