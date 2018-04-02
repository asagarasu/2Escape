build:  
	ocamlbuild -use-ocamlfind GUI.byte && ./GUI.byte
interfacezip:
	zip interfaces.zip *.mli*