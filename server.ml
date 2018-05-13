open Unix
open Lwt
open Lwt_io
open Init

let counter = ref 0
let player1 = ref (ADDR_UNIX "")
let player2 = ref (ADDR_UNIX "")
let player1_file = ref descr_of_out_channel (Pervasives.open_out "fake.txt")
let player2_file = ref descr_of_out_channel (Pervasives.open_out "fake.txt")
let fake_def' = descr_of_out_channel (Pervasives.open_out "fake.txt")
let descr = Lwt_unix.of_unix_file_descr fake_def'
let oc1 = ref (Lwt_io.of_fd Lwt_io.Output descr)
let oc2 = ref (Lwt_io.of_fd Lwt_io.Output descr)
let state1 = ref false
let state2 = ref false
let tell = ref false 
let play = ref true 

let () = Lwt_log.add_rule "*" Lwt_log.Info

(* type of server. input channels and outputchannel *)
type t = in_channel list * out_channel

(**get the ip address of the local computer*)
let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0) ;;

(**temporary function try to read the msg and use handle_connection 
 *to do some simple calculation*)
let handle_message msg =
	let playerid = if (!play = true) then 1 else 2 in
	do' playerid msg

let reinit () =
	(if (!play := true) then Lwt_unix.close player2_file
	else Lwt_unix.close player1_file);
	player1 := ref (ADDR_UNIX "")
    player2 := ref (ADDR_UNIX "")
	
(**process input and output*)	
let rec handle_connection ic oc1 oc2 () =
    Lwt_io.read_line_opt ic >>=
    (fun msg ->
        match msg with
        | Some msg ->
            let reply = handle_message msg in
			match reply with 
			|re1,re2 ->
             Lwt_io.write_line oc1 re1;
			 Lwt_io.write_line oc2 re2
			>>= handle_connection ic oc1 oc2
        | None -> reinit (); Lwt_log.info "Connection closed" >>= return)

let start oc1 oc2=
	Lwt_io.write_line oc1 "start";
	Lwt_io.write_line oc2 "start";
	tell := true
	
let accept_connection conn =
    let fd, sockaddr = conn in 
	if (!state1 = false) then (player1 := sockaddr; 
	oc1 := Lwt_io.of_fd Lwt_io.Output fd; player1_file := fd; state1:=true);
	if (!player1 <> sockaddr && !state1 = true && !state2 = false)
	then (player2 := sockaddr;
	oc2 := Lwt_io.of_fd Lwt_io.Output fd; player2_file := fd; state2:=true);
    (if (!player1 = sockaddr) then play := true else play := false);
    let ic = Lwt_io.of_fd Lwt_io.Input fd in
	let oc1'= !oc1 in let oc2'= !oc2 in
	if (!tell = false && !state1 = true && !state2 = true) then start oc1' oc2';
    Lwt.on_failure (handle_connection ic oc1' oc2' ()) 
	(fun e -> Lwt_log.ign_error (Printexc.to_string e));
    Lwt_log.info "New connection" >>= return

(**create the socket*)
let create_socket (port : int) =
    let open Lwt_unix in
    let sock = socket PF_INET SOCK_STREAM 0 in
    ignore(bind sock @@ ADDR_INET (inet_addr_of_string "127.0.0.1", port));
    listen sock 10;
    sock

(**read the message and send out*)
let create_server_help sock =
    let rec serve () =
        Lwt_unix.accept sock >>= accept_connection >>= serve
    in serve

let create_server (port : int) : unit =
    let sock = create_socket port in
    let serve = create_server_help sock in
    Lwt_main.run @@ serve ()

let () = create_server 8080