class_name TestsBackdrop
extends RefCounted
## Le foto fisse degli sfondi (gruppo `sfondi`, Roadmap 34 «Gli sfondi»): la superficie di ogni bioma del mondo di prova a
## mezzogiorno, senza HUD né schede, dal centro della sua prima striscia larga almeno 60 colonne; più una notte e una
## pioggia nella foresta della partenza. Foto in prove/sfondi/ (il foglio: `python tools/foglio_volto.py prove/sfondi
## prove/sfondi_foglio.png`, che prende le prime nove; `tools/foglio_sfondi.py` per tutte).

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/sfondi"))
	m.fauna.clear()
	var hud0: bool = m.hud.visible
	m.hud.visible = false
	var tips0: Variant = Settings.values.get("tip_attivi", true)
	Settings.values["tip_attivi"] = false
	var done := {}
	var x := 40
	while x < world.w - 40:
		var b := int(world.biomes[x])
		var x1 := x
		while x1 < world.w - 1 and int(world.biomes[x1]) == b:
			x1 += 1
		var id := String(BiomesData.BIOMES[b]["id"])
		if x1 - x >= 60 and not done.has(id):
			done[id] = true
			var cx := (x + x1) / 2
			await _shot(cx, id)
			if id in SkyLife.EMBERS:
				print("sfondi: %d faville lontane nel bioma %s" % [int(m.background.life.count()["faville"]), id])
		x = x1 + 1
	# voce 331: uno stormo di giorno e i pipistrelli al tramonto, alla partenza
	var life: SkyLife = m.background.life
	m.snap_to(world.spawn)                 # lo stormo nasce dove guarda la visuale: prima ci si sposta
	await kit.frames(2)
	life.flock(true)
	await _shot(world.spawn.x, "zz_stormo")
	var t0: float = m.day.time
	m.day.time = 0.8
	m.day.apply(true)
	await kit.frames(2)
	life.bats(true)
	await _shot(world.spawn.x, "zz_pipistrelli")
	var n: Dictionary = life.count()
	print("sfondi: in cielo %d uccelli e %d pipistrelli" % [n["uccelli"], n["pipistrelli"]] if n["uccelli"] > 0 and n["pipistrelli"] > 0
		else "ATTENZIONE: stormo o pipistrelli mancanti (%s)" % str(n))
	# la notte e la pioggia, alla partenza
	m.day.time = 0.92
	m.day.apply(true)
	await _shot(world.spawn.x, "zz_notte")
	if m.get("weather") != null:
		var wn: String = m.weather.id
		m.weather.set_weather("pioggia")
		m.background.clouds.snap()
		await _shot(world.spawn.x, "zz_notte_pioggia")
		m.weather.set_weather(wn)
	m.day.time = t0
	m.day.apply(true)
	if m.get("weather") != null:
		var w0: String = m.weather.id
		# voce 330: le nuvole di ogni tempo
		for wid in ["pioggia", "temporale", "nebbia", "bufera", "cenere"]:
			m.weather.set_weather(wid)
			m.background.clouds.snap()
			await _shot(world.spawn.x, "zz_" + wid)
		m.weather.set_weather(w0)
		m.background.clouds.snap()
	# voce 330: le nuvole scorrono (anche senza vento)
	var cl: Dictionary = m.background.clouds.layers[1]
	var d0: float = cl["drift"]
	await kit.seconds(1.0)
	var moved := absf(float(cl["drift"]) - d0)
	print("sfondi: le nuvole scorrono di %.1f px al secondo" % moved if moved > 0.5 else "ATTENZIONE: le nuvole sono ferme")
	await _garden()
	m.hud.visible = hud0
	Settings.values["tip_attivi"] = tips0
	m.snap_to(world.spawn)
	print("sfondi: %d biomi fotografati in prove/sfondi/ (%s)" % [done.size(), ", ".join(done.keys())])


## Lo sfondo del Giardino (sospeso nel Vuoto), acceso nel mondo di prova: di giorno, di notte, e quanto scorre sullo
## schermo con un salto (2 ott 2026, l'utente: «quando salto lo sfondo si muove in verticale con me»).
func _garden() -> void:
	var bg: Background = m.background
	bg.set_void(true)
	if bg.garden != null:
		bg.garden.snap()
	var t0: float = m.day.time
	await _shot(world.spawn.x, "zz_giardino_giorno")
	var jump := 54.0                                  # un salto pieno (3,4 tessere)
	var cam: Camera2D = m.cam
	var view: Vector2 = m.get_viewport_rect().size / cam.zoom
	var cp := cam.get_screen_center_position()
	var moved := []
	for node in _garden_nodes(bg):
		bg.follow(cp, view, 0.0, true)
		var y0: float = (node as Node2D).global_position.y - cp.y
		bg.follow(cp + Vector2(0, -jump), view, 0.0, true)
		var y1: float = (node as Node2D).global_position.y - (cp.y - jump)
		moved.append(absf(y1 - y0))
	bg.follow(cp, view, 0.0, true)
	var most := 0.0
	for v in moved:
		most = maxf(most, float(v))
	print("sfondo del Giardino: con un salto di %d px i piani scorrono sullo schermo di %s px (il più lento %.0f)" % [
		int(jump), str(moved.map(func(v: float) -> int: return roundi(v))), moved.min() if not moved.is_empty() else 0.0])
	m.day.time = 0.92
	m.day.apply(true)
	await _shot(world.spawn.x, "zz_giardino_notte")
	m.day.time = t0
	m.day.apply(true)
	bg.set_void(false)


## I piani che si vedono nel Giardino (quelli del Giardino se ci sono, altrimenti le radici del cosmo).
func _garden_nodes(bg: Background) -> Array:
	if bg.get("garden") != null and bg.garden != null:
		return bg.garden.nodes()
	return [bg._layers[0]["node"]]


func _shot(cx: int, name: String) -> void:
	var c := kit.floor_near(Vector2i(cx, world.surface[cx] - 1), 12)
	if c.x < 0:
		c = Vector2i(cx, world.surface[cx] - 1)
	m.snap_to(c)
	m.light.dirty = true
	await kit.seconds(1.2)
	if m.get("zone_grade") != null:
		m.zone_grade.snap()
	await kit.frames(2)
	await kit.save("sfondi/" + name)
