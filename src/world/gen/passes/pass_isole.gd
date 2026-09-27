class_name PassIsole
extends GenPass
## Le isole sospese (voce 48, gene raro «Isole sospese», solo per mutazione): zolle di terra ed erba che galleggiano
## nel cielo, con i loro alberi e le radici che pendono; una su tre ha uno scrigno. Negli appunti le loro posizioni.


func title() -> String:
	return "Isole"


func run(w: World, c: GenContext) -> void:
	var n := int(c.genes().get("islands", 0.0))
	var placed: Array[Vector2i] = []
	var chasms: Array = c.notes.get("abissi", [])          # voce 76: nell'Arcipelago le isole stanno sulle voragini
	var roof: PackedInt32Array = c.notes.get("tetto", PackedInt32Array())
	for tries in n * 30:
		if placed.size() >= n:
			break
		var x := c.rng.randi_range(80, w.w - 81)
		var top := 0
		var half := c.rng.randi_range(9, 20)
		if not chasms.is_empty():
			var a: Array = chasms[c.rng.randi_range(0, chasms.size() - 1)]
			x = c.rng.randi_range(int(a[0]) + 16, maxi(int(a[1]) - 16, int(a[0]) + 16))
			half = c.rng.randi_range(7, 14)
			top = w.surface[x] - int(a[2]) - c.rng.randi_range(-12, 10)
		else:
			top = w.surface[x] - c.rng.randi_range(28, 60)
		if absi(x - w.spawn.x) < 60:
			continue
		if top < 14 or (roof.size() > x and top - 6 <= roof[x]):
			continue
		var p := Vector2i(x, top)
		var far := true
		for q in placed:
			if absi(q.x - p.x) < 70:
				far = false
		var isle := Rect2i(x - half - 2, top - 6, 2 * half + 5, 16)
		if not far or not c.is_free(isle):
			continue
		_island(w, c, p, half, placed.size() % 3 == 0)
		c.claim(isle, "isola")
		placed.append(p)
	c.notes["isole"] = placed


func _island(w: World, c: GenContext, p: Vector2i, half: int, chest: bool) -> void:
	var depth_k := c.rng.randf_range(0.45, 0.7)
	for dx in range(-half, half + 1):
		var depth := int(half * depth_k * sqrt(maxf(1.0 - pow(dx / float(half), 2), 0.0))) + 1
		for k in depth + 1:
			w.set_tile(p.x + dx, p.y + k, TileDefs.GRASS if k == 0 else (TileDefs.DIRT if k < depth - 1 else TileDefs.STONE))
		if c.rng.randf() < 0.45:
			w.set_decor(p.x + dx, p.y + depth + 1, TileDefs.DECOR_ROOTS[c.rng.randi_range(0, 1)])
		elif c.rng.randf() < 0.4:
			w.set_decor(p.x + dx, p.y - 1, TileDefs.DECOR_GRASS[c.rng.randi_range(0, 2)])
	for dx in [-half / 2, half / 2]:
		if c.rng.randf() < 0.7 and w.tree_fits(Vector2i(p.x + dx, p.y - 1)):
			w.add_tree(Vector2i(p.x + dx, p.y - 1), TreesData.roll(c.rng, w.biomes[clampi(p.x + dx, 0, w.w - 1)],
				w.free_above(Vector2i(p.x + dx, p.y - 1), FloraData.HEIGHT)))
	if chest:
		var o := Vector2i(p.x - 1, p.y - int(StationsData.STATIONS["scrigno"]["size"][1]))
		for dy in 2:
			for dx in 2:
				w.set_decor(o.x + dx, o.y + dy, 0)
		w.stations[o] = "scrigno"
		var loot := LootData.roll_chest("rovina_2", c.rng, 3)
		for id in loot:
			w.chest_at(o).add(id, int(loot[id]))
