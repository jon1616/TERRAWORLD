class_name PassCuore
extends GenPass
## La camera del Cuore del mondo, nel Fondo, lontana dalla partenza (a destra o a sinistra): una grande cupola con il
## guscio di vuotite, il pavimento piano, due passerelle per muoversi in alto, due gallerie d'ingresso ai lati. Al
## centro del pavimento il Cuore (malato, `cuore_mondo`), sul soffitto quattro nodi avvizziti (`TileDefs.NODO`): chi li
## guarisce tutti cura il Guardiano (voce 8). Il Guardiano lo sveglia `Guardian` quando il giocatore entra.

const RX := 30                         # semiassi della cupola, in tessere
const RY := 15
const FLOOR := 9                       # il pavimento è a tante tessere sotto il centro
## Dove stanno i nodi sul guscio (angoli in gradi, 0 = destra, -90 = in alto).
const NODES := [-160.0, -115.0, -65.0, -20.0]


func title() -> String:
	return "Cuore"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var side := 1 if rng.randf() < 0.5 else -1
	var cx := clampi(w.spawn.x + side * rng.randi_range(350, 650), RX + 40, w.w - RX - 40)
	var cy := mini(w.surface[cx] + StrataData.offset(cx, w.world_seed) + StrataData.top(4) + 60, w.h - 40)
	for y in range(cy - RY - 5, cy + RY + 6):
		for x in range(cx - RX - 5, cx + RX + 6):
			if not w.inside(x, y):
				continue
			var e := pow((x - cx) / float(RX), 2.0) + pow((y - cy) / float(RY), 2.0)
			var i := y * w.w + x
			if e <= 1.0:
				w.tiles[i] = TileDefs.VUOTITE if y >= cy + FLOOR else TileDefs.AIR
				w.decor[i] = 0
				w.walls[i] = TileDefs.WALL_ROOT    # dentro la cupola: il nido di radici del Guardiano
			elif e <= 1.35:
				w.tiles[i] = TileDefs.VUOTITE     # il guscio
				w.walls[i] = TileDefs.WALL_VOID
	# gallerie d'ingresso ai lati, all'altezza del pavimento
	for s in [-1, 1]:
		for k in range(RX - 3, RX + 30):
			for dy in range(FLOOR - 4, FLOOR):
				var x: int = cx + s * k
				var y := cy + dy
				if w.inside(x, y):
					w.tiles[y * w.w + x] = TileDefs.AIR
					w.decor[y * w.w + x] = 0
	# passerelle per salire verso i nodi del soffitto
	for s in [-1, 1]:
		for k in range(8, 19):
			w.set_plat(cx + s * k, cy + 2, true)
		for k in range(2, 8):
			w.set_plat(cx + s * k, cy - 5, true)
	# i nodi avvizziti, incastrati nel guscio ma affacciati sulla cupola
	for a in NODES:
		var r := deg_to_rad(a)
		var p := Vector2(cx + cos(r) * RX * 0.97, cy + sin(r) * RY * 0.97)
		for dy in range(-2, 3):
			for dx in range(-2, 3):
				if Vector2(dx, dy).length() <= 1.6:
					w.set_tile(int(p.x) + dx, int(p.y) + dy, TileDefs.NODO)
	# schegge del Vuoto e funghi luminosi sul pavimento, radici accese dal soffitto: la cupola si legge anche al buio
	for x in range(cx - RX + 3, cx + RX - 2):
		var y := cy + FLOOR - 1
		if w.tile(x, y) == TileDefs.AIR and absi(x - cx) > 3 and rng.randf() < 0.3:
			w.set_decor(x, y, TileDefs.DECOR_SHARD if rng.randf() < 0.6 else TileDefs.DECOR_GLOW)
	for x in range(cx - RX + 4, cx + RX - 3):
		for y in range(cy - RY, cy):
			if w.tile(x, y) == TileDefs.AIR and w.solid(x, y - 1) and rng.randf() < 0.35:
				w.set_decor(x, y, TileDefs.DECOR_ROOTS[rng.randi_range(0, 1)])
				break
	# il Cuore al centro del pavimento
	var o := Vector2i(cx - 1, cy + FLOOR - 3)
	w.stations[o] = "cuore_mondo"
	c.notes["cuore"] = Vector2i(cx, cy)
	c.claim(Rect2i(cx - RX - 30, cy - RY - 5, 2 * RX + 61, 2 * RY + 11), "cuore")   # la cupola e le gallerie
