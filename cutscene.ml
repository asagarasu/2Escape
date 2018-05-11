type t = (string * string) Queue.t

let empty = Queue.create ()

let read csc = try Some (Queue.take csc) with Queue.Empty -> None

let add img text csc = 
  Queue.add (img, text) csc

let create images texts = 
  let combined = List.combine images texts in 
  let q = empty in 
  List.iter (fun x -> Queue.add x q) combined;
  q