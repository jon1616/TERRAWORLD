class_name PassCielo
extends GenPass
## Le Chiome del cielo (Roadmap 16, voce 155): il cielo di ogni mondo, diviso in zone (`SkyData.make_zones`), con le
## isole della forma del loro bioma (`isle` nei file del cielo), le **radici pendenti** (colonne di passerelle che
## scendono dalle isole basse fin quasi a terra), le **correnti ascensionali** (dalla superficie alle isole basse e da
## queste alle alte, lette da `Gravity`), i ponti di liane tra isole vicine e le pozze d'acqua.
## Niente cielo nel Giardino, nei mondi a Guscio (il tetto) e con il gene «Senza cielo».
## Negli appunti: "cielo" (le zone, anche in `World.sky`), "isole_cielo" [{rect, biome, band, top}] per chi viene dopo
## (osservatori, Signori, prove), e le correnti aggiunte a "correnti".

const ISLE_GAP := 8                    # tessere libere attorno a un'isola (la mappa dei posti)
const ROOT_EVERY := 3                  # righe tra due passerelle delle radici pendenti (il salto è di 3,36 tessere)


func title() -> String:
	return "Cielo"


func run(w: World, c: GenContext) -> void:
	var g := c.genes()
	if g.get("roof", false) or g.get("no_sky", false) or c.params.get("giardino", false):
		w.sky = []
		c.notes["cielo"] = []
		return
	var zones := SkyData.make_zones(w, c.rng, float(g.get("sky_scale", 1.0)), g.get("sky", {}))
	w.sky = zones
	c.notes["cielo"] = zones
	var isles := []
	var currents: Array = c.notes.get("correnti", [])
	for z in zones:
		var lows := _band(w, c, z, "basso", isles)
		var highs := _band(w, c, z, "alto", isles)
		_roots(w, c, lows)
		_bridges(w, c, lows)
		_currents(w, c, z, lows, highs, currents)
	c.notes["isole_cielo"] = isles
	c.notes["correnti"] = currents


## Le isole di una fascia di una zona: restituisce le isole messe ({rect, biome, band, top, x}).
func _band(w: World, c: GenContext, z: Dictionary, band: String, all: Array) -> Array:
	var id := String(z["low"] if band == "basso" else z["high"])
	var b := SkyData.get_biome(id)
	var y_lo := int(z["split"]) + 6 if band == "basso" else SkyData.TOP + 8     # la riga più alta per la cima
	var y_hi := int(z["base"]) - 4 if band == "basso" else int(z["split"]) - 6   # la più bassa
	if y_hi - y_lo < 6:
		return []
	var x0 := int(z["x0"])
	var x1 := int(z["x1"])
	var n := int(roundf(float(b.get("isles", 1.5)) * (x1 - x0) / 100.0))
	var out := []
	for tries in n * 8:
		if out.size() >= n:
			break
		var half := c.rng.randi_range(7, 16) if band == "basso" else c.rng.randi_range(6, 14)
		var x := c.rng.randi_range(x0 + half + 4, maxi(x1 - half - 4, x0 + half + 5))
		if absi(x - w.spawn.x) < SkyData.SPAWN_FREE + half:
			continue
		var top := c.rng.randi_range(y_lo, y_hi)
		var r := Rect2i(x - half - ISLE_GAP, top - 10, 2 * half + 2 * ISLE_GAP, 22)
		if r.position.x < 2 or r.end.x > w.w - 2 or not c.is_free(r) or not _above_ground(w, r):
			continue
		var shape := String(b.get("isle", "zolla"))
		var cells := _shape(c, shape, half)
		_paint(w, c, b, Vector2i(x, top), cells)
		c.claim(Rect2i(x - half - 2, top - 8, 2 * half + 4, 18), "cielo")
		var e := {"rect": [x - half, top, 2 * half + 1, 10], "biome": id, "band": band, "top": top, "x": x, "half": half}
		out.append(e)
		all.append(e)
		_extras(w, c, b, Vector2i(x, top), half)
	return out


## Tutto il rettangolo sta sopra il terreno (con 6 tessere d'aria in più sotto).
func _above_ground(w: World, r: Rect2i) -> bool:
	for x in range(maxi(r.position.x, 0), mini(r.end.x, w.w)):
		if r.end.y + 6 >= w.surface[x]:
			return false
	return r.position.y > 2


## Le celle di un'isola rispetto al centro della cima: {Vector2i: "top"|"body"|"rock"}. Le forme dei biomi:
## zolla (lente con la pancia di terra), nuvola (piatta e gonfia), giardino (lente con un terrazzo), scoglio (punte di
## cristallo), tempesta (nuvola scura e spessa, bucata), stelle (grumi sparsi).
func _shape(c: GenContext, shape: String, half: int) -> Dictionary:
	var cells := {}
	match shape:
		"nuvola", "tempesta":
			var thick := 3 if shape == "nuvola" else 5
			for k in half:
				var cx := c.rng.randi_range(-half + 2, half - 2)
				var cy := c.rng.randi_range(0, thick)
				var rr := c.rng.randf_range(2.0, 3.8 if shape == "nuvola" else 4.6)
				for dy in range(-4, 6):
					for dx in range(-5, 6):
						if Vector2(dx, dy * 1.4).length() <= rr:
							cells[Vector2i(cx + dx, cy + dy)] = "body"
			if shape == "tempesta":
				for k in 3:                                   # qualche buco: le nuvole di tempesta sono sfilacciate
					var h := Vector2i(c.rng.randi_range(-half + 3, half - 3), c.rng.randi_range(1, thick))
					for dy in range(-1, 2):
						for dx in range(-1, 2):
							cells.erase(h + Vector2i(dx, dy))
		"scoglio":
			for k in maxi(3, half / 2):
				var bx := c.rng.randi_range(-half + 1, half - 1)
				var hgt := c.rng.randi_range(3, 9)
				var wd := c.rng.randi_range(1, 3)
				for dy in range(-hgt, 4):
					var ww := wd if dy < 0 else wd + 2 - absi(dy) / 2
					for dx in range(-ww, ww + 1):
						cells[Vector2i(bx + dx, dy + 2)] = "body"
			for dx in range(-half + 2, half - 1):             # la base che tiene insieme le punte
				for dy in range(2, 5 - absi(dx) * 3 / half):
					cells[Vector2i(dx, dy)] = "body"
		"stelle":
			for k in maxi(3, half / 2):
				var cx := c.rng.randi_range(-half, half)
				var cy := c.rng.randi_range(-3, 4)
				var rr := c.rng.randf_range(1.6, 3.2)
				for dy in range(-4, 5):
					for dx in range(-4, 5):
						if Vector2(dx, dy).length() <= rr:
							cells[Vector2i(cx + dx, cy + dy)] = "rock" if Vector2(dx, dy).length() < rr - 1.4 else "body"
		_:
			# zolla e giardino: una lente con la cima piatta e la pancia tonda
			var depth_k := c.rng.randf_range(0.45, 0.75)
			for dx in range(-half, half + 1):
				var depth := int(half * depth_k * sqrt(maxf(1.0 - pow(dx / float(half), 2), 0.0))) + 2
				for k in depth + 1:
					cells[Vector2i(dx, k)] = "rock" if k > depth / 2 + 1 else "body"
			if shape == "giardino":
				var th := half / 2
				var off := c.rng.randi_range(-half / 3, half / 3)
				for dx in range(-th, th + 1):
					var d2 := int(2.5 * sqrt(maxf(1.0 - pow(dx / float(th), 2), 0.0))) + 1
					for k in range(1, d2 + 1):
						cells[Vector2i(off + dx, -k)] = "body"
	# la cima: le celle senza niente sopra diventano il pavimento del bioma
	for p in cells.keys():
		if not cells.has(p + Vector2i(0, -1)):
			cells[p] = "top"
	return cells


func _paint(w: World, c: GenContext, b: Dictionary, o: Vector2i, cells: Dictionary) -> void:
	var floor_t := int(b["floor"])
	var body_t := int(b.get("body", floor_t))
	var rock_t := int(b.get("rock", body_t))
	for p in cells:
		var q: Vector2i = o + p
		if not w.inside(q.x, q.y) or q.y < 2:
			continue
		var kind := String(cells[p])
		w.set_tile(q.x, q.y, floor_t if kind == "top" else (rock_t if kind == "rock" else body_t))


## Alberi, radichette che pendono, pozze d'acqua.
func _extras(w: World, c: GenContext, b: Dictionary, o: Vector2i, half: int) -> void:
	# le radichette sotto le zolle
	if String(b.get("isle", "")) in ["zolla", "giardino"]:
		for dx in range(-half, half + 1):
			var x := o.x + dx
			var y := o.y
			while y < o.y + 14 and w.solid(x, y):
				y += 1
			if c.rng.randf() < 0.4 and not w.solid(x, y) and w.solid(x, y - 1):
				w.set_decor(x, y, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)])
	# una pozza: una conca di 4-7 tessere scavata nella cima, piena d'acqua
	if c.rng.randf() < float(b.get("pools", 0.0)) and half >= 8:
		var pw := c.rng.randi_range(4, mini(7, half - 3))
		var px := o.x + c.rng.randi_range(-half + 3, half - 3 - pw)
		var ok := true
		for x in range(px - 1, px + pw + 1):
			for dy in range(0, 4):
				if not w.solid(x, o.y + dy):
					ok = false
		if ok:
			for x in range(px, px + pw):
				for dy in range(0, 2):
					w.set_tile(x, o.y + dy, TileDefs.AIR)
					w.set_liq(x, o.y + dy, 8, 0)
	# un albero o due sulle zolle con l'erba
	if c.rng.randf() < float(b.get("trees", 0.0)):
		for dx in [-half / 2, half / 3]:
			var base := Vector2i(o.x + dx, o.y - 1)
			if w.solid(base.x, base.y + 1) and not w.solid(base.x, base.y) and w.tree_fits(base):
				w.add_tree(base, TreesData.roll(c.rng, w.biomes[clampi(base.x, 0, w.w - 1)],
					w.free_above(base, FloraData.HEIGHT)))


## Le radici pendenti: da metà delle isole basse una colonna di passerelle scende fin quasi a terra.
func _roots(w: World, c: GenContext, lows: Array) -> void:
	for e in lows:
		if c.rng.randf() > 0.6:
			continue
		var half := int(e["half"])
		var x := int(e["x"]) + c.rng.randi_range(-half / 2, half / 2)
		var y := int(e["top"])
		while y < w.h - 1 and w.solid(x, y):
			y += 1
		# la prima passerella proprio sotto l'isola, poi una ogni ROOT_EVERY righe fino a 3 tessere dal terreno
		var ground := int(w.surface[x])
		var yy := y + 1
		var col := []
		var clear := true
		while yy <= ground - 3:
			if w.solid(x, yy) or w.solid(x - 1, yy) or w.solid(x + 1, yy):
				clear = false
				break
			col.append(yy)
			yy += ROOT_EVERY
		if not clear or col.is_empty():
			continue
		for py in col:
			w.set_plat(x, py, true)
			if c.rng.randf() < 0.5:
				w.set_decor(x + (1 if c.rng.randf() < 0.5 else -1), py, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)])
		# l'ultima vicino a terra: si sale saltando dal suolo
		if int(col[col.size() - 1]) < ground - 3:
			w.set_plat(x, ground - 3, true)


## I ponti di liane: tra due isole basse vicine e quasi alla stessa altezza, una fila di passerelle.
func _bridges(w: World, c: GenContext, lows: Array) -> void:
	var list := lows.duplicate()
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["x"]) < int(b["x"]))
	for i in range(list.size() - 1):
		var a: Dictionary = list[i]
		var b: Dictionary = list[i + 1]
		var xa := int(a["x"]) + int(a["half"])
		var xb := int(b["x"]) - int(b["half"])
		if xb - xa > 34 or xb - xa < 4 or absi(int(a["top"]) - int(b["top"])) > 5 or c.rng.randf() > 0.55:
			continue
		var y := maxi(int(a["top"]), int(b["top"])) - 1
		var free := true
		for x in range(xa + 1, xb):
			if w.solid(x, y) or w.solid(x, y - 1) or w.solid(x, y - 2):
				free = false
		if not free:
			continue
		for x in range(xa, xb + 1):
			if not w.solid(x, y):
				w.set_plat(x, y, true)


## Le correnti: una dalla superficie a un'isola bassa, una da un'isola bassa (o da un'isoletta di nuvola messa
## apposta) a un'isola alta, più quelle dei Giardini del vento.
func _currents(w: World, c: GenContext, z: Dictionary, lows: Array, highs: Array, currents: Array) -> void:
	var extra := int(SkyData.get_biome(String(z["low"])).get("currents", 0))
	var ups := 1 + extra
	var shuffled := lows.duplicate()
	for i in shuffled.size():
		var j := c.rng.randi_range(0, shuffled.size() - 1)
		var t: Variant = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = t
	for e in shuffled:
		if ups <= 0:
			break
		var side := -1 if c.rng.randf() < 0.5 else 1
		var x := int(e["x"]) + side * (int(e["half"]) + 2)
		if x < 2 or x >= w.w - 2:
			continue
		var y0 := int(e["top"]) - 2
		var y1 := int(w.surface[x]) - 1
		if _column_clear(w, x, y0 + 1, y1):
			currents.append({"x": x, "w": 1, "y0": y0, "y1": y1, "cielo": true})
			ups -= 1
	# verso il cielo alto
	if highs.is_empty():
		return
	var h: Dictionary = highs[c.rng.randi_range(0, highs.size() - 1)]
	var side := -1 if c.rng.randf() < 0.5 else 1
	var hx := int(h["x"]) + side * (int(h["half"]) + 2)
	if hx < 4 or hx >= w.w - 4:
		return
	var y0 := int(h["top"]) - 2
	# un'isola bassa sotto? altrimenti un'isoletta di nuvola apposta, nel cielo basso
	var pad_y := int(z["split"]) + 8
	for e in lows:
		if absi(int(e["x"]) - hx) <= int(e["half"]) - 1:
			pad_y = int(e["top"])
	if not w.solid(hx, pad_y):
		for dx in range(-3, 4):
			for dy in 2:
				w.set_tile(hx + dx, pad_y + dy, 52)                # Nuvola (la tessera del Mare di nuvole)
	if _column_clear(w, hx, y0 + 1, pad_y - 1):
		currents.append({"x": hx, "w": 1, "y0": y0, "y1": pad_y - 1, "cielo": true})


func _column_clear(w: World, x: int, y0: int, y1: int) -> bool:
	if y1 - y0 < 4:
		return false
	for y in range(y0, y1 + 1):
		for dx in range(-1, 2):
			if w.solid(x + dx, y):
				return false
	return true
