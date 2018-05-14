open Helper
open State
open Yojson

type pairlog' = {first : log'; second : log'}

val parselog : Yojson.Basic.json -> log'

val tojsonlog : log' -> json

val parsepairlog : json -> pairlog'

val tojsonpairlog : pairlog' -> json

val parsecommand : json -> command

val tojsoncommand : command -> json
