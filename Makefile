build:  
	ocamlbuild -use-ocamlfind GUI.cmi 
interfacezip:
	zip interfaces.zip *.mli*