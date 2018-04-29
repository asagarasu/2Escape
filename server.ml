open Unix

let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0) ;;

let print_out ic oc =
   try while true do
         let s = input_line ic in
          output_string oc (s^"\n") ; flush oc
       done
   with _ -> Printf.printf "End of text\n" ;
              flush Pervasives.stdout;
               exit 0 ;;

let main_server  serv_fun =
   try
   let ip = "10.131.16.128" in
   let port = 40005 in
   let addr = ADDR_INET ((inet_addr_of_string ip), port)
   in establish_server print_out addr
       with
         Failure _ ->
         Printf.eprintf "serv_up : bad port number\n" ;;

let start_server () =
   Unix.handle_unix_error main_server print_out;;
