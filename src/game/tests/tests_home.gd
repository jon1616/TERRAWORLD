class_name TestsHome
extends RefCounted
## Prove della Roadmap 8 nel Giardino vero (`-- --prove --prova-giardino`: una partita nuova, come dal menu, con il
## gene «brina» per il primo Seme). Voce 62: l'isola nel Vuoto con l'Albero-Madre e l'Aiuola, niente creature né
## firma, il primo Seme dall'Albero, il portale verso il primo mondo (vigore 1), il Vuoto che respinge chi cade;
## foto 101_giardino.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await garden()
	await stages()


func garden() -> void:
	var g: Giardino = m.giardino
	var grass := 0
	for x in world.w:
		if TileDefs.is_grass(world.tile(x, world.surface[x])):
			grass += 1
	print("Giardino: %d×%d, Giardino attivo %s, Albero-Madre %s, Aiuole %d, partenza %s sull'isola %s, colonne d'erba %d, alberi %d, creature %d, firma %s, casa %s" % [
		world.w, world.h, "sì" if g.active else "NO", world.stations.get(g.tree_o, "NESSUNO"), m.aiuole.count(), world.spawn,
		"sì" if world.solid(world.spawn.x, world.spawn.y + 1) else "NO", grass, _trees(), m.fauna.list.size(),
		m.world_meta.get("firma", {}), "sì" if m.aiuole.is_home() else "NO"])
	m.snap_to(world.spawn)
	m.boons.add("bagliore", 5.0)
	await kit.seconds(0.8)
	await kit.save("101_giardino")
	# il primo Seme
	var b := kit.bisaccia()
	var s0 := b.count("seme_mondo") + b.count("seme_mondo_brina")
	g.touch_tree(g.tree_o)
	var seed_slot := -1
	for i in b.slots.size():
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "seme_mondo":
			seed_slot = i
	var dati: Dictionary = b.data_at(seed_slot) if seed_slot >= 0 else {}
	print("primo Seme: %s, geni %s, vigore %d" % [b.id_at(seed_slot) if seed_slot >= 0 else "NESSUNO", dati.get("geni", []),
		int(dati.get("vigore", 0))])
	m.guardian.lore.visible = false
	# nell'Aiuola: il portale verso il primo mondo
	var ai := Vector2i(-1, -1)
	for o in world.stations:
		if world.stations[o] == "aiuola":
			ai = o
	var planted := false
	var dest := []
	if ai.x >= 0 and seed_slot >= 0:
		m.snap_to(ai + Vector2i(-2, 3))
		kit.hold(b.id_at(seed_slot))
		planted = m.portal.plant(ai + Vector2i(1, 2), m.hud.current()["id"])
		await kit.frames(2)
		if world.stations.get(ai, "") == "portale":
			dest = m.portal.destination(ai)
	print("nell'Aiuola: piantato %s, portale %s verso «%s» (vigore %s)" % ["sì" if planted else "NO",
		"sì" if world.stations.get(ai, "") == "portale" else "NO", dest[1] if dest.size() > 1 else "-", dest[3] if dest.size() > 3 else "-"])
	# il Vuoto
	m.snap_to(Vector2i(world.spawn.x, mini(world.h - 3, int(m.world_meta["isola_fondo"]) + Giardino.FALL + 4)))
	await kit.seconds(0.5)
	var back: bool = m.player.position.distance_to(m.cell_to_feet(world.spawn)) < 3 * S
	print("caduta nel Vuoto: respinto all'Albero %s" % ("sì" if back else "NO"))
	if not g.active or not world.stations.get(g.tree_o, "").begins_with("albero_madre") or seed_slot < 0 or not planted \
			or int(dati.get("vigore", 0)) != 1 or not "brina" in dati.get("geni", []) or not back or m.fauna.list.size() > 0:
		print("ATTENZIONE: il Giardino non funziona come dovrebbe")


func _trees() -> int:
	var n := 0
	for k in world.trees:
		n += (world.trees[k] as Array).size()
	return n


## Voce 63: gli stadi dell'Albero-Madre. Il primo stadio con le offerte vere (legno e humus dalla Bisaccia, il primo
## viaggio), il pannello (foto 102_albero), poi tutti gli altri stadi fino al risveglio (foto 103_albero_sveglio):
## Aiuole, disegno dell'Albero, poteri, abitanti e categorie d'innesto crescono con gli stadi.
func stages() -> void:
	var am: AlberoMadre = m.albero
	var b := kit.bisaccia()
	kit.make_room()
	var ai0: int = m.aiuole.max_aiuole()
	var line0 := String(am._label.text)
	am.open()
	await kit.frames(4)
	await kit.save("102_albero")
	am.panel.visible = false
	var ready0 := am.ready_to_wake()
	b.add("legno", 20)
	var given1 := am.offer()
	b.add("legno", 15)
	b.add("humus", 30)
	var given2 := am.offer()
	var ready1 := am.ready_to_wake()
	m.character.stats["viaggi"] = 1
	var woke := am.awaken()
	await kit.frames(3)
	var ph1: String = world.stations.get(m.giardino.tree_o, "")
	print("Albero-Madre: all'inizio pronto %s; offerti %d poi %d (pronto senza il viaggio: %s); dopo il viaggio si sveglia %s → stadio %d, Aiuole %d → %d, disegno %s; la riga dice «%s»" % [
		"sì (sbagliato)" if ready0 else "no", given1, given2, "sì (sbagliato)" if ready1 else "no", "sì" if woke else "NO",
		am.stage(), ai0, m.aiuole.max_aiuole(), ph1, line0])
	m.guardian.lore.visible = false
	# gli altri stadi: si danno le offerte e i traguardi richiesti
	var grafts0: Array = am.graftable()
	while not am.done():
		var st: Dictionary = am.current()
		for o in st["offers"]:
			if o.has("item"):
				b.add(String(o["item"]), int(o["n"]))
			else:
				m.character.stats[String(o["stat"])] = maxi(int(m.character.stats.get(String(o["stat"]), 0)), int(o["n"]))
		am.offer()
		if not am.awaken():
			print("ATTENZIONE: lo stadio «%s» non si sveglia" % st["name"])
			break
		m.guardian.lore.visible = false
		kit.make_room()
	await kit.frames(3)
	m.snap_to(m.giardino.tree_o + Vector2i(-4, 12))
	m.boons.add("bagliore", 4.0)
	await kit.seconds(0.8)
	await kit.save("103_albero_sveglio")
	print("risveglio: stadio %d, disegno %s, Aiuole %d, poteri %s, abitanti %s, categorie d'innesto %d → %d" % [am.stage(),
		world.stations.get(m.giardino.tree_o, ""), m.aiuole.max_aiuole(), MotherTreeData.gifts(am.stage(), "power"),
		MotherTreeData.gifts(am.stage(), "npc"), grafts0.size(), am.graftable().size()])
	if ready0 or not woke or am.stage() != MotherTreeData.STAGES.size() or ph1 != "albero_madre_1" \
			or m.aiuole.max_aiuole() != 1 + MotherTreeData.aiuole(am.stage()) or am.graftable().size() != GenesData.CATEGORIES.size():
		print("ATTENZIONE: gli stadi dell'Albero-Madre non funzionano come dovrebbero")
