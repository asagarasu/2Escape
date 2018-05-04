open Unix

type t = in_channel * out_channel

let send_command = 
	failwith "Not Yet Implemented"

let receive_state =
	failwith "Not Yet Implemented"
	
(**
 * Temporary function to test the client-server dynamics in ocaml
 *)
let client_fun ic oc =
   try
     while true do
       print_string  "Request : " ;
       flush Pervasives.stdout ;
       output_string oc ((input_line Pervasives.stdin)^"\n") ;
       flush oc ;
       let r = input_line ic
       in Printf.printf "Response : %s\n\n" r;
          if r = "END" then ( shutdown_connection ic ; raise Exit) ;
     done
   with
       Exit -> exit 0
     | exn -> shutdown_connection ic ; raise exn  ;;

(**
 * Temporary implementation to test the client-server dynamics in ocaml
 *)
let create_client (ip : string) =
  let port = 40005 in
  let addr = ADDR_INET ((inet_addr_of_string ip), port)
  in let ic,oc = open_connection addr
    in client_fun ic oc ;
      shutdown_connection ic