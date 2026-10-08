class_name TestsLook
extends RefCounted
## Le scene fisse della grafica (gruppo `volto`, Roadmap 33 «La luce e la profondità»): sempre le stesse inquadrature,
## per confrontare prima e dopo ogni voce. Foto in prove/volto/ (senza HUD, a mezzogiorno fermo o di notte):
##   01 superficie di giorno · 02 superficie di notte con due torce · 03 un altro bioma
##   04-07 una grotta per strato (Sottobosco, Caverne, Profondità, Fondo) con tre torce
##   08-09 creature da vicino in una grotta illuminata (due foto a un attimo di distanza: si vede chi si muove)
## Le grotte si cercano con le stesse regole a ogni giro (la prima adatta da sinistra a destra attorno alla partenza):
## stesso mondo di prova, stesse scene.

const S := 16

var kit: TestKit
var world: World
var m: Node2D
var _hud := true


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/volto"))
	m.fauna.clear()
	_hud = m.hud.visible
	m.hud.visible = false
	var tips0: Variant = Settings.values.get("tip_attivi", true)
	Settings.values["tip_attivi"] = false            # (nessuna scheda nelle foto)
	var t0: float = m.day.time
	# 01 superficie di giorno
	m.snap_to(world.spawn)
	await _shot("01_superficie_giorno")
	# 02 di notte, con due torce
	m.day.time = 0.92
	m.day.apply(true)
	var sp := world.spawn
	for dx in [-6, 6]:
		var c := kit.floor_near(sp + Vector2i(dx, 0), 4)
		if c.x >= 0:
			_torch(c)
	await _shot("02_superficie_notte")
	m.day.time = t0
	m.day.apply(true)
	# 03 un altro bioma
	var bx := _other_biome()
	m.snap_to(kit.floor_near(Vector2i(bx, world.surface[bx] - 1), 10))
	await _shot("03_altro_bioma")
	# 04-07 una grotta per strato
	var names := ["", "04_sottobosco", "05_caverne", "06_profondita", "07_fondo"]
	var cave := Vector2i(-1, -1)
	for s in range(1, 5):
		var c := _cave_in(s)
		if c.x < 0:
			print("ATTENZIONE: nessuna grotta per la foto dello strato %d" % s)
			continue
		for dx in [-7, 0, 7]:
			var f := kit.floor_near(c + Vector2i(dx, 0), 3)
			if f.x >= 0:
				_torch(f)
		m.snap_to(c)
		await _shot(String(names[s]))
		if s == 2:
			cave = c
			m.overlay.visible = false              # la stessa scena senza luce: la forma vera (per capire, non per giudicare)
			await kit.seconds(0.3)
			await kit.save("volto_forma_caverne")
			m.overlay.visible = true
	# 08-09 creature da vicino
	if cave.x >= 0:
		m.snap_to(cave)
		var ids := ["grumo_muschio", "lupo_lunare", "scarabeo_ardesia", "falena_brace", "sputaspore"]
		for k in ids.size():
			var at := kit.floor_near(cave + Vector2i(-6 + k * 3, 0), 3)
			if at.x < 0:
				continue
			var cr: Creature = m.fauna.add(String(ids[k]), Vector2(at.x * S + 8, (at.y + 1) * S - float(CreaturesData.get_data(String(ids[k]))["half"][1]) - 0.1))
			cr.docile = true
			cr.damage = 0
		await kit.seconds(0.6)
		# voce 325: chi cammina sobbalza e si inclina (si misura il disegno per un secondo)
		var lo := 99.0
		var hi := -99.0
		var tilt := 0.0
		var w0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - w0 < 1000:
			for cr in m.fauna.list:
				# (le creature con le pose di Nano Banana hanno i passi nel disegno: il codice non le muove)
				if absf(cr.vel.x) > 5.0 and cr.on_floor and cr._poses.is_empty():
					lo = minf(lo, cr._spr.position.y - cr._base_y)
					hi = maxf(hi, cr._spr.position.y - cr._base_y)
					tilt = maxf(tilt, absf(cr._spr.rotation))
			await kit.frames(1)
		print("creature vive: sobbalzo %.1f px, inclinazione fino a %.2f" % [maxf(hi - lo, 0.0), tilt])
		if hi - lo < 0.5 or tilt < 0.01:
			print("ATTENZIONE: le creature che camminano non si muovono nel disegno")
		await kit.save("volto/08_creature_a")
		await kit.seconds(0.18)
		await kit.save("volto/09_creature_b")
		m.fauna.clear()
	m.hud.visible = _hud
	Settings.values["tip_attivi"] = tips0
	m.snap_to(world.spawn)
	print("volto: foto delle scene fisse in prove/volto/")


## Una torcia accesa direttamente (la prova la mette prima di portarci il Germogliato: `place_torch` vuole la portata).
func _torch(c: Vector2i) -> void:
	if world.solid(c.x, c.y) or world.torches.has(c):
		return
	world.add_torch(c)
	m.view.refresh_around(c)
	m.view.add_torch(c)
	m.light.dirty = true


func _shot(name: String) -> void:
	m.light.dirty = true
	await kit.seconds(1.0)
	m.zone_grade.snap()                         # (la tinta della zona subito, non a metà della sfumatura)
	await kit.frames(2)
	await kit.save("volto/" + name)


## La prima colonna (andando verso destra dalla partenza) con un bioma diverso da quello della partenza.
func _other_biome() -> int:
	var b0 := world.biomes[world.spawn.x]
	for x in range(world.spawn.x + 80, world.w - 40, 10):
		if world.biomes[x] != b0:
			return x + 30
	return mini(world.spawn.x + 400, world.w - 40)


## Una grotta di uno strato: una cella d'aria con il pavimento sotto e almeno 14×5 tessere d'aria attorno, la più
## vicina alla colonna della partenza.
func _cave_in(stratum: int) -> Vector2i:
	for r in range(0, 900, 6):
		for side in [1, -1]:
			var x: int = world.spawn.x + r * side
			if x < 20 or x >= world.w - 20:
				continue
			for y in range(world.surface[x] + 10, world.h - 10):
				if StrataData.at(world, x, y) != stratum:
					continue
				if world.solid(x, y) or not world.solid(x, y + 1):
					continue
				if _open(x, y):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


func _open(x: int, y: int) -> bool:
	for dx in range(-7, 8):
		for dy in range(-4, 1):
			if world.solid(x + dx, y + dy):
				return false
	return true
