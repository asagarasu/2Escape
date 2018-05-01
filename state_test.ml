open OUnit2
open State

let room =
  {id = "test";
   tiles =
     [|[|{ch = Some {id = 1; direction = Up}; mov = None; store = Some {id = "fadf"};
          immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = Some {id = 2; direction = Down}; mov = None;
          store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|]|];
   rows = 3; cols = 3}

let roommap = let h = Hashtbl.create 2 in Hashtbl.add h "test" room; h

let state = { roommap = roommap; pl1_loc = ("test",0,0); pl2_loc = ("test",1,1);
                pl1_inv = []; pl2_inv = ["good"]; chat = []; }



let t_room =
  {id = "test";
   tiles =
     [|[|{ch = Some {id = 1; direction = Up}; mov = None; store = Some {id = "fadf"};
          immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = Some {id = 2; direction = Down}; mov = None;
          store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|]|];
   rows = 3; cols = 3}

let t_room_1 =
  {id = "test";
   tiles =
     [|[|{ch = Some {id = 1; direction = Up}; mov = None; store = None;
          immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = Some {id = 2; direction = Down}; mov = None;
          store = Some {id = "good"}; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|];
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None}|]|];
   rows = 3; cols = 3}

let t_roommap = let h = Hashtbl.create 2 in Hashtbl.add h "test" t_room; h

let t_state = { roommap = t_roommap; pl1_loc = ("test",0,0); pl2_loc = ("test",1,1);
                pl1_inv = []; pl2_inv = ["good"]; chat = []; }

let log_empty = ({room_id = "test"; rows = 3; cols = 3; change = []; chat = None},
                 {room_id = "test"; rows = 3; cols = 3; change = []; chat = None})

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

let drop_1_l =
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

let sl = save state "test.json"; read "test.json"

let get_room st = Hashtbl.find st.roommap "test"

let take_1 = do_command 1 Take t_state
let take_1_ = do_command 1 Take t_state
let take_1__ = do_command 2 Take t_state
let drop_1 = do_command 2 (Drop "good") t_state
let drop_1_ = do_command 2 (Drop "good") t_state
let drop_1__ = do_command 2 (Drop "good") t_state

let tests = [
  "save&load" >:: (fun _ -> assert_equal room (get_room sl));

  "take_1" >:: (fun _ -> assert_equal take_1_l take_1);
  "take_1_" >:: (fun _ -> assert_equal log_empty take_1_);
  "take_1__" >:: (fun _ -> assert_equal log_empty take_1__);
  "drop_1" >:: (fun _ -> assert_equal drop_1_l drop_1);
  "drop_1_" >:: (fun _ -> assert_equal log_empty drop_1_);
  "drop_1__" >:: (fun _ -> assert_equal log_empty drop_1__);
  "drop_1_r" >:: (fun _ -> assert_equal t_room_1 (get_room t_state));


]

let suite =
  "State test suite"
  >::: tests

let _ = run_test_tt_main suite
