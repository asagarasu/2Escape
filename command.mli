open Types

type t

type item

type command =
| Go of {u : bool; r : bool; l : bool; d : bool}
| Take of item
| Drop of item


