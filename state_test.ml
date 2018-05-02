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

let chat_1 = do_command 1 (Message "yes") state

let chat_log_1 = ({room_id = "test"; rows = 3; cols = 3; change = [];
                 chat = Some {id = 1; message = "yes"}},
                {room_id = "test"; rows = 3; cols = 3; change = [];
                 chat = Some {id = 1; message = "yes"}})

let chat_2 = do_command 2 (Message "no") state

let chat_log_2 = ({room_id = "test"; rows = 3; cols = 3; change = [];
                   chat = Some {id = 2; message = "no"}},
                  {room_id = "test"; rows = 3; cols = 3; change = [];
                   chat = Some {id = 2; message = "no"}})

let chat_state = { roommap = roommap; pl1_loc = ("test",0,0); pl2_loc = ("test",1,1);
                     pl1_inv = []; pl2_inv = ["good"];
                     chat = [{ id = 2; message = "no" };{ id = 1; message = "yes" }]; }

let l_room =
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

let l_room_1 =
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

let l_roommap = let h = Hashtbl.create 2 in Hashtbl.add h "test" l_room; h

let l_state = { roommap = l_roommap; pl1_loc = ("test",0,0); pl2_loc = ("test",1,1);
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

let take_1 = do_command 1 Take l_state
let take_1_ = do_command 1 Take l_state
let take_1__ = do_command 2 Take l_state
let drop_1 = do_command 2 (Drop "good") l_state
let drop_1_ = do_command 2 (Drop "good") l_state
let drop_1__ = do_command 2 (Drop "good") l_state



let tile_p1 = { ch = Some {id = 1; direction = Up};
                mov = None; store = None; immov = None; ex = None; kl = None }

let tile_p2 = { ch = Some {id = 2; direction = Down};
                mov = None; store = None; immov = None; ex = None; kl = None }

let tile_p2_ = { ch = Some {id = 2; direction = Down};
                 mov = None; store = None; immov = None; ex = None; kl = None }

let tile = { ch = None; mov = None; store = None; immov = None; ex = None; kl = None }

let t_room = {
  id = "test" ;
  tiles = [|[|tile_p1;tile;tile|];
            [|tile;tile_p2;tile|];
            [|tile;tile;tile|]|];
  rows = 3; cols = 3;
}

let t_roommap = let h = Hashtbl.create 2 in Hashtbl.add h "test" t_room; h

let t_state = {
  roommap = t_roommap;
  pl1_loc = ("test",0,0);
  pl2_loc = ("test",1,1);
  pl1_inv = [];
  pl2_inv = [];
  chat = [];
}

let log1 = {
  room_id = "test";
  rows = 3;
  cols = 3;
  change = [{row = 1; col = 0; newtile = {ch = Some {id = 1; direction = Down};
            mov = None; store = None; immov = None; ex = None; kl = None}};
            {row = 0; col = 0; newtile = {ch = None;
            mov = None; store = None; immov = None;ex = None; kl = None}};

           ];
  chat = None;
}
let log2 = {
  room_id = "test";
  rows = 3;
  cols = 3;
  change = [{row = 1; col = 0; newtile = {ch = Some {id = 1; direction = Down};
             mov = None; store = None; immov = None; ex = None; kl = None}};
            {row = 0; col = 0; newtile = {ch = None;
             mov = None; store = None; immov = None;ex = None; kl = None}};
           ];
  chat = None;
}

let log3 = {
  room_id = "test";
  rows = 3;
  cols = 3;
  change = [{row = 1; col = 0; newtile = {ch = Some {id = 2; direction = Left};
            mov = None; store = None; immov = None; ex = None; kl = None}};
            {row = 1; col = 1; newtile = {ch = None;
            mov = None; store = None; immov = None;ex = None; kl = None}};

           ];
  chat = None;
}
let log4 = {
  room_id = "test";
  rows = 3;
  cols = 3;
  change = [{row = 1; col = 0; newtile = {ch = Some {id = 2; direction = Left};
             mov = None; store = None; immov = None; ex = None; kl = None}};
            {row = 1; col = 1; newtile = {ch = None;
             mov = None; store = None; immov = None;ex = None; kl = None}};
           ];
  chat = None;
}

let direc_1 =
  do_command 1 (Go Down) t_state

let direc_2 =
  do_command 2 (Go Left) t_state


let tests = [
  "save&load" >:: (fun _ -> assert_equal room (get_room sl));

  "take_1" >:: (fun _ -> assert_equal take_1_l take_1);
  "take_1_" >:: (fun _ -> assert_equal log_empty take_1_);
  "take_1__" >:: (fun _ -> assert_equal log_empty take_1__);
  "drop_1" >:: (fun _ -> assert_equal drop_1_l drop_1);
  "drop_1_" >:: (fun _ -> assert_equal log_empty drop_1_);
  "drop_1__" >:: (fun _ -> assert_equal log_empty drop_1__);
  "drop_1_r" >:: (fun _ -> assert_equal l_room_1 (get_room l_state));

  "chat_1" >:: (fun _ -> assert_equal chat_log_1 chat_1);
  "chat_2" >:: (fun _ -> assert_equal chat_log_2 chat_2);
  "chat_st" >:: (fun _ -> assert_equal chat_state state);

  "direction1" >:: (fun _ -> assert_equal direc_1 (log1,log2));
  "direction2" >:: (fun _ -> assert_equal direc_2 log_empty);
]


let suite =
  "State test suite"
  >::: tests

let _ = run_test_tt_main suite
