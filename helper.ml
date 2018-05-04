(**
 * Helper function to return the first element of a triplet
 *
 * Returns: the [a] in [(a, _, _)]
 *)
let fst_third (a,_, _) = a

(**
 * Helper function to return the second element of a triplet
 * 
 * Returns: the [b] in [(_, b, _)]
 *)
let snd_third (_,b,_) = b

(**
 * Helper function to return the third element of a triplet
 *)
let thd_third (_,_,c) = c

(**
 * Helper to return whether an option has a value
 * 
 * returns : [true] if x is [Some _] and [false] if x is [None]
 *)
let bool_opt (x : 'a option) : bool = 
  match x with 
  | Some _ -> true
  | None -> false

(**
 * Helper to return the option value
 *
 * requires : x is [Some x]
 * raises : [Failure "Precondition broken"] if x is [None]
 *)
let access_opt (x : 'a option) : 'a = 
  match x with 
  | Some a -> a
  | None -> failwith "Precondition broken"