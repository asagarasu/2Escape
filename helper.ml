let fst_third (a,b,c) = a

let snd_third (a,b,c) = b

let thd_third (a,b,c) = c

let access_ll (y : int) (x : int) (ll : 'a list list) : 'a option = 
  try 
    let row = List.nth ll y in 
    Some (List.nth row x)
  with 
    Failure _ -> None

(**
 * Helper to return whether the x is a [Some _]
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