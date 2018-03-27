type visible
type movable = {
  mutable stored : int
}
type storable
type room
type character
type textMessage = {
  from : string;
  content : string;
  time : int;
}

module type Visible = sig
  type t
(* val texture : Texture.t *)
  val object_id : t -> string
  val dialogue : t -> string
  val size_box : t -> int * int
  val canvas_box : t -> int * int
  val weight : t -> int
end

module type Movable = sig
  type t
  (*
  val valid_move : Command.t -> t -> boolean
  val move_to : Command.t -> t -> t
  *)
  include Visible with type t := t
end

module type Storable = sig
  type t
  val is_stored : t -> bool
  (*
  val valid_store : Command.t -> t -> boolean
  *)
  val inv_description : t -> string
  include Visible with type t := t
end

module type Room = sig
  module Decora : Visible
  module Trick : Movable
  module Equip : Storable
  type decora = Decora
  type trick = Trick
  type equip = Equip
  type t
  val room_id : t -> string
  val cutscenes : t -> string
  val decora_list : t -> decora list
  val trick_list : t -> trick list
  val equip_list : t -> equip list
  val exit_list : t -> trick list
  val drop_equip : t -> trick -> t
  val take_equip : t -> trick -> t
end

module type Character = sig
  module Body : Movable
  module Equip : Storable
  module Room_loc : Room
  type equip = Equip.t
  type room_loc = Room_loc.t
  type t
(*
  val move : t -> Command.t -> t
  val move_to : t -> room_loc -> t
  val take : t -> Command.t -> equip -> t
  val drop : t -> Command.t -> equip -> t
*)
  val current_room : t -> room_loc
  val inv : t -> equip list
  val hp : t -> int
end
