class_name TestsTorch
extends RefCounted
## La torcia in mano (richiesta dell'utente, 25 set 2026): si vede nella mano con la sua fiamma e illumina attorno
## come una torcia piantata; foto 57_torcia_in_mano (nel buio di una grotta) e 58_torcia_vicino (ingrandita).

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Una grotta buia vicina alla partenza (pavimento, niente torce vicine).
func _cave() -> Vector2i:
	for r in range(40, 400, 7):
		for side in [1, -1]:
			var x: int = world.spawn.x + side * r
			for y in range(world.surface[x] + 25, world.surface[x] + 120):
				if not world.solid(x, y) and not world.solid(x, y - 1) and not world.solid(x, y - 2) \
						and world.solid(x, y + 1) and not world.torch_near(Vector2i(x, y), 12.0):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


func run() -> void:
	var c := _cave()
	if c.x < 0:
		print("ATTENZIONE: nessuna grotta buia per la prova della torcia")
		return
	m.snap_to(c)
	kit.make_room()
	kit.hold("piccone_radicite")
	await kit.seconds(1.0)
	var dark: float = m.light.value_at(c + Vector2i(0, -3))
	m.character.bisaccia.add("torcia", 5)
	kit.hold("torcia")
	await kit.seconds(1.2)
	var lit: float = m.light.value_at(c + Vector2i(0, -3))
	print("torcia in mano: si vede %s, fiamma %s, luce 3 tessere sopra la testa da %.2f a %.2f" % [
		"sì" if m.player.tool.visible else "NO", "sì" if m.player.flame.visible else "NO", dark, lit])
	# la luce tremola: valori diversi nel giro di due secondi, senza perdere fotogrammi
	var seen := {}
	var worst := 0.0
	var t0 := Time.get_ticks_msec()
	var last := t0
	var frames := 0
	while Time.get_ticks_msec() - t0 < 2000:
		await kit.frames(1)
		var now := Time.get_ticks_msec()
		worst = maxf(worst, now - last)
		last = now
		frames += 1
		seen[snappedf(m.light.player_light.r, 0.01)] = true
	print("luce che tremola: %d intensità diverse in 2 s, %d fotogrammi (peggiore %d ms)" % [seen.size(), frames, int(worst)])
	await kit.save("57_torcia_in_mano")
	# torce piantate attorno: la loro luce tremola, ognuna per conto suo, senza perdere fotogrammi
	for dx in [-6, -3, 3, 6]:
		m.actions.place_torch(c + Vector2i(dx, 0))
	kit.hold("piccone_radicite")
	await kit.seconds(0.5)
	var vals := {}
	var worst2 := 0.0
	var t1 := Time.get_ticks_msec()
	var last2 := t1
	var n2 := 0
	while Time.get_ticks_msec() - t1 < 2000:
		await kit.frames(1)
		var now2 := Time.get_ticks_msec()
		worst2 = maxf(worst2, now2 - last2)
		last2 = now2
		n2 += 1
		vals[snappedf(m.light.value_at(c + Vector2i(-6, -1)), 0.005)] = true
	print("torce piantate che tremolano: %d valori di luce diversi in 2 s, %d fotogrammi (peggiore %d ms)" % [vals.size(), n2, int(worst2)])
	kit.hold("torcia")
	await kit.seconds(0.3)
	m.cam.zoom *= 2.5
	await kit.seconds(0.5)
	await kit.save("58_torcia_vicino")
	m.cam.zoom /= 2.5
	kit.hold("piccone_radicite")
	await kit.frames(3)
