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
		x = x1 + 1
	# la notte e la pioggia, alla partenza
	var t0: float = m.day.time
	m.day.time = 0.92
	m.day.apply(true)
	await _shot(world.spawn.x, "zz_notte")
	m.day.time = t0
	m.day.apply(true)
	if m.get("weather") != null:
		var w0: String = m.weather.id
		m.weather.set_weather("pioggia")
		await _shot(world.spawn.x, "zz_pioggia")
		m.weather.set_weather(w0)
	m.hud.visible = hud0
	Settings.values["tip_attivi"] = tips0
	m.snap_to(world.spawn)
	print("sfondi: %d biomi fotografati in prove/sfondi/ (%s)" % [done.size(), ", ".join(done.keys())])


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
