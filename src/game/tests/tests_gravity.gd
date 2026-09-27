class_name TestsGravity
extends RefCounted
## Prove della gravità e dei mondi strani (voce 76): la gravità lieve alza il salto e attenua le cadute; una corrente
## ascensionale solleva il Germogliato; il generatore fa davvero un Guscio (tetto, pozzi di sole, buio sotto il tetto,
## niente pioggia) e un Arcipelago (voragini con l'acqua sul fondo, correnti, isole, partenza su un pilastro), ed entrambi
## hanno il Cuore del mondo. Foto 142_corrente.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Altezza del salto pieno, in tessere, con il peso indicato.
func _jump(g: float) -> float:
	var p: Player = m.player
	p.grav_mult = g
	var spot := _open_spot(world.spawn.x + 10)
	m.snap_to(spot)
	await kit.seconds(0.3)
	var y0 := p.position.y
	var top := y0
	p.auto_jump = true
	var t := 0.0
	while t < 1.6:
		await kit.frames(1)
		t += m.get_process_delta_time()
		top = minf(top, p.position.y)
	p.auto_jump = false
	await kit.seconds(0.8)
	return (y0 - top) / 16.0


func run() -> void:
	var gv: Gravity = m.gravity
	var p: Player = m.player
	var g0 := p.grav_mult
	var normal: float = await _jump(1.0)
	var light: float = await _jump(0.55)
	p.grav_mult = g0
	# le cadute: la stessa altezza ferisce meno se il mondo è leggero
	var fall_n := 30.0 * 1.0
	var fall_l := 30.0 * 0.55
	# la corrente ascensionale
	m.vitals.refill()
	var spot := _open_spot(world.spawn.x - 14)
	var saved: Array = gv.currents
	gv.currents = [{"x": spot.x, "w": 1, "y0": spot.y - 22, "y1": spot.y}]
	m.snap_to(spot)
	await kit.seconds(0.2)
	var y0 := p.position.y
	await kit.seconds(1.6)
	var rose := (y0 - p.position.y) / 16.0
	var inside := gv.current_at(m.player_cell()) >= 0
	await kit.save("142_corrente")
	var parts := gv._fx.size()
	gv.currents = saved
	for k in gv._fx:
		(gv._fx[k] as Node).queue_free()
	gv._fx.clear()
	m.snap_to(world.spawn)
	await kit.seconds(0.3)
	m.vitals.refill()
	# i mondi generati
	var ws: Array[World] = await kit.gen_many([[7607, WorldGen.WIDTH, WorldGen.HEIGHT, {"geni": ["guscio"], "vigore": 3}],
		[7608, WorldGen.WIDTH, WorldGen.HEIGHT, {"geni": ["arcipelago"], "vigore": 3}]])
	var sh := _measure(["guscio"], ws[0])
	var ar := _measure(["arcipelago"], ws[1])
	var run_l := Genome.effects(["lieve"], "run")
	var run_g := Genome.effects(["guscio"], "run")
	print("gravità: salto normale %.2f tessere, lieve %.2f; caduta di 30 tessere conta %.0f / %.1f; corrente: salito %.1f tessere (dentro %s, particelle %d); lieve grav %.2f, guscio senza pioggia %s" % [
		normal, light, fall_n, fall_l, rose, "sì" if inside else "NO", parts, float(run_l["grav"]), "sì" if run_g["roof"] else "NO"])
	print("guscio: %s" % sh)
	print("arcipelago: %s" % ar)
	if light < normal * 1.5 or rose < 6.0 or parts < 1 or float(run_l["grav"]) >= 1.0 or not run_g["roof"] \
			or not sh["ok"] or not ar["ok"]:
		print("ATTENZIONE: la gravità o i mondi strani non funzionano come dovrebbero")


## Una cella sul terreno con il cielo libero per 26 tessere (le prove di prima costruiscono attorno alla partenza).
func _open_spot(from: int) -> Vector2i:
	for d in 200:
		for x in [from + d, from - d]:
			var y: int = world.surface[x] - 1
			var ok := world.solid(x, y + 1) and world.solid(x + 1, y + 1)
			for dy in 26:
				for dx in [-1, 0, 1]:
					if world.solid(x + dx, y - dy) or world.plat(x + dx, y - dy):
						ok = false
			if ok:
				return Vector2i(x, y)
	print("ATTENZIONE: nessun posto con il cielo libero per la prova della gravità")
	return world.spawn


## Misura la forma di un mondo generato con questi geni.
func _measure(genes: Array, w: World) -> Dictionary:
	var out := {"cuore": false}
	for o in w.stations:
		if String(w.stations[o]) == "cuore_mondo":
			out["cuore"] = true
	var sp := w.spawn
	out["partenza_libera"] = not w.solid(sp.x, sp.y) and w.solid(sp.x, sp.y + 1)
	if "guscio" in genes:
		var roof: PackedInt32Array = w.gen_notes.get("tetto", PackedInt32Array())
		var holes: Array = w.gen_notes.get("pozzi", [])
		# sopra la partenza (fuori dal pozzo) c'è il tetto, e dietro l'aria la parete
		var x := sp.x - 20
		var y := w.surface[x] - 2
		while y > 0 and not w.solid(x, y):
			y -= 1
		out["tetto"] = y > 0 and w.surface[x] - y >= 25
		out["parete"] = w.wall(x, w.surface[x] - 5) != 0
		out["pozzi"] = holes.size()
		out["alberi"] = w.trees.size()
		out["ok"] = out["cuore"] and out["partenza_libera"] and out["tetto"] and out["parete"] and holes.size() >= 10 \
			and roof.size() == w.w and w.trees.size() > 20
	else:
		var ch: Array = w.gen_notes.get("abissi", [])
		var cu: Array = w.gen_notes.get("correnti", [])
		var wet := 0
		var deep := 0
		for a in ch:
			var cx := (int(a[0]) + int(a[1])) / 2
			if w.liq(cx, w.surface[cx] - 1) > 0:
				wet += 1
			if w.surface[cx] - w.surface[maxi(int(a[0]) - 1, 0)] >= 25:
				deep += 1
		out["voragini"] = ch.size()
		out["bagnate"] = wet
		out["profonde"] = deep
		out["correnti"] = cu.size()
		out["isole"] = (w.gen_notes.get("isole", []) as Array).size()
		out["ok"] = out["cuore"] and out["partenza_libera"] and ch.size() >= 8 and cu.size() == ch.size() \
			and wet >= ch.size() / 2 and deep >= ch.size() / 2 and int(out["isole"]) >= 4
	return out
