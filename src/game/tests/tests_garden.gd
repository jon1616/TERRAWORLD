class_name TestsGarden
extends RefCounted
## Prove della voce 33: seminare le cinque colture (dove possono stare), farle crescere, annaffiare, raccogliere con
## il clic destro, i semi che tornano, il salvataggio delle colture, un piatto del Paiolo che sazia, la Pozione di
## notte; foto 61_giardino.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _count(id: String) -> int:
	var n := 0
	for d in m.drops._items:
		if String(d["id"]) == id:
			n += int(d["n"])
	return n


func run() -> void:
	var g: Garden = m.garden
	var b: Bisaccia = m.character.bisaccia
	g.paused = true
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(-60, 0), 4)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per il giardino")
		return
	kit.flatten(spot, 7)
	# un'aiuola di muschio
	for x in range(spot.x - 6, spot.x + 7):
		world.set_tile(x, spot.y + 1, TileDefs.GRASS)
	for x in range(spot.x - 6, spot.x + 7, 3):
		m.view.refresh_around(Vector2i(x, spot.y + 1))
	m.snap_to(spot)
	await kit.frames(3)
	var planted := []
	var x := spot.x - 4
	for crop in ["rugiada", "brace", "campanula", "tubero"]:
		var seed_id := String(CropsData.CROPS[crop]["seed"])
		b.add(seed_id, 2)
		if g.plant(Vector2i(x, spot.y), seed_id):
			planted.append(crop)
		x += 2
	b.add("spore_luminose", 1)
	var lum_top: bool = g.plant(Vector2i(x, spot.y), "spore_luminose")
	print("giardino: seminate %s; funghi luminosi in superficie rifiutati %s" % [planted, "sì" if not lum_top else "NO"])
	# annaffiare dimezza il tempo che manca
	var c0 := Vector2i(spot.x - 4, spot.y)
	var t0 := float(world.crops[c0][1]) if world.crops.has(c0) else 0.0
	kit.hold("annaffiatoio")
	b.add("annaffiatoio", 1)
	g.water(c0)
	print("annaffiatoio: tempo che manca da %.0f a %.0f s" % [t0, float(world.crops[c0][1]) if world.crops.has(c0) else -1.0])
	# le colture si salvano con il mondo
	var saved := WorldSave.save(world, "prova_giardino", {"nome": "giardino"})
	var back := WorldSave.load_world("prova_giardino")
	print("colture salvate e ricaricate: %s" % ("sì" if saved == OK and back != null and back.crops.size() == world.crops.size() else "NO"))
	WorldSave.delete("prova_giardino")
	g.grow(500.0)
	await kit.frames(2)
	var mature := 0
	for c in world.crops:
		if float(world.crops[c][1]) <= 0.0 and world.decor_at(c.x, c.y) == int(CropsData.CROPS[String(world.crops[c][0])]["decor"]):
			mature += 1
	print("dopo 500 s: mature %d su %d" % [mature, world.crops.size()])
	m.boons.add("bagliore", 10.0)
	await kit.seconds(1.0)
	await kit.save("61_giardino")
	var f0 := _count("foglia_rugiada")
	var s0 := _count("seme_rugiada")
	var ok := g.harvest(c0)
	await kit.frames(2)
	print("raccolto con il clic destro %s: foglie di rugiada +%d, semi +%d" % ["sì" if ok else "NO",
		_count("foglia_rugiada") - f0, _count("seme_rugiada") - s0])
	for c in world.crops.keys():
		g.harvest(c)
	# un piatto del Paiolo: sazio
	b.add("zuppa_funghi", 1)
	kit.hold("zuppa_funghi")
	m.actions.drink("zuppa_funghi")
	await kit.frames(2)
	print("Zuppa di funghi: sazio %s, danno ×%.2f, corsa ×%.2f" % ["sì" if m.boons.active.has("sazio") else "NO",
		m.combat._boon(), m.player.boon_run])
	b.add("pozione_notte", 1)
	kit.hold("pozione_notte")
	m.actions.drink("pozione_notte")
	await kit.frames(2)
	print("Pozione di notte: chiarore minimo %s" % m.light.ambient_boost)
	m.boons.active.clear()
	g.paused = false
	await kit.frames(2)
