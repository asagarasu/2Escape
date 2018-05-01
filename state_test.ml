open OUnit2
open State

let tile_p1 = {
  ch = Some {id = 1; direction = Up};
  mov = None;
  store = None;
  immov = None;
  ex = None;
  kl = None
}

let tile_p2 = {
  ch = Some {id = 2; direction = Down};
  mov = None;
  store = None;
  immov = None;
  ex = None;
  kl = None
}

let tile = {
  ch = None;
  mov = None;
  store = None;
  immov = None;
  ex = None;
  kl = None
}

let t_room = {
  id = "test" ;
  tiles = [|[|tile_p1;tile;tile|];
            [|tile;tile_p2;tile|];
            [|tile;tile;tile|]|];
  rows = 3; cols = 3;
}

let t_roommap = let h = Hashtbl.create 2 in Hashtbl.add h "t" t_room; h

let t_state = {
  roommap = t_roommap;
  pl1_loc = ("test",0,0);
  pl2_loc = ("test",1,1);
  pl1_inv = [];
  pl2_inv = [];
  chat = [];
}

let sl = save t_state "test.json"; read "test.json"

let tests = [
  "save&load" >:: (fun _ -> assert_equal t_room (Hashtbl.find sl.roommap "test"));
  "save&load" >:: (fun _ -> assert_equal t_room sl_room);
]

let suite =
  "State test suite"
  >::: tests

let _ = run_test_tt_main suite
