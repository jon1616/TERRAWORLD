class_name TestsChallenges
extends RefCounted
## Prove delle sfide dei Semi (voce 82): il Sigillo va su un portale mai attraversato; «Senza torce» spegne le torce;
## «Vita fragile» dimezza la Vita e la rende alla vittoria, che dà premio, medaglia e record; «Contro il tempo» si perde
## allo scadere; «Senza ritorno» si perde appassendo; «Solo antiche» accende la regola della fauna; i record del
## personaggio. Foto 149_sfida.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _start(cid: String, lvl: int) -> void:
	var cg: Challenges = m.challenges
	Challenges.start(m.world_meta, cid, lvl)
	cg.state = m.world_meta["sfida"]
	cg.apply()


func run() -> void:
	var cg: Challenges = m.challenges
	var ch: Character = m.character
	var rec0: Dictionary = ch.sfide.duplicate(true)
	m.snap_to(world.spawn)
	await kit.seconds(0.2)
	m.vitals.refill()
	# il Sigillo su un portale finto, mai attraversato
	var o := world.spawn + Vector2i(3, -3)
	world.stations[o] = "portale"
	m.portal._portals()[Portal._key(o)] = {"mondo": "", "seme": 7, "ritorno": false, "geni": [], "vigore": 2}
	kit.bisaccia().add("sigillo_sfida_tempo", 1)
	var sealed := cg.seal_portal(o, "sigillo_sfida_tempo")
	var carried := String(m.portal._portals()[Portal._key(o)].get("sfida", ""))
	m.portal._portals().erase(Portal._key(o))
	world.stations.erase(o)
	# Senza torce
	_start("buio", 1)
	var spot := kit.floor_near(world.spawn + Vector2i(6, 0), 8)
	var t0: int = world.torches.size()
	m.actions.place_torch(spot)
	var no_torch: bool = world.torches.size() == t0
	await kit.seconds(0.3)
	await kit.save("149_sfida")
	var shown: bool = cg._label.visible and cg._label.text.contains("Senza torce")
	cg.lose("prova")
	var torch_back: bool = not m.actions.no_torches
	# Vita fragile, poi vinta
	var hp0: int = m.vitals.hp_max
	_start("fragile", 1)
	var hp_half: int = m.vitals.hp_max
	cg.state["t"] = 95.0
	var rec: Dictionary = cg.win()
	var hp_back: int = m.vitals.hp_max
	# Contro il tempo, allo scadere
	_start("tempo", 1)
	cg.state["t"] = ChallengesData.limit(1) + 1.0
	await kit.frames(3)
	var timed_out := String(cg.state["stato"]) == "persa"
	# Senza ritorno
	_start("senza_ritorno", 1)
	cg._on_died()
	var fell := String(cg.state["stato"]) == "persa"
	# Solo antiche
	_start("antiche", 2)
	var ancient_rule: bool = m.fauna.force_ancient
	cg.lose("prova")
	var lines := Challenges.records(ch)
	var next := cg.next_level("fragile")
	# si rimette tutto com'era
	m.world_meta.erase("sfida")
	cg.state = {}
	cg.apply()
	ch.sfide = rec0
	m.vitals.refill()
	print("sfide: sigillo messo %s (porta «%s»); senza torce: torcia negata %s, riga %s, poi tornano %s; fragile: Vita %d → %d → %d, record %s; tempo scaduto %s; senza ritorno perso %s; solo antiche %s; prossimo livello di fragile %d; record: %s" % [
		"sì" if sealed else "NO", carried, "sì" if no_torch else "NO", "sì" if shown else "NO", "sì" if torch_back else "NO",
		hp0, hp_half, hp_back, rec, "sì" if timed_out else "NO", "sì" if fell else "NO", "sì" if ancient_rule else "NO", next, lines[4]])
	if not sealed or carried != "tempo" or not no_torch or not shown or not torch_back or hp_half >= hp0 or hp_back != hp0 \
			or int(rec.get("vinte", 0)) != 1 or not timed_out or not fell or not ancient_rule or next != 2 or lines.size() != 6:
		print("ATTENZIONE: le sfide dei Semi non funzionano come dovrebbero")
