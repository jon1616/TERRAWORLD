extends Node
## Autoload `Session`: la scelta fatta nel menu (personaggio e mondo) passata alla scena di gioco.

var character: Character
## Mondo salvato da caricare ("" se il mondo va creato).
var world_id := ""
## Mondo da creare: {"id", "nome", "seme"}.
var new_world := {}
## Prove automatiche: salvataggi in una cartella a parte, mondo fisso.
var test_mode := false
## Prova del viaggio tra i mondi: a che tappa si è (sopravvive al cambio di scena).
var test_hops := 0


## `extra`: dati in più per il mondo nuovo (dal portale: "vigore" e "ritorno" = id del mondo d'origine).
func start_new_world(world_name: String, sd: int, id := "", extra := {}) -> void:
	world_id = ""
	new_world = {"id": id if id != "" else SavePaths.new_id(world_name), "nome": world_name, "seme": sd}
	new_world.merge(extra)


func start_saved_world(id: String) -> void:
	world_id = id
	new_world = {}
