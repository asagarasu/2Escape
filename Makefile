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
	ocamlbuild -use-ocamlfind cutscene.cmo -r
	ocamlbuild -use-ocamlfind state.cmo -r
	ocamlbuild -use-ocamlfind json.cmo -r
	ocamlbuild -use-ocamlfind init.cmo -r
gui:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links GUI.d.js
client:
	ocamlbuild -use-ocamlfind clienttest.byte && ./clienttest.byte
server:
	ocamlbuild -use-ocamlfind server.byte && ./server.byte
