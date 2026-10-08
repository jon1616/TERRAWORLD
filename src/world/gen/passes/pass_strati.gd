class_name PassStrati
extends GenPass
## Riempie il sottosuolo secondo gli strati di profondità (`StrataData`): terra in superficie, poi la roccia di ogni
## strato (ardesia, scisto di Linfa, vuotite) con le sue sacche e la sua parete di fondo. Il confine tra gli strati
## ondeggia, e dove due strati si toccano le rocce si mescolano un poco.


const LOBE := 40                       # voce 451: la fascia dei confini vivi, in righe

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
	for st in strata:
		rock.append(int(st["rock"]))
		pocket.append(int(st["pocket"]))
		wall.append(int(st["wall"]))
	var tops := c.strata_tops()
	var last := strata.size() - 1
	var n_lobe := c.noise("lingue_strati", 0.018, 2)
	var n_colm := c.noise("colonne_strati", 0.012, 1)
	var off := c.strata_off(w)
	var ww := w.w
	var surf := w.surface
	var dds := PackedInt32Array()
	dds.resize(ww)
	for x in ww:
		dds[x] = 14 + int(n_dd.get_noise_1d(x) * 7.0)
	var tiles := w.tiles
	var walls := w.walls
	# a fasce di righe su più processori (`GenBands`): ogni cella dipende solo da sé
	var parts := GenBands.run(c, w.h, func(_b: int, y0: int, y1: int) -> Array:
		var t: PackedByteArray = tiles.slice(y0 * ww, y1 * ww)
		var wl: PackedByteArray = walls.slice(y0 * ww, y1 * ww)
		for y in range(y0, y1):
			var row := (y - y0) * ww
			for x in ww:
				var s := surf[x]
				if y < s:
					continue
				var dd := dds[x]
				var dep := y - s
				var d := dep - off[x]
				var k := last
				while k > 0 and d < tops[k]:
					k -= 1
				# confini sfrangiati tra gli strati (il rumore serve solo vicino a un confine). Voce 451: dalle Caverne in giù
				# la fascia di confine è larga `LOBE` righe, con lingue e sacche (un rumore lento in 2D) e, qua e là, colonne
				# della roccia di sotto che salgono (`n_colm`): cambia la roccia, non lo strato del gioco.
				var near := LOBE if k >= 2 or (k + 1 <= last and k + 1 >= 2 and tops[k + 1] - d < LOBE) else 9
				if (k > 0 and d - tops[k] < near) or (k < last and tops[k + 1] - d < near):
					d += int(n_mix.get_noise_2d(x, y) * 8.0)
					if near == LOBE:
						d += int(n_lobe.get_noise_2d(x, y * 1.6) * 30.0) + int(maxf(n_colm.get_noise_1d(x) - 0.35, 0.0) * 110.0)
					k = last
					while k > 0 and d < tops[k]:
						k -= 1
				var tt := TileDefs.DIRT if dep < dd else int(rock[k])
				var pk := n_p.get_noise_2d(x, y)
				if tt == TileDefs.DIRT and pk > 0.42 and dep > 3:
					tt = TileDefs.STONE
				elif tt != TileDefs.DIRT and pk > 0.45:
					tt = int(pocket[k])
				t[row + x] = tt
				if dep > 1:
					wl[row + x] = TileDefs.WALL_DIRT if dep < dd + 3 else int(wall[k])
		return [t, wl])
	w.tiles = GenBands.join(parts, 0)
	w.walls = GenBands.join(parts, 1)
