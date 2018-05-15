open Json_parser
open Init
open OUnit2

let testcommand = [
  "up" >:: (fun _ -> assert_equal (State.Go State.Up) (State.Go State.Up |> tojsoncommand |> parsecommand));
  "down" >:: (fun _ -> assert_equal (State.Go State.Down) (State.Go State.Down |> tojsoncommand |> parsecommand));
  "left" >:: (fun _ -> assert_equal (State.Go State.Left) (State.Go State.Left |> tojsoncommand |> parsecommand));
  "right" >:: (fun _ -> assert_equal (State.Go State.Right) (State.Go State.Right |> tojsoncommand |> parsecommand));
  "message" >:: (fun _ -> assert_equal (State.Message "wassup") (State.Message "wassup" |> tojsoncommand |> parsecommand));
  "take" >:: (fun _ -> assert_equal (State.Take) (State.Take |> tojsoncommand |> parsecommand));
  "drop" >:: (fun _ -> assert_equal (State.Drop "something") (State.Drop "something" |> tojsoncommand |> parsecommand));
  "enter" >:: (fun _ -> assert_equal (State.Enter) (State.Enter |> tojsoncommand |> parsecommand))
]

let examplelogs = State.do_command 1 (State.Go State.Left) gamestate
let examplelog = fst examplelogs

let testlog = [
  "equals" >:: (fun _ -> assert_equal (examplelog) (examplelog |> tojsonlog |> parselog));
]

let doublelog = {first = fst examplelogs; second = snd examplelogs}

let testpairlog = [
  "equals" >:: (fun _ -> assert_equal (doublelog) (doublelog |> tojsonpairlog |> parsepairlog))
]

let tsc command : sentcommand = 
  {id = 1; command = command}

let testsentcommand = [
  "up" >:: (fun _ -> assert_equal (State.Go State.Up |> tsc) (State.Go State.Up |> tojsoncommand |> parsecommand |> tsc));
  "down" >:: (fun _ -> assert_equal (State.Go State.Down |> tsc) (State.Go State.Down |> tojsoncommand |> parsecommand |> tsc));
  "left" >:: (fun _ -> assert_equal (State.Go State.Left |> tsc) (State.Go State.Left |> tojsoncommand |> parsecommand |> tsc));
  "right" >:: (fun _ -> assert_equal (State.Go State.Right |> tsc) (State.Go State.Right |> tojsoncommand |> parsecommand |> tsc));
  "message" >:: (fun _ -> assert_equal (State.Message "wassup" |> tsc) (State.Message "wassup" |> tojsoncommand |> parsecommand |> tsc));
  "take" >:: (fun _ -> assert_equal (State.Take |> tsc) (State.Take |> tojsoncommand |> parsecommand |> tsc));
  "drop" >:: (fun _ -> assert_equal (State.Drop "something" |> tsc) (State.Drop "something" |> tojsoncommand |> parsecommand |> tsc));
  "enter" >:: (fun _ -> assert_equal (State.Enter |> tsc) (State.Enter |> tojsoncommand |> parsecommand |> tsc))
]

let tests = testcommand @ testlog @ testpairlog

let suite = 
  "suit" >::: tests

let _ = run_test_tt_main suite
