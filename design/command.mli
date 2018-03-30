open Types

type item

type command =
| Go of {u : bool; r : bool; l : bool; d : bool}
<<<<<<< HEAD
| Take of string
| Drop of string
=======
| Take of item
| Drop of item
>>>>>>> 18d82ef29d3dcb02a20d28b4de5b04c8a536bd66
