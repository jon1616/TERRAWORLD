class_name TestsWeather
extends RefCounted
## Prove del tempo atmosferico (voce 75): il vento spinge chi è in aria e devia i dardi; la pioggia riempie le conche;
## la nebbia accorcia la vista delle creature e vela il mondo; la cenere ferisce allo scoperto; la bufera rallenta; i
## fulmini cadono in superficie; l'orologio dice che tempo fa; le scelte variano. Foto 139-141.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _hop(wind: float) -> float:
	var wt: Weather = m.weather
	wt.wind = wind
	wt._goal_wind = wind
	var p: Player = m.player
	var spot := kit.flat_spot(world.spawn + Vector2i(10, 0), 6)
	if spot.x < 0:
		spot = world.spawn
	m.snap_to(spot)
	await kit.seconds(0.3)
	var x0 := p.position.x
	p.auto_jump = true
	await kit.seconds(0.5)
	p.auto_jump = false
	await kit.seconds(0.3)
	return p.position.x - x0


func run() -> void:
	var wt: Weather = m.weather
	wt.paused = true
	m.snap_to(world.spawn)
	await kit.seconds(0.4)
	var outdoor := wt.outdoor()
	# il vento
	wt.set_weather("temporale")
	var calm: float = await _hop(0.0)
	var windy: float = await _hop(160.0)
	# i dardi deviati
	Projectiles.wind = 160.0
	var pr: Projectiles = m.shots
	var drift := 0.0
	if pr != null:
		pr.fire(m.player.position + Vector2(0, -40), Vector2(0, -150), 0.0, 1, true)
		var node: Node2D = pr._shots[-1]["node"]
		var x0 := node.position.x
		# (l'ultima posizione vista: se il dardo tocca qualcosa sparisce prima della fine)
		var t := 0.0
		while t < 0.4 and is_instance_valid(node):
			drift = node.position.x - x0
			await kit.frames(1)
			t += m.get_process_delta_time()
	wt.wind = 0.0
	wt._goal_wind = 0.0
	# la pioggia riempie le conche vicine
	wt.set_weather("pioggia")
	var before := _water_near()
	for k in 30:
		wt._rain_drop()
	var after := _water_near()
	await kit.seconds(0.6)
	await kit.save("139_pioggia")
	# la nebbia
	wt.set_weather("nebbia")
	await kit.seconds(1.2)
	var fog_sight := Behavior.fog
	var fog_on: bool = wt._fog.visible
	await kit.save("140_nebbia")
	# la cenere, allo scoperto
	wt.set_weather("cenere")
	m.vitals.refill()
	var hp0: int = m.vitals.hp
	await kit.seconds(2.3)
	var ash_hurt: bool = m.vitals.hp < hp0
	# la bufera
	wt.set_weather("bufera")
	await kit.seconds(0.8)
	var slow: float = m.player.weather_run
	var clock: String = m.day.clock_text()
	await kit.save("141_bufera")
	# un fulmine
	wt.set_weather("temporale")
	var bolt := wt.strike()
	# le scelte
	var seen := {}
	for k in 300:
		seen[wt.choose()] = true
	wt.set_weather("sereno")
	wt.wind = 0.0
	wt._goal_wind = 0.0
	Projectiles.wind = 0.0
	m.vitals.refill()
	print("meteo: in superficie %s; salto senza vento %.0f px, con vento %.0f px; dardo deviato %.0f px; pioggia: acqua vicina %d → %d; nebbia: vista ×%.2f, velo %s; cenere ferisce %s; bufera: corsa ×%.2f, orologio «%s»; fulmine in %s; tempi scelti %s" % [
		"sì" if outdoor else "NO", calm, windy, drift, before, after, fog_sight, "sì" if fog_on else "NO", "sì" if ash_hurt else "NO",
		slow, clock, bolt, seen.keys()])
	if not outdoor or absf(windy) < absf(calm) + 8.0 or absf(drift) < 3.0 or after <= before \
			or fog_sight >= 1.0 or not fog_on or not ash_hurt or slow >= 1.0 or not clock.contains("Bufera") or seen.size() < 3:
		print("ATTENZIONE: il tempo atmosferico non funziona come dovrebbe")


func _water_near() -> int:
	var pc: Vector2i = m.player_cell()
	var n := 0
	for y in range(pc.y - 30, pc.y + 30):
		for x in range(pc.x - 55, pc.x + 55):
			n += world.liq(x, y)
	return n
