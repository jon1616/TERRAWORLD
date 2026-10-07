class_name PassMinerali
extends GenPass
## Vene di minerale nella roccia e nella terra, più preziose più si scende. I parametri stanno in `TileDefs.ORES`:
## ogni minerale compare solo nei suoi strati (`StrataData`) e nelle sue rocce.


func title() -> String:
	return "Minerali"


func run(w: World, c: GenContext) -> void:
	# Roadmap 52, voce 413: le vene con «vmin»/«vmax» ci sono solo nei mondi di quei vigori
	var vig := int(c.params.get("vigore", 1))
	var ores: Array = TileDefs.ORES.filter(func(o: Dictionary) -> bool:
		return vig >= int(o.get("vmin", 0)) and vig <= int(o.get("vmax", 9999)))
	var richer := 0.025 * (int(c.params.get("vigore", 1)) - 1)   # vene più grandi nei mondi più vigorosi
	richer += float(c.genes()["ore"])                               # gene «Vene ricche»
	var shallow := float(c.genes()["shallow"])                      # gene «Vene affioranti»
	var boost: Dictionary = c.genes()["ore_boost"]                  # geni di un metallo (voce 43)
	var noises: Array[FastNoiseLite] = []
	var hosts: Array[PackedByteArray] = []
	var in_stratum: Array[PackedByteArray] = []
	for o in ores:
		noises.append(c.noise("minerale_%d" % o["type"], o["freq"], int(o.get("oct", 2))))   # Roadmap 52: «oct» 1 costa metà
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
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	var last := tops.size() - 1
	# le soglie e le profondità una volta sola, non a ogni tessera
	var th := PackedFloat64Array()
	var mind := PackedFloat64Array()
	var kind := PackedByteArray()
	for o in ores:
		th.append(float(o["threshold"]) - richer - float(boost.get(o["type"], 0.0)))
		mind.append(int(o["min_depth"]) * shallow)
		kind.append(int(o["type"]))
	var n_ores := ores.size()
	var tiles := w.tiles
	var surf := w.surface
	var ww := w.w
	# a fasce di righe su più processori (`GenBands`): ogni cella dipende solo da sé
	var parts := GenBands.run(c, w.h, func(_b: int, y0: int, y1: int) -> Array:
		var out: PackedByteArray = tiles.slice(y0 * ww, y1 * ww)
		for y in range(y0, y1):
			var row := (y - y0) * ww
			for x in ww:
				var t := out[row + x]
				if t == TileDefs.AIR:
					continue
				var dep := y - surf[x]
				var sk := last
				while sk > 0 and dep - off[x] < tops[sk]:
					sk -= 1
				for k in n_ores:
					if hosts[k][t] == 1 and in_stratum[k][sk] == 1 and dep > mind[k] \
							and noises[k].get_noise_2d(x, y) > th[k]:
						out[row + x] = kind[k]
						break
		return [out])
	w.tiles = GenBands.join(parts, 0)
