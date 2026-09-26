class_name PassGrotte
extends GenPass
## Gallerie a verme (dove il rumore è vicino a zero) e caverne (dove è alto). Tre cose le rendono varie:
## - la profondità: vicino alla superficie solo gallerie strette, più giù caverne sempre più ampie;
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
	var tiles := w.tiles
	for y in w.h:
		var row := y * w.w
		for x in w.w:
			var dep := y - w.surface[x]
			if dep <= 6:
				continue
			var f := minf(dep / 300.0, 1.0)
			var reg := n_reg.get_noise_2d(x, y) * 1.6
			var worm := (0.035 + 0.025 * f + 0.02 * reg) * worm_k
			var room := 0.47 - 0.16 * f - 0.1 * reg + room_d
			var carve := absf(n_worm.get_noise_2d(x, y * 1.4)) < worm or n_room.get_noise_2d(x, y * 1.2) > room
			if not carve and dep > DEEP:
				carve = n_big.get_noise_2d(x, y * 1.5) > 0.5 - 0.08 * minf((dep - DEEP) / 200.0, 1.0) + big_d
			if not carve and comb and dep > 30:
				carve = n_cell.get_noise_2d(x, y * 1.15) > -0.62         # l'interno di una cella; i bordi restano muri
			if carve:
				tiles[row + x] = TileDefs.AIR
	w.tiles = tiles
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
