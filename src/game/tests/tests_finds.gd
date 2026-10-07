class_name TestsFinds
extends RefCounted
## I ritrovamenti (Roadmap 45, voci 392-396). Gruppo «ritrovamenti».
## I dati (un raro per specie, le casse e le chiavi di ogni bioma, i mimi, le trasformazioni della Pozza), il mondo di
## prova (casse dei biomi nelle rovine, la Pozza), e in gioco: la cassa sigillata chiede la chiave, il mimo si sveglia,
## la Pozza trasforma, un raro cade.

var kit: TestKit
var m: Node2D
var res := {}


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	data()
	world()
	await sealed_and_mimic()
	structures()
	pool()
	rare()
	print("ritrovamenti: %s" % str(res))
	if not res.values().all(func(x: Variant) -> bool: return x == true):
		print("ATTENZIONE: i ritrovamenti non vanno come dovrebbero")


func data() -> void:
	var rares := 0
	var bad := []
	for id in ItemsData.all():
		var it: Dictionary = ItemsData.all()[id]
		if it.has("raro_di"):
			rares += 1
			if not CreaturesData.CREATURES.has(String(it["raro_di"])):
				bad.append(id)
	var biomes := BiomesData.BIOMES.size() + BiomesData.UNDER.size() + BiomesData.SKY.size()
	var chests := 0
	var keys := 0
	for e in ChestsData.FOUND:
		if e.has("biome"):
			chests += 1
			if e.has("key") and ItemsData.has(String(e["key"])):
				keys += 1
	res["dati"] = rares >= 250 and bad.is_empty() and chests == biomes * 2 and keys == biomes \
		and ChestsData.MIMICS.size() == biomes and TransmuteData.count() >= 700
	print("ritrovamenti, i dati: rari %d (senza specie %s), casse dei biomi %d (biomi %d), chiavi %d, mimi %d, trasformazioni %d" % [
		rares, str(bad), chests, biomes, keys, ChestsData.MIMICS.size(), TransmuteData.count()])


func world() -> void:
	var biome_chests := 0
	var mimics := 0
	var pools := 0
	for o in m.world.stations:
		var sid := String(m.world.stations[o])
		if sid == "pozza_linfa":
			pools += 1
		elif not ChestsData.mimic_of(sid).is_empty():
			mimics += 1
		elif ChestsData.info(sid).has("biome"):
			biome_chests += 1
	res["mondo"] = biome_chests >= 3 and pools == 1
	print("ritrovamenti, il mondo di prova: casse dei biomi %d, mimi %d, Pozza %d" % [biome_chests, mimics, pools])


## Voce 394: le strutture del mondo di prova (con il tesoro del bioma) e il guardiano che si sveglia.
func structures() -> void:
	var list: Array = m.world.gen_notes.get("strutture", [])
	var with_treasure := 0
	for e in list:
		var b := String(PlacesData.PLACES[String(e["id"])]["biome"])
		var rect := Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"]))
		for o in m.world.stations:
			if String(m.world.stations[o]) == "scrigno" and rect.has_point(o):
				for it in LootData.items_of("cassa_" + b):
					if m.world.chest_at(o).count(String(it)) > 0:
						with_treasure += 1
						break
	var n_all := 0
	for id in PlacesData.PLACES:
		if PlacesData.PLACES[id].get("struttura", false):
			n_all += 1
	var pc := Vector2i(floori(m.player.position.x / 16.0), floori(m.player.position.y / 16.0))
	var fake := {"id": "str_foresta_1", "x": pc.x + 2, "y": pc.y - 6, "w": 20, "h": 8}
	var g: Creature = m.finds.guard(fake)
	var guard_ok := g != null and g.ancient != null
	if g != null:
		m.fauna.kill(g)
	res["strutture"] = n_all >= 100 and list.size() >= 2 and with_treasure == list.size() and guard_ok
	print("ritrovamenti, le strutture: %d in tutto, %d nel mondo di prova (%s), con il tesoro del bioma %d; il guardiano %s" % [
		n_all, list.size(), str(list.map(func(e: Dictionary) -> String: return String(e["id"]))), with_treasure,
		Finds.strongest_of("foresta")])


## Una cassa sigillata chiede la chiave e la consuma; un mimo si sveglia quando lo tocchi.
func sealed_and_mimic() -> void:
	var b: Bisaccia = m.character.bisaccia
	var at: Vector2i = Vector2i(floori(m.player.position.x / 16.0) + 4, floori(m.player.position.y / 16.0) - 1)
	m.world.stations[at] = "cassa_foresta_sigillata"
	var keys0 := b.count("chiave_foresta")
	if keys0 > 0:
		b.remove("chiave_foresta", keys0)
	var blocked: bool = m.finds.touch(at, "cassa_foresta_sigillata")
	b.add("chiave_foresta", 1)
	var opens: bool = not m.finds.touch(at, "cassa_foresta_sigillata")
	var used := b.count("chiave_foresta") == 0
	var again: bool = not m.finds.touch(at, "cassa_foresta_sigillata")      # aperta una volta, resta aperta
	m.world.stations.erase(at)
	m.world.chests.erase(at)
	m.view.remove_station(at)
	var n0: int = m.fauna.list.size()
	m.world.stations[at] = "mimo_cassa_foresta"
	m.finds.touch(at, "mimo_cassa_foresta")
	await kit.frames(2)
	var mimic: Creature = null
	for c in m.fauna.list:
		if is_instance_valid(c) and c.id == "mimo_foresta":
			mimic = c
	var woke: bool = mimic != null and not m.world.stations.has(at) and m.fauna.list.size() == n0 + 1
	if mimic != null:
		m.fauna.kill(mimic)
	res["sigillata_mimo"] = blocked and opens and used and again and woke
	print("ritrovamenti, la cassa sigillata: chiusa senza chiave %s, si apre %s, la chiave si consuma %s, resta aperta %s; il mimo si sveglia %s" % [
		blocked, opens, used, again, woke])


## La Pozza: dopo il primo Guardiano un'arma firma diventa la seguente della sua fase.
func pool() -> void:
	var b: Bisaccia = m.character.bisaccia
	var g0 := int(m.character.stats.get("guardiani", 0))
	m.character.stats["guardiani"] = 0
	var asleep: bool = m.finds._pool()                  # dorme: gestito (true) ma nulla cambia
	m.character.stats["guardiani"] = 1
	var id := "firma_f1_0"
	var to := TransmuteData.of(id)
	kit.hold(id)
	var had := b.count(to)
	m.finds._pool()
	var ok := to != "" and b.count(to) == had + 1
	m.character.stats["guardiani"] = g0
	if b.count(to) > had:
		b.remove(to, 1)
	res["pozza"] = asleep and ok
	print("ritrovamenti, la Pozza: %s → %s %s" % [id, to, ok])


## Un raro cade (con tanta fortuna) quando si sconfigge la sua specie.
func rare() -> void:
	var sid := "lepre_linfa"
	var rid := Rares.of_species(sid)
	var luck0: float = m.fauna.luck
	m.fauna.luck = 1000.0
	var d0: int = m.rares.dropped
	var c: Creature = m.fauna.add(sid, m.player.position + Vector2(60, -4))
	m.fauna.kill(c)
	m.fauna.luck = luck0
	res["raro"] = rid != "" and m.rares.dropped == d0 + 1
	print("ritrovamenti, il raro di %s: %s, caduto %s" % [sid, rid, m.rares.dropped == d0 + 1])
