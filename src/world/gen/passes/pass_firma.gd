class_name PassFirma
extends GenPass
## La firma del mondo (voce 44, dati in `SignaturesData`): un luogo che si trova solo in questo mondo, scelto dal seme
## e dai geni (`params["firma"]` la impone: le prove). Lontano dalla partenza e dal Cuore; dentro, lo **scrigno della
## firma** (bottino del profondo, Linfa antica, il ricordo del luogo). Negli appunti: `notes["firma"]` = {id, x, y}
## (il centro, per sapere quando il Germogliato la trova) e l'angolo dello scrigno.
## Viene quasi per ultima: nessuna passata dopo ci costruisce sopra.

const FAR_SPAWN := 260                 # colonne dalla partenza
const FAR_CUORE := 150


func title() -> String:
	return "Firma"


func run(w: World, c: GenContext) -> void:
	var id := String(c.params.get("firma", ""))
	if not SignaturesData.SIGNATURES.has(id):
		id = SignaturesData.choose(w.world_seed, c.params.get("geni", []))
	var sd: Dictionary = SignaturesData.SIGNATURES[id]
	for tries in 200:
		var strict := tries < 150               # le prime 150 prove solo in un posto libero (`GenContext.is_free`)
		var x := _column(w, c)
		if x < 0:
			continue
		var where: Variant = sd["where"]
		var ctr := Vector2i(x, w.surface[x])
		if where is int:
			var t0 := StrataData.top(int(where))
			var t1 := StrataData.top(int(where) + 1) if int(where) + 1 < StrataData.STRATA.size() else t0 + 200
			ctr.y += c.rng.randi_range(t0 + 30, maxi(t1 - 30, t0 + 31))
			if ctr.y > w.h - 40:
				continue
		var area := Rect2i(ctr.x - 35, ctr.y - 60, 70, 95)        # il luogo unico più grande, con il suo scrigno
		if strict and not c.is_free(area):
			continue                              # (poi dove capita: la firma è una promessa di ogni mondo)
		var chest: Vector2i = call("_" + id, w, c, ctr)
		if chest.x < 0:
			continue
		_fill_chest(w, c, chest, id)
		c.claim(area, "firma")
		c.notes["firma"] = {"id": id, "x": ctr.x, "y": ctr.y, "scrigno": chest}
		return
	c.notes["firma"] = {}


## Una colonna lontana dalla partenza, dal Cuore e dai bordi.
func _column(w: World, c: GenContext) -> int:
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	var margin := mini(160, w.w / 6)
	var x := c.rng.randi_range(margin, w.w - margin - 1)
	if absi(x - w.spawn.x) < mini(FAR_SPAWN, w.w / 4) or absi(x - cuore.x) < FAR_CUORE:
		return -1
	return x


## Lo scrigno della firma: 2×2 d'aria, pavimento sotto, il bottino del profondo, Linfa antica e il ricordo.
func _chest_at(w: World, o: Vector2i) -> Vector2i:
	for dy in 2:
		for dx in 2:
			w.set_tile(o.x + dx, o.y + dy, TileDefs.AIR)
			w.set_decor(o.x + dx, o.y + dy, 0)
		if not w.solid(o.x + dy, o.y + 2):
			w.set_tile(o.x + dy, o.y + 2, TileDefs.PIETRA_SEM)
	var so := o + Vector2i(0, 2 - int(StationsData.STATIONS["scrigno"]["size"][1]))          # appoggiato al pavimento (le casse sono basse)
	w.stations[so] = "scrigno"
	return so


func _fill_chest(w: World, c: GenContext, o: Vector2i, id: String) -> void:
	var chest := w.chest_at(o)
	var loot := LootData.roll_chest("rovina_4", c.rng, 4)
	for it in loot:
		chest.add(it, int(loot[it]))
	chest.add("linfa_antica", 3)
	chest.add(String(SignaturesData.SIGNATURES[id]["ricordo"]), 1)


func _disc(w: World, cx: float, cy: float, r: float, t: int) -> void:
	var ri := int(ceil(r))
	for dy in range(-ri, ri + 1):
		for dx in range(-ri, ri + 1):
			if dx * dx + dy * dy <= r * r + 0.3 and w.inside(int(cx) + dx, int(cy) + dy):
				w.set_tile(int(cx) + dx, int(cy) + dy, t)


func _clear_trees(w: World, x0: int, x1: int) -> void:
	for k in w.trees.keys():
		var keep: Array = []
		for t in w.trees[k]:
			if t.x < x0 or t.x > x1:
				keep.append(t)
		w.trees[k] = keep


# --- superficie ---------------------------------------------------------------------------------------------------
func _albero_colossale(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var gy := w.surface[ctr.x]
	var h := c.rng.randi_range(48, 60)
	if gy - h - 16 < 6:
		return Vector2i(-1, -1)
	_clear_trees(w, ctr.x - 24, ctr.x + 24)
	for y in range(gy - h, gy + 3):
		var flare := 3 + (maxi(0, y - (gy - 6)) if y > gy - 6 else 0)
		for dx in range(-flare, flare):
			w.set_tile(ctr.x + dx, y, TileDefs.RADICE)
	# rami e chioma: grandi masse di muschio attorno alla cima
	for k in 5:
		var side := -1 if k % 2 == 0 else 1
		var by := gy - h + 8 + k * 7
		for s in 12 + k * 2:
			_disc(w, ctr.x + side * s, by - s * 0.45, 1.2, TileDefs.RADICE)
		# una nuvola di ciuffi piccoli, non un blocco: la chioma resta irregolare e lascia passare la luce
		var tip := Vector2(ctr.x + side * (13 + k * 2), by - (13 + k * 2) * 0.45 - 2)
		for n in 7:
			_disc(w, tip.x + c.rng.randf_range(-6, 6), tip.y + c.rng.randf_range(-4, 3), c.rng.randf_range(1.6, 3.2), TileDefs.GRASS)
	for n in 16:
		_disc(w, ctr.x + c.rng.randf_range(-13, 13), gy - h - c.rng.randf_range(-2, 9), c.rng.randf_range(1.8, 3.6), TileDefs.GRASS)
	# la cavità in cima al tronco, con lo scrigno
	var o := Vector2i(ctr.x - 1, gy - h - 2)
	for dy in range(-2, 2):
		for dx in range(-3, 4):
			w.set_tile(o.x + dx, o.y + dy, TileDefs.AIR)
	for dx in range(-3, 4):
		w.set_tile(o.x + dx, o.y + 2, TileDefs.RADICE)
	return _chest_at(w, o)


func _cratere_stelle(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var r := 28
	var d := 14
	var base := w.surface[ctr.x]
	for dx in range(-r - 4, r + 5):
		var x := ctr.x + dx
		var old := w.surface[x]
		if absi(dx) <= r:
			var ny := base + int(d * sqrt(1.0 - pow(dx / float(r), 2)))
			for y in range(mini(old, base) - 20, ny):
				w.set_tile(x, y, TileDefs.AIR)
				w.set_decor(x, y, 0)
			w.surface[x] = ny
			var lining := TileDefs.CRYSTAL if absi(dx) < r / 2 else TileDefs.VUOTITE
			for k in 2:
				w.set_tile(x, ny + k, lining)
			if absi(dx) < r - 2 and c.rng.randf() < 0.3:
				w.set_decor(x, ny - 1, TileDefs.DECOR_SHARD)
		else:
			for k in 3:                              # il bordo sollevato
				w.set_tile(x, old - 1 - k, TileDefs.STONE)
			w.surface[x] = old - 3
	_clear_trees(w, ctr.x - r - 4, ctr.x + r + 4)
	return _chest_at(w, Vector2i(ctr.x - 1, base + d - 2))


func _foresta_pietrificata(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var half := 40
	_clear_trees(w, ctr.x - half, ctr.x + half)
	for dx in range(-half, half + 1):
		var x := ctr.x + dx
		var gy := w.surface[x]
		w.set_tile(x, gy, TileDefs.STONE)
		w.set_decor(x, gy - 1, TileDefs.DECOR_ROCKS[c.rng.randi_range(0, 1)] if c.rng.randf() < 0.15 else 0)
	var chest := Vector2i(-1, -1)
	for k in 10:
		var x := ctr.x - half + 4 + k * 8 + c.rng.randi_range(-1, 1)
		var gy := w.surface[x]
		var big := k == 5
		var hh := c.rng.randi_range(7, 12) + (6 if big else 0)
		var tw := 4 if big else c.rng.randi_range(1, 2)
		for y in range(gy - hh, gy):
			for dx in tw:
				w.set_tile(x + dx, y, TileDefs.STONE)
		_disc(w, x + tw / 2.0, gy - hh - 2, 3.5 + (2.0 if big else 0.0), TileDefs.MATTONI)
		if big:
			chest = Vector2i(x + 1, gy - 2)          # lo scrigno nel cavo del tronco più grande
	if chest.x < 0:
		return chest
	return _chest_at(w, chest)


func _pozzo_senza_fondo(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var bottom := w.surface[ctr.x] + StrataData.top(4) + 20
	if bottom > w.h - 12:
		return Vector2i(-1, -1)
	var top := w.surface[ctr.x] - 6
	for y in range(top, bottom + 2):
		for dx in range(-4, 5):
			var t := TileDefs.AIR
			if absi(dx) == 4 or y == bottom + 1:
				t = TileDefs.PIETRA_SEM
			if y < w.surface[ctr.x] and absi(dx) < 4:
				continue
			w.set_tile(ctr.x + dx, y, t)
			if absi(dx) < 4 and y >= w.surface[ctr.x]:
				w.walls[y * w.w + ctr.x + dx] = TileDefs.WALL_SEM
		if y % 9 == 0 and y > w.surface[ctr.x] + 4:
			w.set_decor(ctr.x - 3, y, TileDefs.DECOR_RUNE)
	for side in [-1, 1]:                         # le due colonne dei Seminatori all'imbocco
		for k in 6:
			w.set_tile(ctr.x + side * 5, w.surface[ctr.x] - 1 - k, TileDefs.PIETRA_SEM)
	return _chest_at(w, Vector2i(ctr.x - 1, bottom - 1))


# --- cielo --------------------------------------------------------------------------------------------------------
func _arco_radici(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var span := 110
	var rise := 46
	var x0 := ctr.x - span / 2
	var base := w.surface[ctr.x]
	if base - rise - 12 < 6:
		return Vector2i(-1, -1)
	for s in span * 3:
		var t := s / float(span * 3)
		var x := x0 + span * t
		var y := lerpf(w.surface[x0], w.surface[x0 + span], t) - rise * sin(PI * t)
		_disc(w, x, y, 2.6 - 1.0 * sin(PI * t), TileDefs.RADICE)
	var apex := Vector2i(ctr.x, int(lerpf(w.surface[x0], w.surface[x0 + span], 0.5) - rise) - 2)
	for dx in range(-4, 5):
		w.set_tile(apex.x + dx, apex.y + 1, TileDefs.RADICE)
	return _chest_at(w, Vector2i(apex.x - 1, apex.y - 2))


func _isola_sospesa(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var top := w.surface[ctr.x] - c.rng.randi_range(40, 50)
	if top < 12:
		return Vector2i(-1, -1)
	var half := 20
	for dx in range(-half, half + 1):
		var depth := int(12.0 * sqrt(maxf(1.0 - pow(dx / float(half), 2), 0.0)))
		for k in depth + 1:
			w.set_tile(ctr.x + dx, top + k, TileDefs.GRASS if k == 0 else TileDefs.DIRT)
		if depth > 0:
			w.set_decor(ctr.x + dx, top + depth + 1, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)] if c.rng.randf() < 0.5 else 0)
	for dx in [-12, 11]:
		if w.tree_fits(Vector2i(ctr.x + dx, top - 1)):
			w.add_tree(Vector2i(ctr.x + dx, top - 1), TreesData.roll(c.rng, w.biomes[clampi(ctr.x + dx, 0, w.w - 1)],
				w.free_above(Vector2i(ctr.x + dx, top - 1), FloraData.HEIGHT)))
	return _chest_at(w, Vector2i(ctr.x - 1, top - 2))


# --- sottosuolo ---------------------------------------------------------------------------------------------------
func _cave(w: World, ctr: Vector2i, rx: int, ry: int, wall: int) -> void:
	for y in range(ctr.y - ry, ctr.y + ry + 1):
		for x in range(ctr.x - rx, ctr.x + rx + 1):
			if Vector2((x - ctr.x) / float(rx), (y - ctr.y) / float(ry)).length() <= 1.0 and w.inside(x, y):
				w.set_tile(x, y, TileDefs.AIR)
				w.walls[y * w.w + x] = wall


func _floor_of(w: World, x: int, y: int) -> int:
	for k in 40:
		if w.solid(x, y + k):
			return y + k
	return y


func _grotta_lucciole(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	_cave(w, ctr, 30, 13, TileDefs.WALL_ROOT)
	for dx in range(-30, 31):
		var x := ctr.x + dx
		var fy := _floor_of(w, x, ctr.y)
		w.set_tile(x, fy, TileDefs.GRASS)
		var r := c.rng.randf()
		w.set_decor(x, fy - 1, TileDefs.DECOR_GLOW if r < 0.35 else (TileDefs.DECOR_FLOWERS[c.rng.randi_range(0, 2)] if r < 0.7 else 0))
		for y in range(ctr.y - 14, ctr.y):
			if w.solid(x, y) and not w.solid(x, y + 1):
				if c.rng.randf() < 0.45:
					w.set_decor(x, y + 1, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)])
				break
	return _chest_at(w, Vector2i(ctr.x - 1, _floor_of(w, ctr.x, ctr.y) - 2))


func _cuore_radice(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var n := c.noise("nodo_radici", 0.12, 2)
	for y in range(ctr.y - 18, ctr.y + 19):
		for x in range(ctr.x - 18, ctr.x + 19):
			var d := Vector2(x - ctr.x, y - ctr.y).length()
			if d + n.get_noise_2d(x, y) * 4.0 <= 16.0 and w.inside(x, y):
				w.set_tile(x, y, TileDefs.RADICE if d > 6.0 else TileDefs.AIR)
				w.walls[y * w.w + x] = TileDefs.WALL_ROOT
	for x in range(ctr.x + 5, ctr.x + 22):           # un cunicolo per entrare
		for dy in range(1, 4):
			w.set_tile(x, ctr.y + dy, TileDefs.AIR)
	for dx in range(-5, 6):
		w.set_tile(ctr.x + dx, ctr.y + 4, TileDefs.RADICE)
	return _chest_at(w, Vector2i(ctr.x - 1, ctr.y + 2))


func _serra_sepolta(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var rw := 44
	var rh := 13
	var p := Vector2i(ctr.x - rw / 2, ctr.y)
	for y in range(p.y - rh - 1, p.y + 3):
		for x in range(p.x - 1, p.x + rw + 1):
			var shell := y == p.y - rh - 1 or y == p.y + 2 or x == p.x - 1 or x == p.x + rw
			w.set_tile(x, y, TileDefs.PIETRA_SEM if shell else (TileDefs.DIRT if y > p.y else TileDefs.AIR))
			w.walls[y * w.w + x] = TileDefs.WALL_SEM
			w.set_decor(x, y, 0)
	for x in range(p.x, p.x + rw):
		w.set_tile(x, p.y + 1, TileDefs.GRASS)
		var r := c.rng.randf()
		if r < 0.25:
			w.set_decor(x, p.y, TileDefs.DECOR_CROPS[c.rng.randi_range(1, TileDefs.DECOR_CROPS.size() - 1)])
		elif r < 0.45:
			w.set_decor(x, p.y, TileDefs.DECOR_FERN)
		elif r < 0.6:
			w.set_decor(x, p.y, TileDefs.DECOR_FLOWERS[c.rng.randi_range(0, 2)])
	for x in range(p.x + 2, p.x + rw - 2, 5):
		w.set_decor(x, p.y - rh, TileDefs.DECOR_RUNE)
	for side in [p.x - 1, p.x + rw]:                  # porte sui due lati
		for dy in range(-2, 1):
			w.set_tile(side, p.y + dy, TileDefs.AIR)
	# due scrigni normali ai lati, quello della firma al centro
	for ox in [p.x + 4, p.x + rw - 6]:
		var o := _chest_at(w, Vector2i(ox, p.y - 1))
		var loot := LootData.roll_chest("rovina_2", c.rng, 2)
		for it in loot:
			w.chest_at(o).add(it, int(loot[it]))
	return _chest_at(w, Vector2i(ctr.x - 1, p.y - 1))


## Roadmap 19, voce 206: una Centrale dei Seminatori già viva (`PassCentrali.build`), lo scrigno nella sala interna.
func _centrale_intatta(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var x := ctr.x - PassCentrali.W / 2
	var y := ctr.y - PassCentrali.H / 2
	PassCentrali.build(w, x, y, c.rng, true)
	var out: Array = c.notes.get("centrali", [])
	out.append([Vector2i(x, y), true])
	c.notes["centrali"] = out
	return _chest_at(w, Vector2i(x + PassCentrali.W - 4, y + PassCentrali.H - 2))


func _colonne_ambra(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var half := 26
	var hh := 9
	for dx in range(-half, half + 1):
		var h := int(hh * sqrt(maxf(1.0 - pow(dx / float(half + 2), 4), 0.0)))
		for y in range(ctr.y - h, ctr.y + 1):
			w.set_tile(ctr.x + dx, y, TileDefs.AIR)
			w.walls[y * w.w + ctr.x + dx] = TileDefs.WALL_STONE
		w.set_tile(ctr.x + dx, ctr.y + 1, TileDefs.GRASS_AMBRA)
		if (dx + half) % 7 == 3 and absi(dx) > 3:
			for y in range(ctr.y - h, ctr.y + 1):
				w.set_tile(ctr.x + dx, y, TileDefs.AMBRA)
				w.set_tile(ctr.x + dx + 1, y, TileDefs.AMBRA)
	return _chest_at(w, Vector2i(ctr.x - 1, ctr.y - 1))


func _alveare_cristallo(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var cells: Array[Vector2i] = []
	for row in range(-2, 3):
		for col in range(-3, 4):
			cells.append(ctr + Vector2i(col * 9 + (4 if row % 2 != 0 else 0), row * 8))
	for p in cells:
		_disc(w, p.x, p.y, 4.6, TileDefs.CRYSTAL)
	for p in cells:
		_disc(w, p.x, p.y, 3.4, TileDefs.AIR)
		for y in range(p.y - 4, p.y + 5):
			for x in range(p.x - 4, p.x + 5):
				if w.inside(x, y):
					w.walls[y * w.w + x] = TileDefs.WALL_SCISTO
	# passaggi tra le celle vicine, e un'uscita
	for i in cells.size():
		for j in range(i + 1, cells.size()):
			if Vector2(cells[i] - cells[j]).length() < 10.0:
				for s in 11:
					var q := Vector2(cells[i]).lerp(Vector2(cells[j]), s / 10.0)
					_disc(w, q.x, q.y, 1.2, TileDefs.AIR)
	for x in range(ctr.x + 30, ctr.x + 46):
		for dy in range(-1, 2):
			w.set_tile(x, ctr.y + dy, TileDefs.AIR)
	return _chest_at(w, Vector2i(ctr.x - 1, ctr.y + 1))


func _bolla_vuoto(w: World, c: GenContext, ctr: Vector2i) -> Vector2i:
	var r := 17.0
	if ctr.y + r + 4 >= w.h:
		return Vector2i(-1, -1)
	for y in range(ctr.y - 20, ctr.y + 21):
		for x in range(ctr.x - 20, ctr.x + 21):
			var d := Vector2(x - ctr.x, y - ctr.y).length()
			if d > r + 2.0 or not w.inside(x, y):
				continue
			var t := TileDefs.AIR
			if d > r:
				t = TileDefs.VUOTITE
			elif y > ctr.y + 12:
				t = TileDefs.CRYSTAL
			w.set_tile(x, y, t)
			w.walls[y * w.w + x] = TileDefs.WALL_VOID
	for dx in range(-9, 10):
		var fy := _floor_of(w, ctr.x + dx, ctr.y)
		if c.rng.randf() < 0.3:
			w.set_decor(ctr.x + dx, fy - 1, TileDefs.DECOR_SHARD)
	return _chest_at(w, Vector2i(ctr.x - 1, _floor_of(w, ctr.x, ctr.y) - 2))
