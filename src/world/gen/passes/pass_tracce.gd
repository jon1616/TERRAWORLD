class_name PassTracce
extends GenPass
## Le tracce del passato (voce 463, Roadmap 59): una grande struttura per mondo che lega superficie, sottosuolo e cielo
## nello stesso punto, lontana dalla partenza (350-1000 colonne) e fuori dai mari. Il genoma la sceglie (il gene «Città
## sepolta» vuole la città), altrimenti il caso:
## - **radice cosmica**: un tronco di radice largo 12-18 che scende dal cielo (fin sotto la prima isola o il primo
##   continente che incontra) fino al Fondo, cavo dentro (un pozzo
##   di 4 colonne con le liane per salire e scendere), con una finestra ogni 40-60 righe sulle grotte attorno;
## - **città sepolta**: la città dei Seminatori (`PassRovine._city`) nelle Caverne, con un pozzo dalla superficie che ci
##   scende (passerelle ogni 6 righe) e un arco di pietra dei Seminatori sopra l'imbocco;
## - **cratere**: una conca larga 60-90 e profonda 16-24, con al centro la stella caduta: un nocciolo di cristallo e
##   uno scrigno con stelline, Schegge di vigore e Polvere iridata.
## Dopo le Rovine (le altre strutture vedono il suo posto preso). Appunti "traccia" {id, x, y}.

const KINDS := ["radice", "citta", "cratere"]
const LIANA := 99


func title() -> String:
	return "Tracce del passato"


func run(w: World, c: GenContext) -> void:
	c.notes["traccia"] = {}
	if bool(c.params.get("giardino", false)):
		return
	var kind: String = "citta" if bool(c.genes()["city"]) and c.notes.get("citta", Vector2i(-1, -1)) == Vector2i(-1, -1) \
		else String(KINDS[c.rng.randi_range(0, KINDS.size() - 1)])
	if KINDS.has(str(c.params.get("traccia", ""))):
		kind = str(c.params["traccia"])                  # (per le misure e le prove: una traccia scelta)
	for tries in 30:
		var side := -1 if c.rng.randf() < 0.5 else 1
		var x := w.spawn.x + side * c.rng.randi_range(350, 1000)
		if x < WorldShapesData.SEA_EDGE + 60 or x > w.w - WorldShapesData.SEA_EDGE - 60:
			continue
		var done := false
		match kind:
			"radice":
				done = _root(w, c, x)
			"citta":
				done = _city(w, c, x)
			"cratere":
				done = _crater(w, c, x)
		if done:
			# voce 466: la traccia è anche un punto di riferimento sulla mappa
			var t: Dictionary = c.notes["traccia"]
			(c.notes.get("riferimenti", []) as Array).append([int(t["x"]), int(t["y"]) - 2, {"radice": "La radice cosmica",
				"citta": "La città sepolta", "cratere": "Il cratere della stella"}[kind]])
			return


func _root(w: World, c: GenContext, x: int) -> bool:
	# sale dalla superficie finché il cielo è libero: si ferma sotto la prima isola o il primo continente che incontra
	# (sembrano appesi a lei); sotto terra attraversa la roccia ma non le stazioni, i nodi, i sigilli e le porte
	var s := int(w.surface[x])
	if not c.is_free(Rect2i(x - 12, s - 30, 24, 60)):
		return false
	var top := s - 30
	while top > SkyData.TOP + 4 and c.is_free(Rect2i(x - 12, top - 1, 24, 1)):
		top -= 1
	if s - top < 120:
		return false
	var bottom := mini(s + StrataData.top(4) + 40, w.h - 12)
	var rect := Rect2i(x - 12, top, 24, s - top + 30)
	var keep := {TileDefs.NODO: true, TileDefs.PORTA: true, TileDefs.PORTA_SEM: true}
	for t in TileDefs.SEALS.values():
		keep[int(t)] = true
	var nz := c.noise("radice_cosmica", 0.03, 2)
	var next_win := int(w.surface[x]) + c.rng.randi_range(40, 60)
	for y in range(top, bottom):
		var cx := x + int(nz.get_noise_1d(y) * 6.0)
		var half := 6 + int(3.0 * (1.0 - float(y - top) / (bottom - top)))      # più grossa in alto, dove nasce
		var window := y >= next_win and y < next_win + 5
		if y >= next_win + 5:
			next_win += c.rng.randi_range(40, 60)
		for dx in range(-half, half + 1):
			var xx := cx + dx
			if not w.inside(xx, y) or keep.has(w.tile(xx, y)) or not w.station_at(Vector2i(xx, y)).is_empty():
				continue
			if absi(dx) <= 2:
				w.set_tile(xx, y, TileDefs.AIR)                 # il pozzo
				w.walls[y * w.w + xx] = TileDefs.WALL_ROOT
				if dx == -2 and w.decor_at(xx, y) == 0:
					w.set_decor(xx, y, LIANA)
			elif window and absi(dx) >= half - 1 and (dx < 0) == (y % 2 == 0):
				w.set_tile(xx, y, TileDefs.AIR)
			else:
				w.set_tile(xx, y, TileDefs.RADICE)
	_clear_trees(w, rect.position.x, rect.end.x)
	c.claim(rect, "radice_cosmica")
	c.notes["traccia"] = {"id": "radice", "x": x, "y": int(w.surface[x])}
	return true


func _city(w: World, c: GenContext, x: int) -> bool:
	var at: Vector2i = c.notes.get("citta", Vector2i(-1, -1))
	if at.x < 0:
		at = PassRovine.new()._city(w, c)
		if at.x < 0:
			return false
		c.notes["citta"] = at
	var sx := at.x + 4
	var s := int(w.surface[sx])
	# il pozzo dalla superficie al tetto della prima stanza
	for y in range(s - 1, at.y - 8):
		for dx in range(-1, 2):
			if w.tile(sx + dx, y) != TileDefs.NODO:
				w.set_tile(sx + dx, y, TileDefs.AIR)
				w.walls[y * w.w + sx + dx] = TileDefs.WALL_STONE
		if (y - s) % 6 == 5:
			for dx in range(-1, 2):
				w.set_plat(sx + dx, y, true)
	# l'arco sopra l'imbocco
	for dy in range(1, 6):
		w.set_tile(sx - 3, s - dy, TileDefs.PIETRA_SEM)
		w.set_tile(sx + 3, s - dy, TileDefs.PIETRA_SEM)
	for dx in range(-3, 4):
		w.set_tile(sx + dx, s - 6, TileDefs.PIETRA_SEM)
	c.notes["traccia"] = {"id": "citta", "x": sx, "y": s}
	return true


func _crater(w: World, c: GenContext, x: int) -> bool:
	var r := c.rng.randi_range(30, 45)
	var depth := c.rng.randi_range(16, 24)
	var rect := Rect2i(x - r - 4, int(w.surface[x]) - 20, 2 * r + 8, depth + 30)
	if not c.is_free(rect):
		return false
	var rim := int(w.surface[x])
	for xx in range(x - r - 4, x + r + 5):
		var d := absf(float(xx - x)) / r
		var floor_y: int
		if d <= 1.0:
			floor_y = rim + int(depth * (1.0 - d * d))
		else:
			floor_y = rim - int(3.0 * (1.0 - (d - 1.0) * r / 4.0))   # l'orlo un poco rialzato
		var old := int(w.surface[xx])
		if d > 1.0:
			floor_y = mini(floor_y, old)                  # fuori dalla conca l'orlo alza soltanto, non taglia i pendii
		var grass := w.tile(xx, old)
		for y in range(mini(old, floor_y), maxi(old, floor_y)):
			if floor_y > old:
				w.set_tile(xx, y, TileDefs.AIR)
				w.walls[y * w.w + xx] = 0
				w.set_decor(xx, y, 0)
			else:
				w.set_tile(xx, y, TileDefs.DIRT)
		w.surface[xx] = floor_y
		w.set_tile(xx, floor_y, grass if TileDefs.is_grass(grass) else TileDefs.STONE)
	# la stella caduta: un nocciolo di cristallo nel fondo, lo scrigno sopra
	var bottom := rim + depth
	for dy in range(0, 4):
		for dx in range(-4, 5):
			if Vector2(dx, dy).length() <= 4.2:
				w.set_tile(x + dx, bottom + dy, TileDefs.CRYSTAL)
	var o := Vector2i(x - 1, bottom - 2)
	if w.station_fits("scrigno", o):
		w.stations[o] = "scrigno"
		var chest := w.chest_at(o)
		chest.add("stellina", c.rng.randi_range(8, 16))
		chest.add("scheggia_vigore", c.rng.randi_range(2, 4))
		chest.add("polvere_iridata", c.rng.randi_range(1, 3))
	_clear_trees(w, rect.position.x, rect.end.x)
	c.claim(rect, "cratere")
	c.notes["traccia"] = {"id": "cratere", "x": x, "y": bottom}
	return true


## Gli alberi già piantati tra x0 e x1 se ne vanno (resterebbero sospesi nel cratere o dentro la radice).
static func _clear_trees(w: World, x0: int, x1: int) -> void:
	for k in w.trees.keys():
		var keep: Array[Vector3i] = []
		for t in w.trees[k]:
			var tv: Vector3i = t
			if tv.x < x0 or tv.x >= x1:
				keep.append(tv)
		w.trees[k] = keep
