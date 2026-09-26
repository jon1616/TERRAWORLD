class_name TestsChains
extends RefCounted
## Prove delle catene di ricerca (voce 69): un mondo che nasce con i geni della tappa ha la cripta con il leggio, uno
## senza no; il leggio fa avanzare la catena e dà il premio; le catene brevi nascono dai geni visti; la scheda di un
## Seme dice se porta a una cripta. Foto 129_leggio e 130_taccuino.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var ch: Character = m.character
	var had: Dictionary = ch.catene.duplicate(true)
	var had_gen: Dictionary = ch.genario.duplicate()
	ch.catene = {"lunga": {"tappa": 0, "fatta": false}, "brevi": [], "fatte": 0, "n": 0}
	var pend := Chains.pending(ch)
	# due mondi piccoli: con il gene della prima tappa e senza
	var w1 := World.new()
	WorldGen.generate(w1, 4242, 1600, 900, {"geni": ["lanterna", "radici_giganti"], "vigore": 2, "catene": pend})
	var w2 := World.new()
	WorldGen.generate(w2, 4242, 1600, 900, {"geni": ["lanterna", "cavo"], "vigore": 2, "catene": pend})
	var c1: Array = w1.gen_notes.get("cripte", [])
	var c2: Array = w2.gen_notes.get("cripte", [])
	var has_leggio: bool = c1.size() > 0 and w1.stations.get(c1[0]["leggio"], "") == "leggio"
	# il leggio nel mondo di prova: la tappa avanza, il premio arriva
	var spot := kit.flat_spot(world.spawn + Vector2i(-30, 0), 4)
	if spot.x < 0:
		spot = kit.floor_near(world.spawn + Vector2i(-30, 0), 40)
	var o := spot + Vector2i(0, -2)
	world.stations[o] = "leggio"
	(m.world_meta["cripte"] as Array).append({"catena": "lunga", "tappa": 0, "x": o.x, "y": o.y})
	var b := kit.bisaccia()
	kit.make_room()
	var tab0 := b.count("tavoletta_seminatori")
	m.chains.read(o)
	var step := int(ch.catene["lunga"]["tappa"])
	var tab1 := b.count("tavoletta_seminatori")
	await kit.frames(4)
	await kit.save("129_leggio")
	m.language.panel.visible = false
	# una seconda lettura non dà di nuovo il premio
	m.chains.read(o)
	m.language.panel.visible = false
	var again: bool = b.count("tavoletta_seminatori") == tab1 and int(ch.catene["lunga"]["tappa"]) == step
	# le brevi dai geni visti
	for g in ["cavo", "fungaie", "stellato", "pascoli"]:
		ch.genario[g] = 1
	var sh: Dictionary = m.chains.make_short()
	if not sh.is_empty():
		(ch.catene["brevi"] as Array).append(sh)
	# la scheda di un Seme per la tappa due (Avvizzito, vigore 2)
	var seed_tip := ItemTip.card({"id": "seme_mondo", "n": 1, "dati": {"geni": ["lanterna", "avvizzito"], "vigore": 2}},
		{"ch": ch}).plain()
	# il Taccuino
	var sp: SemenzaioPanel = null
	for x in m.hud.get_children():
		if x is SemenzaioPanel:
			sp = x
	if sp != null:
		sp.visible = true
		sp.tab = "catene"
		sp.selected = "lunga"
		sp.refresh()
		await kit.frames(4)
		await kit.save("130_taccuino")
		sp.visible = false
	world.stations.erase(o)
	print("catene: tappe aperte %d; mondo con Radici giganti: %d cripte (leggio %s), senza: %d; leggio: tappa 0 → %d, tavolette %d → %d, seconda lettura senza premio %s; breve «%s» (%s); il Seme della tappa dopo lo dice %s" % [
		pend.size(), c1.size(), "sì" if has_leggio else "NO", c2.size(), step, tab0, tab1, "sì" if again else "NO",
		sh.get("name", "nessuna"), sh.get("need", {}).get("geni", []), "sì" if seed_tip.contains("Porta a una cripta") else "NO"])
	if c1.is_empty() or not has_leggio or not c2.is_empty() or step != 1 or tab1 != tab0 + 2 or not again or sh.is_empty() \
			or not seed_tip.contains("Porta a una cripta"):
		print("ATTENZIONE: le catene di ricerca non funzionano come dovrebbero")
	ch.catene = had
	ch.genario = had_gen
