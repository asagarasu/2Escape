let fst_third (a,b,c) = a

let snd_third (a,b,c) = b

let thd_third (a,b,c) = c

let access_ll (y : int) (x : int) (ll : 'a list list) : 'a option = 
  try 
    let row = List.nth ll y in 
    Some (List.nth row x)
  with 
    Failure _ -> None

let bool_opt (x : 'a option) : bool = 
  match x with 
  | Some _ -> true
  | None -> false