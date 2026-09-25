class_name PassGemme
extends GenPass
## Gemme a grappolo sui pavimenti delle grotte (voce 24): ogni gemma nel suo strato, a gruppetti di due o tre vicini,
## lontani dagli altri grappoli. Brillano del loro colore: nel buio si vedono da lontano e invitano a scendere.
## Si raccolgono con il piccone come ogni decorazione (`TileDefs.DECOR_DROP`).

## [decorazione, strati, quanti grappoli]
const GEMS := [
	[23, [2, 3], 90],                      # brillaluce: Caverne d'ardesia (qualcuna nelle Profondità)
	[24, [1, 2], 90],                      # sanguinella: Sottobosco e Caverne
	[25, [3], 80],                         # lagunite: Profondità della Linfa
	[26, [4], 80],                         # nottilite: il Fondo
]
const SPACING := 14.0


func title() -> String:
	return "Gemme"


func run(w: World, c: GenContext) -> void:
	var placed: Array[Vector2i] = []
	var got := []
	for g in GEMS:
		got.append(_scatter(w, c, int(g[0]), g[1], int(g[2]), placed))
	c.notes["gemme"] = got


func _scatter(w: World, c: GenContext, decor: int, strata: Array, n: int, placed: Array[Vector2i]) -> int:
	var top := StrataData.top(int(strata.min()))
	var bottom := StrataData.top(int(strata.max()) + 1) if int(strata.max()) + 1 < StrataData.STRATA.size() else w.h
	var got := 0
	for k in n * 300:
		if got >= n:
			break
		var x := c.rng.randi_range(10, w.w - 11)
		var y := w.surface[x] + c.rng.randi_range(top + 4, mini(bottom, w.h - w.surface[x] - 8))
		for s in 24:
			var yy := y + s
			if not w.inside(x, yy + 1) or w.solid(x, yy):
				break
			if w.solid(x, yy + 1):
				var q := Vector2i(x, yy)
				if int(StrataData.at(w, x, yy)) in strata and w.wall(x, yy) != 0 and w.decor_at(x, yy) == 0 \
						and w.tile(x, yy + 1) != TileDefs.PIETRA_SEM and w.station_at(q).is_empty() and _far(placed, q):
					w.set_decor(x, yy, decor)
					placed.append(q)
					got += 1
					# un secondo cristallo accanto, se c'è pavimento
					for dx in [1, -1]:
						if c.rng.randf() < 0.5 and not w.solid(x + dx, yy) and w.solid(x + dx, yy + 1) \
								and w.decor_at(x + dx, yy) == 0:
							w.set_decor(x + dx, yy, decor)
				break
	return got


func _far(placed: Array[Vector2i], q: Vector2i) -> bool:
	for p in placed:
		if absi(p.x - q.x) < SPACING and absi(p.y - q.y) < SPACING:
			return false
	return true
