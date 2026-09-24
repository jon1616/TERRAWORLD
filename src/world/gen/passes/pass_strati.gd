class_name PassStrati
extends GenPass
## Riempie il sottosuolo: terra in superficie, roccia sotto, sacche dell'una nell'altra; pareti di fondo sotto la superficie.


func title() -> String:
	return "Strati"


func run(w: World, c: GenContext) -> void:
	var n_dd := c.noise("spessore_terra", 0.03, 2)
	var n_p := c.noise("sacche", 0.07, 3)
	for x in w.w:
		var dd := 14 + int(n_dd.get_noise_1d(x) * 7.0)
		var s := w.surface[x]
		for y in range(maxi(s, 0), w.h):
			var dep := y - s
			var t := TileDefs.DIRT if dep < dd else TileDefs.STONE
			var pk := n_p.get_noise_2d(x, y)
			if t == TileDefs.DIRT and pk > 0.42 and dep > 3:
				t = TileDefs.STONE
			elif t == TileDefs.STONE and pk > 0.45:
				t = TileDefs.DIRT
			var i := y * w.w + x
			w.tiles[i] = t
			if dep > 1:
				w.walls[i] = TileDefs.WALL_DIRT if dep < dd + 3 else TileDefs.WALL_STONE
