class_name PassStrati
extends GenPass
## Riempie il sottosuolo secondo gli strati di profondità (`StrataData`): terra in superficie, poi la roccia di ogni
## strato (ardesia, scisto di Linfa, vuotite) con le sue sacche e la sua parete di fondo. Il confine tra gli strati
## ondeggia, e dove due strati si toccano le rocce si mescolano un poco.


func title() -> String:
	return "Strati"


func run(w: World, c: GenContext) -> void:
	var n_dd := c.noise("spessore_terra", 0.03, 2)
	var n_p := c.noise("sacche", 0.07, 3)
	var n_mix := c.noise("confini", 0.09, 2)
	var strata: Array = StrataData.STRATA
	var rock := PackedByteArray()
	var pocket := PackedByteArray()
	var wall := PackedByteArray()
	var tops := PackedInt32Array()
	for st in strata:
		rock.append(int(st["rock"]))
		pocket.append(int(st["pocket"]))
		wall.append(int(st["wall"]))
		tops.append(int(st["top"]))
	var last := strata.size() - 1
	for x in w.w:
		var dd := 14 + int(n_dd.get_noise_1d(x) * 7.0)
		var s := w.surface[x]
		var off := StrataData.offset(x, w.world_seed)
		for y in range(maxi(s, 0), w.h):
			var dep := y - s
			var d := dep - off
			var k := last
			while k > 0 and d < tops[k]:
				k -= 1
			# confini sfrangiati tra gli strati (il rumore serve solo vicino a un confine)
			if (k > 0 and d - tops[k] < 9) or (k < last and tops[k + 1] - d < 9):
				d += int(n_mix.get_noise_2d(x, y) * 8.0)
				k = last
				while k > 0 and d < tops[k]:
					k -= 1
			var t := TileDefs.DIRT if dep < dd else int(rock[k])
			var pk := n_p.get_noise_2d(x, y)
			if t == TileDefs.DIRT and pk > 0.42 and dep > 3:
				t = TileDefs.STONE
			elif t != TileDefs.DIRT and pk > 0.45:
				t = int(pocket[k])
			var i := y * w.w + x
			w.tiles[i] = t
			if dep > 1:
				w.walls[i] = TileDefs.WALL_DIRT if dep < dd + 3 else int(wall[k])
