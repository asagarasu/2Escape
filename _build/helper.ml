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

(**
 * Helper to find the first index of the value in a list 
 * that satisfies the condition
 *
 * raises: Not_found if nothing is found
 *)
let find_index (func : 'a -> bool) (l : 'a list) : int = 
  let rec find_index_helper (func1 : 'a -> bool) (li : 'a list) (tracker : int) : int = 
    (match li with 
    | [] -> raise Not_found
    | hd :: tl when func1 hd -> tracker
    | _ :: tl -> find_index_helper func1 tl (tracker + 1)) in 
  find_index_helper func l 0