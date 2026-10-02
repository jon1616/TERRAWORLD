class_name TestsAtmosphere
extends RefCounted
## Le foto fisse dell'atmosfera (gruppo `atmosfera`, Roadmap 35): sempre le stesse scene, per confrontare prima e dopo.
## Foto in prove/atmosfera/ (senza HUD né schede), la partenza in prove/atmosfera_prima/:
##   a01 grotta con le torce · a02 un blocco di roccia che si rompe · a03 un minerale che si rompe · a04 un colpo di
##   brace · a05 una creatura sconfitta · a06 uno specchio d'acqua · a07 lo stesso con la pioggia · a08 il Germogliato
##   che ci entra · a09 la bufera in un bioma freddo · a10 dopo la pioggia · a11 il tramonto in un prato · a12 un fulmine
## Le scene si cercano con le stesse regole a ogni giro (stesso mondo di prova, stesse scene).

const S := 16

var kit: TestKit
var world: World
var m: Node2D
var look: TestsLook


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m
	look = TestsLook.new(tk)


func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/atmosfera"))
	m.fauna.clear()
	var hud0: bool = m.hud.visible
	m.hud.visible = false
	var tips0: Variant = Settings.values.get("tip_attivi", true)
	Settings.values["tip_attivi"] = false
	var t0: float = m.day.time
	var w0: String = m.weather.id
	# a01-a05 nella grotta delle Caverne
	var cave := look._cave_in(2)
	if cave.x < 0:
		print("ATTENZIONE: nessuna grotta per le foto dell'atmosfera")
	else:
		for dx in [-7, 7]:
			var f := kit.floor_near(cave + Vector2i(dx, 0), 3)
			if f.x >= 0:
				look._torch(f)
		m.snap_to(cave)
		await _shot("a01_grotta_torce")
		var rock := _solid_near(cave, false)
		if rock.x >= 0:
			m.actions.break_tile(rock)
			await kit.seconds(0.07)
			await kit.save("atmosfera/a02_scavo_roccia")
		var ore := _solid_near(cave, true)
		if ore.x >= 0:
			m.snap_to(kit.floor_near(ore, 6) if kit.floor_near(ore, 6).x >= 0 else cave)
			await kit.seconds(0.6)
			m.actions.break_tile(ore)
			await kit.seconds(0.07)
			await kit.save("atmosfera/a03_scavo_minerale")
		else:
			print("ATTENZIONE: nessun minerale vicino alla grotta delle foto")
		m.snap_to(cave)
		await kit.seconds(0.5)
		var at := kit.floor_near(cave + Vector2i(4, 0), 3)
		if at.x >= 0:
			var cr: Creature = m.fauna.add("grumo_muschio", Vector2(at.x * S + 8, (at.y + 1) * S - float(CreaturesData.get_data("grumo_muschio")["half"][1]) - 0.1))
			cr.docile = true
			cr.damage = 0
			cr.hp = 9999
			await kit.seconds(0.3)
			m.combat._strike(cr, 3, m.player.position.x, 0.2, "brace")
			await kit.seconds(0.06)
			await kit.save("atmosfera/a04_colpo_brace")
			cr.hp = 1
			m.fauna.kill(cr)
			await kit.seconds(0.12)
			await kit.save("atmosfera/a05_sconfitta")
		m.fauna.clear()
	# a06-a08 uno specchio d'acqua
	var pond := _water()
	if pond.x < 0:
		print("ATTENZIONE: nessuno specchio d'acqua per le foto dell'atmosfera")
	else:
		var stand := kit.floor_near(pond + Vector2i(-4, -1), 8)
		m.snap_to(stand if stand.x >= 0 else pond + Vector2i(0, -2))
		await _shot("a06_acqua")
		m.weather.set_weather("pioggia")
		await _shot("a07_acqua_pioggia", 2.0)
		if m.get("water_fx") != null:
			var n: Dictionary = m.water_fx.counts()
			print("acqua: %d celle di superficie in vista, %d increspature sotto la pioggia" % [n["superfici"], n["increspature"]])
			if n["increspature"] == 0:
				print("ATTENZIONE: la pioggia non increspa l'acqua")
		m.weather.set_weather("sereno")
		m.snap_to(pond + Vector2i(0, -3))
		await kit.seconds(0.4)
		await kit.save("atmosfera/a08_tuffo")
		await kit.seconds(0.8)
	# a09 la bufera in un bioma freddo
	var cold := _biome_x(["brina", "ghiacciaio"])
	if cold >= 0:
		m.snap_to(kit.floor_near(Vector2i(cold, world.surface[cold] - 1), 10))
		m.weather.set_weather("bufera")
		await _settle()
		await _shot("a09_bufera", 1.5)
	else:
		print("ATTENZIONE: nessun bioma freddo per la foto della bufera")
	# a10 dopo la pioggia, alla partenza
	m.snap_to(world.spawn)
	m.weather.set_weather("pioggia")
	await _settle()
	m.weather.set_weather("sereno")
	await _shot("a10_dopo_pioggia")
	# a11 il tramonto in un prato
	var meadow := _biome_x(["prati", "foresta"])
	if meadow >= 0:
		m.snap_to(kit.floor_near(Vector2i(meadow, world.surface[meadow] - 1), 10))
		m.day.time = 0.8
		m.day.apply(true)
		await _shot("a11_tramonto_prato", 2.5)
		m.day.time = t0
		m.day.apply(true)
	# a12 un fulmine
	m.snap_to(world.spawn)
	m.weather.set_weather("temporale")
	await kit.seconds(0.8)
	m.weather.strike()
	await kit.seconds(0.05)
	await kit.save("atmosfera/a12_fulmine")
	await kit.seconds(1.0)
	m.weather.set_weather(w0)
	await _settle()
	m.hud.visible = hud0
	Settings.values["tip_attivi"] = tips0
	m.snap_to(world.spawn)
	print("atmosfera: foto delle scene fisse in prove/atmosfera/")


func _shot(name: String, wait := 1.0) -> void:
	m.light.dirty = true
	await kit.seconds(wait)
	m.zone_grade.snap()
	if m.background.get("clouds") != null:
		m.background.clouds.snap()
	await kit.frames(2)
	await kit.save("atmosfera/" + name)


## Il tempo che si posa (voce 337) arriva subito, non dopo minuti di bufera o di pioggia.
func _settle() -> void:
	if m.get("weather_cover") != null:
		m.weather_cover.snap()
	await kit.frames(2)


## Un blocco pieno vicino alla cella `c` che tocca l'aria (`ore` = un minerale o un cristallo).
func _solid_near(c: Vector2i, ore: bool) -> Vector2i:
	for r in range(1, 20):
		for dy in range(-r, r + 1):
			for dx in [-r, r]:
				var q := c + Vector2i(dx, dy)
				if not world.inside(q.x, q.y) or not world.solid(q.x, q.y):
					continue
				var t := world.tile(q.x, q.y)
				var is_ore := t == TileDefs.CRYSTAL
				for o in TileDefs.ORES:
					if int(o["type"]) == t:
						is_ore = true
				if is_ore != ore or not TileDefs.DROP.has(t):
					continue
				if not world.solid(q.x - 1, q.y) or not world.solid(q.x + 1, q.y) or not world.solid(q.x, q.y - 1):
					return q
	return Vector2i(-1, -1)


## La superficie di uno specchio d'acqua (almeno 6 celle d'acqua in fila sotto l'aria), la più vicina alla partenza.
func _water() -> Vector2i:
	for r in range(0, 1400, 2):
		for side in [1, -1]:
			var x: int = world.spawn.x + r * side
			if x < 10 or x >= world.w - 10:
				continue
			for y in range(maxi(world.surface[x] - 30, 1), mini(world.surface[x] + 12, world.h - 1)):
				if world.liq(x, y) <= 0 or world.liq(x, y - 1) > 0 or world.solid(x, y - 1):
					continue
				var run := 0
				while run < 6 and world.liq(x + run, y) > 0:
					run += 1
				if run >= 6:
					return Vector2i(x + 3, y)
	return Vector2i(-1, -1)


## Il centro della prima striscia larga di uno dei biomi dati.
func _biome_x(ids: Array) -> int:
	var x := 40
	while x < world.w - 40:
		var b := int(world.biomes[x])
		var x1 := x
		while x1 < world.w - 1 and int(world.biomes[x1]) == b:
			x1 += 1
		if x1 - x >= 60 and String(BiomesData.BIOMES[b]["id"]) in ids:
			return (x + x1) / 2
		x = x1 + 1
	return -1
