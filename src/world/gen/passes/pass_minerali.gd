class_name PassMinerali
extends GenPass
## Vene di minerale nella roccia e nella terra, più preziose più si scende. I parametri stanno in `TileDefs.ORES`.


func title() -> String:
	return "Minerali"


func run(w: World, c: GenContext) -> void:
	var ores: Array = TileDefs.ORES
	var noises: Array[FastNoiseLite] = []
	var hosts: Array[PackedByteArray] = []
	for o in ores:
		noises.append(c.noise("minerale_%d" % o["type"], o["freq"], 2))
		var h := PackedByteArray()
		h.resize(TileDefs.TYPES + 1)
		for t in o["in"]:
			h[t] = 1
		hosts.append(h)
	var tiles := w.tiles
	for y in w.h:
		var row := y * w.w
		for x in w.w:
			var t := tiles[row + x]
			if t == TileDefs.AIR:
				continue
			var dep := y - w.surface[x]
			for k in ores.size():
				var o: Dictionary = ores[k]
				if hosts[k][t] == 1 and dep > int(o["min_depth"]) and noises[k].get_noise_2d(x, y) > float(o["threshold"]):
					tiles[row + x] = o["type"]
					break
	w.tiles = tiles
