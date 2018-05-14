open Unix
open Init

let handle_message msg = do' msg

let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0) ;;

let handle_connection ic oc=
   try while true do
       let s = input_line ic in
       let reply = handle_message s in
       output_string oc reply ;flush oc
       done
   with _ -> reinit ();
             Printf.printf "Connection closed" ;
             flush Pervasives.stdout;
             exit 0 ;;

let main_server serv_fun port=
   try
   let port = port in
   let addr = ADDR_INET (get_my_addr (), port)
   in establish_server handle_connection addr
       with
         Failure _ ->
         Printf.eprintf "bad port number\n" ;;

let start_server port=
   Unix.handle_unix_error main_server handle_connection port;;
