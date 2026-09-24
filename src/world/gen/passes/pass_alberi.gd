class_name PassAlberi
extends GenPass
## Alberi sull'erba in piano, distanziati. La variante sceglie una delle forme disegnate da `NatureArt.tree`.

const VARIANTS := 8


func title() -> String:
	return "Alberi"


func run(w: World, c: GenContext) -> void:
	var last := -99
	for x in range(3, w.w - 3):
		var gy := w.surface[x]
		if w.tile(x, gy) != TileDefs.GRASS or w.surface[x - 1] != gy or w.surface[x + 1] != gy:
			continue
		if x - last < 5 or absi(x - w.spawn.x) < 4 or c.rng.randf() > 0.4:
			continue
		var clear := true
		for k in range(1, 7):
			if w.solid(x, gy - k):
				clear = false
		if not clear:
			continue
		w.add_tree(Vector2i(x, gy - 1), c.rng.randi_range(0, VARIANTS - 1))
		last = x
