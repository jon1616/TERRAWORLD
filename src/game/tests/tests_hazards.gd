class_name TestsHazards
extends RefCounted
## Prove dei pericoli dell'ambiente (voce 20c): quanti rovi e rune trappola nel mondo, un rovo punge, una runa
## trappola scatta una volta (ferita e veleno) e si spegne; foto 42_rovi.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _nearest(kind: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e18
	for i in world.decor.size():
		if world.decor[i] == kind:
			var c := Vector2i(i % world.w, i / world.w)
			var d := Vector2(c - world.spawn).length_squared()
			if d < bd:
				bd = d
				best = c
	return best


func run() -> void:
	var rovi := 0
	var traps := 0
	for d in world.decor:
		if d == TileDefs.DECOR_ROVO:
			rovi += 1
		elif d == TileDefs.DECOR_TRAP:
			traps += 1
	print("pericoli: %d rovi spinosi, %d rune trappola" % [rovi, traps])
	var v: Vitals = m.vitals
	m.hazards.paused = false
	m.combat.invuln = 0.0
	# un rovo punge
	var r := _nearest(TileDefs.DECOR_ROVO)
	if r.x >= 0:
		v.refill()
		m.snap_to(r)
		await kit.frames(4)
		print("rovo a profondità %d: Vita da %d a %d" % [world.depth(r.x, r.y), v.hp_max, v.hp])
		m.snap_to(r + Vector2i(-3, 0))
		await kit.seconds(2.0)
		await kit.save("42_rovi")
	# una runa trappola scatta e si spegne
	var t := _nearest(TileDefs.DECOR_TRAP)
	if t.x >= 0:
		v.refill()
		v.poison_t = 0.0
		m.combat.invuln = 0.0
		m.snap_to(t)
		await kit.frames(4)
		print("runa trappola: Vita da %d a %d, avvelenato %s, spenta %s" % [v.hp_max, v.hp,
			"sì" if v.poison_t > 0.0 else "NO", "sì" if world.decor_at(t.x, t.y) == 0 else "NO"])
	v.poison_t = 0.0
	v.refill()
	m.hazards.paused = true
