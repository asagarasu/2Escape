open Helper
open State
open Yojson.Basic

type pairlog' = {first : log'; second : log'}

type sentcommand = {id : int; command : command}

val parselog : json -> log'

val tojsonlog : log' -> json

val parsepairlog : json -> pairlog'

val tojsonpairlog : pairlog' -> json

val parsecommand : json -> command

val tojsoncommand : command -> json

val parsesentcommand : json -> sentcommand

val tojsonsentcommand : sentcommand -> json
