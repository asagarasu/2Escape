open Json_parser
open Init
open OUnit2

let testdirection = [
  "up" >:: (fun _ -> assert_equal State.Up (State.Up |> tojsondirection |> parsedirection))
]
