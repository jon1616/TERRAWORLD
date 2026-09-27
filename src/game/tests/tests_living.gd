class_name TestsLiving
extends RefCounted
## Prove della terra viva (voce 77): con i geni Radici vive, Cristalli vivi e Frane nel mondo di prova, un cunicolo
## scavato si richiude di radice dopo un'assenza (tranne accanto a una torcia), i cristalli crescono, una colonna di
## terra senza appoggio frana, e l'avviso «Mentre eri via» racconta cosa è cambiato. Foto 143_frana.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var le: LivingEarth = m.living
	var genes0: Array = m.world_meta.get("geni", [])
	m.world_meta["geni"] = ["radici_vive", "cristalli_vivi", "frane"]
	le.apply()
	var seeds := (m.world_meta.get("cristalli", []) as Array).size()
	# un cunicolo sotto la superficie, lontano dalla partenza
	var x0 := world.spawn.x + 60
	var dug: Array[Vector2i] = []
	for k in 6:
		var xk := x0 + k if k < 5 else x0 + 14      # l'ultima lontana dalle altre: la sua torcia non le protegge
		var c := Vector2i(xk, world.surface[xk] + 8)
		world.set_tile(c.x, c.y, TileDefs.AIR)
		world.walls[c.y * world.w + c.x] = TileDefs.WALL_DIRT
		dug.append(c)
	le.falling = false                         # il cunicolo è una prova delle radici: niente frane qui
	for c in dug:
		le._on_dug(TileDefs.DIRT, c)
	le.falling = true
	# una torcia accanto all'ultima tessera la tiene aperta
	var lit: Vector2i = dug[5]
	world.add_torch(lit)
	var wounds := (m.world_meta.get("ferite", []) as Array).size()
	var cr0 := _count_crystals()
	var note := le.away(3.0 * 3600.0)
	var closed := 0
	for k in 5:
		if world.tile(dug[k].x, dug[k].y) == TileDefs.RADICE:
			closed += 1
	var kept_open := not world.solid(lit.x, lit.y)
	world.remove_torch(lit)
	var cr1 := _count_crystals()
	# la frana: si scava sotto una colonna di terra
	var fx := _dirt_column(world.spawn.x - 40)
	var s := world.surface[fx]
	for y in range(s + 3, s + 7):
		world.set_tile(fx, y, TileDefs.AIR)
	var top0 := world.tile(fx, s)
	m.view.refresh_rect(Rect2i(fx - 2, s - 2, 5, 12))
	m.snap_to(Vector2i(fx + 3, world.surface[fx + 3] - 1))
	await kit.seconds(0.3)
	le._on_dug(TileDefs.DIRT, Vector2i(fx, s + 3))
	await kit.seconds(1.2)
	var moved := not world.solid(fx, s) and world.solid(fx, s + 6)
	await kit.save("143_frana")
	m.world_meta["geni"] = genes0
	le.apply()
	print("terra viva: punti di crescita dei cristalli %d; ferite %d, richiuse %d su 5, accanto alla torcia aperta %s; cristalli %d → %d; frana: la cima era %d, scesa %s (zolle cadute %d); avviso «%s»" % [
		seeds, wounds, closed, "sì" if kept_open else "NO", cr0, cr1, top0, "sì" if moved else "NO", le.fallen, note])
	if seeds < 10 or wounds < 6 or closed < 5 or not kept_open or cr1 < cr0 + 5 or not moved or not note.contains("radici") \
			or not note.contains("cristalli"):
		print("ATTENZIONE: la terra viva non funziona come dovrebbe")


## Una colonna di terra intatta (humus o erba dalla superficie a 7 tessere sotto), senza alberi né stazioni sopra.
func _dirt_column(from: int) -> int:
	for d in 300:
		for x in [from - d, from + d]:
			var s: int = world.surface[x]
			var ok := not world.solid(x, s - 1) and world.tree_at(Vector2i(x, s - 1)).x < 0 and world.station_at(Vector2i(x, s - 1)).is_empty()
			for y in range(s, s + 7):
				if not (world.tile(x, y) in LivingData.FALLING or TileDefs.is_grass(world.tile(x, y))):
					ok = false
			if ok:
				return x
	print("ATTENZIONE: nessuna colonna di terra intatta per la prova della frana")
	return from


func _count_crystals() -> int:
	var n := 0
	var i := world.tiles.find(TileDefs.CRYSTAL)
	while i >= 0:
		n += 1
		i = world.tiles.find(TileDefs.CRYSTAL, i + 1)
	return n
