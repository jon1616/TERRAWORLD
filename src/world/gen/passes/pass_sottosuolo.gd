class_name PassSottosuolo
extends GenPass
## I biomi del sottosuolo portati dai geni (voce 43, categoria «sottosuolo» di `GenesData`, effetto `under`):
## - **fungaie**: grandi sale nel Sottobosco di radici con funghi giganti (gambo di radice, cappello di muschio di
##   spore) e il pavimento di spore;
## - **geodi di brina**: grotte tonde nelle Caverne d'ardesia, guscio di cristallo e dentro muschio di brina;
## - **fiumi di brace**: lunghe gallerie serpeggianti nelle Profondità della Linfa, pavimento di cenere viva e vene di
##   tizzonite nelle pareti;
## - **laghi di Linfa**: caverne larghe nel profondo con un lago di cristallo di Linfa rappreso sul fondo;
## - **cuore cavo** (voce 48): una caverna immensa nel Fondo, pavimento di cristallo e schegge del Vuoto.
## Viene prima delle Decorazioni, che vestono da sole i pavimenti di spore, brina e cenere (vedi `PassDecorazioni`).
## Voce 450 (Roadmap 57): ogni mondo ha anche almeno `REGIONS` **regioni sotterranee**, una striscia di 200-500 colonne nello
## strato del bioma dove i suoi luoghi sono fitti (`_column` sceglie dentro `region`): sulla mappa si vedono, e senza geni
## il sottosuolo non è più tutto uguale. Appunti "regioni" [{id, x0, x1, strato}].

const SPAWN_FREE := 80                 # colonne libere attorno alla partenza
const NONE := Vector2i(-1, -1)

var _rect := Rect2i()                  # voce 440: lo spazio scavato dall'ultimo luogo (per il `claim`)
var region := Vector2i(-1, -1)          # voce 450: le colonne della regione in costruzione (-1 = tutto il mondo)

const REGIONS := 3
const REGION_W := [200, 500]
const REGION_DENSITY := 2.5             # i luoghi di una regione: questo × la densità che il gene dà a tutto il mondo


func title() -> String:
	return "Sottosuolo"


func run(w: World, c: GenContext) -> void:
	var made := {}
	c.notes["sottosuolo_pos"] = {}
	for f in c.genes().get("under", []):
		var u: Dictionary = UnderBiomesData.UNDER.get(String(f), {})     # voce 91: i dati in `UnderBiomesData`
		if not u.is_empty():
			var bname := String(u["build"])
			var build := Callable(self, bname) if has_method(bname) else \
				func(w2: World, c2: GenContext) -> Vector2i: return UnderBuilders.build(bname, self, w2, c2, u)   # voce 94
			made[f] = _many(w, c, int(u["count"]), build, f)
	_regions(w, c, made)
	c.notes["sottosuolo"] = made


## Voce 450: le regioni sotterranee: almeno `REGIONS` biomi del sottosuolo (prima quelli dei geni), ognuno in una striscia
## del suo strato che non tocca le altre dello stesso strato.
func _regions(w: World, c: GenContext, made: Dictionary) -> void:
	var picked: Array = []
	for f in c.genes().get("under", []):
		if UnderBiomesData.UNDER.has(String(f)) and not String(f) in picked and String(f) != "cuore_cavo":
			picked.append(String(f))
	var pool: Array = UnderBiomesData.UNDER.keys().filter(func(k: Variant) -> bool: return String(k) != "cuore_cavo")
	pool.sort()
	while picked.size() < REGIONS and picked.size() < pool.size():
		var k := String(pool[c.rng.randi_range(0, pool.size() - 1)])
		if not k in picked:
			picked.append(k)
	var spans := {}
	var out := []
	for f in picked:
		var u: Dictionary = UnderBiomesData.UNDER[f]
		var st := int(u["stratum"])
		var span := c.rng.randi_range(REGION_W[0], REGION_W[1])
		var x0 := -1
		for tries in 30:
			var cand := c.rng.randi_range(40, w.w - span - 40)
			if absi(cand + span / 2 - w.spawn.x) < SPAWN_FREE + span / 2:
				continue
			var ok := true
			for s in spans.get(st, []):
				if cand < int(s[1]) + 40 and cand + span > int(s[0]) - 40:
					ok = false
			if ok:
				x0 = cand
				break
		if x0 < 0:
			continue
		if not spans.has(st):
			spans[st] = []
		(spans[st] as Array).append([x0, x0 + span])
		region = Vector2i(x0, x0 + span)
		var bname := String(u["build"])
		var build := Callable(self, bname) if has_method(bname) else \
			func(w2: World, c2: GenContext) -> Vector2i: return UnderBuilders.build(bname, self, w2, c2, u)
		var n := maxi(3, int(roundf(float(u["count"]) * REGION_DENSITY * span / float(w.w))))
		made[f + "_regione"] = _many(w, c, n, build, f + "_regione")
		out.append({"id": f, "x0": x0, "x1": x0 + span, "strato": st})
	region = Vector2i(-1, -1)
	c.notes["regioni"] = out


## Prova a costruire n volte un luogo; restituisce quanti ne sono riusciti. Il centro di ognuno finisce negli appunti
## (`notes["sottosuolo_pos"][nome]`: le prove li vanno a vedere).
func _many(w: World, c: GenContext, n: int, build: Callable, what: String) -> int:
	var got: Array[Vector2i] = []
	for k in n * 20:
		if got.size() >= n:
			break
		_rect = Rect2i()
		var p: Vector2i = build.call(w, c)
		if p.x >= 0:
			got.append(p)
			# voce 440 (8 ott 2026): il luogo si prenota, così le strutture costruite dopo non lo coprono (prima no)
			if _rect.has_area() and c.is_free(_rect):
				c.claim(_rect, "sottosuolo_" + what)
	c.notes["sottosuolo_pos"][what] = got
	return got.size()


## Una colonna a caso lontana dalla partenza e dai bordi.
func _column(w: World, c: GenContext, margin: int) -> int:
	for k in 30:
		var x := c.rng.randi_range(margin, w.w - margin - 1)
		if region.x >= 0:
			x = c.rng.randi_range(region.x + mini(margin / 3, 40), maxi(region.y - mini(margin / 3, 40), region.x + 1))
		if absi(x - w.spawn.x) > SPAWN_FREE:
			return x
	return -1


## Una profondità a caso dentro uno strato (lontana dai suoi confini).
func _depth_in(c: GenContext, st: int, pad: int) -> int:
	var t0 := StrataData.top(st)
	var t1 := StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else t0 + 300
	return c.rng.randi_range(t0 + pad, maxi(t1 - pad, t0 + pad + 1))


## Scava un'ellisse dal bordo irregolare; restituisce le celle d'aria nuove.
func _carve(w: World, ctr: Vector2i, rx: int, ry: int, n: FastNoiseLite) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	var r := Rect2i(ctr.x - rx - 2, ctr.y - ry - 2, rx * 2 + 5, ry * 2 + 5)
	_rect = r if not _rect.has_area() else _rect.merge(r)
	for y in range(ctr.y - ry - 2, ctr.y + ry + 3):
		for x in range(ctr.x - rx - 2, ctr.x + rx + 3):
			if not w.inside(x, y) or y - w.surface[x] < 8:
				continue
			var e := Vector2((x - ctr.x) / float(rx), (y - ctr.y) / float(ry)).length()
			if e + n.get_noise_2d(x, y) * 0.22 <= 1.0 and w.tile(x, y) != TileDefs.NODO:
				w.set_tile(x, y, TileDefs.AIR)
				out.append(Vector2i(x, y))
	return out


## Il primo blocco sotto una cella d'aria (il pavimento), o -1.
func _floor(w: World, x: int, y: int, reach: int) -> int:
	for k in reach:
		if w.solid(x, y + k):
			return y + k
	return -1


# --- fungaie ------------------------------------------------------------------------------------------------------
func _fungaia(w: World, c: GenContext) -> Vector2i:
	var x := _column(w, c, 60)
	if x < 0:
		return NONE
	var ctr := Vector2i(x, w.surface[x] + _depth_in(c, 1, 30))
	var rx := c.rng.randi_range(22, 34)
	var ry := c.rng.randi_range(11, 15)
	if ctr.y + ry + 4 >= w.h:
		return NONE
	var air := _carve(w, ctr, rx, ry, c.noise("fungaie", 0.08, 2))
	# pavimento di spore
	for x2 in range(ctr.x - rx - 2, ctr.x + rx + 3):
		var fy := _floor(w, x2, ctr.y, ry + 4)
		if fy > 0:
			w.set_tile(x2, fy, TileDefs.GRASS_SPORE)
			if w.solid(x2, fy + 1):
				w.set_tile(x2, fy + 1, TileDefs.DIRT)
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_ROOT
	# i funghi giganti
	var n := c.rng.randi_range(4, 7)
	for k in n:
		var mx := ctr.x - rx + 4 + int((2 * rx - 8) * (k + c.rng.randf_range(0.2, 0.8)) / n)
		var fy := _floor(w, mx, ctr.y, ry + 4)
		if fy < 0:
			continue
		var h := c.rng.randi_range(5, mini(10, ry + 2))
		var cw := c.rng.randi_range(3, 6)
		for k2 in h:
			w.set_tile(mx, fy - 1 - k2, TileDefs.RADICE)
		var top := fy - 1 - h
		for dy in range(-2, 1):
			var half := cw - (1 if dy == -2 else 0)
			for dx in range(-half, half + 1):
				if w.inside(mx + dx, top + dy) and w.tile(mx + dx, top + dy) == TileDefs.AIR:
					w.set_tile(mx + dx, top + dy, TileDefs.GRASS_SPORE)
	return ctr


# --- geodi di brina -----------------------------------------------------------------------------------------------
func _geode_brina(w: World, c: GenContext) -> Vector2i:
	var x := _column(w, c, 30)
	if x < 0:
		return NONE
	var ctr := Vector2i(x, w.surface[x] + _depth_in(c, 2, 20))
	var r := c.rng.randf_range(8.0, 12.5)
	if ctr.y + r + 2 >= w.h:
		return NONE
	var ri := int(ceil(r))
	for y in range(ctr.y - ri, ctr.y + ri + 1):
		for x2 in range(ctr.x - ri, ctr.x + ri + 1):
			var d := Vector2(x2 - ctr.x, (y - ctr.y) * 1.15).length()
			if d > r or not w.inside(x2, y):
				continue
			var i := y * w.w + x2
			if d > r - 1.3:
				w.tiles[i] = TileDefs.CRYSTAL
			elif d > r - 2.6 or y > ctr.y + r * 0.45:
				w.tiles[i] = TileDefs.GRASS_BRINA            # il ghiaccio che riveste l'interno e il fondo
			else:
				w.tiles[i] = TileDefs.AIR
			w.walls[i] = TileDefs.WALL_STONE
	return ctr


# --- fiumi di brace -----------------------------------------------------------------------------------------------
func _fiume_brace(w: World, c: GenContext) -> Vector2i:
	var x0 := _column(w, c, 200)
	if x0 < 0:
		return NONE
	var y := float(w.surface[x0] + _depth_in(c, 3, 40))
	var length := c.rng.randi_range(250, 480)
	var dir := 1 if c.rng.randf() < 0.5 else -1
	var bend := c.noise("fiumi_brace", 0.02, 2)
	var x := x0
	var mid := NONE
	for s in length:
		x += dir
		if x < 10 or x > w.w - 11:
			break
		y += bend.get_noise_2d(x0, s) * 0.9
		var h := 6 + int(absf(bend.get_noise_2d(s, x0)) * 8.0)
		var yi := int(y)
		if s == 40:
			mid = Vector2i(x, yi - 3)
		for k in range(-h, 1):
			w.set_tile(x, yi + k, TileDefs.AIR)
			w.walls[(yi + k) * w.w + x] = TileDefs.WALL_SCISTO
		w.set_liq(x, yi, 8, LiquidsData.BRACE)                  # voce 74: il fiume è di brace vera
		w.set_liq(x, yi - 1, 4, LiquidsData.BRACE)
		w.set_tile(x, yi + 1, TileDefs.GRASS_CENERE)            # il letto di cenere viva
		w.set_tile(x, yi + 2, TileDefs.GRASS_CENERE)
		if c.rng.randf() < 0.18:
			w.set_tile(x, yi - h - 1, TileDefs.TIZZONITE)        # la brace che affiora nel soffitto
		if c.rng.randf() < 0.08:
			w.set_tile(x, yi + 3, TileDefs.TIZZONITE)
	return mid


# --- laghi di Linfa -----------------------------------------------------------------------------------------------
func _lago_linfa(w: World, c: GenContext) -> Vector2i:
	var x := _column(w, c, 60)
	if x < 0:
		return NONE
	var st := 3 if c.rng.randf() < 0.6 else 4
	var ctr := Vector2i(x, w.surface[x] + _depth_in(c, st, 30))
	var rx := c.rng.randi_range(26, 42)
	var ry := c.rng.randi_range(9, 13)
	if ctr.y + ry + 4 >= w.h:
		return NONE
	var air := _carve(w, ctr, rx, ry, c.noise("laghi_linfa", 0.07, 2))
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_SCISTO
	# il lago: sul fondo il cristallo di Linfa rappreso, sopra tre righe di Linfa liquida (voce 74)
	var level := ctr.y + ry / 3
	for cell in air:
		if cell.y >= level + 3:
			w.set_tile(cell.x, cell.y, TileDefs.CRYSTAL)
		elif cell.y >= level:
			w.set_liq(cell.x, cell.y, 8, LiquidsData.LINFA)
	return ctr


# --- cuore cavo (voce 48) -------------------------------------------------------------------------------------
func _cuore_cavo(w: World, c: GenContext) -> Vector2i:
	var x := _column(w, c, 220)
	if x < 0:
		return NONE
	var ctr := Vector2i(x, w.surface[x] + StrataData.top(4) + 60)
	var rx := mini(150, w.w / 5)
	var ry := 42
	if ctr.y + ry + 6 >= w.h:
		ctr.y = w.h - ry - 8
	var air := _carve(w, ctr, rx, ry, c.noise("cuore_cavo", 0.03, 2))
	for cell in air:
		w.walls[cell.y * w.w + cell.x] = TileDefs.WALL_VOID
		if cell.y > ctr.y + ry * 0.6:
			w.set_tile(cell.x, cell.y, TileDefs.CRYSTAL)
	return ctr
