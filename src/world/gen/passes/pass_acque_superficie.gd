class_name PassAcqueSuperficie
extends GenPass
## Le acque di superficie (voce 468, Roadmap 60): dopo l'Acqua.
## - **laghi nelle valli**: dove la superficie fa una conca tra due rive (la riva più bassa entro `RIM` colonne a destra e
##   a sinistra), l'acqua sale fino a due righe sotto quella riva; si tengono i 3-6 laghi più grandi profondi almeno
##   `MIN_DEPTH` e larghi al più `MAX_W`;
## - **fiumi brevi**: su un tratto quasi piano (dislivello al più 5) di 30-90 colonne si scava un letto piatto tre righe
##   sotto la colonna più bassa e lo si riempie fin lì; le rive restano più alte, l'acqua non scappa.
## Mai nei mari, nel canyon, entro 150 colonne dalla partenza (resta asciutta: anche le prove ci costruiscono le loro
## conche) e sopra le stazioni. Gli alberi sommersi se ne vanno.
## Appunti "laghi_valle" [[x0, x1, livello]], "fiumi" [[x0, x1, riga]].
## Le cascate restano da fare: l'acqua che scorre sempre vuole una sorgente che non allaghi la valle (i liquidi lavorano
## solo vicino al Germogliato).

const RIM := 90
const MIN_DEPTH := 6
const MAX_W := 110
const LAKES := [3, 6]
const RIVERS := [2, 4]


func title() -> String:
	return "Acque di superficie"


func run(w: World, c: GenContext) -> void:
	c.notes["laghi_valle"] = []
	c.notes["fiumi"] = []
	if bool(c.params.get("giardino", false)) or bool(c.genes()["sea"]) or bool(c.genes()["roof"]):
		return
	var keep := PackedByteArray()
	keep.resize(w.w)
	for x in range(maxi(w.spawn.x - 150, 0), mini(w.spawn.x + 151, w.w)):        # la partenza resta asciutta
		keep[x] = 1
	for s in c.notes.get("mari", []):
		for x in range(maxi(int(s[0]) - 30, 0), mini(int(s[1]) + 30, w.w)):
			keep[x] = 1
	if c.notes.has("canyon"):
		var cn: Array = c.notes["canyon"]
		for x in range(maxi(int(cn[0]) - 10, 0), mini(int(cn[1]) + 10, w.w)):
			keep[x] = 1
	c.notes["laghi_valle"] = _lakes(w, c, keep)
	c.notes["fiumi"] = _rivers(w, c, keep)


func _lakes(w: World, c: GenContext, keep: PackedByteArray) -> Array:
	# il livello dell'acqua che la superficie trattiene in ogni colonna (come la pioggia tra due muri)
	var level := PackedInt32Array()
	level.resize(w.w)
	for x in w.w:
		var left := int(w.surface[x])
		for k in range(maxi(x - RIM, 0), x):
			left = mini(left, int(w.surface[k]))
		var right := int(w.surface[x])
		for k in range(x + 1, mini(x + RIM + 1, w.w)):
			right = mini(right, int(w.surface[k]))
		level[x] = maxi(left, right) + 2                    # due righe sotto la riva più bassa
	# i tratti allagabili
	var spans := []
	var x := 0
	while x < w.w:
		if level[x] >= int(w.surface[x]) or keep[x] == 1:
			x += 1
			continue
		var x0 := x
		var lv := level[x]
		var deep := 0
		while x < w.w and level[x] < int(w.surface[x]) and keep[x] == 0 and absi(level[x] - lv) <= 1:
			deep = maxi(deep, int(w.surface[x]) - level[x])
			x += 1
		if deep >= MIN_DEPTH and x - x0 <= MAX_W and x - x0 >= 8:
			spans.append([x0, x, lv, deep * (x - x0)])
	spans.sort_custom(func(a: Array, b: Array) -> bool: return int(a[3]) > int(b[3]))
	var made := []
	for sp in spans.slice(0, c.rng.randi_range(LAKES[0], LAKES[1])):
		var x0 := int(sp[0])
		var x1 := int(sp[1])
		var lv := int(sp[2])
		if not c.is_free(Rect2i(x0, lv, x1 - x0, 4)):
			continue
		for xx in range(x0, x1):
			for y in range(lv, int(w.surface[xx])):
				if not w.solid(xx, y) and w.station_at(Vector2i(xx, y)).is_empty():
					w.set_liq(xx, y, 8, LiquidsData.ACQUA)
					w.set_decor(xx, y, 0)
		_drown_trees(w, x0, x1, lv)
		made.append([x0, x1, lv])
	return made


func _rivers(w: World, c: GenContext, keep: PackedByteArray) -> Array:
	var made := []
	var want := c.rng.randi_range(RIVERS[0], RIVERS[1])
	for tries in 200:
		if made.size() >= want:
			break
		var len := c.rng.randi_range(30, 90)
		var x0 := c.rng.randi_range(60, w.w - 60 - len)
		var lo := int(w.surface[x0])
		var hi := lo
		var bad := false
		for xx in range(x0 - 3, x0 + len + 3):
			if keep[xx] == 1:
				bad = true
				break
			lo = mini(lo, int(w.surface[xx]))
			hi = maxi(hi, int(w.surface[xx]))
		if bad or hi - lo > 5:
			continue
		var bed := hi + 3                                     # il letto: tre righe sotto la colonna più bassa
		if not c.is_free(Rect2i(x0, lo - 4, len, bed - lo + 6)):
			continue
		for xx in range(x0, x0 + len):
			if not w.station_at(Vector2i(xx, hi)).is_empty():
				continue
			for y in range(int(w.surface[xx]), bed):
				w.set_tile(xx, y, TileDefs.AIR)
				w.walls[y * w.w + xx] = 0
				w.set_decor(xx, y, 0)
			for y in range(hi, bed):
				w.set_liq(xx, y, 8, LiquidsData.ACQUA)
			w.set_tile(xx, bed, TileDefs.DIRT)
			w.surface[xx] = bed                               # la terra ora è il letto del fiume
		_drown_trees(w, x0, x0 + len, bed)
		c.claim(Rect2i(x0, lo - 4, len, bed - lo + 6), "fiume")
		made.append([x0, x0 + len, hi])
	return made


static func _drown_trees(w: World, x0: int, x1: int, level: int) -> void:
	for k in w.trees.keys():
		var keep: Array[Vector3i] = []
		for t in w.trees[k]:
			var tv: Vector3i = t
			if tv.x < x0 - 2 or tv.x >= x1 + 2 or tv.y < level - 1:
				keep.append(tv)
		w.trees[k] = keep
