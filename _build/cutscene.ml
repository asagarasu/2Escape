type t = (string * string) list

let empty = []

let read csc = match csc with 
  [] -> [], None
  | hd :: tl -> tl, Some hd

let add img text csc = 
  csc @ [(img, text)]

let create images texts = 
  List.combine images texts