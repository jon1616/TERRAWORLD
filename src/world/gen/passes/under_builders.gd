class_name UnderBuilders
extends RefCounted
## Le forme dei biomi del sottosuolo della voce 94 (i dati nei loro file, `src/data/biomes/sotto_*.gd`): le chiama
## `PassSottosuolo` con il nome scritto in "build", passando se stessa per gli attrezzi comuni (`_column`, `_depth_in`,
## `_carve`, `_floor`). Ognuna restituisce il centro di ciò che ha costruito, o (-1, -1).
##   canto      caverne alte con colonne e punte di cristallo cantante che salgono dal pavimento e scendono dal soffitto
##   giungla    sale larghe e basse di muschio di giungla, radici che pendono e grandi ciuffi
##   lago       una caverna con un lago d'acqua vera sopra il fondo di fango
##   catacombe  gallerie squadrate di mattoni con celle ai lati, e uno scrigno antico in fondo

const NONE := Vector2i(-1, -1)
const NAMES := ["canto", "giungla", "lago", "catacombe"]


static func build(name: String, p: PassSottosuolo, w: World, c: GenContext, u: Dictionary) -> Vector2i:
	match name:
		"canto":
			return _canto(p, w, c, u)
		"giungla":
			return _giungla(p, w, c, u)
		"lago":
			return _lago(p, w, c, u)
		"catacombe":
			return _catacombe(p, w, c, u)
	return NONE


static func _center(p: PassSottosuolo, w: World, c: GenContext, u: Dictionary, margin: int, pad: int) -> Vector2i:
	var x := p._column(w, c, margin)
	if x < 0:
		return NONE
	return Vector2i(x, w.surface[x] + p._depth_in(c, int(u["stratum"]), pad))


static func _canto(p: PassSottosuolo, w: World, c: GenContext, u: Dictionary) -> Vector2i:
	var ctr := _center(p, w, c, u, 60, 30)
	if ctr.x < 0:
		return NONE
	var rx := c.rng.randi_range(20, 30)
	var ry := c.rng.randi_range(12, 17)
	if ctr.y + ry + 4 >= w.h:
		return NONE
	var floor_t := int(u["floor"])
	var air := p._carve(w, ctr, rx, ry, c.noise("canto", 0.09, 2))
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_STONE
	# il pavimento e le punte: dal pavimento salgono, dal soffitto scendono
	for x in range(ctr.x - rx, ctr.x + rx + 1):
		var fy := p._floor(w, x, ctr.y, ry + 4)
		if fy > 0:
			w.set_tile(x, fy, floor_t)
			if c.rng.randf() < 0.12:
				for k in c.rng.randi_range(2, 6):
					if w.inside(x, fy - 1 - k) and w.tile(x, fy - 1 - k) == TileDefs.AIR:
						w.set_tile(x, fy - 1 - k, floor_t)
		if c.rng.randf() < 0.1:
			var cy := ctr.y
			while cy > ctr.y - ry - 3 and w.inside(x, cy - 1) and not w.solid(x, cy - 1):
				cy -= 1
			for k in c.rng.randi_range(2, 5):
				if w.inside(x, cy + k) and w.tile(x, cy + k) == TileDefs.AIR:
					w.set_tile(x, cy + k, floor_t)
	return ctr


static func _giungla(p: PassSottosuolo, w: World, c: GenContext, u: Dictionary) -> Vector2i:
	var ctr := _center(p, w, c, u, 60, 25)
	if ctr.x < 0:
		return NONE
	var rx := c.rng.randi_range(30, 44)
	var ry := c.rng.randi_range(9, 12)
	if ctr.y + ry + 4 >= w.h:
		return NONE
	var floor_t := int(u["floor"])
	var air := p._carve(w, ctr, rx, ry, c.noise("giungla", 0.07, 2))
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_ROOT
	for x in range(ctr.x - rx - 2, ctr.x + rx + 3):
		var fy := p._floor(w, x, ctr.y, ry + 4)
		if fy > 0:
			w.set_tile(x, fy, floor_t)
			if w.solid(x, fy + 1):
				w.set_tile(x, fy + 1, TileDefs.DIRT)
	# radici che pendono dal soffitto (tessere di radice, due-sei di fila)
	for k in c.rng.randi_range(6, 12):
		var x := ctr.x + c.rng.randi_range(-rx + 3, rx - 3)
		var y := ctr.y
		while y > ctr.y - ry - 3 and w.inside(x, y - 1) and not w.solid(x, y - 1):
			y -= 1
		for d in c.rng.randi_range(2, 6):
			if w.inside(x, y + d) and w.tile(x, y + d) == TileDefs.AIR:
				w.set_tile(x, y + d, TileDefs.RADICE)
	return ctr


static func _lago(p: PassSottosuolo, w: World, c: GenContext, u: Dictionary) -> Vector2i:
	var ctr := _center(p, w, c, u, 60, 30)
	if ctr.x < 0:
		return NONE
	var rx := c.rng.randi_range(24, 38)
	var ry := c.rng.randi_range(9, 13)
	if ctr.y + ry + 4 >= w.h:
		return NONE
	var floor_t := int(u["floor"])
	var air := p._carve(w, ctr, rx, ry, c.noise("lago", 0.07, 2))
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_STONE
	# il fondo di fango e sopra l'acqua, fino a metà della caverna
	var level := ctr.y
	for cell in air:
		if cell.y >= ctr.y + ry - 2:
			w.set_tile(cell.x, cell.y, floor_t)
		elif cell.y >= level:
			w.set_liq(cell.x, cell.y, 8, LiquidsData.ACQUA)
	for x in range(ctr.x - rx, ctr.x + rx + 1):
		var fy := p._floor(w, x, ctr.y, ry + 4)
		if fy > 0 and w.tile(x, fy) != floor_t:
			w.set_tile(x, fy, floor_t)
	return ctr


static func _catacombe(p: PassSottosuolo, w: World, c: GenContext, u: Dictionary) -> Vector2i:
	var ctr := _center(p, w, c, u, 120, 30)
	if ctr.x < 0:
		return NONE
	var brick := int(u["floor"])
	var length := c.rng.randi_range(60, 110)
	if ctr.y + 12 >= w.h:
		return NONE
	var x0 := ctr.x - length / 2
	# la galleria principale: 4 tessere d'aria, mattoni sopra e sotto
	for x in range(x0, x0 + length):
		for dy in range(-3, 3):
			if not w.inside(x, ctr.y + dy):
				continue
			w.walls[(ctr.y + dy) * w.w + x] = TileDefs.WALL_SEM
			if dy == -3 or dy == 2:
				w.set_tile(x, ctr.y + dy, brick)
			else:
				w.set_tile(x, ctr.y + dy, TileDefs.AIR)
	# le celle ai lati, in alto e in basso, ogni tanto
	var x := x0 + 6
	while x < x0 + length - 8:
		var up := c.rng.randf() < 0.5
		var cy0 := ctr.y - 7 if up else ctr.y + 3
		for yy in range(cy0, cy0 + 5):
			for xx in range(x, x + 6):
				if not w.inside(xx, yy):
					continue
				w.walls[yy * w.w + xx] = TileDefs.WALL_SEM
				var edge := yy == cy0 or yy == cy0 + 4 or xx == x or xx == x + 5
				w.set_tile(xx, yy, brick if edge else TileDefs.AIR)
		# la porta della cella verso la galleria
		for xx in range(x + 2, x + 4):
			w.set_tile(xx, ctr.y - 3 if up else ctr.y + 2, TileDefs.AIR)
			w.set_tile(xx, cy0 + 4 if up else cy0, TileDefs.AIR)
		x += c.rng.randi_range(10, 16)
	# uno scrigno antico in fondo alla galleria, con il bottino del profondo
	var o := Vector2i(x0 + length - 4, ctr.y + 1)
	if w.inside(o.x, o.y) and not w.stations.has(o):
		w.stations[o] = "scrigno_antico"
		var chest := w.chest_at(o)
		var loot := LootData.roll_chest("rovina_3", c.rng)
		for id in loot:
			chest.add(String(id), int(loot[id]))
	return ctr
