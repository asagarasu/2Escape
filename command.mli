open Types

type t

type item

type trick

type character

type objects = | Item of item | Trick of trick | Character of character

type direction = | Left | Right | Up | Down

type command =
  | Go of direction
  | Take of item
  | Drop of item
  | Move of trick * direction

