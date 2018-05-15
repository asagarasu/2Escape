open Unix
open Lwt
open Lwt_io
open Init

let () = Lwt_log.add_rule "*" Lwt_log.Info

(**get the ip address of the local computer*)
let get_my_addr () =
  (Unix.gethostbyname(Unix.gethostname())).Unix.h_addr_list.(0) ;;

(**temporary function try to read the msg and use handle_connection
 *to do some simple calculation*)
let handle_message msg = do' msg

(**process input and output*)
let rec handle_connection ic oc () =
  Lwt_io.read_line_opt ic >>=
  (fun msg ->
     match msg with
     | Some msg ->
       let reply = handle_message msg in
          Lwt_io.write_line oc reply;
          >>= handle_connection ic oc
     | None -> Lwt_log.info "Connection closed" >>= return)

let accept_connection conn =
  let fd, sockaddr = conn in
  let ic = Lwt_io.of_fd Lwt_io.Input fd in
  let oc = Lwt_io.of_fd Lwt_io.Output fd in
  Lwt.on_failure (handle_connection ic oc ())
    (fun e -> Lwt_log.ign_error (Printexc.to_string e));
  Lwt_log.info "New connection" >>= return

(**create the socket*)
let create_socket (port : int) =
  let open Lwt_unix in
  let sock = socket PF_INET SOCK_STREAM 0 in
  bind sock @@ ADDR_INET (inet_addr_of_string "127.0.0.1", port);
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

let _ = create_server 8080
