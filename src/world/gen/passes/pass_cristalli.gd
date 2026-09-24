class_name PassCristalli
extends GenPass
## Cristalli di Linfa sulle pareti delle caverne profonde, a grappoli.

const MIN_DEPTH := 350


func title() -> String:
	return "Cristalli"


func run(w: World, c: GenContext) -> void:
	var n_cr := c.noise("cristalli", 0.08, 2)
	var seeds: Array[Vector2i] = []
	for y in range(1, w.h - 1):
		for x in range(1, w.w - 1):
			if w.tiles[y * w.w + x] != TileDefs.STONE or y - w.surface[x] <= MIN_DEPTH:
				continue
			if n_cr.get_noise_2d(x, y) > 0.3 and _near_air(w, x, y):
				seeds.append(Vector2i(x, y))
	for s in seeds:
		w.set_tile(s.x, s.y, TileDefs.CRYSTAL)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = s + o
			if w.tile(q.x, q.y) == TileDefs.STONE and c.rng.randf() < 0.25:
				w.set_tile(q.x, q.y, TileDefs.CRYSTAL)


static func _near_air(w: World, x: int, y: int) -> bool:
	return not w.solid(x - 1, y) or not w.solid(x + 1, y) or not w.solid(x, y - 1) or not w.solid(x, y + 1)
