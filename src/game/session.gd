extends Node
## Autoload `Session`: la scelta fatta nel menu (personaggio e mondo) passata alla scena di gioco.

var character: Character
## Mondo salvato da caricare ("" se il mondo va creato).
var world_id := ""
## Mondo da creare: {"id", "nome", "seme"}.
var new_world := {}
## Prove automatiche: salvataggi in una cartella a parte, mondo fisso.
var test_mode := false


func start_new_world(world_name: String, sd: int, id := "") -> void:
	world_id = ""
	new_world = {"id": id if id != "" else SavePaths.new_id(world_name), "nome": world_name, "seme": sd}


func start_saved_world(id: String) -> void:
	world_id = id
	new_world = {}
