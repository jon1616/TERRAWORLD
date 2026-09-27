class_name PassStagni
extends GenPass
## Laghi e stagni di superficie (voce 118, Roadmap 14 «Le acque vive»): prima in superficie non c'era quasi acqua (solo
## col gene Sommerso), e la pesca sarebbe stata solo sotto terra. Quanti e quanto grandi li dice ogni bioma (campo
## «stagni» dei file in `src/data/biomes/`): tanti nelle Torbiere e nelle paludi, nessuno nel deserto di vetro e nelle
## terre di brace. Uno stagno è una conca scavata nel terreno piano (fondo arrotondato), piena d'acqua fino al bordo più
## basso, senza grotte sotto (l'acqua resterebbe ferma solo finché nessuno la tocca). Viene dopo l'erba e prima degli
## alberi; usa la mappa dei posti (`GenContext.claim`).

const DEFAULT := [1.0, 10, 20, 3, 5]
const SPAWN_FREE := 40                   # colonne libere attorno alla partenza
const BUMPY := 5                         # dislivello massimo del terreno sopra lo stagno (il più alto si abbassa)


func title() -> String:
	return "Stagni"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var made := 0
	# i tratti di bioma: a ognuno gli stagni che gli spettano (densità × lunghezza), cercando più posti a caso
	var x := 0
	while x < w.w:
		var b := int(w.biomes[x])
		var e := x
		while e < w.w and int(w.biomes[e]) == b:
			e += 1
		var spec: Array = BiomesData.BIOMES[b].get("stagni", DEFAULT)
		var exact := float(spec[0]) * (e - x) / 1000.0
		var want := floori(exact) + (1 if rng.randf() < exact - floori(exact) else 0)
		var got := 0
		for tries in want * 40:
			if got >= want:
				break
			var half := rng.randi_range(int(spec[1]), int(spec[2])) / 2
			var depth := rng.randi_range(int(spec[3]), int(spec[4]))
			if e - x < half * 2 + 6:
				break
			var cx := rng.randi_range(x + half + 2, e - half - 3)
			if _dig(w, c, cx, half, depth):
				got += 1
		made += got
		x = e
	c.notes["stagni"] = made


## Scava uno stagno centrato nella colonna cx, largo 2·half+1, profondo depth al centro. Falso se il posto non va.
func _dig(w: World, c: GenContext, cx: int, half: int, depth: int) -> bool:
	var x0 := cx - half
	var x1 := cx + half
	if x0 < 20 or x1 >= w.w - 20 or absi(cx - w.spawn.x) < SPAWN_FREE + half:
		return false
	var lo := 1 << 30                       # la riga più alta del terreno (y più piccola)
	var hi := -1                            # la più bassa: il pelo dell'acqua sta lì, così non trabocca
	for x in range(x0 - 1, x1 + 2):
		lo = mini(lo, w.surface[x])
		hi = maxi(hi, w.surface[x])
		if int(w.biomes[x]) != int(w.biomes[cx]):
			return false                        # uno stagno sta in un bioma solo
	if hi - lo > BUMPY:
		return false
	var rect := Rect2i(x0 - 2, lo - 4, x1 - x0 + 5, hi - lo + depth + 8)
	if not c.is_free(rect):
		return false
	var level := hi                          # la prima riga d'acqua
	# il fondo: arrotondato, e sotto deve esserci terreno pieno (niente grotte che si aprono sotto l'acqua)
	var floor_y := PackedInt32Array()
	for x in range(x0, x1 + 1):
		var t := float(x - cx) / float(half + 1)
		var d := maxi(1, roundi(depth * (1.0 - t * t)))
		floor_y.append(level + d - 1)
		for y in range(level + d, level + d + 3):
			if not w.solid(x, y):
				return false
	for k in [x0 - 1, x1 + 1]:                # i bordi reggono l'acqua
		for y in range(level, level + 2):
			if not w.solid(k, y):
				return false
	for i in floor_y.size():
		var x := x0 + i
		for y in range(w.surface[x], level):
			w.set_tile(x, y, TileDefs.AIR)        # il terreno più alto sopra il pelo dell'acqua si abbassa
			w.set_decor(x, y, 0)
		for y in range(level, floor_y[i] + 1):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_decor(x, y, 0)
			w.set_liq(x, y, 8, LiquidsData.ACQUA)
		w.surface[x] = level
	c.claim(rect, "stagno")
	return true
