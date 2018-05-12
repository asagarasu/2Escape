(*nonmutable design for cutscenes*)
type t

val empty : t

val read : t -> t * (string * string) option

val add : string -> string -> t -> t

val create : string list -> string list -> t