class_name PassDoni
extends GenPass
## I doni da trovare (voce 21): **Boccioli del cuore** sui pavimenti delle grotte dal Sottobosco in giù (danno Vita
## massima) e **Stille perenni** appese ai soffitti dalle Profondità della Linfa in giù (Linfa massima). Pochi e lontani
## tra loro, più fitti scendendo: una ragione per esplorare ogni grotta.

const BOCCIOLI := 24                   # voce 187: erano 60, e il tetto (15) si toccava nel primo mondo
const STILLE := 16                     # voce 187: erano 36 (tetto 10: si toccava nel primo mondo)
const SPACING := 28.0                  # distanza minima tra due doni, in tessere


func title() -> String:
	return "Doni"


func run(w: World, c: GenContext) -> void:
	var placed: Array[Vector2i] = []
	var nb := _scatter(w, c, BOCCIOLI, 1, false, TileDefs.DECOR_BOCCIOLO, placed)
	var ns := _scatter(w, c, STILLE, 3, true, TileDefs.DECOR_STILLA, placed)
	c.notes["doni"] = [nb, ns]


## Sparge `n` decorazioni dallo strato `stratum` in giù, su pavimenti (o soffitti) di grotte vere (con la parete dietro).
func _scatter(w: World, c: GenContext, n: int, stratum: int, ceiling: bool, decor: int, placed: Array[Vector2i]) -> int:
	var got := 0
	for k in n * 400:
		if got >= n:
			break
		var x := c.rng.randi_range(20, w.w - 21)
		var top := w.surface[x] + StrataData.top(stratum) + 8
		if top >= w.h - 12:
			continue
		# più probabili in profondità
		var y := int(lerpf(top, w.h - 8, sqrt(c.rng.randf())))
		var dir := -1 if ceiling else 1
		for s in 30:
			var yy := y + s * dir
			if not w.inside(x, yy + dir) or yy < top:
				break
			if w.solid(x, yy):
				break
			if w.solid(x, yy + dir):
				if w.decor_at(x, yy) == 0 and w.wall(x, yy) != 0 and w.tile(x, yy + dir) != TileDefs.PIETRA_SEM \
						and w.tile(x, yy + dir) != TileDefs.NODO and w.station_at(Vector2i(x, yy)).is_empty() \
						and _far(placed, Vector2i(x, yy)):
					w.set_decor(x, yy, decor)
					placed.append(Vector2i(x, yy))
					got += 1
				break
	return got


func _far(placed: Array[Vector2i], q: Vector2i) -> bool:
	for p in placed:
		if Vector2(p).distance_to(Vector2(q)) < SPACING:
			return false
	return true
