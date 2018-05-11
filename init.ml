open State

let air_keyloc : keyloc = {
  id = "air_loc";
  key = "air_key";
  is_solved = false;
  exit_effect = [];
  immovable_effect = [];
}

let air_to_gears = { id = "air_to_gears"; is_open = true; to_room = ("gears",-1,-1) }

let air_to_study = { id = "air_to_study"; is_open = true; to_room = ("study",1,3) }

let air =
  {id = "air";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "air_key"}; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_topleft"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_topright"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_bottomleft"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "air_bottomright"}; ex = None; kl = Some air_keyloc; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some air_to_gears; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some air_to_study; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 5; cols = 6}

let study_to_air = { id = "study_to_air"; is_open = true; to_room = ("air",5,2) }

let study_to_basement = { id = "study_to_basement"; is_open = true; to_room = ("basement",-1,-1) }

let study_to_hall = { id = "study_to_hall"; is_open = true; to_room = ("hall",-1,-1) }

let study =
  {id = "study";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_air; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = Some {id = "desk_top"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_basement; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "blue_bookshelf"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some study_to_hall; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov =  Some {id = "desk_bottom"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 5; cols = 6}

let roommap =
  let table = Hashtbl.create 10 in
  Hashtbl.add table "air" air;
  Hashtbl.add table "study" study;
  table

let state =
  {roommap = roommap;
   pl1_loc = ("test", 0, 0); pl2_loc = ("test", 1, 1);
   pl1_inv = []; pl2_inv = ["good"];
   chat = [{id = 2; message = "no"}; {id = 1; message = "yes"}]}
