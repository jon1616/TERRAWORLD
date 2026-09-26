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
