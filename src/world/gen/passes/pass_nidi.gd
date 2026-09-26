class_name PassNidi
extends GenPass
## I nidi e le tane delle famiglie (voce 58, `FamiliesData` nest): per ogni famiglia che ne ha, `n` nidi nei luoghi dove
## vive la sua specie (strati e biomi di `CreaturesData`), lontani dalla partenza e tra loro. Negli appunti
## `notes["nidi"]` = {"x,y": famiglia}; da lì nascono le creature della zona (`Ecology`).

const MIN_DIST := 70.0


func title() -> String:
	return "Nidi"


func run(w: World, c: GenContext) -> void:
	var out := {}
	var placed: Array[Vector2i] = []
	for f in FamiliesData.FAMILIES:
		var fd: Dictionary = FamiliesData.FAMILIES[f]
		if not fd.has("nest"):
			continue
		var species := String(fd["members"][0])
		var cd: Dictionary = CreaturesData.CREATURES[species]
		var strata: Array = cd.get("strata", [])
		if strata.is_empty():
			continue
		var kind := "nido_" + String(fd["nest"]["type"])
		var got := 0
		for tries in int(fd["nest"]["n"]) * 150:
			if got >= int(fd["nest"]["n"]):
				break
			var x := c.rng.randi_range(30, w.w - 31)
			if absi(x - w.spawn.x) < 50:
				continue
			var st := int(strata[c.rng.randi_range(0, strata.size() - 1)])
			var y := w.surface[x] - 1
			if st == 0:
				if cd.has("biomes") and not String(BiomesData.BIOMES[BiomesData.at(w, x)]["id"]) in cd["biomes"]:
					continue
			else:
				var t0 := StrataData.top(st)
				var t1 := StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else t0 + 200
				y = w.surface[x] + c.rng.randi_range(t0 + 6, maxi(t1 - 6, t0 + 7))
				for k in 40:
					if w.solid(x, y + 1):
						break
					y += 1
			var size: Array = StationsData.STATIONS[kind]["size"]
			var o := Vector2i(x, y - int(size[1]) + 1)
			if not w.station_fits(kind, o):
				continue
			var far := true
			for q in placed:
				if Vector2(q - o).length() < MIN_DIST:
					far = false
					break
			if not far:
				continue
			for dy in size[1]:
				for dx in size[0]:
					w.set_decor(o.x + dx, o.y + dy, 0)
			w.stations[o] = kind
			out["%d,%d" % [o.x, o.y]] = f
			placed.append(o)
			got += 1
	c.notes["nidi"] = out
