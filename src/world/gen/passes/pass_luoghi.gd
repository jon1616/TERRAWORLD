class_name PassLuoghi
extends GenPass
## I luoghi scritti a mano (voce 70, disegni e dati in `PlacesData`): nei mondi con i geni giusti, al più
## `MAX_PER_WORLD` luoghi scavati nel loro strato (o appoggiati alla superficie), lontano dalla partenza, dal Cuore e
## da ciò che è già costruito. Lo scrigno ha un bottino ricco, l'oggetto unico del luogo, tavolette e Linfa antica.
## Il Santuario del Vuoto è chiuso a chiave: la chiave va in uno scrigno delle rovine dello stesso mondo.
## Appunti: `notes["luoghi"]` = [{"id", "x", "y", "w", "h", "leggio", "porta": [celle], "mecc": {"1": cella, …}}].


func title() -> String:
	return "Luoghi"


func run(w: World, c: GenContext) -> void:
	var genes: Array = c.params.get("geni", [])
	var cand := []
	for id in PlacesData.PLACES:
		for g in PlacesData.PLACES[id]["genes"]:
			if g in genes:
				cand.append(String(id))
				break
	if bool(c.params.get("luoghi_tutti", false)):          # prove e strumenti: tutti
		cand = PlacesData.PLACES.keys()
	var out := []
	for id in cand:
		if out.size() >= PlacesData.MAX_PER_WORLD and not bool(c.params.get("luoghi_tutti", false)):
			break
		var o := _find(w, c, String(id))
		if o.x >= 0:
			out.append(build(w, String(id), o, c.rng))
	c.notes["luoghi"] = out
	for e in out:
		if String(e["id"]) == "santuario":
			_hide_key(w, c)


## Dove mettere un luogo: nel suo strato, o con il pavimento sulla superficie.
func _find(w: World, c: GenContext, id: String) -> Vector2i:
	var pd: Dictionary = PlacesData.PLACES[id]
	var grid := PlacesData.grid(id)
	var gw: int = (grid[0] as String).length()
	var gh := grid.size()
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	for k in 120:
		var x := c.rng.randi_range(40, w.w - 40 - gw)
		if absi(x + gw / 2 - w.w / 2) < 110:
			continue
		var y := 0
		if pd.get("surface", false):
			y = w.surface[x + gw / 2] - (gh - 3)
		else:
			var st: Array = pd["strata"]
			var t0 := StrataData.top(int(st[0]))
			var last := int(st[1])
			var t1 := StrataData.top(last + 1) if last + 1 < StrataData.STRATA.size() else w.h - w.surface[x] - gh - 10
			y = w.surface[x] + c.rng.randi_range(t0 + 4, maxi(t1 - gh - 4, t0 + 5))
		if y < 4 or y + gh + 2 >= w.h:
			continue
		if Vector2(Vector2i(x + gw / 2, y) - cuore).length() < 80.0 or _busy(w, Rect2i(x - 3, y - 3, gw + 6, gh + 6)):
			continue
		return Vector2i(x, y)
	return Vector2i(-1, -1)


func _busy(w: World, r: Rect2i) -> bool:
	for o in w.stations:
		if r.has_point(o):
			return true
	return false


## Scava il disegno di un luogo con l'angolo in alto a sinistra in o. Restituisce il suo appunto.
static func build(w: World, id: String, o: Vector2i, rng: RandomNumberGenerator) -> Dictionary:
	var grid := PlacesData.grid(id)
	var e := {"id": id, "x": o.x, "y": o.y, "w": (grid[0] as String).length(), "h": grid.size(), "porta": [], "mecc": {}}
	var stations := []
	for gy in grid.size():
		var row: String = grid[gy]
		for gx in row.length():
			var ch := row[gx]
			var x := o.x + gx
			var y := o.y + gy
			if ch == " " or not w.inside(x, y):
				continue
			w.set_decor(x, y, 0)
			if PlacesData.TILE.has(ch):
				w.set_tile(x, y, int(PlacesData.TILE[ch]))
				w.walls[y * w.w + x] = TileDefs.WALL_SEM
				continue
			if ch == "D":
				w.set_tile(x, y, TileDefs.PORTA_SEM)           # voce 71: la porta del tesoro
				w.walls[y * w.w + x] = TileDefs.WALL_SEM
				(e["porta"] as Array).append(Vector2i(x, y))
				continue
			w.set_tile(x, y, TileDefs.AIR)
			w.walls[y * w.w + x] = 0 if ch == "_" else TileDefs.WALL_SEM
			if ch == "." and gy == 2 and gx % 3 == 0:
				w.set_decor(x, y, TileDefs.DECOR_RUNE)    # le rune accese sul soffitto, come nelle rovine
			if ch in ["1", "2", "3", "4"]:
				e["mecc"][ch] = Vector2i(x, y)
				var tipo := String(PlacesData.PLACES[id]["enigma"]["tipo"])
				if PlacesData.MECH.has(tipo):
					stations.append([String(PlacesData.MECH[tipo]), Vector2i(x, y)])
			elif PlacesData.STATION.has(ch):
				stations.append([String(PlacesData.STATION[ch]), Vector2i(x, y)])
	for s in stations:
		w.stations[s[1]] = s[0]
		if s[0] == "leggio":
			e["leggio"] = s[1]
		elif s[0] == "scrigno":
			var chest := w.chest_at(s[1])
			var st := clampi(StrataData.at(w, o.x, o.y), 1, 4)
			var loot := LootData.roll_chest("rovina_%d" % st, rng, 5)
			for iid in loot:
				chest.add(iid, int(loot[iid]))
			chest.add(String(PlacesData.PLACES[id]["unique"]), 1)
			chest.add("tavoletta_seminatori", 2)
			chest.add("linfa_antica", 1)
	return e


## La chiave del Santuario: in uno scrigno delle rovine di questo mondo (il più lontano dal santuario).
func _hide_key(w: World, c: GenContext) -> void:
	var best := Vector2i(-1, -1)
	var bd := -1.0
	for o in w.stations:
		if String(w.stations[o]) == "scrigno" and w.chests.has(o):
			var d := Vector2(o).distance_to(Vector2(w.w / 2.0, 0.0)) + c.rng.randf() * 200.0
			if d > bd:
				bd = d
				best = o
	if best.x >= 0:
		w.chest_at(best).add("chiave_seminatori", 1)
