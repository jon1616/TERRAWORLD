class_name PassPrimo
extends GenPass
## Il Giardino oltre il Vuoto (Roadmap 28, voce 263; `params["primo"]`): nel mondo del Seme Primo, lontano dalla partenza,
## una radura spianata con l'**Albero Antico** (stazione `albero_antico`, 9×13) al centro, un cerchio di otto colonne
## di pietra dei Seminatori e gli archi spezzati di due serre di vetro. Appunti: `notes["primo"]` = {"tree", "x", "y"}.

const TREE := Vector2i(9, 13)
const HALF := 46


func title() -> String:
	return "Il Giardino oltre il Vuoto"


func run(w: World, c: GenContext) -> void:
	if not bool(c.params.get("primo", false)):
		return
	var cx := _column(w, c)
	var sy := int(w.surface[cx]) - 1
	# la radura: aria sopra, terra sotto, erba
	for x in range(cx - HALF, cx + HALF + 1):
		if not w.inside(x, sy):
			continue
		for y in range(sy - 22, sy + 1):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_decor(x, y, 0)
			w.set_liq(x, y, 0, 0)
		w.set_tile(x, sy + 1, TileDefs.GRASS)
		for y in range(sy + 2, sy + 6):
			if not w.solid(x, y):
				w.set_tile(x, y, TileDefs.DIRT)
		w.surface[x] = sy + 1
	# il cerchio di colonne
	for k in 8:
		var x := cx - HALF + 6 + k * ((HALF * 2 - 12) / 7)
		if absi(x - cx) < 8:
			continue
		var h := 6 + (k * 7) % 5
		for y in range(sy - h + 1, sy + 1):
			w.set_tile(x, y, TileDefs.PIETRA_SEM)
	# due serre di vetro, spezzate
	for side in [-1, 1]:
		var gx: int = cx + side * 30
		for a in 19:
			var ang := PI * a / 18.0
			var p := Vector2(gx + cos(ang) * 9.0, sy - sin(ang) * 8.0)
			if a % 5 != 2:                                  # i vetri mancanti
				w.set_tile(int(p.x), int(p.y), TileDefs.VETRO)
	# i fiori della radura
	for x in range(cx - HALF + 2, cx + HALF - 1, 2):
		if not w.solid(x, sy) and absi(x - cx) > 6:
			w.set_decor(x, sy, TileDefs.DECOR_FLOWERS[absi(x) % 3])
	var o := Vector2i(cx - TREE.x / 2, sy - TREE.y + 1)
	w.stations[o] = "albero_antico"
	c.claim(Rect2i(cx - HALF, sy - 22, HALF * 2 + 1, 28), "giardino oltre il Vuoto")
	c.notes["primo"] = {"tree": o, "x": cx, "y": sy}


## Una colonna lontana dalla partenza dove la radura non pesta altre strutture.
func _column(w: World, c: GenContext) -> int:
	var a := w.w / 4
	var b := w.w * 3 / 4
	var base := a if absi(a - w.spawn.x) > absi(b - w.spawn.x) else b
	for k in 40:
		var x: int = base + (k / 2) * 23 * (1 if k % 2 == 0 else -1)
		if x < HALF + 20 or x > w.w - HALF - 20:
			continue
		if c.is_free(Rect2i(x - HALF, int(w.surface[x]) - 24, HALF * 2 + 1, 30)):
			return x
	return base
