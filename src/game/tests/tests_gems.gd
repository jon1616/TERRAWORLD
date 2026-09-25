class_name TestsGems
extends RefCounted
## Prove della voce 24: quanta pallidite e tizzonite nel mondo e in quali strati, quanti grappoli di gemme, la forza
## di piccone che serve, l'onda di lagunite che rallenta, la Lanterna di brillaluce; foto 48_gemme.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	# minerali e gemme nel mondo, per strato
	var ores := {TileDefs.PALLIDITE: [0, 0, 0, 0, 0], TileDefs.TIZZONITE: [0, 0, 0, 0, 0]}
	for y in range(0, world.h, 2):
		for x in range(0, world.w, 2):
			var t := world.tile(x, y)
			if ores.has(t):
				ores[t][StrataData.at(world, x, y)] += 1
	print("minerali nuovi (campione 1 cella su 4) per strato: pallidite %s, tizzonite %s" % [ores[TileDefs.PALLIDITE],
		ores[TileDefs.TIZZONITE]])
	var gems := {}
	var first := {}
	for i in world.decor.size():
		var d := int(world.decor[i])
		if d in TileDefs.DECOR_GEMS:
			gems[d] = int(gems.get(d, 0)) + 1
			var c := Vector2i(i % world.w, i / world.w)
			if not first.has(d) or Vector2(c - world.spawn).length() < Vector2(first[d] - world.spawn).length():
				first[d] = c
	print("gemme a grappolo: brillaluce %d, sanguinella %d, lagunite %d, nottilite %d" % [gems.get(23, 0), gems.get(24, 0),
		gems.get(25, 0), gems.get(26, 0)])
	# forza di piccone: la tizzonite non cede al piccone di legnoferro, sì a quello d'ambra
	var need := int(TileDefs.POWER[TileDefs.TIZZONITE])
	print("tizzonite: forza richiesta %d, piccone di legnoferro %d, d'ambra %d" % [need,
		int(ItemsData.get_item("piccone_legnoferro")["power"]), int(ItemsData.get_item("piccone_ambra")["power"])])
	print("famiglia di pallidite: %s, danno spada %d a %.1f colpi/s" % [ItemsData.get_item("spada_pallidite")["name"],
		int(ItemsData.get_item("spada_pallidite")["damage"]), float(ItemsData.get_item("spada_pallidite")["speed"])])
	# l'onda di lagunite rallenta
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per le prove delle gemme")
		return
	m.snap_to(spot)
	m.fauna.clear()
	m.combat.god = true
	await kit.frames(3)
	var cr: Creature = m.fauna.add("strisciaradice", m.player.position + Vector2(60, -6))
	cr.set_process(false)
	cr.hp_max = 500
	cr.hp = 500
	m.vitals.refill()
	kit.hold("bastone_lagunite")
	m.spells.auto_aim = cr.position
	m.spells.auto_fire = true
	await kit.frames(3)
	m.spells.auto_fire = false
	await kit.seconds(0.5)
	print("onda di lagunite: creatura colpita %s, rallentata per %.1f s" % ["sì" if cr.hp < 500 else "NO", cr.chill_t])
	m.spells.auto_aim = Vector2.INF
	m.fauna.clear()
	# la Lanterna di brillaluce
	kit.hold("lanterna_brillaluce")
	await kit.frames(2)
	print("Lanterna di brillaluce in mano: luce del Germogliato %s" % m.light.player_light)
	kit.hold("piccone_radicite")
	m.combat.god = false
	# foto: un grappolo di gemme nel buio di una grotta
	var g: Vector2i = first.get(24, first.get(23, Vector2i(-1, -1)))
	if g.x < 0:
		print("ATTENZIONE: nessuna gemma nel mondo")
		return
	var near := kit.floor_near(g, 4)
	m.snap_to(near if near.x >= 0 else g)
	await kit.seconds(2.0)
	await kit.save("48_gemme")
