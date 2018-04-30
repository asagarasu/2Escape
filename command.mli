open Types

type t

type item

type trick

type character

type objects = | Item of item | Trick of trick | Character of character

type direction = | Left | Right | Up | Down

type command =
  | Go of direction
  | Take of item
  | Drop of item
  | Move of trick * direction

type log

module type Log = sig
  type t
  val get_timestamp : t -> int
  val get_row : t -> int
  val get_rol : t -> int
  val get_diff : t -> ( int * int * objects * bool ) list
  val get_text : t -> Types.textMessage
end

(* [ind_conflict]: it is done based on the command and the object that
   command exerts on. The side effect is it changes the record of the object.
   It is not in charge of conflicts between players.*)
val ind_conflict : t -> Types.character -> Types.visible -> t
(* [dbl_conflict]: it compares the two commands from the two players.
   Two players cannot act on the same object at the same time. *)
val dbl_conflict : t -> t -> bool
