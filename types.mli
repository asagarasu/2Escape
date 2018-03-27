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
  type t
  (*
  val inv : Storable.t list
  *)
  include Movable with type t := t
end
