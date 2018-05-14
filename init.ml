open State
open Printf

let air_to_gears : exit = { id = "air_to_gears"; is_open = false; to_room = ("gears",-1,-1); cscene = None }

let air_to_study : exit = { id = "air_to_study"; is_open = true; to_room = ("study",0,2); cscene = None}

let turbine_loc = {id = "turbine_loc"; key = "turbine"; is_solved = false; exit_effect = []; immovable_effect = [("handler",2,1)]}

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
         {ch = None; mov = None; store = Some {id = "turbine"}; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "turbine_topleft"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "turbine_topright"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "turbine_bottomleft"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "turbine_bottomright"}; ex = None; kl = Some turbine_loc; rt = None};
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

let study_to_air = { id = "study_to_air"; is_open = true; to_room = ("air",2,4); cscene = None }

let study_to_basement = { id = "study_to_basement"; is_open = true; to_room = ("basement",2,2); cscene = None }

let study_to_hall = { id = "study_to_hall"; is_open = true; to_room = ("hall",0,8); cscene = None }

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

let basement_to_study = {id = "basement_to_study"; is_open = false; to_room = ("study",5,3); cscene = None}

let ladder_loc = {id = "ladder_loc"; key = "ladder"; is_solved = false; exit_effect = [("basement",3,3)]; immovable_effect = []}

let basement =
  {id = "basement";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some { id = "ladder" }; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some basement_to_study; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = Some ladder_loc; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

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
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 5; cols = 6}

let workshop_to_handler = {id = "workshop_to_handler"; is_open = false; to_room = ("handler",-1,-1); cscene = None}

let workshop_to_hall = {id = "workshop_to_hall"; is_open = true; to_room = ("hall",-1,-1); cscene = None}

let workshop_key_loc = {
  id = "workshop_key_loc";
  key = "workshop_key";
  is_solved = false;
  exit_effect = [("workshop",1,4)];
  immovable_effect = []
}

let rope_loc = {
  id = "rope_loc";
  key = "rope";
  is_solved = false;
  exit_effect = [];
  immovable_effect = [("air",5,3)]
}

let workshop =
  {id = "workshop";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "steel"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some workshop_to_handler; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "steel"}; store = None; immov = None; ex = None; kl = Some workshop_key_loc; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "workshop_key"}; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "steel"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "rope"}; immov = None; ex = None; kl = Some rope_loc; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "workshop_desk_top"}; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = Some workshop_to_hall; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "steel"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "workshop_desk_bottom"}; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "steel"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 5; cols = 6}

let handler_to_gears = {id = "handler_to_gears"; is_open = false; to_room = ("gears",-1,-1); cscene = None}

let handler_to_workshop = {id = "handler_to_workshop"; is_open = true; to_room = ("workshop",0,3); cscene = None}

let handler_loc = {
  id = "handler_loc";
  key = "handler_key";
  is_solved = false;
  exit_effect = [("workshop",1,4)];
  immovable_effect = []
}

let hall_handler_loc = {
  id = "hall_handler_loc";
  key = "hall_handler_key";
  is_solved = false;
  exit_effect = [("air",5,3)];
  immovable_effect = []
}

let handler =
  {id = "handler";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "handler"}; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "transparent"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = Some hall_handler_loc; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "handler_key"}; immov = None; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some handler_to_workshop; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 5; cols = 6}

let hall_to_study = {id = "hall_to_study"; is_open = false; to_room = ("study",-1,-1); cscene = None}

let hall_to_workshop = {id = "hall_to_workshop"; is_open = true; to_room = ("workshop",-1,-1); cscene = None}

let book_loc = {
  id = "book_loc";
  key = "book";
  is_solved = false;
  exit_effect = [("hall",0,8)];
  immovable_effect = []
}

let hall =
  {id = "hall";
   tiles =
     [|
       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = Some {id = "hall_handler_key"}; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "red_bookshelf"}; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = Some {id = "book"}; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = Some book_loc; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = Some {id = 2; direction = Left}; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = Some hall_to_study; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = Some {id = 1; direction = Right}; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = Some hall_to_workshop; kl = None; rt = None};|];

       [|{ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = Some {id = "debris"}; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None};
         {ch = None; mov = None; store = None; immov = None; ex = None; kl = None; rt = None}|];
     |];
   rows = 10; cols = 6}

let roommap =
  let table = Hashtbl.create 10 in
  Hashtbl.add table "air" air;
  Hashtbl.add table "study" study;
  Hashtbl.add table "basement" basement;
  Hashtbl.add table "workshop" workshop;
  Hashtbl.add table "handler" handler;
  Hashtbl.add table "hall" hall;
  table

let state =
  {roommap = roommap;
   pl1_loc = ("hall", 1, 8); pl2_loc = ("hall", 4, 7);
   pl1_inv = ["book"]; pl2_inv = [];
   chat = []}

let do' (playerid:int) (cmd:string) : string * string =
  let cmd' = parse_command cmd in
  make_log (do_command playerid cmd' state)

let save_pair l =
  let file = "some.json" in
  let message = fst l ^"

" ^ snd l
  in
  let oc = open_out file in
  fprintf oc "%s\n" message;
  close_out oc;
