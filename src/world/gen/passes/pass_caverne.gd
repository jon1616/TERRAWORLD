class_name PassCaverne
extends GenPass
## Le grandi caverne e le voragini (voce 449, Roadmap 57 «Le profondità vere»): le cose grandi del sottosuolo, che prima
## mancavano (solo macchie della stessa misura).
## - **Caverne enormi** (`CAVERNS`): 4-8 per mondo, almeno una per strato dal Sottobosco al Fondo, larghe 60-130 e alte
##   30-55, il pavimento quasi piano e un **contenuto**: un lago, un bosco di funghi luminosi, pilastri di roccia, pareti
##   di cristallo. Appunti "caverne" [{rect, kind, strato}].
## - **Voragini** (`CHASMS`): 2-4 tagli verticali larghi 8-16 che partono dal Sottobosco e scendono attraverso due o tre
##   strati, con le cenge a destra e a sinistra per scendere e risalire. Appunti "voragini" [{x, y0, y1}].
## Lontane dalla partenza, ognuna con `claim`.

const CAVERNS := {"n": [4, 8], "w": [60, 130], "h": [30, 55], "kinds": ["lago", "funghi", "pilastri", "cristalli"]}
const CHASMS := {"n": [2, 4], "w": [8, 16], "depth": [240, 420], "ledge_every": 14}
const SPAWN_FREE := 160


func title() -> String:
	return "Grandi caverne"


func run(w: World, c: GenContext) -> void:
	c.notes["caverne"] = []
	c.notes["voragini"] = []
	if bool(c.params.get("giardino", false)):
		return
	var n := c.rng.randi_range(int(CAVERNS["n"][0]), int(CAVERNS["n"][1]))
	var strata := [1, 2, 3, 4]
	for k in n:
		var st: int = strata[k] if k < strata.size() else c.rng.randi_range(1, 4)
		_cavern(w, c, st)
	for k in c.rng.randi_range(int(CHASMS["n"][0]), int(CHASMS["n"][1])):
		_chasm(w, c)


func _cavern(w: World, c: GenContext, st: int) -> void:
	var nz := c.noise("caverna_bordo", 0.06, 2)
	for tries in 40:
		var cw := c.rng.randi_range(int(CAVERNS["w"][0]), int(CAVERNS["w"][1]))
		var ch := c.rng.randi_range(int(CAVERNS["h"][0]), int(CAVERNS["h"][1]))
		var x0 := c.rng.randi_range(20, w.w - cw - 20)
		if absi(x0 + cw / 2 - w.spawn.x) < SPAWN_FREE:
			continue
		var t0 := StrataData.top(st) + 10
		var t1 := (StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else t0 + 150) - ch - 6
		var y0 := int(w.surface[x0 + cw / 2]) + c.rng.randi_range(t0, maxi(t1, t0 + 1))
		if y0 + ch >= w.h - 10:
			continue
		var r := Rect2i(x0, y0, cw, ch)
		if not c.is_free(r.grow(4)):
			continue
		# un'ellisse schiacciata in basso: la volta tonda, il pavimento quasi piano
		var cx := x0 + cw / 2.0
		var cy := y0 + ch * 0.55
		var floor_y := []
		for x in range(x0, x0 + cw):
			var fy := y0
			for y in range(y0, y0 + ch):
				var dx := (x - cx) / (cw / 2.0)
				var dy := (y - cy) / (ch * (0.55 if y < cy else 0.45))
				var e := dx * dx + (dy * dy if y < cy else pow(absf(dy), 4.0))
				if e + nz.get_noise_2d(x, y) * 0.35 <= 1.0 and w.tile(x, y) != TileDefs.NODO:
					w.set_tile(x, y, TileDefs.AIR)
					fy = y
			floor_y.append(fy)
		var kind: String = CAVERNS["kinds"][c.rng.randi_range(0, (CAVERNS["kinds"] as Array).size() - 1)]
		_fill(w, c, kind, r, floor_y)
		c.claim(r.grow(2), "caverna")
		(c.notes["caverne"] as Array).append({"rect": [x0, y0, cw, ch], "kind": kind, "strato": st})
		return


## Il contenuto di una caverna.
func _fill(w: World, c: GenContext, kind: String, r: Rect2i, floor_y: Array) -> void:
	match kind:
		"lago":
			# un lago sul fondo: le celle d'aria sotto il livello, dal pavimento in su per 4-7 righe
			var deep := c.rng.randi_range(4, 7)
			var lowest := 0
			for fy in floor_y:
				lowest = maxi(lowest, int(fy))
			var level := lowest - deep
			for x in range(r.position.x, r.end.x):
				for y in range(level, lowest + 1):
					if not w.solid(x, y) and w.solid(x, int(floor_y[x - r.position.x]) + 1):
						w.set_liq(x, y, 8, 0)
		"funghi":
			for i in floor_y.size():
				var x := r.position.x + i
				var y := int(floor_y[i])
				if w.solid(x, y + 1) and not w.solid(x, y) and c.rng.randf() < 0.45:
					w.set_decor(x, y, TileDefs.DECOR_GLOW if c.rng.randf() < 0.6 else TileDefs.DECOR_MUSHROOM)
		"pilastri":
			var x := r.position.x + c.rng.randi_range(8, 14)
			while x < r.end.x - 8:
				var wpil := c.rng.randi_range(2, 4)
				for dx in wpil:
					for y in range(r.position.y - 2, r.end.y + 2):
						if not w.solid(x + dx, y):
							w.set_tile(x + dx, y, TileDefs.STONE)
				x += c.rng.randi_range(14, 24)
		"cristalli":
			for x in range(r.position.x - 1, r.end.x + 1):
				for y in range(r.position.y - 1, r.end.y + 1):
					if w.solid(x, y) and c.rng.randf() < 0.35 and (not w.solid(x - 1, y) or not w.solid(x + 1, y)
							or not w.solid(x, y - 1) or not w.solid(x, y + 1)):
						w.set_tile(x, y, TileDefs.CRYSTAL)


## Una voragine: dal Sottobosco giù per due o tre strati, che ondeggia appena, con le cenge alterne.
func _chasm(w: World, c: GenContext) -> void:
	var bend := c.noise("voragine_grande", 0.02, 2)
	for tries in 30:
		var x := c.rng.randi_range(80, w.w - 80)
		if absi(x - w.spawn.x) < SPAWN_FREE:
			continue
		var wd := c.rng.randi_range(int(CHASMS["w"][0]), int(CHASMS["w"][1]))
		var depth := c.rng.randi_range(int(CHASMS["depth"][0]), int(CHASMS["depth"][1]))
		var y0 := int(w.surface[x]) + StrataData.top(1) + 10
		var y1 := mini(y0 + depth, w.h - 14)
		var r := Rect2i(x - wd - 12, y0, wd * 2 + 24, y1 - y0)
		if not c.is_free(r):
			continue
		var every := int(CHASMS["ledge_every"])
		for y in range(y0, y1):
			var cx := x + int(bend.get_noise_1d(y) * 18.0)
			for dx in range(-wd / 2, wd / 2 + 1):
				w.set_tile(cx + dx, y, TileDefs.AIR)
			# una cenga ogni tanto, una volta a sinistra e una a destra, larga metà della voragine
			if (y - y0) % every == every - 1:
				var side := 1 if ((y - y0) / every) % 2 == 0 else -1
				for dx in range(0, wd / 2 + 1):
					w.set_tile(cx + side * (wd / 2 - dx), y, TileDefs.STONE)
		c.claim(r, "voragine")
		(c.notes["voragini"] as Array).append({"x": x, "y0": y0, "y1": y1})
		return
