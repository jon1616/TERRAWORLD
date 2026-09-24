class_name GenPass
extends RefCounted
## Una passata del generatore di mondi. Ogni passata fa una cosa sola (terreno, grotte, minerali…), legge ciò che hanno
## fatto le precedenti e si può sostituire o spostare senza toccare le altre. Si aggiunge in `WorldGen.PASSES`.


func title() -> String:
	return "passata"


func run(_w: World, _c: GenContext) -> void:
	pass
