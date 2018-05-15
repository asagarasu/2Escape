open Unix
open Init

(*Loads whole game*)
let start_logs () = Json_parser.tojsonpairlog {first = State.logifyfull 1 gamestate; second = State.logifyfull 2 gamestate}

(*Changes (log', log') into a pairlog*)
let to_pairlog ((a, b) : State.log' * State.log') : Json_parser.pairlog' = 
  {first = a; second = b}

(**
 * Handles a message s
 *
 * requires: [s] is "init" or is another command
 * returns: a string which is a json that is our pairlog from [s]
 * effects: our state is changed accordingly
 *)
let handle_message s = match s with 
  |"init" -> start_logs () |> Yojson.Basic.to_string
  | _ -> (let scommand = Json_parser.parsesentcommand (s |> Yojson.Basic.from_string) in 
      State.do_command scommand.id scommand.command gamestate |> to_pairlog 
      |> Json_parser.tojsonpairlog |> Yojson.Basic.to_string
    ) 

(**
 * Helper method to get my ip address
 *)
let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0)

(**
 * Handles a connection
 *
 * requires: ic, oc are [input_channel] and [output_channel]
 * effects: creates a loop that responds to the input and output channels
 *)
let handle_connection ic oc=
   try while true do
       let s = input_line ic in
       let reply = handle_message s in
       output_string oc (reply); flush oc
       done
   with _ -> Printf.printf "Connection closed" ;
             flush Pervasives.stdout;
             exit 0

(**
 * Instantiates a server
 * 
 * requires: serv_fun is a valid server function, port is an int
 * effects: creates a server at 127.0.0.1:port
 *)
let main_server serv_fun port=
   try
   let addr = ADDR_INET ((inet_addr_of_string "127.0.0.1"), port)
   in establish_server handle_connection addr
       with
         Failure _ ->
         Printf.eprintf "Bad port, server not loaded\n"

let start_server port=
    print_string ("Server created at 127.0.0.1:" ^ (string_of_int port));
    Unix.handle_unix_error main_server handle_connection port

let _ = 
  print_string ("Current local ip address is: " ^  string_of_inet_addr (get_my_addr ()) ^ "\n");
  print_string "Please enter you desired server port: ";
  let port = read_int () in 
    start_server port
