type textMessage = {
  from : string;
  content : string;
  time : int;
}



type visible = {
  id: string;
  dialogue : string;
  length_height : int * int;
  canvas_loc : int * int;
}

module type Visible = sig
  type t
  val get_object_id : t -> string
  val get_dialogue : t -> string
  val get_size_box : t -> int * int
  val get_canvas_loc : t -> int * int
end

module Visible = struct
  type t = visible
  let get_object_id t = t.id
  let get_dialogue t = t.dialogue
  let get_length_height t = t.length_height
  let get_canvas_loc t = t.canvas_loc
end



type movable = {
  id: string;
  dialogue : string;
  length_height : int * int;
  canvas_loc : (int * int) ref;
  weight : int;
}

module type Movable = sig
  type t = movable
  val get_weight : t -> int
  val update_loc : t -> int * int -> unit
  include Visible with type t := t
end

module Movable = struct
  include Visible
  let get_canvas_loc t = !t.canvas_loc
  let get_weight t = t.weight
  let update_loc t loc = t.canvas_loc := loc
end



type storable = {
  id: string;
  dialogue : string;
  length_height : int * int;
  canvas_loc : int * int;
  weight : int;
  stored : bool;
  inv_description : string;
}

module type Storable = sig
  type t
  val get_weight : t -> int
  val is_stored : t -> bool
  val to_store : t -> t
  val to_remove : t -> t
  val get_inv_description : t -> string
  include Visible with type t := t
end

module Storable = struct
  include Visible
  let get_canvas_loc t = !t.canvas_loc
  let get_weight t = t.weight
  let is_stored t = t.stored
  let to_store t = { t with stored = true }
  let to_remove t = { t with stored = false }
  let get_inv_description t = t.inv_description
end



type room = {
  room_id : string;
  cutscenes : string;
  matrix : (bool list) list;
  trick_list : movable list;
  equip_list : (storable list) ref;
  exit_list : movable list;
}

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

module Room = struct
  let get_room_id t = t.room_id
  let get_cutscenes t = t.cutscenes
  let get_trick_list t = t.trick_list
  let get_equip_list t = t.equip_list
  let get_exit_list t = t.exit_list
  let equip_dropped t equip loc =
    let equip' = { equip with canvas_loc = loc; stored = false; } in
    let e = equip'::!(t.equip_list) in
    t.equip_list := e
  let equip_taken t equip =
    let equip' = { equip with canvas_loc = (-1,-1); stored = true; } in
    let e = List.filter (fun x -> x.id <> equip'.id) !(t.equip_list) in
    t.equip_list := e
end



type character = {
  id: string;
  dialogue : string ref;
  length_height : int * int;
  body : movable;
  inventory : (storable list) ref;
  room_loc : room ref;
  hp: int ref;
}

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

module Character = struct
  let get_id t = t.id
  let get_dialogue t = !t.dialogue
  let get_length_height t = t.length_height
  let get_canvas_loc t = !t.body.canvas_loc
  let get_body t = t.body
  let get_inventory t = !t.inventory
  let get_room_loc t = !t.room_loc
  let get_hp t = !t.hp
  let update_dialogue t dialogue = t.dialogue := dialogue
  let move_to t loc = t.body.canvas_loc := loc
  let take_equip t equip =
    let equip_list = equip::!(t.inventory) in
    t.inventory := equip_list
  let drop_equip t equip =
    let equip_list = List.filter (fun x -> equip <> x) !(t.inventory) in
    t.inventory := equip_list
  let to_room t room = t.room_loc := room
  let change_hp t change = let hp = !(t.hp) + change in t.hp := hp
end
