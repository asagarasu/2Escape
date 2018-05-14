open Unix

type t = in_channel * out_channel

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

let copy_channels ic oc =
   try while true do
         let s = input_line ic
         in if s = "END" then raise End_of_file
            else (output_string oc (s^"\n"); flush oc)
       done
   with End_of_file -> () ;;

let child_fun in_file out_sock =
   copy_channels in_file out_sock ;
   output_string out_sock ("FIN\n") ;
   flush out_sock ;;

let parent_fun out_file in_sock = copy_channels in_sock out_file ;;

let create_client client_parent_fun client_child_fun (ip : string) =
  let port = 40003 in
  let addr = ADDR_INET ((inet_addr_of_string ip), port)
  in let ic,oc = open_connection addr
     in match Unix.fork () with
        |0 -> if Unix.fork() = 0 then client_child_fun oc ;
              exit 0
        | id -> client_parent_fun ic ;
                shutdown_connection ic ;
                ignore (Unix.waitpid [] id)

let go_client (ip : string) =
	let in_file = open_in "in.txt"
    and out_file = open_out "out.txt"
    in create_client (parent_fun out_file) (child_fun in_file) (ip : string) ;
    close_in in_file ;
    close_out out_file ;;
