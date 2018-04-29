open Unix

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

let create_client () =
let ip = "10.131.16.128" in
let port = 40005 in
let addr = ADDR_INET ((inet_addr_of_string ip), port)
in let ic,oc = open_connection addr
   in client_fun ic oc ;
      shutdown_connection ic