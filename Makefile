build:  
	ocamlbuild -use-ocamlfind GUI.byte && ./GUI.byte
interfacezip:
	zip interfaces.zip *.mli*
test:
	ocamlbuild -use-ocamlfind test_gui.byte && ./test_gui.byte
	js_of_ocaml test_gui.byte