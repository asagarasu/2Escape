(*nonmutable design for cutscenes*)
type t = (string * string) list

val empty : t

val read : t -> t * (string * string) option

val add : string -> string -> t -> t

val create : string list -> string list -> t
