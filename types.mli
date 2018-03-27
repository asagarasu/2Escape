module type Visible = sig
  type t
  (* val texture : Texture.t *)
  val size_box : int * int
  val loc_box : int * int
  val format : Format.formatter -> t -> unit
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
  (*
  val valid_store : Command.t -> t -> boolean
  *)
  include Visible with type t := t
end

module type Character = sig
  module Body : Movable
  module Equip : Storable
  type equip = Equip.t
  type t
  val inv : equip list
end

module type Room = sig
  module Decora : Visible
  module Trick : Movable
  module Equip : Storable
  type decora = Decora
  type trick = Trick
  type equip = Equip
  type t
  val decora_list : decora list
  val trick : trick list
  val equip : equip list
end
