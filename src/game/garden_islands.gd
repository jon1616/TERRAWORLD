class_name GardenIslands
extends Node
## Le isole del Giardino (Roadmap 22, voce 228; dati in `GardenIslandsData`). Nel Giardino, quando la bellezza più alta
## raggiunta arriva alla soglia di un'isola, l'isola nasce (tessere, ponte o corrente) e la si annuncia. Stato in
## `world_meta["isole"]` = {id: {"x", "y", "giorno"}}. Le cose che ci sono solo lì:
##   orto     le colture sull'isola crescono ×1.5 (`grow_at`, letto da `Garden`)
##   bestie   ogni giorno una creatura mansueta di una famiglia da addomesticare
##   miniera  le vene di minerale ricrescono ogni giorno
##   stelle   ogni notte cade polvere di stelle

var m: Node2D
var _t := 3.0


func setup(main: Node2D) -> void:
	m = main


func home() -> bool:
	return m.get("beauty") != null and m.beauty.home()


func built() -> Dictionary:
	if not m.world_meta.has("isole"):
		m.world_meta["isole"] = {}
	return m.world_meta["isole"]


func _process(dt: float) -> void:
	if not m.built or not home():
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 5.0
	var best: int = m.beauty.best()
	for id in GardenIslandsData.ORDER:
		if not built().has(id) and best >= int(GardenIslandsData.ISLANDS[id]["need"]):
			build(String(id))
	_daily()


## Il centro del Giardino e la sua superficie (dall'Albero-Madre).
func _center() -> Vector2i:
	var o: Vector2i = m.giardino.tree_o if m.get("giardino") != null and m.giardino.tree_o.x >= 0 else Vector2i(m.world.w / 2 - 4, 110 - 13)
	return Vector2i(o.x + 4, o.y + 13)


## Fa nascere un'isola.
func build(id: String) -> void:
	var d: Dictionary = GardenIslandsData.ISLANDS[id]
	var w: World = m.world
	var c := _center()
	var cx := clampi(c.x + int(d["dx"]), int(d["half"]) + 3, w.w - int(d["half"]) - 3)
	var top := c.y + int(d["dy"])
	var half := int(d["half"])
	var cloud := id == "cielo"
	for x in range(cx - half, cx + half + 1):
		var t := float(x - cx) / half
		var surf := top + int(t * t * 3.0)
		var bottom := surf + int((1.0 - t * t) * 12.0) + 3
		for y in range(surf, bottom + 1):
			var k := y - surf
			var tile := TileDefs.GRASS if k == 0 else (TileDefs.DIRT if k < 5 else TileDefs.STONE)
			if cloud:
				tile = 52                                   # la nuvola (`cielo_nubi`)
			elif id == "bottega" and k > 0:
				tile = TileDefs.STONE
			w.set_tile(x, y, tile)
			if k > 0 and not cloud:
				w.walls[y * w.w + x] = TileDefs.WALL_DIRT if k < 5 else TileDefs.WALL_STONE
		w.surface[x] = mini(int(w.surface[x]), surf)
	# le cose di ogni isola
	match id:
		"orto":
			for x in range(cx - 3, cx + 4):
				w.set_tile(x, top, TileDefs.AIR)
				w.set_tile(x, top + 1, TileDefs.AIR)
				w.set_liq(x, top + 1, 8, LiquidsData.ACQUA)
				w.set_liq(x, top, 6, LiquidsData.ACQUA)
		"bestie":
			w.stations[Vector2i(cx - 8, top - int(StationsData.STATIONS["recinto"]["size"][1]))] = "recinto"
			w.stations[Vector2i(cx + 6, top - int(StationsData.STATIONS["incubatrice"]["size"][1]))] = "incubatrice"
	# la strada: un ponte di passerelle dall'isola grande, o una corrente che sale da sotto
	if String(d["bridge"]) == "passerelle":
		var from := c.x + (-95 if int(d["dx"]) < 0 else 95)
		var to := cx + (half if int(d["dx"]) < 0 else -half)
		for x in range(mini(from, to), maxi(from, to) + 1):
			if not w.solid(x, top - 1):
				w.set_plat(x, top - 1, true)
	else:
		var cur := {"x": cx - half - 3 if int(d["dx"]) < 0 else cx + half + 3, "w": 2, "y0": top - 6, "y1": c.y - 1}
		if not m.world_meta.has("correnti"):
			m.world_meta["correnti"] = []
		m.world_meta["correnti"].append(cur)
		if m.get("gravity") != null:
			m.gravity.currents = m.world_meta["correnti"]
	built()[id] = {"x": cx, "y": top, "half": half, "giorno": -1}
	m.view.refresh_rect(Rect2i(cx - half - 2, top - 16, half * 2 + 5, 36))
	m.view.refresh_rect(Rect2i(mini(c.x, cx) - half, mini(top, c.y) - 4, absi(cx - c.x) + half * 2, 8))
	for o in w.stations:
		if Rect2i(cx - half, top - 4, half * 2, 6).has_point(o):
			m.view.add_station(o)
	m.light.dirty = true
	m.sfx.play("portale")
	m.hud.toast("Il Giardino cresce: %s. %s" % [String(d["name"]), String(d["desc"]).capitalize()])
	m.objectives.bump("isole")


## Le colture sull'isola dell'orto crescono di più (per `Garden.grow`).
func grow_at(c: Vector2i) -> float:
	var e: Variant = built().get("orto", null) if m.world_meta.has("isole") else null
	if e == null:
		return 1.0
	return GardenIslandsData.ORTO_GROW if absi(c.x - int(e["x"])) <= int(e["half"]) and absi(c.y - int(e["y"])) <= 12 else 1.0


## Una volta al giorno (del Giardino): la creatura mansueta, la miniera viva, la polvere di stelle di notte.
func _daily() -> void:
	var day := int(m.day.day) if m.get("day") != null else 0
	var night: bool = m.day.is_night() if m.get("day") != null else false
	for id in built():
		var e: Dictionary = built()[id]
		match id:
			"bestie":
				if int(e.get("giorno", -1)) != day:
					e["giorno"] = day
					_beast(e)
			"bottega":
				if int(e.get("giorno", -1)) != day:
					e["giorno"] = day
					_mine(e)
			"cielo":
				if night and int(e.get("notte", -1)) != day:
					e["notte"] = day
					var at := Vector2(int(e["x"]), int(e["y"]) - 2) * 16.0
					m.drops.spawn("polvere_stelle", GardenIslandsData.STARS_PER_NIGHT, at)


func _beast(e: Dictionary) -> void:
	var fams := HerdData.TAME.keys()
	if fams.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var fam := String(fams[rng.randi_range(0, fams.size() - 1)])
	var members: Array = FamiliesData.FAMILIES.get(fam, {}).get("members", [])
	if members.is_empty():
		return
	var at := Vector2(int(e["x"]) + rng.randi_range(-8, 8), int(e["y"]) - 2) * 16.0
	var c: Creature = m.fauna.add(String(members[0]), at)
	c.docile = true


func _mine(e: Dictionary) -> void:
	var w: World = m.world
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var cx := int(e["x"])
	var top := int(e["y"])
	var half := int(e["half"])
	for v in GardenIslandsData.MINE:
		var tile: int = int(v[0])
		for k in int(v[1]):
			var x := cx + rng.randi_range(-half + 3, half - 3)
			var y := top + rng.randi_range(2, 9)
			if w.tile(x, y) == TileDefs.STONE:
				w.set_tile(x, y, tile)
	m.view.refresh_rect(Rect2i(cx - half, top, half * 2 + 1, 16))
