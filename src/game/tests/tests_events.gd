class_name TestsEvents
extends RefCounted
## Prove della voce 34: la Pioggia di stelle fa cadere Stelline vicino al Germogliato; la Notte dell'Avvizzimento alza
## il pericolo, sceglie gli Avvizziti e dopo 40 creature sconfitte dà il premio; la Fioritura raddoppia le rare; foto
## 62_pioggia_stelle.

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
	var ev: Events = m.events
	kit.make_room()
	var spot := kit.flat_spot(world.spawn, 4)
	m.snap_to(spot)
	# Pioggia di stelle, di notte
	m.day.time = 0.95
	m.day.apply(true)
	ev.start("pioggia_stelle")
	var s0 := _count("stellina")
	ev.fall_star()
	ev.fall_star()
	await kit.seconds(0.6)
	await kit.save("62_pioggia_stelle")
	await kit.seconds(1.0)
	print("Pioggia di stelle: attiva %s, stelline a terra +%d" % ["sì" if ev.active == "pioggia_stelle" else "NO",
		_count("stellina") - s0])
	# Notte dell'Avvizzimento
	ev.start("notte_avvizzita")
	var d0: float = m.fauna.event_danger
	var picked := {}
	for k in 40:
		var cr: Creature = m.fauna.try_spawn()
		if cr:
			picked[cr.id] = int(picked.get(cr.id, 0)) + 1
	m.fauna.clear()
	var a0 := _count("cenere_avvizzita")
	for k in 40:
		var c: Creature = m.fauna.add("avvizzito_errante", m.player.position + Vector2(40, -10))
		m.fauna.kill(c)
	await kit.frames(3)
	print("Notte dell'Avvizzimento: pericolo +%.1f, nascite %s, vinta %s, premio a terra %s" % [d0, picked,
		"sì" if ev.won else "NO", "sì" if _count("cenere_avvizzita") > a0 else "NO"])
	# Fioritura
	ev.start("fioritura")
	print("Fioritura: creature rare ×%.1f, semi selvatici ×%.1f" % [m.fauna.event_rare, m.garden.wild_mult])
	ev.stop()
	print("fine evento: pericolo +%.1f, rare ×%.1f" % [m.fauna.event_danger, m.fauna.event_rare])
	m.fauna.clear()
	m.day.time = 0.5
	m.day.apply(true)
	await kit.frames(3)
