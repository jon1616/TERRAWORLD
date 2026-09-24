class_name PassMinerali
extends GenPass
## Vene di minerale nella roccia e nella terra, più preziose più si scende. I parametri stanno in `TileDefs.ORES`:
## ogni minerale compare solo nei suoi strati (`StrataData`) e nelle sue rocce.


func title() -> String:
	return "Minerali"


func run(w: World, c: GenContext) -> void:
	var ores: Array = TileDefs.ORES
	var noises: Array[FastNoiseLite] = []
	var hosts: Array[PackedByteArray] = []
	var in_stratum: Array[PackedByteArray] = []
	for o in ores:
		noises.append(c.noise("minerale_%d" % o["type"], o["freq"], 2))
		var h := PackedByteArray()
		h.resize(TileDefs.TYPES + 1)
		for t in o["in"]:
			h[t] = 1
		hosts.append(h)
		var st := PackedByteArray()
		st.resize(StrataData.STRATA.size())
		for k in o["strata"]:
			st[k] = 1
		in_stratum.append(st)
	var off := PackedInt32Array()
	off.resize(w.w)
	for x in w.w:
		off[x] = StrataData.offset(x, w.world_seed)
	var tops := PackedInt32Array()
	for st in StrataData.STRATA:
		tops.append(int(st["top"]))
	var last := tops.size() - 1
	var tiles := w.tiles
	for y in w.h:
		var row := y * w.w
		for x in w.w:
			var t := tiles[row + x]
			if t == TileDefs.AIR:
				continue
			var dep := y - w.surface[x]
			var sk := last
			while sk > 0 and dep - off[x] < tops[sk]:
				sk -= 1
			for k in ores.size():
				var o: Dictionary = ores[k]
				if hosts[k][t] == 1 and in_stratum[k][sk] == 1 and dep > int(o["min_depth"]) \
						and noises[k].get_noise_2d(x, y) > float(o["threshold"]):
					tiles[row + x] = o["type"]
					break
	w.tiles = tiles
