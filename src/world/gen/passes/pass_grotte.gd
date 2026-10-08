class_name PassGrotte
extends GenPass
## Gallerie a verme (dove il rumore è vicino a zero) e caverne (dove è alto). Tre cose le rendono varie:
## - lo strato (voce 448): ogni strato ha il suo stile (`CaveStylesData`: gallerie orizzontali nel Sottobosco, sale nelle
##   Caverne, pozzi con le cenge nelle Profondità, vuoti nel Fondo), sfumato sui confini;
## - le regioni: un rumore molto lento alterna zone compatte e zone traforate;
## - le grandi caverne, rare, solo nel profondo.
## Geni delle grotte (voce 43): gallerie più o meno larghe, caverne più o meno frequenti, grandi caverne ovunque nel
## profondo, celle ad alveare, voragini dalla superficie.

const DEEP := 180                      # le grandi caverne: dentro le Caverne d'ardesia (vedi `StrataData`)


func title() -> String:
	return "Grotte"


func run(w: World, c: GenContext) -> void:
	var n_worm := c.noise("gallerie", 0.022, 3)
	var n_room := c.noise("caverne", 0.035, 3)
	var n_big := c.noise("grandi_caverne", 0.009, 2)
	var n_reg := c.noise("regioni", 0.004, 2)
	var g := c.genes()
	var worm_k := float(g["worm"])
	var room_d := float(g["room"])
	var big_d := float(g["big"])
	var comb := bool(g["comb"])
	var n_cell := c.noise("alveare", 0.045, 1)
	n_cell.noise_type = FastNoiseLite.TYPE_CELLULAR
	n_cell.fractal_type = FastNoiseLite.FRACTAL_NONE
	n_cell.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	var n_shaft := c.noise("pozzi", 0.03, 2)
	var tiles := w.tiles
	var surf := w.surface
	var ww := w.w
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	# voce 448: gli stili per strato, come tabelle di numeri per profondità (una riga ogni 2 di profondità) già sfumati
	var deep := w.h
	var table := []
	for d in range(0, deep, 2):
		var k := 0
		for i in tops.size():
			if d >= tops[i]:
				k = i
		var t := 0.0
		if k + 1 < tops.size():
			t = clampf(float(d - (tops[k + 1] - CaveStylesData.BLEND)) / CaveStylesData.BLEND, 0.0, 1.0)
		table.append(CaveStylesData.mix(k, t))
	# a fasce di righe su più processori (`GenBands`): ogni cella dipende solo da sé
	var parts := GenBands.run(c, w.h, func(_b: int, y0: int, y1: int) -> Array:
		var t: PackedByteArray = tiles.slice(y0 * ww, y1 * ww)
		for y in range(y0, y1):
			var row := (y - y0) * ww
			for x in ww:
				var dep := y - surf[x]
				if dep <= 6:
					continue
				var st: Dictionary = table[clampi((dep - off[x]) / 2, 0, table.size() - 1)]
				var reg := n_reg.get_noise_2d(x, y) * 1.6
				var worm := (float(st["worm"]) + 0.02 * reg) * worm_k
				var room := float(st["room"]) - 0.1 * reg + room_d
				var carve := absf(n_worm.get_noise_2d(x, y * float(st["worm_sy"]))) < worm \
					or n_room.get_noise_2d(x, y * float(st["room_sy"])) > room
				var sh := float(st["shaft"])
				if not carve and sh > 0.0 and reg > 0.15 and absf(n_shaft.get_noise_2d(x * 0.9, y * 0.12)) < sh:
					var ledge := int(st["ledge"])
					carve = ledge <= 0 or (y + x / 7) % ledge != 0           # le cenge: una riga di roccia ogni tanto
				if not carve and dep > DEEP:
					carve = n_big.get_noise_2d(x, y * 1.5) > float(st["big"]) - 0.08 * minf((dep - DEEP) / 200.0, 1.0) + big_d
				if not carve and comb and dep > 30:
					carve = n_cell.get_noise_2d(x, y * 1.15) > -0.62     # l'interno di una cella; i bordi restano muri
				if carve:
					t[row + x] = TileDefs.AIR
		return [t])
	w.tiles = GenBands.join(parts, 0)
	_shafts(w, c, int(g["shafts"]))


## Le voragini: pozzi un poco storti dalla superficie fino alle Caverne d'ardesia o più giù.
func _shafts(w: World, c: GenContext, n: int) -> void:
	var bend := c.noise("voragini", 0.04, 2)
	for k in n:
		var x := float(c.rng.randi_range(60, w.w - 61))
		if absf(x - w.spawn.x) < 90.0:
			continue
		var depth := c.rng.randi_range(170, 420)
		var width := c.rng.randi_range(2, 4)
		var top := w.surface[int(x)] - 2
		for y in range(top, mini(top + depth, w.h - 12)):
			x += bend.get_noise_2d(k * 70.0, y) * 0.7
			for dx in range(-width, width + 1):
				var xi := clampi(int(x) + dx, 1, w.w - 2)
				w.set_tile(xi, y, TileDefs.AIR)
