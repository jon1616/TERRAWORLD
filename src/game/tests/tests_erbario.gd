class_name TestsErbario
extends RefCounted
## Prove dell'Erbario (voce 14): dopo tutte le altre prove ci sono creature sconfitte, oggetti visti e pagine lette;
## il pannello si apre sulle creature (foto 33_erbario) e le scoperte si salvano con il personaggio.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var e: Erbario = m.erbario
	print("Erbario: %d%% (creature %d%%, oggetti %d%%, pagine %d%%), creature sconfitte %s" % [roundi(e.percent()),
		roundi(e.percent("creature")), roundi(e.percent("oggetti")), roundi(e.percent("pagine")),
		(e.data["creature"] as Dictionary).keys()])
	var ep: ErbarioPanel = m.hud.overlays[0]
	ep.toggle()
	ep.selected = "guardiano_nodo"
	ep._refresh()
	await kit.seconds(1.0)
	await kit.save("33_erbario")
	ep.toggle()
	m.save_game()
	var saved := Character.load_id(m.character.id)
	print("Erbario salvato con il personaggio: %s" % ("sì" if saved != null and saved.erbario == m.character.erbario else "NO"))
