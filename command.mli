open Types

type t

type item = Types.storable

type command =
| Go of {u : bool; r : bool; l : bool; d : bool}
| Take of item
| Drop of item

(* [ind_conflict]: it is done based on the command and the object that
   command exerts on. The side effect is it changes the record of the object.
   It is not in charge of conflicts between players.*)
val ind_conflict : t -> Types.visible -> Types.visible -> t
(* [dbl_conflict]: it compares the two commands from the two players.
   Two players cannot act on the same object at the same time. *)
val dbl_conflict : t -> t -> bool
