class_name PassAcqua
extends GenPass
## L'acqua dei mondi (voce 73): laghetti nelle conche delle grotte (in ogni mondo qualcuno; il gene Sorgenti ne mette
## molti di più) e, con il gene **Sommerso**, un mare che copre quasi tutto: sotto un livello comune ogni conca di
## superficie si riempie, con le grotte aperte vicine; al centro un'isola asciutta per la partenza. Tutto nasce fermo:
## l'acqua scorre solo quando qualcosa la tocca (`Liquids`).

const POOLS := 40                      # conche cercate in un mondo normale
const POOL_MAX := 600                  # celle al più: più grande è una grotta aperta, non una conca
const ISLAND := 26
## Voce 452 (Roadmap 57): le falde, laghi sotterranei grandi nelle Caverne e nelle Profondità: quante, quanto profonde,
## quante celle al più.
const FALDE := {"n": 10, "depth": [4, 9], "max": 3000}                     # metà larghezza dell'isola della partenza, nei mondi sommersi


func title() -> String:
	return "Acqua"


func run(w: World, c: GenContext) -> void:
	_chasms(w, c)
	if bool(c.params.get("giardino", false)):
		return
	_seas(w, c)                                     # voce 461: i mari ai bordi (`PassMari`)
	var g := c.genes()
	var rng := c.rng
	var n := roundi(POOLS * float(g.get("pools", 1.0)))
	var made := 0
	for k in n * 4:
		if made >= n:
			break
		var x := rng.randi_range(20, w.w - 21)
		var y := w.surface[x] + rng.randi_range(StrataData.top(1), mini(StrataData.top(4), w.h - w.surface[x] - 10))
		if y >= w.h - 4 or w.solid(x, y):
			continue
		while y < w.h - 2 and not w.solid(x, y + 1):
			y += 1
		if _fill_basin(w, Vector2i(x, y), rng.randi_range(1, 4), LiquidsData.ACQUA):
			made += 1
	# voce 74: qualche pozza di brace nel Fondo e di Linfa nelle Profondità, in ogni mondo
	for spec in [[LiquidsData.BRACE, 4, 6], [LiquidsData.LINFA, 3, 4]]:
		var got := 0
		for k in int(spec[2]) * 6:
			if got >= int(spec[2]):
				break
			var x := rng.randi_range(20, w.w - 21)
			var y := w.surface[x] + rng.randi_range(StrataData.top(int(spec[1])), mini(StrataData.top(int(spec[1])) + 80, w.h - w.surface[x] - 10))
			if y >= w.h - 4 or w.solid(x, y):
				continue
			while y < w.h - 2 and not w.solid(x, y + 1):
				y += 1
			if _fill_basin(w, Vector2i(x, y), rng.randi_range(1, 3), int(spec[0])):
				got += 1
	# voce 452: le falde
	var falde := 0
	for k in int(FALDE["n"]) * 8:
		if falde >= int(FALDE["n"]):
			break
		var x := rng.randi_range(20, w.w - 21)
		var y := w.surface[x] + rng.randi_range(StrataData.top(2) + 10, mini(StrataData.top(4) - 10, w.h - w.surface[x] - 10))
		if y >= w.h - 4 or w.solid(x, y):
			continue
		while y < w.h - 2 and not w.solid(x, y + 1):
			y += 1
		if _fill_basin(w, Vector2i(x, y), rng.randi_range(int(FALDE["depth"][0]), int(FALDE["depth"][1])), LiquidsData.ACQUA,
				int(FALDE["max"])):
			falde += 1
	c.notes["falde"] = falde
	if bool(g.get("sea", false)):
		_sea(w)
	c.notes["laghi"] = made


## Riempie la conca che ha il fondo in `floor`, fino a `depth` righe sopra: solo se è chiusa (sotto `POOL_MAX` celle).
static func _fill_basin(w: World, floor: Vector2i, depth: int, type: int, cap := POOL_MAX) -> bool:
	var top := floor.y - depth + 1
	var seen := {}
	var todo: Array[Vector2i] = [floor]
	var cells: Array[Vector2i] = []
	while not todo.is_empty():
		var p: Vector2i = todo.pop_back()
		if seen.has(p) or p.y < top or not w.inside(p.x, p.y) or w.solid(p.x, p.y):
			continue
		seen[p] = true
		cells.append(p)
		if cells.size() > cap:
			return false
		todo.append(p + Vector2i(1, 0))
		todo.append(p + Vector2i(-1, 0))
		todo.append(p + Vector2i(0, 1))
		todo.append(p + Vector2i(0, -1))
	if cells.size() < 6:
		return false
	for p in cells:
		w.set_liq(p.x, p.y, 8, type)
	return true


## Il mare del gene Sommerso: un livello più alto di quasi tutta la superficie; l'isola della partenza resta fuori.
static func _sea(w: World) -> void:
	var hs := Array(w.surface)
	hs.sort()
	var level: int = hs[int(hs.size() * 0.08)] - 6       # sopra quasi tutta la superficie: un mare, non una pozza
	var cx := w.w / 2
	for x in range(cx - ISLAND, cx + ISLAND):
		var top := mini(w.surface[x], level - 3)
		for y in range(top, w.surface[x]):
			w.set_tile(x, y, TileDefs.DIRT)
			w.set_decor(x, y, 0)
		if top < w.surface[x]:
			w.set_tile(x, top, TileDefs.GRASS)
			w.surface[x] = top
	# gli alberi sotto il mare o sepolti dall'isola se ne vanno
	for k in w.trees.keys():
		var keep: Array[Vector3i] = []
		for t in w.trees[k]:
			var tv: Vector3i = t
			if tv.y < level and absi(tv.x - cx) >= ISLAND:
				keep.append(tv)
		w.trees[k] = keep
	for x in w.w:
		if absi(x - cx) < ISLAND:
			continue
		for y in range(level, mini(w.surface[x] + 60, w.h)):
			if not w.solid(x, y):
				w.set_liq(x, y, 8, LiquidsData.ACQUA)
			elif y > w.surface[x] + 2:
				break                                         # sotto il fondo solo le grotte che si aprono sul mare


## Voce 461: l'acqua dei mari ai bordi (`PassMari`), gli alberi sott'acqua tolti, e in ogni mare un relitto: uno scafo
## di assi rovesciato sul fondale, con uno scrigno dentro (il bottino delle rovine più un Forziere sommerso).
func _seas(w: World, c: GenContext) -> void:
	var wrecks := []
	for sea in c.notes.get("mari", []):
		var x0 := int(sea[0])
		var x1 := int(sea[1])
		var level := int(sea[2])
		for x in range(x0, x1):
			for y in range(level, mini(w.surface[x] + 1, w.h)):
				if not w.solid(x, y):
					w.set_liq(x, y, 8, LiquidsData.ACQUA)
					w.set_decor(x, y, 0)
		for k in w.trees.keys():
			var keep: Array[Vector3i] = []
			for t in w.trees[k]:
				var tv: Vector3i = t
				if tv.x < x0 or tv.x >= x1 or tv.y < level:
					keep.append(tv)
			w.trees[k] = keep
		# il relitto: verso il largo, dove il fondale è profondo
		var wx := x0 + (x1 - x0) / 3 if x0 == 0 else x1 - (x1 - x0) / 3
		var fy := int(w.surface[wx])
		if fy - level < 8:
			continue
		for dx in range(-9, 10):
			for dy in range(-6, 1):
				var x := wx + dx
				var y := fy - 1 + dy
				var edge := absi(dx) == 9 or dy == 0 or (dy == -6 and absi(dx) < 3)
				var inside := absi(dx) < 9 and dy < 0 and dy > -6
				if edge and c.rng.randf() < 0.85:
					w.set_tile(x, y, TileDefs.ASSI)
				elif inside:
					w.set_tile(x, y, TileDefs.AIR)
					w.walls[y * w.w + x] = TileDefs.WALL_ASSI
					w.set_liq(x, y, 8, LiquidsData.ACQUA)
		var o := Vector2i(wx - 1, fy - 3)
		if w.station_fits("scrigno", o):
			w.stations[o] = "scrigno"
			var loot := LootData.roll_chest("rovina_1", c.rng, 3)
			for id in loot:
				w.chest_at(o).add(id, int(loot[id]))
			w.chest_at(o).add("forziere_sommerso", 1)
			wrecks.append([o.x, o.y])
	c.notes["relitti"] = wrecks


## Voce 76: il fondo delle voragini dell'Arcipelago è un lago (chi ci cade non si ferisce).
func _chasms(w: World, c: GenContext) -> void:
	for a in c.notes.get("abissi", []):
		for x in range(int(a[0]) + 5, int(a[1]) - 5):
			for y in range(w.surface[x] - 4, w.surface[x]):
				if w.inside(x, y) and not w.solid(x, y):
					w.set_liq(x, y, 8, LiquidsData.ACQUA)
