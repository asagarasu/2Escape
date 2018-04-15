open Types

type t = unit

type item

type command =
| Go of {u : bool; r : bool; l : bool; d : bool}
| Take of item
| Drop of item
