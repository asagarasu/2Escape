open Types


type value =
  | Row_col_rooms  of (int*int*room)list
  | Map_matrix of room
  | Inventory of string
  | Chat of textMessage


let do_command c t =
  failwith "Unimplemented"

let save s =
  failwith "Unimplemented"
