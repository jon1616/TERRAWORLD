class_name PassSegretiAnomalie
extends GenPass
## I segreti del secondo ciclo (voce 97), con un generatore di numeri suo (non sposta il resto del mondo):
##   camere-enigma  quattro piccole camere dei Seminatori, una per tipo di enigma (bracieri, leve, piastre, cristalli):
##                  sono luoghi come quelli della voce 70 (`PlacesData`, `PassLuoghi.build`), in `notes["camere"]`,
##                  così porta, meccanismi, leggio e scritta funzionano da soli (`Mechanisms`, `Places`)
##   visioni        tre cerchi di pietre dei Seminatori con le rune accese su un pavimento di grotta (`notes["visioni"]`)
##   anomalia       al più una per mondo (`SecretsData.ANOMALY_CHANCE`): una colonna dove si cade verso l'alto (una
##                  corrente di `Gravity`), un lago circondato di cristallo cantante, un albero antichissimo, una stella
##                  caduta in un cratere che non si spegne (`notes["anomalie"]` = [[x, y, w, h, nome]])

const CAMERE := ["camera_bracieri", "camera_leve", "camera_piastre", "camera_cristalli"]
const VISIONS := 3

var _rng := RandomNumberGenerator.new()


var _c: GenContext                      # la mappa dei posti (`GenContext.claim`)


func title() -> String:
	return "Camere e anomalie"


func run(w: World, c: GenContext) -> void:
	_rng.seed = hash([c.world_seed, "segreti_anomalie"])
	_c = c
	var cams := []
	for id in CAMERE:
		for k in 200:
			var o := _spot(w, id)
			if o.x >= 0:
				cams.append(PassLuoghi.build(w, id, o, _rng))
				break
	c.notes["camere"] = cams                             # `Places` le unisce ai luoghi
	var visions := []
	for k in VISIONS * 80:                           # (più tentativi: con le grotte piene di nidi e stagni una non trovava posto)
		if visions.size() >= VISIONS:
			break
		var v := _vision(w)
		if not v.is_empty():
			visions.append(v)
	c.notes["visioni"] = visions
	var anomalies := []
	if _rng.randf() < SecretsData.ANOMALY_CHANCE:
		var kinds := SecretsData.ANOMALIES.keys()
		var kind := String(kinds[_rng.randi_range(0, kinds.size() - 1)])
		for k in 150:
			var a := _anomaly(w, c, kind)
			if not a.is_empty():
				anomalies.append(a)
				break
	c.notes["anomalie"] = anomalies


## Un posto per una camera: tutto pieno di roccia attorno, negli strati 1-3, niente stazioni vicine.
func _spot(w: World, id: String) -> Vector2i:
	var grid := PlacesData.grid(id)
	var gw: int = (grid[0] as String).length()
	var gh := grid.size()
	var x := _rng.randi_range(60, w.w - 60 - gw)
	var y := w.surface[x] + _rng.randi_range(StrataData.top(1) + 6, StrataData.top(3) + 60)
	if y + gh + 3 >= w.h:
		return Vector2i(-1, -1)
	for yy in range(y - 2, y + gh + 2):
		for xx in range(x - 2, x + gw + 2):
			if not w.inside(xx, yy) or not w.solid(xx, yy) or w.tile(xx, yy) in [TileDefs.NODO, TileDefs.PIETRA_SEM, TileDefs.PORTA_SEM] 					or w.walls[yy * w.w + xx] == TileDefs.WALL_SEM:
				return Vector2i(-1, -1)
	var area := Rect2i(x - 4, y - 4, gw + 8, gh + 8)
	if not _c.is_free(area):
		return Vector2i(-1, -1)
	for o in w.stations:
		if area.has_point(o):
			return Vector2i(-1, -1)
	_c.claim(area, "camera")
	return Vector2i(x, y)


func _vision(w: World) -> Array:
	var x := _rng.randi_range(60, w.w - 61)
	# scendendo dalla profondità a caso, il primo pavimento di grotta
	var y := w.surface[x] + _rng.randi_range(StrataData.top(1) + 4, StrataData.top(3))
	while y < w.h - 2 and not (not w.solid(x, y) and w.solid(x, y + 1)):
		y += 1
	if not w.inside(x, y + 1) or y - w.surface[x] > StrataData.top(4):
		return []
	var area := Rect2i(x - 3, y - 3, 7, 5)
	if not _c.is_free(area):
		return []
	# un pavimento di grotta largo 5
	for dx in range(-2, 3):
		if w.solid(x + dx, y) or w.solid(x + dx, y - 1) or not w.solid(x + dx, y + 1) 				or w.walls[y * w.w + x + dx] == TileDefs.WALL_SEM:     # non dentro i luoghi e le rovine
			return []
	_c.claim(area, "visione")
	for dx in range(-2, 3):
		w.set_tile(x + dx, y + 1, TileDefs.PIETRA_SEM)
		if absi(dx) == 2:
			w.set_decor(x + dx, y, TileDefs.DECOR_RUNE)
	return [x - 2, y - 2, 5, 3]


func _anomaly(w: World, c: GenContext, kind: String) -> Array:
	var x := _rng.randi_range(120, w.w - 121)
	if absi(x - w.spawn.x) < 100:
		return []
	var s := w.surface[x]
	var name := String(SecretsData.ANOMALIES[kind]["name"])
	for dx in range(-6, 7):
		if absi(w.surface[x + dx] - s) > 2:
			return []
	var area := Rect2i(x - 7, s - 36, 15, 42)           # la più grande delle anomalie (la bolla sale di 34)
	if not _c.is_free(area):
		return []
	_c.claim(area, "anomalia")
	match kind:
		"bolla":
			var cur: Array = c.notes.get("correnti", [])
			cur.append({"x": x, "w": 2, "y0": s - 34, "y1": s - 1})
			c.notes["correnti"] = cur
			for dx in [-3, 3]:
				w.set_tile(x + dx, s - 1, TileDefs.PIETRA_SEM)
				w.set_tile(x + dx, s - 2, TileDefs.PIETRA_SEM)
			return [x - 3, s - 14, 7, 14, name]
		"lago_cantante":
			for dx in range(-5, 6):
				for dy in range(0, 3):
					var edge := absi(dx) == 5 or dy == 2
					if edge:
						w.set_tile(x + dx, s + dy, 40)          # il cristallo cantante (voce 94)
					else:
						w.set_tile(x + dx, s + dy, TileDefs.AIR)
						w.set_liq(x + dx, s + dy, 8, LiquidsData.ACQUA)
			return [x - 5, s - 3, 11, 5, name]
		"albero_primo":
			if w.free_above(Vector2i(x, s - 1), FloraData.HEIGHT) < FloraData.HEIGHT - 1 or not TileDefs.is_grass(w.tile(x, s)):
				return []
			w.add_tree(Vector2i(x, s - 1), TreesData.encode(TreesData.species_of_biome(w.biomes[x]), TreesData.SIZES.size() - 1, 0))
			for dx in [-2, 2]:
				w.set_decor(x + dx, s - 1, TileDefs.DECOR_RUNE)
			return [x - 4, s - 12, 9, 12, name]
		"stella":
			for dx in range(-4, 5):
				var depth := 3 - absi(dx) / 2
				for dy in range(0, depth):
					w.set_tile(x + dx, s + dy, TileDefs.AIR)
				w.set_tile(x + dx, s + depth, TileDefs.CRYSTAL)
			w.stations[Vector2i(x, s + 2)] = "stella_eterna"
			return [x - 4, s - 3, 9, 6, name]
	return []
