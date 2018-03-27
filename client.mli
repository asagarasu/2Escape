module type Client = sig

	val is_connected : bool
	
	(** obtain input-output channels for a socket*)
	val open_connection : 
	Unix.sockaddr -> in_channel * out_channel = <fun>
	
	(**close the socket*)
	val shutdown_connection : in_channel -> unit = <fun>
	
	(**building a client that can both send and receive message*)
	val main_client : (in_channel -> 'a) -> (out_channel -> unit) -> unit = <fun>

	(**copies from one channel to another*)
	val copy_channels : in_channel -> out_channel -> unit = <fun>

	(**send the message*)
	val send : in_channel -> out_channel -> unit = <fun>

	(**receive the message*)
	val receive : out_channel -> in_channel -> unit = <fun>
	
	(**main client function collects name of input and output file*)
	val go_client : unit -> unit = <fun>
	
	(**return whether the client is connected*)	
	val is_connected : Client -> bool
end