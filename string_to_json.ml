open Printf

(* [save_one] can take in a single log and save it locally to [one_log.json]
   It would be ready to use. *)
let save_one l =
  let file = "one_log.json" in
  let message = l in
  let oc = open_out file in
  fprintf oc "%s\n" message;
  close_out oc;
