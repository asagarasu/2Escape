(*nonmutable design for cutscenes*)

(* list of pairs of picture and text*)
type t = (string * string) list

(* empty value*)
val empty : t

(** 
 * Reads a log and returns the tl and the hd
 *
 * returns: [tl [csc] , Some hd] if csc has a hd
 *          otherwise [], None
 *)
val read : t -> t * (string * string) option

(**
 * adds a new scene
 *
 * returns: the new pair is appended
 *)
val add : string -> string -> t -> t

(**
 * Creates a cutscene
 *
 * requires: the [images] and [texts] have same length
 * returns: a cutscene of the images and texts concatenated
 *)
val create : string list -> string list -> t
