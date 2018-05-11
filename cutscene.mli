(*mutable design for cutscenes*)
type t

val empty : t

val read : t -> (string * string) option

val add : string -> string -> t -> unit

val create : string list -> string list -> t