build:  
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links GUI.d.js
	ocamlbuild -use-ocamlfind state_testing.cmo -r
interfacezip:
	zip interfaces.zip *.mli*
gui:
	ocamlbuild -use-ocamlfind -plugin-tag "package(js_of_ocaml.ocamlbuild)" -no-links GUI.d.js