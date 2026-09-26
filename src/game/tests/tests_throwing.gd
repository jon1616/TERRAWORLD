class_name TestsThrowing
extends RefCounted
## Prove della voce 32: un Baccello esplosivo rompe la roccia attorno ma non l'ambra, ferisce le creature; il Seme
## ricurvo ferisce e torna in mano; il giavellotto attraversa due creature; foto 60_scoppio.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _solid_count(c: Vector2i, r: int) -> int:
	var n := 0
	for y in range(c.y - r, c.y + r + 1):
		for x in range(c.x - r, c.x + r + 1):
			if world.solid(x, y):
				n += 1
	return n


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var th: Throwing = m.throwing
	kit.make_room()
	m.combat.god = true
	var spot := kit.flat_spot(world.spawn, 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per le prove dei lanci")
		return
	m.snap_to(spot)
	m.fauna.clear()
	await kit.frames(3)
	# uno scoppio nella roccia, con un blocco d'ambra accanto che deve restare
	var at := spot + Vector2i(8, 6)
	world.set_tile(at.x + 1, at.y, TileDefs.AMBRA)
	var before := _solid_count(at, 3)
	var cr: Creature = m.fauna.add("strisciaradice", Vector2(at.x * S + 8, (at.y - 5) * S))
	cr.set_process(false)
	cr.hp_max = 500
	cr.hp = 500
	cr.position = Vector2(at.x * S + 8, at.y * S - 20)
	th.explode(Vector2(at) * S + Vector2(8, 8), ItemsData.get_item("baccello_esplosivo")["blast"])
	await kit.frames(3)
	print("scoppio: tessere solide attorno da %d a %d, l'ambra resta %s, creatura ferita %s (Vita %d)" % [before,
		_solid_count(at, 3), "sì" if world.tile(at.x + 1, at.y) == TileDefs.AMBRA else "NO",
		"sì" if cr.hp < 500 else "NO", cr.hp])
	m.fauna.clear()
	# un baccello lanciato davvero: vola, rimbalza e scoppia dopo la miccia
	b.add("baccello_esplosivo", 2)
	kit.hold("baccello_esplosivo")
	var n0 := th.blasts
	var ok := th.throw("baccello_esplosivo", m.player.position + Vector2(120, -40))
	await kit.seconds(1.2)
	m.boons.add("bagliore", 10.0)
	await kit.seconds(0.35)
	await kit.save("60_scoppio")
	await kit.seconds(0.5)
	print("baccello lanciato: partito %s, scoppiato %s" % ["sì" if ok else "NO", "sì" if th.blasts > n0 else "NO"])
	# seme ricurvo: ferisce e torna (terreno spianato davanti: nel giro lungo le prove di prima lo lasciano ingombro)
	kit.flatten(spot, 10)
	m.snap_to(spot)
	await kit.frames(2)
	var t: Creature = m.fauna.add("falena_brace", m.player.position + Vector2(70, -10))
	t.set_process(false)
	t.hp_max = 500
	t.hp = 500
	b.add("seme_ricurvo", 1)
	kit.hold("seme_ricurvo")
	th.throw("seme_ricurvo", t.position)
	var back := false
	for f in 120:
		await kit.frames(1)
		if th._rang.is_empty():
			back = true
			break
	print("seme ricurvo: ferisce %s (Vita %d), tornato in mano %s" % ["sì" if t.hp < 500 else "NO", t.hp, "sì" if back else "NO"])
	m.fauna.clear()
	# giavellotto: due creature in fila
	var row: Array[Creature] = []
	for k in 2:
		var c2: Creature = m.fauna.add("strisciaradice", m.player.position + Vector2(50 + k * 30, -8))
		c2.set_process(false)
		c2.hp_max = 500
		c2.hp = 500
		row.append(c2)
	b.add("giavellotto_aculeo", 3)
	th._cool = 0.0
	th.throw("giavellotto_aculeo", m.player.position + Vector2(200, -12))
	await kit.seconds(0.6)
	print("giavellotto: creature colpite %d su 2" % row.filter(func(c: Creature) -> bool: return c.hp < 500).size())
	m.fauna.clear()
	m.combat.god = false
