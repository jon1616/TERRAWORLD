class_name TestsRelics
extends RefCounted
## Prove della voce 28: dodici reliquiari murati con la loro reliquia, aprirne uno lo segna, una collezione completa
## dà il bonus per sempre, la Mappa dei Seminatori indica e rivela il reliquiario più vicino; i geodi; foto
## 53_nascondiglio e 54_geode.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var rel := []
	var with_relic := 0
	for o in world.stations:
		if world.stations[o] == "reliquiario":
			rel.append(o)
			for s in world.chest_at(o).slots:
				if not s.is_empty() and RelicsData.collection_of(String(s["id"])) != "":
					with_relic += 1
	print("reliquiari: %d, con una reliquia dentro %d (reliquie in tutto %d)" % [rel.size(), with_relic,
		RelicsData.ITEMS.size() - 1])
	if rel.is_empty():
		print("ATTENZIONE: nessun reliquiario nel mondo")
		return
	# la Mappa dei Seminatori: indica il più vicino e lo rivela sulla mappa
	var b: Bisaccia = m.character.bisaccia
	b.add("mappa_seminatori", 1)
	kit.hold("mappa_seminatori")
	var ok: bool = m.interact._use("mappa", "mappa_seminatori", m.player_cell())
	var near: Vector2i = rel[0]
	for o in rel:
		if (Vector2(o) * S).distance_to(m.player.position) < (Vector2(near) * S).distance_to(m.player.position):
			near = o
	print("Mappa dei Seminatori: usata %s, reliquiario più vicino rivelato sulla mappa %s" % ["sì" if ok else "NO",
		"sì" if world.explored[near.y * world.w + near.x] != 0 else "NO"])
	# dentro il nascondiglio: si apre il reliquiario
	m.snap_to(near + Vector2i(-1, 1))
	m.boons.add("bagliore", 30.0)
	await kit.seconds(2.0)
	await kit.save("53_nascondiglio")
	m.interact.touch(near)
	print("reliquiario aperto e segnato: %s" % ("sì" if "%d,%d" % [near.x, near.y] in m.world_meta.get("reliquiari_aperti", []) else "NO"))
	m.interact.chest_panel.close()              # (con close: spegnerla a mano lasciava «Creare» nascosto)
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	# una collezione completa: gli Attrezzi dei Seminatori
	var dig0: float = m.actions.dig_mult
	for p in RelicsData.COLLECTIONS["attrezzi"]["pieces"]:
		b.add(String(p), 1)
	await kit.frames(2)
	print("collezione Attrezzi completa: %s, scavo ×%.2f → ×%.2f" % [m.gear.relics, dig0, m.actions.dig_mult])
	for p in RelicsData.COLLECTIONS["attrezzi"]["pieces"]:
		b.remove(String(p), 1)
	await kit.frames(1)
	print("tolte dalla Bisaccia: il bonus resta %s" % ("sì" if "attrezzi" in m.gear.relics else "NO"))
	# un geode: gemme sul fondo di una sfera di cristalli
	var geo := Vector2i(-1, -1)
	var bd := 1e18
	for i in world.decor.size():
		if world.decor[i] == TileDefs.DECOR_GEMS[0] or world.decor[i] == TileDefs.DECOR_GEMS[2]:
			var c := Vector2i(i % world.w, i / world.w)
			if world.tile(c.x, c.y + 1) == TileDefs.CRYSTAL:
				var d := Vector2(c - world.spawn).length_squared()
				if d < bd:
					bd = d
					geo = c
	if geo.x < 0:
		print("ATTENZIONE: nessun geode nel mondo")
	else:
		m.snap_to(geo)
		await kit.seconds(2.0)
		await kit.save("54_geode")
		print("geode trovato a profondità %d" % world.depth(geo.x, geo.y))
	m.snap_to(world.spawn)
	await kit.frames(3)
