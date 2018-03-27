module type Server = sig
	
	val address : string
	val port : int
	val is_connected : bool

	(**set up connection to the server*)
	val establish_server :
	(in_channel -> out_channel -> 'a) -> Unix.sockaddr -> unit = <fun>
	
	(**return the address of local machine*)
	val get_my_addr : unit -> Unix.inet_addr = <fun>
	
	(** build a server that takes a port number parameter*)
	val main_server : (in_channel -> out_channel -> 'a) -> unit = <fun>

	(**send the message to the client*)
	val send : in_channel -> out_channel -> unit = <fun>

	(**receive the message from the client*)
	val receive : out_channel -> in_channel -> unit = <fun>

	(**return whether the server is connected*)	
	val is_connected : Server -> bool

end