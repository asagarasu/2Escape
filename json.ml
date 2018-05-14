open Printf
open Helper
open State


(* [make_log] takes in a pair of log and pass out a string of two logs in json format *)
let make_log (log_pair:log'*log') : string =
  let f = fst log_pair in
  let s = snd log_pair in
  let mkdir d = (match d with | Left -> "left" | Right -> "right" | Up -> "up" | Down -> "down" ) in

  let effect e =
    let raw = List.fold_left
      (fun acc a -> acc ^ "[" ^ (fst_third a) ^ ", " ^ (string_of_int (snd_third a)) ^
                    ", " ^ (string_of_int (thd_third a)) ^ "]," ) "" e
    in
    String.sub raw 0 (String.length raw - 1)
  in

  let rotate (r:rotatable) = "[" ^ r.id ^ ", " ^ mkdir r.rotate ^ ", " ^ mkdir r.correct ^
                 "[" ^ effect r.exit_effect ^ "], " ^ effect r.immovable_effect ^ "]"
  in
  let loc (k:keyloc) = "[" ^ k.id ^ k.key ^ string_of_bool k.is_solved ^ "[" ^
            effect k.exit_effect ^ "],[" ^ effect k.immovable_effect ^ "]]"

  in

  let scene (c:Cutscene.t option) =
    if bool_opt c
    then
      let opt = (match c with | Some a -> a | None -> []) in
      let raw = List.fold_left
          (fun acc a -> acc ^ "[" ^ (fst a) ^ ", " ^ (snd a) ^ "]," ) "" opt
      in
      String.sub raw 0 (String.length raw - 1)
    else ""
  in

  let ch_line t =
    if bool_opt t.ch
    then
      let opt = (match t.ch with | Some a -> a | None -> {id = 1; direction = Up}) in
      "{\"ch\":[" ^ string_of_int opt.id ^ ", \"" ^ mkdir opt.direction ^ "\"],\"mov\":"
    else "{\"ch\":[],\"mov\":"
  in

  let mov_line t =
    if bool_opt t.mov
    then
      let opt = (match t.mov with | Some a -> a | None -> {id = ""}) in
    "\"" ^ opt.id ^ "\",\"store\":"
    else "\"\"" ^ ",\"store\":"
  in
  let store_line t =
    if bool_opt t.store
    then
      let opt = (match t.store with | Some a -> a | None -> {id = ""}) in
      "\"" ^ opt.id ^ "\",\"immov\":"
    else "\"\"" ^ ",\"immov\":"
  in

  let immov_line t =
    if bool_opt t.immov
    then
      let opt = (match t.immov with | Some a -> a | None -> {id = ""}) in
      "\"" ^ opt.id ^ "\",\"ex\":["
    else "\"\"" ^ ",\"ex\":["
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
      "\"" ^ opt.id ^ "\", \"" ^ string_of_bool opt.is_open ^ "\", ["
        ^ fst_third opt.to_room ^ "\", \""
        ^ string_of_int (snd_third opt.to_room) ^ "\", \""
        ^ string_of_int (thd_third opt.to_room) ^ "\"], ["
        ^ scene opt.cscene ^ "]],\"kl\":["
    else "],\"kl\":["
  in

  let kl_line t =
    if bool_opt t.kl
    then
      let opt =
        (match t.kl with
         | Some a -> a
         | None ->
           {id = "";key = "";is_solved = false;exit_effect = [];immovable_effect = []})
      in loc opt ^ "],\"rt\":"
    else "],\"rt\":"
  in

  let rt_line t =
    if bool_opt t.rt
    then
      let opt =
        (match t.rt with
         | Some a -> a
         | None ->
           {id = ""; rotate = Up ; correct = Up;exit_effect = []; immovable_effect = []})
      in rotate opt ^ "}"
    else "[]}"
  in

  let tile t = ch_line t ^ mov_line t ^ store_line t ^ immov_line t ^
               ex_line t ^ kl_line t ^ rt_line t
  in

  let change ch =
    if ch <> []
    then
      let raw = List.fold_left
          (fun acc a -> acc ^ "{\"row\": " ^ string_of_int a.row ^
                        ",\"col\": " ^ string_of_int a.col ^ ",\"newtile\": " ^
                        tile a.newtile ^ "},") "" ch
      in
      String.sub raw 0 (String.length raw - 1)
    else ""
  in

  let inven i : string  =
    (match i.add, i.remove with
     | Some b, Some c -> "\"" ^ b ^ "\", \"" ^ c ^ "\""
     | Some d, None -> "\"" ^ d ^ "\", \"\""
     | None, Some e -> "\"\", \"" ^ e ^ "\""
     | None, None -> "\"\", \"\""
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
      "[" ^ string_of_int opt.id ^ ", \"" ^ opt.message ^ "\"]"
    else "[]"
  in

  let f_str = "
  \"log_1\": {
    \"room_id\": \"" ^ f.room_id ^ "\",
    \"rows\": " ^ string_of_int f.rows ^ ",
    \"cols\": " ^ string_of_int f.cols ^ ",
    \"change\": [" ^ change f.change ^ "],
    \"inv_change\": [" ^ inven f.inv_change ^ "],
    \"chat\": " ^ chat_line f.chat ^ ",
    \"cutscene\": [" ^ scene f.cutscene ^ "]}"
  in

  let s_str = "
  \"log_2\": {
    \"room_id\": \"" ^ s.room_id ^ "\",
    \"rows\": " ^ string_of_int s.rows ^ ",
    \"cols\": " ^ string_of_int s.cols ^ ",
    \"change\": [" ^ change s.change ^ "],
    \"inv_change\": [" ^ inven s.inv_change ^ "],
    \"chat\": " ^ chat_line s.chat ^ ",
    \"cutscene\": [" ^ scene s.cutscene ^ "]}"
  in
  "{"^f_str^"}" ^ ",
"^ "{"^s_str^"}"

(* [save_one] can take in a single log and save it locally to [one_log.json]
   It would be ready to use. *)
let save_one l =
  let file = "one_log.json" in
  let message = l in
  let oc = open_out file in
  fprintf oc "%s\n" message;
  close_out oc;
