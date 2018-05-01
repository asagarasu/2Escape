build:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links Gui2.d.js
	ocamlbuild -use-ocamlfind state.byte &&./state.byte
interfacezip:
	zip interfaces.zip *.mli*
gui:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links GUI.d.js
