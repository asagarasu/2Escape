type visible

type movable

type storable

type room

type character

type textMessage = {
  from : string;
  content : string;
  time : int;
}

(* [state_value] is a state, which maps
   1) row_colum_rooms, aka the room id of the current state_value
   2) map_matrix
   3) location: location of the character/items
   4) inventory: what the player is currently carrying
   5) chat: the message chat
*)
type state_value ={
  row_col_rooms: (int*int*room)list;
  map_matrix: room;
  inventory: string;
  chat: textMessage;
}

module type Visible = sig
  type t
  val get_object_id : t -> string
  val get_dialogue : t -> string
  val get_size_box : t -> int * int
  val get_canvas_loc : t -> int * int
end

module type Movable = sig
  type t = movable
  val get_weight : t -> int
  val update_loc : t -> int * int -> unit
  include Visible with type t := t
end

module type Storable = sig
  type t
  val get_weight : t -> int
  val is_stored : t -> bool
  val to_store : t -> t
  val to_remove : t -> t
  val get_inv_description : t -> string
  include Visible with type t := t
end

module type Room = sig
  module Trick : Movable
  module Equip : Storable
  type decora = Decora
  type trick = Trick
  type equip = Equip
  type t = room
  val get_room_id : t -> string
  val get_cutscenes : t -> string
  val get_trick_list : t -> trick list
  val get_equip_list : t -> equip list
  val get_exit_list : t -> trick list
  val equip_dropped : t -> equip -> unit
  val equip_taken : t -> equip -> unit
end

module type Character = sig
  module Body : Movable
  module Equip : Storable
  module Room_loc : Room
  type equip = Equip.t
  type room_loc = Room_loc.t
  type t = character
  val get_id : t -> string
  val get_dialogue : t -> string
  val get_length_height : t -> int * int
  val get_canvas_loc : t -> int * int
  val get_body : t -> movable
  val get_inventory : t -> storable list
  val get_room_loc : t -> room
  val get_hp : t -> int
  val update_dialogue : t -> string -> unit
  val move_to : t -> int * int -> unit
  val take_equip : t -> equip -> unit
  val drop_equip : t -> equip -> unit
  val to_room : t -> room -> unit
  val change_hp : t -> int -> unit
end
