class_name SkyContinents
extends RefCounted
## I continenti sospesi (voce 443, Roadmap 56 «Il cielo grande»): nel cielo di mezzo di ogni zona 1-2 masse grandi
## (`SkyData.CONTINENT`), fatte come la superficie: una cima mossa da un rumore, una «chiglia» sotto che si assottiglia
## verso i bordi. Dentro: il pavimento del bioma, un corpo di terra, il cuore di roccia, **grotte con le pareti di fondo**
## (senza parete la luce del cielo le illuminerebbe come fuori, `LightMap`), le vene del bioma, uno scrigno del cielo.
## Sopra alberi e pozze (`PassCielo._extras`), sotto stalattiti e radichette; al centro della cima il luogo dei
## Seminatori (voce 445: `SkyData.SANCTUARY`, un progetto di `ProjectsData` con uno scrigno e una stele; appunti
## "luoghi_cielo" [progetto, x, cima], la stele in "rovine" per `PassStele`). Li chiama `PassCielo` prima delle isole,
## che così si sistemano attorno; ognuno fa `claim` e finisce negli appunti "isole_cielo" con "continente": true.


static func build(p: PassCielo, w: World, c: GenContext, z: Dictionary, all: Array) -> Array:
	var id := SkyData.band_biome(z, "medio")
	var rows := SkyData.band_rows(z, "medio")
	if id == "" or rows.is_empty():
		return []
	var b := SkyData.get_biome(id)
	var cd: Dictionary = SkyData.CONTINENT
	var x0 := int(z["x0"])
	var x1 := int(z["x1"])
	var zw := x1 - x0
	var out := []
	var n := c.rng.randi_range(int(cd["per_zone"][0]), int(cd["per_zone"][1]))
	if zw < int(cd["min_zone"]):
		n = mini(n, 1)
	for k in n:
		for tries in 24:
			var half := c.rng.randi_range(int(cd["half"][0]), mini(int(cd["half"][1]), zw / 2 - 24))
			if half < int(cd["half"][0]):
				break
			var cx := c.rng.randi_range(x0 + half + 12, x1 - half - 12)
			var thick := c.rng.randi_range(int(cd["thick"][0]), int(cd["thick"][1]))
			var y_lo := int(rows[0]) + 10
			var y_hi := int(rows[1]) - thick - 8
			if y_hi < y_lo:
				thick = int(rows[1]) - y_lo - 8
				y_hi = y_lo
				if thick < int(cd["thick"][0]) * 2 / 3:
					break
			var y0 := c.rng.randi_range(y_lo, y_hi)
			var r := Rect2i(cx - half - 8, y0 - 12, 2 * half + 16, thick + 34)
			if r.position.x < 4 or r.end.x > w.w - 4 or not c.is_free(r) or not p._above_ground(w, r):
				continue
			var e := _make(p, w, c, b, id, cx, y0, half, thick)
			c.claim(Rect2i(cx - half - 4, y0 - 10, 2 * half + 8, thick + 26), "continente")
			out.append(e)
			all.append(e)
			break
	return out


static func _make(p: PassCielo, w: World, c: GenContext, b: Dictionary, id: String, cx: int, y0: int, half: int,
		thick: int) -> Dictionary:
	var floor_t := int(b["floor"])
	var body_t := int(b.get("body", floor_t))
	var rock_t := int(b.get("rock", body_t))
	var n_top := c.noise("continente_cima", 0.03, 3)
	var n_keel := c.noise("continente_chiglia", 0.05, 2)
	var n_cave := c.noise("continente_grotte", 0.07, 2)
	var n_worm := c.noise("continente_gallerie", 0.04, 2)
	var cells := {}                                   # rispetto a (cx, y0): come le isole, per `PassCielo._ores`
	var tops := {}
	for x in range(cx - half, cx + half + 1):
		var t := float(x - cx) / half
		var env := sqrt(maxf(1.0 - t * t, 0.0))
		var ytop := y0 + int(n_top.get_noise_1d(x) * 5.0) + int((1.0 - env) * 9.0)
		# la chiglia: più profonda al centro, come una montagna capovolta, mai più sottile di un terzo ai bordi
		var ybot := ytop + maxi(3, int(thick * (0.3 + 0.7 * pow(env, 1.4)) + n_keel.get_noise_1d(x) * 8.0))
		tops[x] = ytop
		for y in range(ytop, ybot + 1):
			if y < 2:
				continue
			var d := y - ytop
			var kind := "top" if d == 0 else ("body" if d < 4 + int(n_keel.get_noise_1d(x * 3) * 2.0) else "rock")
			w.set_tile(x, y, floor_t if kind == "top" else (rock_t if kind == "rock" else body_t))
			if d >= 1:
				w.walls[y * w.w + x] = TileDefs.WALL_ROOT
			cells[Vector2i(x - cx, y - y0)] = kind
		# stalattiti e radichette sotto la chiglia
		if c.rng.randf() < 0.22:
			var drop := c.rng.randi_range(1, 4)
			for dy in range(1, drop + 1):
				w.set_tile(x, ybot + dy, body_t)
				cells[Vector2i(x - cx, ybot + dy - y0)] = "body"
		elif c.rng.randf() < 0.3:
			w.set_decor(x, ybot + 1, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)])
	# le grotte: dentro il corpo, mai a meno di 3 righe dalla cima né dalla chiglia (le pareti restano: sono buie)
	var caves := []
	for q in cells.keys():
		var x: int = cx + q.x
		var y: int = y0 + q.y
		if String(cells[q]) == "top" or y - int(tops.get(x, y)) < 4:
			continue
		if not w.solid(x, y + 3) or not w.solid(x, y + 2):
			continue
		var cave := n_cave.get_noise_2d(x, y * 1.4) > float(SkyData.CONTINENT["cave"]) \
			or absf(n_worm.get_noise_2d(x, y * 1.8)) < float(SkyData.CONTINENT["worm"])
		if cave:
			w.set_tile(x, y, TileDefs.AIR)
			cells.erase(q)
			caves.append(Vector2i(x, y))
	p._ores(w, c, b, Vector2i(cx, y0), cells)
	# alberi e pozze lungo la cima, a tratti
	var step := int(SkyData.CONTINENT["extras_every"])
	for x in range(cx - half + 10, cx + half - 10, step):
		if absi(x - cx) > 12:                     # il centro resta al luogo dei Seminatori
			p._extras(w, c, b, Vector2i(x, int(tops[x])), mini(step / 2, 14))
	_sanctuary(w, c, b, id, cx, int(tops[cx]))
	_chest(w, c, caves)
	return {"rect": [cx - half, y0, 2 * half + 1, thick], "biome": id, "band": "medio", "top": y0, "x": cx, "half": half,
		"continente": true}


## Voce 445: il luogo dei Seminatori al centro della cima (spianata sotto, aria sopra), con lo scrigno e la stele.
static func _sanctuary(w: World, c: GenContext, b: Dictionary, id: String, cx: int, top: int) -> void:
	var pid := String(SkyData.SANCTUARY.get(id, SkyData.SANCTUARY["_"]))
	var grid: Array = ProjectsData.PROJECTS[pid]["grid"]
	var gw := String(grid[0]).length()
	var gh := grid.size()
	var x0 := cx - gw / 2
	var y0 := top - gh + 1                            # l'ultima riga (il pavimento) sulla cima
	if y0 - 3 < SkyData.TOP:
		return
	var body_t := int(b.get("body", b.get("floor", TileDefs.STONE)))
	for x in range(x0 - 1, x0 + gw + 1):
		for y in range(y0 - 3, top):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_decor(x, y, 0)
			w.set_plat(x, y, false)
		for y in range(top, top + 3):
			if not w.solid(x, y):
				w.set_tile(x, y, body_t)
	var wall := ProjectsData.wall_id()
	for r in gh:
		var row := String(grid[r])
		for i in row.length():
			var ch := row[i]
			var q := Vector2i(x0 + i, y0 + r)
			var k := ProjectsData.kind_of(ch)
			if k > 0:
				w.set_build(q.x, q.y, k)
			elif ch == ".":
				w.walls[q.y * w.w + q.x] = wall
			elif ProjectsData.STATION.has(ch):
				w.walls[q.y * w.w + q.x] = wall
				if w.station_fits(String(ProjectsData.STATION[ch]), q):
					w.stations[q] = String(ProjectsData.STATION[ch])
	# lo scrigno: sul pavimento, dove c'è posto (dentro o accanto)
	var floor_y := top - 1
	for dx in [0, -3, 3, -5, 5, -(gw / 2 + 3), gw / 2 + 2]:
		var o := Vector2i(cx + int(dx), floor_y - 1)
		if w.station_fits("scrigno", o) and w.solid(o.x, floor_y + 1) and w.solid(o.x + 1, floor_y + 1):
			w.stations[o] = "scrigno"
			var loot := LootData.roll_chest("rovina_cielo", c.rng, 3)
			for it in loot:
				w.chest_at(o).add(it, int(loot[it]))
			break
	var rovine: Array = c.notes.get("rovine", [])
	rovine.append(Vector2i(x0 - 2, floor_y))           # la stele accanto all'ingresso (la mette `PassStele`)
	c.notes["rovine"] = rovine
	var luoghi: Array = c.notes.get("luoghi_cielo", [])
	luoghi.append([pid, cx, top])
	c.notes["luoghi_cielo"] = luoghi


## Lo scrigno del cielo in una grotta del continente: su un pavimento, con due celle libere sopra.
static func _chest(w: World, c: GenContext, caves: Array) -> void:
	for k in mini(caves.size(), 200):
		var q: Vector2i = caves[c.rng.randi_range(0, caves.size() - 1)]
		var o := Vector2i(q.x, q.y - 1)
		if w.solid(q.x, q.y + 1) and w.solid(q.x + 1, q.y + 1) and w.station_fits("scrigno", o):
			w.stations[o] = "scrigno"
			var loot := LootData.roll_chest("rovina_cielo", c.rng, 3)
			for id in loot:
				w.chest_at(o).add(id, int(loot[id]))
			return
