class_name TestsWorkshop
extends RefCounted
## Prove della voce 25: i tre banchi nuovi si fabbricano e si piazzano, aprono le loro ricette; le pozioni
## dell'Alambicco danno il loro effetto; le vesti di seta rinforzano gli incantesimi; foto 49_banchi.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(30, 0), 12)
	if spot.x < 0:
		spot = kit.flat_spot(world.spawn, 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per i banchi")
		return
	kit.flatten(spot, 12)
	m.snap_to(spot)
	await kit.frames(3)
	for id in ["alambicco", "telaio", "mola"]:
		for k in RecipesData.making(id)[0]["in"]:
			b.add(k, int(RecipesData.making(id)[0]["in"][k]))
		var made := kit.craft(id)
		var placed := kit.place_station_near(id, m.player_cell())
		print("banco %s: fabbricato %s, piazzato %s" % [id, "sì" if made else "NO", "sì" if placed else "NO"])
	var near := Crafting.stations_near(world, m.player_cell())
	for st in ["alambicco", "telaio", "mola"]:
		var n := RecipesData.all().filter(func(r: Dictionary) -> bool: return r["station"] == st).size()
		print("  %s a portata %s, ricette %d" % [st, "sì" if near.has(st) else "NO", n])
	await kit.seconds(1.5)
	await kit.save("49_banchi")
	# le pozioni dell'Alambicco
	var before := [m.player.boon_run, m.actions.boon_dig, m.combat.boon_thorns, m.fauna.rare_mult, m.fauna.boon_luck]
	for p in ["pozione_passo", "pozione_minatore", "pozione_spine", "pozione_esca", "pozione_fortuna"]:
		kit.hold(p)
		m.actions.drink(p)
	await kit.frames(2)
	print("pozioni dell'Alambicco: corsa %.2f→%.2f, scavo %.2f→%.2f, spine %d→%d, rare ×%.1f→%.1f, fortuna %.1f→%.1f" % [
		before[0], m.player.boon_run, before[1], m.actions.boon_dig, before[2], m.combat.boon_thorns, before[3],
		m.fauna.rare_mult, before[4], m.fauna.boon_luck])
	m.boons.active.clear()
	# vesti di seta
	var old := {}
	for sl in ["elmo", "corazza", "gambali"]:
		old[sl] = String(b.equip.get(sl, ""))
	b.wear("elmo", {"id": "cappuccio_seta", "n": 1})
	b.wear("corazza", {"id": "veste_seta", "n": 1})
	b.wear("gambali", {"id": "calzari_seta", "n": 1})
	await kit.frames(1)
	print("vesti di seta: incantesimi ×%.2f, Linfa ×%.2f, Scorza %d" % [m.combat.magic_mult, m.vitals.linfa_regen_mult,
		b.scorza()])
	for sl in old:
		b.wear(sl, {})
		if old[sl] != "":
			b.wear(sl, {"id": old[sl], "n": 1})
	await kit.frames(1)
