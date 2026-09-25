class_name TestsObjectives
extends RefCounted
## Prove degli obiettivi (voce 16): alla fine delle altre prove molti traguardi sono raggiunti (oggetti, stazioni,
## strati, Guardiano); si controlla che scattino, che diano la ricompensa e che si salvino con il personaggio.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var o: Objectives = m.objectives
	var before: int = m.character.bisaccia.count("pozione_rugiada")
	o.paused = false
	var n := o.check_all()
	print("obiettivi: %d raggiunti ora, %d su %d in tutto: %s" % [n, m.character.obiettivi.size(),
		ObjectivesData.LIST.size(), m.character.obiettivi])
	print("ricompense: pozioni di rugiada da %d a %d" % [before, m.character.bisaccia.count("pozione_rugiada")])
	await kit.seconds(0.5)
	await kit.save("34_obiettivi")
	m.save_game()
	var saved := Character.load_id(m.character.id)
	print("obiettivi salvati con il personaggio: %s" % ("sì" if saved != null and saved.obiettivi == m.character.obiettivi and saved.stats == m.character.stats else "NO"))
