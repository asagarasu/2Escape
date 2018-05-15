open Helper
open State
open Yojson.Basic

(*A pair of log data structure*)
type pairlog' = {first : log'; second : log'}

(*A command with attached id*)
type sentcommand = {id : int; command : command}

(** 
 * Parses a log
 *
 * requires: j is an [`Assoc] with log mapping
 * returns: parsed log
 * raises: Failure if precond broken
 *)
val parselog : json -> log'

(**
 * Sends a log to a json
 *
 * returns: an [`Assoc] with log mapping
 *)
val tojsonlog : log' -> json

(**
 * Parses a pair of logs
 *
 * requires: an [`Assoc] with pairlog' mapping
 * returns: the parsed pairlog'
 * raises: Failure if precond broken
 *)
val parsepairlog : json -> pairlog'

(**
 * Sends a pairlog to a json
 * 
 * returns: an [`Assoc] with pairlog' mapping
 *)
val tojsonpairlog : pairlog' -> json

(**
 * Parses a command. Format is [order; extrastuff if applicable]
 *
 * requires:  j is a [`List l] where l satsifies the above format
 * returns: The corresponding command
 * raises: [Failure "json is not a command"] if precondition not met
 *)
val parsecommand : json -> command

(** 
 * Sends a command to a json. Format is [order; extrastuff if applicable]
 *
 * returns: a [`List l] where l follows the above format
 *)
val tojsoncommand : command -> json

(**
 * Parses a sentcommand
 *
 * requires: an [`Assoc] with sentcommand mapping
 * returns: the parsed sentcommand
 * raises: Failure if precond broken 
 *)
val parsesentcommand : json -> sentcommand

(**
 * Sends a sentcommand to a json
 * 
 * returns: an [`Assoc] with sentcommand mapping
 *)
val tojsonsentcommand : sentcommand -> json
