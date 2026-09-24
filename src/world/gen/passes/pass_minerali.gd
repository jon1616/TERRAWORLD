class_name PassMinerali
extends GenPass
## Vene di minerale nella roccia e nella terra: più preziose più si scende.

const COPPER_DEPTH := 4
const IRON_DEPTH := 60
const GOLD_DEPTH := 180


func title() -> String:
	return "Minerali"


func run(w: World, c: GenContext) -> void:
	var n_cu := c.noise("rame", 0.11, 2)
	var n_fe := c.noise("ferro", 0.12, 2)
	var n_au := c.noise("oro", 0.13, 2)
	var tiles := w.tiles
	for y in w.h:
		var row := y * w.w
		for x in w.w:
			var t := tiles[row + x]
			if t != TileDefs.STONE and t != TileDefs.DIRT:
				continue
			var dep := y - w.surface[x]
			if dep > COPPER_DEPTH and n_cu.get_noise_2d(x, y) > 0.5:
				tiles[row + x] = TileDefs.COPPER
			elif t == TileDefs.STONE and dep > IRON_DEPTH and n_fe.get_noise_2d(x, y) > 0.52:
				tiles[row + x] = TileDefs.IRON
			elif t == TileDefs.STONE and dep > GOLD_DEPTH and n_au.get_noise_2d(x, y) > 0.55:
				tiles[row + x] = TileDefs.GOLD
	w.tiles = tiles
