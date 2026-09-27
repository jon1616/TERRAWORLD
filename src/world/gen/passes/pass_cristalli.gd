class_name PassCristalli
extends GenPass
## Cristalli di Linfa sulle pareti delle caverne dalle Profondità della Linfa in giù, a grappoli.

const HOSTS := [TileDefs.STONE, TileDefs.SCISTO, TileDefs.VUOTITE]


func title() -> String:
	return "Cristalli"


func run(w: World, c: GenContext) -> void:
	var n_cr := c.noise("cristalli", 0.08, 2)
	var th := 0.3 - float(c.genes()["crystal"])                     # gene «Cristalli giganti» (voce 43)
	var min_depth := StrataData.top(3)
	var off := c.strata_off(w)
	var tiles := w.tiles
	var surf := w.surface
	var ww := w.w
	var hh := w.h
	var host := PackedByteArray()
	host.resize(TileDefs.TYPES + 1)
	for t in HOSTS:
		host[t] = 1
	# i punti dei grappoli si cercano a fasce su più processori (`GenBands`), in ordine; la crescita resta una sola
	var parts := GenBands.run(hh, func(_b: int, y0: int, y1: int) -> Array:
		var found := []
		for y in range(maxi(y0, 1), mini(y1, hh - 1)):
			var row := y * ww
			for x in range(1, ww - 1):
				var i := row + x
				if host[tiles[i]] == 0 or y - surf[x] - off[x] <= min_depth:
					continue
				if n_cr.get_noise_2d(x, y) > th and (tiles[i - 1] == TileDefs.AIR or tiles[i + 1] == TileDefs.AIR \
						or tiles[i - ww] == TileDefs.AIR or tiles[i + ww] == TileDefs.AIR):
					found.append(Vector2i(x, y))
		return [found])
	var seeds := GenBands.join_list(parts, 0)
	for s: Vector2i in seeds:
		w.set_tile(s.x, s.y, TileDefs.CRYSTAL)
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = s + o
			if w.tile(q.x, q.y) in HOSTS and c.rng.randf() < 0.25:
				w.set_tile(q.x, q.y, TileDefs.CRYSTAL)



static func _near_air(w: World, x: int, y: int) -> bool:
	return not w.solid(x - 1, y) or not w.solid(x + 1, y) or not w.solid(x, y - 1) or not w.solid(x, y + 1)
