class_name PassOsservatori
extends GenPass
## Gli osservatori dei Seminatori e i nidi del cielo (Roadmap 16, voce 163). Su un'isola alta di ogni zona del cielo
## (dalle isole di `PassCielo`, appunti "isole_cielo") i Seminatori guardavano le stelle: una cupola di cristallo celeste
## su colonne, aperta ai lati, costruita come il loro progetto «osservatorio» (`ProjectsData`, così il giocatore può
## rifarla), con uno scrigno (tabella «rovina_cielo») e una stele (il punto va negli appunti "rovine": la mette
## `PassStele`). Sulle isole basse, i nidi delle famiglie del cielo (campo `nest`, specie con `sky`): `PassNidi` le
## salta, qui vanno sulle isole del loro bioma. Appunti: "osservatori" [[x, cima]], "nidi" (aggiunti).

const MAX := 4


func title() -> String:
	return "Osservatori"


func run(w: World, c: GenContext) -> void:
	var isles: Array = c.notes.get("isole_cielo", [])
	if isles.is_empty():
		c.notes["osservatori"] = []
		return
	var done := []
	var zones_done := {}
	var rovine: Array = c.notes.get("rovine", [])
	for e in isles:
		if done.size() >= MAX:
			break
		if String(e["band"]) != "alto" or int(e["half"]) < 7:
			continue
		var z := SkyData.zone_of(w, int(e["x"]))
		var zk := int(z.get("x0", -1))
		if zones_done.has(zk):
			continue
		var x0 := int(e["x"]) - 5
		var top := int(e["top"])
		if top - 8 < SkyData.TOP:
			continue
		_build(w, c, x0, top, String(e["biome"]))
		zones_done[zk] = true
		done.append([x0, top])
		rovine.append(Vector2i(x0 + 2, top - 1))          # la stele, a sinistra dello scrigno (`PassStele`)
	c.notes["rovine"] = rovine
	c.notes["osservatori"] = done
	_nests(w, c, isles)


## La cupola del progetto «osservatorio», con la cima dell'isola spianata sotto.
func _build(w: World, c: GenContext, x0: int, top: int, biome: String) -> void:
	var grid: Array = ProjectsData.PROJECTS["osservatorio"]["grid"]
	var gw := String(grid[0]).length()
	var gh := grid.size()
	var y0 := top - gh + 1                               # l'ultima riga della griglia (il pavimento) sulla cima
	var b := SkyData.get_biome(biome)
	var body_t := int(b.get("body", b.get("floor", TileDefs.STONE)))
	# spiana: aria sopra, pieno sotto il pavimento
	for x in range(x0 - 1, x0 + gw + 1):
		for y in range(y0 - 2, top):
			w.set_tile(x, y, TileDefs.AIR)
			w.set_decor(x, y, 0)
			w.set_plat(x, y, false)
		for y in range(top, top + 3):
			if not w.solid(x, y):
				w.set_tile(x, y, body_t)
	var wall := ProjectsData.wall_id()
	for r in gh:
		var row := String(grid[r])
		for i in row.length():
			var ch := row[i]
			var q := Vector2i(x0 + i, y0 + r)
			var k := ProjectsData.kind_of(ch)
			if k > 0:
				w.set_build(q.x, q.y, k)
			elif ch == ".":
				w.walls[q.y * w.w + q.x] = wall
			elif ch == "L":
				w.walls[q.y * w.w + q.x] = wall
				if w.station_fits(String(ProjectsData.STATION["L"]), q):
					w.stations[q] = String(ProjectsData.STATION["L"])
	var o := Vector2i(x0 + 6, top - 2)
	w.stations[o] = "scrigno"
	var loot := LootData.roll_chest("rovina_cielo", c.rng, 3)
	for id in loot:
		w.chest_at(o).add(id, int(loot[id]))
	# Roadmap 45, voce 392: a volte la cassa del bioma del cielo (con un caso suo, che non sposta il resto della passata)
	var rb := RandomNumberGenerator.new()
	rb.seed = hash([o.x, o.y, w.world_seed, "bioma"])
	var sky_b := ChestsData.biome_at(w, o, 0)
	var cid := "cassa_%s%s" % [sky_b, "_sigillata" if rb.randf() < 0.3 else ""]
	if rb.randf() < 0.5 and ChestsData.is_found(cid):
		w.stations[o] = cid
		# lo scrigno era già pieno (20 caselle): diventa grande quanto la cassa del bioma, come la ricrea il caricamento
		w.chest_at(o).grow(int(StationsData.STATIONS[cid].get("slots", 20)))
		var bl := LootData.roll(cid, rb)
		for id in bl:
			w.chest_at(o).add(String(id), int(bl[id]))
	# niente `claim`: l'isola sotto è già segnata da `PassCielo` (la cupola sta dentro il suo posto)


## I nidi delle famiglie del cielo sulle isole basse del bioma della loro specie.
func _nests(w: World, c: GenContext, isles: Array) -> void:
	var nests: Dictionary = c.notes.get("nidi", {})
	var fams := FamiliesData.FAMILIES.keys()
	fams.sort()
	for f in fams:
		var fd: Dictionary = FamiliesData.FAMILIES[f]
		if not fd.has("nest"):
			continue
		var cd: Dictionary = CreaturesData.CREATURES.get(String(fd["members"][0]), {})
		var sky := String(cd.get("sky", ""))
		if sky == "":
			continue
		var kind := "nido_" + String(fd["nest"]["type"])
		var size: Array = StationsData.STATIONS[kind]["size"]
		var got := 0
		for e in isles:
			if got >= int(fd["nest"]["n"]):
				break
			if String(e["biome"]) != sky:
				continue
			var x := int(e["x"]) + c.rng.randi_range(-int(e["half"]) / 2, int(e["half"]) / 2)
			var y := int(e["top"]) - 1
			while y > SkyData.TOP and w.solid(x, y):
				y -= 1
			var o := Vector2i(x, y - int(size[1]) + 1)
			if not w.station_fits(kind, o):
				continue
			for dy in size[1]:
				for dx in size[0]:
					w.set_decor(o.x + dx, o.y + dy, 0)
			w.stations[o] = kind
			nests["%d,%d" % [o.x, o.y]] = f
			got += 1
	c.notes["nidi"] = nests
