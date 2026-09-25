class_name TestsRuins
extends RefCounted
## Prove delle rovine e degli scrigni (voce 10): quante rovine per strato, lo scrigno più vicino alla partenza si apre
## con il clic destro, «Prendi tutto» lo svuota nella Bisaccia, lo scrigno vuoto si porta via; gli accessori cambiano
## corsa, salto, planata e alone. Il salvataggio (in `TestsWorld.run_and_save`, dopo) confronta anche i contenitori.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var per := [0, 0, 0, 0, 0]
	var chests: Array[Vector2i] = []
	for o in world.stations:
		if world.stations[o] == "scrigno":
			chests.append(o)
			per[StrataData.at(world, o.x, o.y)] += 1
	print("rovine dei Seminatori: %d scrigni (per strato %s)" % [chests.size(), per])
	if chests.is_empty():
		return
	var o := kit.nearest(chests, world.spawn, func(_c: Vector2i) -> bool: return true)
	var inside: int = world.chest_at(o).slots.filter(func(sl: Dictionary) -> bool: return not sl.is_empty()).size()
	m.snap_to(o + Vector2i(-2, 1))
	await kit.seconds(1.0)
	var opened: bool = m.interact.touch(o)
	await kit.seconds(1.0)
	await kit.save("28_rovina_scrigno")
	var before := _items(m.character.bisaccia)
	m.interact.chest_panel.take_all()
	var moved := _items(m.character.bisaccia) - before
	print("scrigno a profondità %d: aperto %s, pile dentro %d, oggetti presi %d, vuoto %s" % [world.depth(o.x, o.y),
		"sì" if opened else "NO", inside, moved, "sì" if world.chest_at(o).is_empty() else "NO"])
	m.hud.panel.toggle()
	await kit.frames(3)
	# lo scrigno vuoto si porta via come una cesta
	m.actions.build.take_station(o)
	print("scrigno vuoto portato via: %s" % ("sì" if not world.stations.has(o) else "NO"))
	# accessori
	var b: Bisaccia = m.character.bisaccia
	b.wear("accessorio_1", {"id": "stivali_radice", "n": 1})
	b.wear("accessorio_2", {"id": "foglia_planante", "n": 1})
	await kit.frames(2)
	var same := b.wear("accessorio_2", {"id": "stivali_radice", "n": 1})
	print("accessori: corsa ×%.2f, planata %s, niente ferite da caduta %s, doppione rifiutato %s" % [m.player.run_mult,
		"sì" if m.player.glide else "NO", "sì" if m.life.fall_safe else "NO", "sì" if not same.is_empty() else "NO"])
	b.wear("accessorio_1", {"id": "anello_lucciola", "n": 1})
	b.wear("accessorio_2", {"id": "pappo_seme", "n": 1})
	await kit.frames(2)
	print("accessori: alone ×%.1f, salto ×%.2f" % [m.boons.halo_mult, m.player.jump_mult])
	b.equip.erase("accessorio_1")
	b.equip.erase("accessorio_2")
	b.changed.emit()
	# una cesta piena accanto alla partenza: il salvataggio dopo deve ritrovarla uguale
	var spot := kit.flat_spot(world.spawn, 4)
	m.snap_to(spot + Vector2i(-3, 0))
	await kit.frames(5)
	b.add("cesta", 1)
	kit.hold("cesta")
	if kit.place_station_near("cesta", spot + Vector2i(-3, 0)):
		for c in world.stations:
			if world.stations[c] == "cesta":
				world.chest_at(c).add("legno", 7)
				world.chest_at(c).add("torcia", 3)
		print("cesta di radici piazzata e riempita")
	else:
		print("cesta di radici: NON piazzata")
	m.hud.panel.visible = false


func _items(b: Bisaccia) -> int:
	var n := 0
	for sl in b.slots:
		n += int(sl.get("n", 0))
	return n
