open OUnit2
open State

let tile_p1 = { ch = Some {id = 1; direction = Up};
  mov = None; store = None; immov = None; ex = None; kl = None }

let tile_p2 = { ch = Some {id = 2; direction = Down};
  mov = None; store = None; immov = None; ex = None; kl = None }

let tile_p2_ = { ch = Some {id = 2; direction = Down};
                mov = None; store = None; immov = None; ex = None; kl = None }

let tile_take = { ch = Some {id = 1; direction = Up};
                       mov = None; store = Some {id = "thing"};
                       immov = None; ex = None; kl = None }

let tile = { ch = None; mov = None; store = None; immov = None; ex = None; kl = None }

let t_room = {
  id = "test" ;
  tiles = [|[|tile_p1;tile;tile|];
            [|tile;tile_p2;tile|];
            [|tile;tile;tile|]|];
  rows = 3; cols = 3;
}

let t_room_take = {
  id = "test" ;
  tiles = [|[|tile_take;tile;tile|];
            [|tile;tile_p2_;tile|];
            [|tile;tile;tile|]|];
  rows = 3; cols = 3;
}

let t_roommap = let h = Hashtbl.create 2 in Hashtbl.add h "test" t_room; h

let t_roommap_take = let h = Hashtbl.create 2 in Hashtbl.add h "test" t_room_take; h

let t_state = {
  roommap = t_roommap;
  pl1_loc = ("test",0,0);
  pl2_loc = ("test",1,1);
  pl1_inv = [];
  pl2_inv = [];
  chat = [];
}

let t_state_take = {
  roommap = t_roommap_take;
  pl1_loc = ("test",0,0);
  pl2_loc = ("test",1,1);
  pl1_inv = [];
  pl2_inv = ["good"];
  chat = [];
}

let sl = save t_state "test.json"; read "test.json"

let take_1 = do_command 1 Take t_state_take

let take_1_l =
  ({room_id = "test"; rows = 3; cols = 3;
    change =
      [{row = 0; col = 0;
        newtile =
          {ch = Some {id = 1; direction = Up}; mov = None; store = None;
           immov = None; ex = None; kl = None}}];
    chat = None},
   {room_id = "test"; rows = 3; cols = 3;
    change =
      [{row = 0; col = 0;
        newtile =
          {ch = Some {id = 1; direction = Up}; mov = None; store = None;
           immov = None; ex = None; kl = None}}];
    chat = None})

let take_2 = do_command 2 Take t_state_take

let log_empty = ({room_id = "test"; rows = 3; cols = 3; change = []; chat = None},
                 {room_id = "test"; rows = 3; cols = 3; change = []; chat = None})

let drop_1 = do_command 1 (Drop "good") t_state_take

let drop_2 = do_command 2 (Drop "good") t_state_take

let drop_2_l =
  ({room_id = "test"; rows = 3; cols = 3;
    change =
      [{row = 1; col = 1;
        newtile =
          {ch = Some {id = 2; direction = Down}; mov = None;
           store = Some {id = "good"}; immov = None; ex = None; kl = None}}];
    chat = None},
   {room_id = "test"; rows = 3; cols = 3;
    change =
      [{row = 1; col = 1;
        newtile =
          {ch = Some {id = 2; direction = Down}; mov = None;
           store = Some {id = "good"}; immov = None; ex = None; kl = None}}];
    chat = None})

let get_room st = Hashtbl.find st.roommap "test"

let tests = [
  "save&load" >:: (fun _ -> assert_equal t_room (get_room sl));
  "take_1" >:: (fun _ -> assert_equal take_1_l take_1);
  "take_2" >:: (fun _ -> assert_equal log_empty take_2);
  "drop_1" >:: (fun _ -> assert_equal log_empty drop_1);
  "drop_2" >:: (fun _ -> assert_equal drop_2_l drop_2);
]

let suite =
  "State test suite"
  >::: tests

let _ = run_test_tt_main suite
