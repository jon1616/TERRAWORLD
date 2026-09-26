class_name TestsGuardian
extends RefCounted
## Prove del primo anello (voce 8): il Guardiano si sveglia entrando nella cupola del Cuore, entra nella seconda fase,
## viene sconfitto (frammenti, Cuore vivo, Seme di mondo); poi, rimesso tutto com'era, viene curato con la Rugiada
## sui quattro nodi (Linfa del Guardiano, +20 Vita massima). Infine il portale, il lingotto di Linfa, pozioni e lanterna.

const S := 16

var kit: TestKit
var world: World
var m: Node2D
var g: Guardian


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m
	g = tk.m.guardian


func _close_lore() -> void:
	g.lore.visible = false


func run() -> void:
	if g.cuore.x < 0:
		print("ERRORE: nessun Cuore del mondo nel mondo di prova")
		return
	print("Cuore del mondo a %s, profondità %d, strato %s, nodi avvizziti %d" % [g.cuore, world.depth(g.cuore.x, g.cuore.y),
		StrataData.STRATA[StrataData.at(world, g.cuore.x, g.cuore.y)]["name"], g.nodes_left()])
	m.combat.god = true
	m.fauna.clear()
	var floor_cell := g.cuore + Vector2i(-10, 2)
	m.snap_to(floor_cell)
	await kit.seconds(1.5)
	print("Guardiano sveglio: %s, pagina del Cuore %s" % ["sì" if g.boss != null else "NO", "sì" if g.lore.visible else "NO"])
	_close_lore()
	await kit.seconds(2.0)
	await kit.save("21_guardiano")
	if g.boss == null:
		m.combat.god = false
		return
	# seconda fase: sotto metà Vita diventa rosso, più veloce, e chiama grumi in aiuto
	g.boss.hp = int(g.boss.hp_max * 0.4)
	await kit.seconds(4.0)
	print("seconda fase: %s, grumi chiamati %d" % ["sì" if g.boss.enraged else "NO", g.boss.minions])
	await kit.save("22_guardiano_fase2")
	# strada 1: sconfitto
	m.combat._strike(g.boss, 99999, m.player.position.x, 1.0)
	await kit.seconds(1.0)
	_close_lore()
	var st := String(world.stations.get(g.cuore, ""))
	print("sconfitto: stato %s, Cuore %s, oggetti a terra %d" % [m.world_meta.get("guardiano", "?"), st, m.drops.count()])
	await kit.seconds(1.0)
	await kit.save("23_cuore_vivo")
	# strada 2: si rimette tutto com'era e lo si cura
	m.fauna.clear()
	world.stations[g.cuore] = "cuore_mondo"
	m.view.remove_station(g.cuore)
	m.view.add_station(g.cuore)
	m.world_meta["guardiano"] = "dorme"
	g.state = "dorme"
	g.boss = null
	await kit.seconds(1.0)
	_close_lore()
	var hp_before: int = m.vitals.hp_max
	var b: Bisaccia = m.character.bisaccia
	b.add("rugiada_linfa", 4)
	kit.hold("rugiada_linfa")
	var cured := 0
	for y in range(g.cuore.y - 30, g.cuore.y + 15):
		for x in range(g.cuore.x - 40, g.cuore.x + 43):
			if world.tile(x, y) == TileDefs.NODO:
				m.player.position = Vector2(x * S + 8, y * S + 40)
				if g.cure_at(Vector2i(x, y)):
					cured += 1
	m.snap_to(floor_cell)
	await kit.seconds(1.5)
	_close_lore()
	print("curato: nodi guariti %d, stato %s, Guardiano calmo %s, Vita massima da %d a %d" % [cured,
		m.world_meta.get("guardiano", "?"), "sì" if g.boss == null or g.boss.calm else "NO", hp_before, m.vitals.hp_max])
	await kit.seconds(1.0)
	await kit.save("24_guardiano_curato")
	m.combat.god = false
	m.fauna.clear()
	# il grado della Linfa: il lingotto con i frammenti (o la Linfa del Guardiano)
	b.add("cristallo_linfa", 8)
	b.add("frammento_nodo", 1)
	b.add("linfa_guardiano", 1)
	print("lingotto di Linfa: dai frammenti %s, dalla Linfa del Guardiano %s" % [
		_craft_with("frammento_nodo"), _craft_with("linfa_guardiano")])
	# pozione di bagliore e lanterna: la luce del Germogliato cambia
	b.add("pozione_bagliore", 1)
	kit.hold("pozione_bagliore")
	m.actions.drink("pozione_bagliore")
	await kit.frames(3)
	var glow_ok: bool = m.light.player_light == Boons.LIGHT_BAGLIORE
	m.boons.active.clear()
	kit.hold("lanterna_linfa")
	await kit.frames(3)
	var lamp_ok: bool = m.light.player_light.g >= Boons.LIGHT_LANTERNA.g
	print("pozione di bagliore: %s, lanterna di Linfa: %s" % ["luce più forte" if glow_ok else "NO", "luce turchese" if lamp_ok else "NO"])
	# il portale: si pianta il Seme di mondo vicino alla partenza
	var spot := kit.flat_spot(world.spawn, 4)
	m.snap_to(spot + Vector2i(-3, 0))
	await kit.frames(5)
	b.add("seme_mondo", 1)
	kit.hold("seme_mondo")
	kit.aiuola(spot)
	var planted: bool = m.portal.plant(spot, "seme_mondo")
	var dest: Array = m.portal.destination(spot - Vector2i(1, 3))
	var back: Vector2i = m.portal.place_return("mondo_di_ritorno")
	var back_dest: Array = m.portal.destination(back)
	print("portale: piantato %s, mondo di destinazione «%s» seme %d vigore %d; portale di ritorno %s verso «%s»" % [
		"sì" if planted else "NO", dest[1], dest[2], dest[3], "piazzato" if back.x >= 0 else "NON piazzato",
		String(back_dest[0]) if String(back_dest[0]) != "" else "(mondo inesistente, come previsto)"])
	await kit.seconds(1.0)
	_close_lore()
	await kit.seconds(1.0)
	await kit.save("25_portale")


func _craft_with(extra: String) -> String:
	var b: Bisaccia = m.character.bisaccia
	for r in RecipesData.making("lingotto_linfa"):
		if (r["in"] as Dictionary).has(extra):
			var before := b.count("lingotto_linfa")
			Crafting.craft(r, b)
			return "sì" if b.count("lingotto_linfa") > before else "NO"
	return "NO (ricetta mancante)"
