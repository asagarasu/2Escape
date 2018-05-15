open Unix
open Init

let start_logs () = Json_parser.tojsonpairlog {first = State.logifyfull 1 gamestate; second = State.logifyfull 2 gamestate}

let to_pairlog ((a, b) : State.log' * State.log') : Json_parser.pairlog' = 
  {first = a; second = a}

let handle_message s = match s with 
  |"init" -> start_logs () |> Yojson.Basic.to_string
  | _ -> (let scommand = Json_parser.parsesentcommand (s |> Yojson.Basic.from_string) in 
      State.do_command scommand.id scommand.command gamestate |> to_pairlog 
      |> Json_parser.tojsonpairlog |> Yojson.Basic.to_string
    ) 

let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0)

let handle_connection ic oc=
   try while true do
       let s = input_line ic in
       let reply = handle_message s in
       output_string oc (reply); flush oc
       done
   with _ -> Printf.printf "Connection closed" ;
             flush Pervasives.stdout;
             exit 0

let main_server serv_fun port=
   try
   let port = port in
   let addr = ADDR_INET ((inet_addr_of_string "127.0.0.1"), port)
   in establish_server handle_connection addr
       with
         Failure _ ->
         Printf.eprintf "bad port number\n"

let start_server port=
   Unix.handle_unix_error main_server handle_connection port

let _ = start_server 8080
