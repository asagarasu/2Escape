test:
	ocamlbuild -use-ocamlfind state_test.byte && ./state_test.byte
build:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links Gui.d.js
	ocamlbuild -use-ocamlfind state.cmo -r
interfacezip:
	zip interfaces.zip *.mli*
prototype:
	zip prototype.zip *.ml* Gui.d.js index.html test.json sprites/*
state:
	ocamlbuild -use-ocamlfind state.byte &&./state.byte
gui:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links GUI.d.js
