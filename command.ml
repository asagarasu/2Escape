type direction = | Left | Right | Up | Down

type command =
| Go of direction
| Take of string
| Drop of string
| Message of string