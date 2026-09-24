class_name PassGrotte
extends GenPass
## Gallerie a verme (dove il rumore è vicino a zero) e caverne (dove è alto). Tre cose le rendono varie:
## - la profondità: vicino alla superficie solo gallerie strette, più giù caverne sempre più ampie;
## - le regioni: un rumore molto lento alterna zone compatte e zone traforate;
## - le grandi caverne, rare, solo nel profondo.

const DEEP := 180                      # le grandi caverne: dentro le Caverne d'ardesia (vedi `StrataData`)


func title() -> String:
	return "Grotte"


func run(w: World, c: GenContext) -> void:
	var n_worm := c.noise("gallerie", 0.022, 3)
	var n_room := c.noise("caverne", 0.035, 3)
	var n_big := c.noise("grandi_caverne", 0.009, 2)
	var n_reg := c.noise("regioni", 0.004, 2)
	var tiles := w.tiles
	for y in w.h:
		var row := y * w.w
		for x in w.w:
			var dep := y - w.surface[x]
			if dep <= 6:
				continue
			var f := minf(dep / 300.0, 1.0)
			var reg := n_reg.get_noise_2d(x, y) * 1.6
			var worm := 0.035 + 0.025 * f + 0.02 * reg
			var room := 0.47 - 0.16 * f - 0.1 * reg
			var carve := absf(n_worm.get_noise_2d(x, y * 1.4)) < worm or n_room.get_noise_2d(x, y * 1.2) > room
			if not carve and dep > DEEP:
				carve = n_big.get_noise_2d(x, y * 1.5) > 0.5 - 0.08 * minf((dep - DEEP) / 200.0, 1.0)
			if carve:
				tiles[row + x] = TileDefs.AIR
	w.tiles = tiles
