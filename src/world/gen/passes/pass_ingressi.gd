class_name PassIngressi
extends GenPass
## Gli ingressi del sottosuolo (voce 467: riscritta come dati, `EntrancesData`): una galleria vicino alla partenza, poi uno
## ogni 170-250 colonne di una forma a caso (galleria, caverna sul fianco, dolina, pozzo), mai nei mari né nel posto di
## un'altra struttura. Lascia in `c.notes["ingressi"]` la cella in fondo a ciascuno (le prime creature nascono lì) e in
## `c.notes["ingressi_forme"]` [[x, forma]]. Le liane delle doline e dei pozzi le mette `PassRocce` (appunti
## "liane_ingressi" [[x, da, a]]), dopo le Decorazioni che riscrivono le celle d'aria.


func title() -> String:
	return "Ingressi"


func run(w: World, c: GenContext) -> void:
	var ends: Array[Vector2i] = []
	var forms := []
	var vines := []
	c.notes["liane_ingressi"] = vines
	ends.append(_galleria(w, c, w.spawn.x + int(EntrancesData.SPAWN["x"]), int(EntrancesData.SPAWN["steps"])))
	var sea := PackedByteArray()
	sea.resize(w.w)
	for s in c.notes.get("mari", []):
		for x in range(maxi(int(s[0]) - 15, 0), mini(int(s[1]) + 15, w.w)):
			sea[x] = 1
	var kinds: Array = EntrancesData.KINDS.keys()
	var tot := 0
	for k in kinds:
		tot += int(EntrancesData.KINDS[k]["w"])
	var x := 120 + c.rng.randi_range(0, 120)
	while x < w.w - 120:
		if absi(x - w.spawn.x) > 40 and sea[x] == 0:
			var r := c.rng.randi_range(1, tot)
			var kind := "galleria"
			for k in kinds:
				r -= int(EntrancesData.KINDS[k]["w"])
				if r <= 0:
					kind = String(k)
					break
			var d: Dictionary = EntrancesData.KINDS[kind]
			var e := Vector2i(-1, -1)
			match kind:
				"galleria":
					e = _galleria(w, c, x, c.rng.randi_range(int(d["steps"][0]), int(d["steps"][1])))
				"fianco":
					e = _fianco(w, c, x, d)
				"dolina":
					e = _dolina(w, c, x, d, vines)
				"pozzo":
					e = _pozzo(w, c, x, d, vines)
			if e.x < 0:
				e = _galleria(w, c, x, c.rng.randi_range(60, 120))
				kind = "galleria"
			ends.append(e)
			forms.append([x, kind])
		x += c.rng.randi_range(int(EntrancesData.EVERY[0]), int(EntrancesData.EVERY[1]))
	c.notes["ingressi"] = ends
	c.notes["ingressi_forme"] = forms


func _galleria(w: World, c: GenContext, x0: int, steps: int) -> Vector2i:
	var rng := c.rng
	var p := Vector2(x0, w.surface[x0] - 1)
	var ang := PI * 0.5 + rng.randf_range(-0.4, 0.4)
	for step in steps:
		var r := rng.randf_range(1.7, 2.7)
		_carve_disc(w, p, r)
		ang = clampf(ang + rng.randf_range(-0.3, 0.3), 0.45, 2.7)
		p += Vector2(cos(ang), sin(ang))
	return _floor_of(w, Vector2i(clampi(int(p.x), 1, w.w - 2), clampi(int(p.y), 0, w.h - 2)))


## Una sala scavata nel pendio, con la bocca dalla parte più bassa della terra.
func _fianco(w: World, c: GenContext, x: int, d: Dictionary) -> Vector2i:
	var sw := c.rng.randi_range(int(d["size"][0][0]), int(d["size"][0][1]))
	var sh := c.rng.randi_range(int(d["size"][1][0]), int(d["size"][1][1]))
	if absi(int(w.surface[x + 12]) - int(w.surface[x - 12])) < 4:
		return Vector2i(-1, -1)                                         # niente pendio: non c'è un fianco
	var down := 1 if w.surface[x + 12] > w.surface[x - 12] else -1      # verso valle
	var cx := x
	var cy := int(w.surface[x]) + sh / 2 + 3
	var rect := Rect2i(cx - sw / 2 - 2, cy - sh / 2 - 2, sw + 4, sh + 4)
	if not c.is_free(rect):
		return Vector2i(-1, -1)
	for yy in range(cy - sh / 2, cy + sh / 2 + 1):
		for xx in range(cx - sw / 2, cx + sw / 2 + 1):
			var dx := float(xx - cx) / (sw / 2.0)
			var dy := float(yy - cy) / (sh / 2.0)
			if dx * dx + dy * dy <= 1.0:
				_set_air(w, xx, yy)
	# la bocca: una galleria orizzontale dalla sala verso valle, fino all'aria aperta
	var yb := cy + sh / 4
	var xx := cx
	for k in 80:
		if xx < 2 or xx > w.w - 3:
			break
		if yb < int(w.surface[xx]) - 1:
			break
		for dy in range(-2, 2):
			_set_air(w, xx, yb + dy)
		xx += down
	c.claim(rect, "ingresso")
	return _floor_of(w, Vector2i(cx, cy))


## Un imbuto che si stringe in un pozzo.
func _dolina(w: World, c: GenContext, x: int, d: Dictionary, vines: Array) -> Vector2i:
	var top := c.rng.randi_range(int(d["top"][0]), int(d["top"][1]))
	var depth := c.rng.randi_range(int(d["depth"][0]), int(d["depth"][1]))
	var s := int(w.surface[x])
	var rect := Rect2i(x - top / 2 - 2, s - 2, top + 4, depth + 4)
	if not c.is_free(rect):
		return Vector2i(-1, -1)
	var cone := mini(12, depth / 3)
	for dy in range(0, depth):
		var half := 2.0 if dy > cone else lerpf(top / 2.0, 2.0, float(dy) / cone)
		for dx in range(-int(half), int(half) + 1):
			_set_air(w, x + dx, s + dy)
	vines.append([x - 2, s + cone, s + depth])
	c.claim(rect, "ingresso")
	return _floor_of(w, Vector2i(x, s + depth - 1))


func _pozzo(w: World, c: GenContext, x: int, d: Dictionary, vines: Array) -> Vector2i:
	var depth := c.rng.randi_range(int(d["depth"][0]), int(d["depth"][1]))
	var s := int(w.surface[x])
	var rect := Rect2i(x - 3, s - 2, 7, depth + 4)
	if not c.is_free(rect):
		return Vector2i(-1, -1)
	for dy in range(-1, depth):
		for dx in range(-1, 2):
			_set_air(w, x + dx, s + dy)
	# l'orlo del pozzo: due pietre ai lati, perché si veda da lontano
	for side in [-2, 2]:
		w.set_tile(x + side, s - 1, TileDefs.STONE)
	vines.append([x - 1, s, s + depth])
	c.claim(rect, "ingresso")
	return _floor_of(w, Vector2i(x, s + depth - 1))


static func _carve_disc(w: World, p: Vector2, r: float) -> void:
	for y in range(int(p.y - r) - 1, int(p.y + r) + 2):
		for x in range(int(p.x - r) - 1, int(p.x + r) + 2):
			if x < 1 or x >= w.w - 1 or y < 0 or y >= w.h - 1:
				continue
			if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
				w.tiles[y * w.w + x] = TileDefs.AIR


static func _set_air(w: World, x: int, y: int) -> void:
	if x < 1 or x >= w.w - 1 or y < 0 or y >= w.h - 1 or w.tile(x, y) == TileDefs.NODO:
		return
	w.tiles[y * w.w + x] = TileDefs.AIR


static func _floor_of(w: World, e: Vector2i) -> Vector2i:
	while e.y < w.h - 2 and w.tile(e.x, e.y + 1) == TileDefs.AIR:
		e.y += 1
	return e
