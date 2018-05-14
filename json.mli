open Printf
open Helper
open State
open Yojson

type pairlog' = {first : log'; second : log'}

val parsepairlog : json -> pairlog'

val tojsonpairlog : pairlog' -> json

val parselog : json -> log'

val tojsonlog : log' -> json

val parsecommand : json -> command

val tojsoncommand : command -> json