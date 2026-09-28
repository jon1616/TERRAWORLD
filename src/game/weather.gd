class_name Weather
extends Node
## Il tempo atmosferico (voce 75, dati in `WeatherData`): ogni `CHANGE` secondi il mondo sceglie un tempo secondo la
## stagione, i biomi e i geni (Piovoso, Ventoso, Nebbioso); lo stato è in `world_meta["meteo"]`. Vale in superficie:
##   il vento spinge chi è in aria (di più planando: `Player.wind`) e devia i dardi e gli incantesimi (`Projectiles.wind`);
##   la pioggia versa acqua nelle conche vicine e fa crescere l'orto (`Garden.weather_mult`);
##   la nebbia vela il mondo e accorcia la vista delle creature (`Behavior.fog`);
##   i fulmini del temporale feriscono chi è vicino e lasciano la Fulgorite;
##   la cenere ferisce chi è allo scoperto; la bufera rallenta la corsa.
## Gocce, fiocchi e cenere sono particelle attaccate alla visuale; la nebbia un velo sotto la luce.

var m: Node2D
var id := "sereno"
var wind := 0.0                         # px/s², con il segno (verso destra se positivo)
var wind_mult := 1.0                    # accessori (Mantello del vento)
var _t := 0.0
var _goal_wind := 0.0
var _bolt := 6.0
var _puddle := 0.0
var _ash := 0.0
var _rng := RandomNumberGenerator.new()
var _parts: CPUParticles2D
var _fog: ColorRect
var paused := false                     # le prove lo fermano o lo scelgono
var _tex := {}
var roofed := false                     # voce 76: il Guscio ha un tetto di roccia, sotto non piove


static func _drop_tex(sz: Vector2i, c: Color) -> Texture2D:
	var im := Image.create_empty(sz.x, sz.y, false, Image.FORMAT_RGBA8)
	im.fill(c)
	return ImageTexture.create_from_image(im)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	var st: Dictionary = m.world_meta.get("meteo", {})
	id = String(st.get("id", "sereno"))
	CreaturesData.now_weather = id                 # voce 134
	roofed = bool(Genome.effects(m.world_meta.get("geni", []), "run").get("roof", false))
	_t = float(st.get("t", WeatherData.CHANGE))
	_parts = CPUParticles2D.new()
	_parts.z_as_relative = false
	_parts.z_index = 19                   # sotto la luce: di notte le gocce sono buie come tutto il resto
	_parts.amount = 260
	_parts.lifetime = 1.4
	_parts.emitting = false
	m.fx.add_child(_parts)
	_tex = {"rain": _drop_tex(Vector2i(2, 9), Color(0.75, 0.85, 1.0, 0.8)), "snow": _drop_tex(Vector2i(3, 3), Color(1, 1, 1, 0.95)),
		"ash": _drop_tex(Vector2i(3, 2), Color(0.5, 0.42, 0.4, 0.9))}
	_fog = ColorRect.new()
	_fog.color = Color(0.75, 0.8, 0.8, 0.0)
	_fog.z_as_relative = false
	_fog.z_index = 19
	_fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.fx.add_child(_fog)
	apply()


## Il tempo di questo mondo, adesso (solo per chi è in superficie).
func state() -> Dictionary:
	return WeatherData.STATES.get(id, WeatherData.STATES["sereno"])


func outdoor() -> bool:
	return not m.giardino.active and m.depth_watch.stratum == 0 and not roofed


## Sceglie il tempo che viene: stagione, biomi e geni.
func choose() -> String:
	var season: int = maxi(m.seasons.current, 0) if m.seasons != null else 0
	var run := Genome.effects(m.world_meta.get("geni", []), "run")
	var pool := []
	for k in WeatherData.STATES:
		var wgt := float(WeatherData.STATES[k]["weights"][season])
		match String(k):
			"pioggia", "temporale":
				wgt *= float(run.get("rain", 1.0))
			"nebbia":
				wgt *= float(run.get("fog", 1.0))
			"bufera":
				wgt *= float(run.get("wind", 1.0))
		wgt *= _biome_weather(String(k))             # voce 91: i tempi che portano i biomi del mondo
		if wgt > 0.0:
			pool.append([k, wgt])
	var tot := 0.0
	for e in pool:
		tot += float(e[1])
	var r := _rng.randf() * tot
	for e in pool:
		r -= float(e[1])
		if r <= 0.0:
			return String(e[0])
	return "sereno"


## Quanto i biomi del mondo rendono probabile un tempo: il loro moltiplicatore se ci sono; se il tempo è di un bioma
## che il mondo non ha, quello di `WeatherData` («senza_bioma»).
func _biome_weather(k: String) -> float:
	var own := false
	var out := 1.0
	for b in BiomesData.BIOMES:
		var bw: Dictionary = b.get("weather", {})
		if bw.has(k):
			own = true
			if _has_biome(String(b["id"])):
				out *= float(bw[k])
	if own and out == 1.0:
		return float(WeatherData.STATES[k].get("senza_bioma", 1.0))
	return out


func _has_biome(b: String) -> bool:
	var w: World = m.world
	for x in range(0, w.w, 50):
		if String(BiomesData.BIOMES[w.biomes[x]]["id"]) == b:
			return true
	return false


## Mette un tempo (anche dalle prove) e ne sceglie il vento.
func set_weather(new_id: String) -> void:
	id = new_id
	CreaturesData.now_weather = id                 # voce 134
	var wr: Array = state()["wind"]
	var run := Genome.effects(m.world_meta.get("geni", []), "run")
	_goal_wind = _rng.randf_range(float(wr[0]), float(wr[1])) * float(run.get("wind", 1.0)) * (1.0 if _rng.randf() < 0.5 else -1.0)
	m.world_meta["meteo"] = {"id": id, "t": _t}
	apply()


func apply() -> void:
	var st := state()
	var out := outdoor()
	m.garden.weather_mult = float(st.get("grow", 1.0)) if out else 1.0
	Behavior.fog = float(st.get("sight", 1.0)) if out else 1.0
	m.player.weather_run = float(st.get("slow", 1.0)) if out else 1.0
	m.background.weather_tint = (st["tint"] as Color) if out else Color.WHITE


func _process(dt: float) -> void:
	if not m.built:
		return
	if not paused:
		_t -= dt
		if _t <= 0.0:
			_t = WeatherData.CHANGE
			set_weather(choose())
	var st := state()
	var out := outdoor()
	wind = move_toward(wind, _goal_wind, 40.0 * dt)
	m.player.wind = wind * wind_mult if out else 0.0
	Projectiles.wind = wind if out else 0.0
	apply()
	_visuals(st, out)
	if not out:
		return
	if st.get("rain", 0.0) > 0.0:
		_puddle -= dt
		if _puddle <= 0.0:
			_puddle = WeatherData.PUDDLE_EVERY / float(st["rain"])
			_rain_drop()
	if st.get("storm", false):
		_bolt -= dt
		if _bolt <= 0.0:
			_bolt = _rng.randf_range(WeatherData.BOLT_EVERY[0], WeatherData.BOLT_EVERY[1])
			strike()
	if st.get("ash", 0.0) > 0.0:
		_ash += dt
		if _ash >= 2.0:
			_ash = 0.0
			var pc: Vector2i = m.player_cell()
			if m.world.wall(pc.x, pc.y) == 0:          # allo scoperto: niente parete dietro
				m.vitals.hurt(WeatherData.ASH_DAMAGE)


## La pioggia: un po' d'acqua sulla superficie vicina (le conche si riempiono).
func _rain_drop() -> void:
	var w: World = m.world
	var x: int = clampi(m.player_cell().x + _rng.randi_range(-50, 50), 1, w.w - 2)
	var y := 0
	while y < w.h - 1 and not w.solid(x, y + 1):
		y += 1
	if w.liq(x, y) < 8 and not w.solid(x, y) and w.wall(x, y) == 0:
		m.liquids.pour(Vector2i(x, y), 2, LiquidsData.ACQUA)


## Un fulmine su una colonna vicina: lampo, ferita a chi è vicino, a volte la Fulgorite.
func strike() -> Vector2i:
	var w: World = m.world
	var x: int = clampi(m.player_cell().x + _rng.randi_range(-40, 40), 1, w.w - 2)
	var y := 0
	while y < w.h - 1 and not w.solid(x, y + 1):
		y += 1
	var c := Vector2i(x, y)
	m.life.flash(Color(1, 1, 1, 0.35), 0.25)
	m.sfx.play("scoppio", Vector2(c) * 16.0)
	Fx.puff(m.fx, Vector2(c) * 16.0 + Vector2(8, 8), Color(1.8, 1.8, 2.2))
	if Vector2(m.player_cell() - c).length() <= WeatherData.BOLT_RANGE:
		m.vitals.hurt(WeatherData.BOLT_DAMAGE)
	for cr in m.fauna.list:
		if is_instance_valid(cr) and cr.position.distance_to(Vector2(c) * 16.0) < WeatherData.BOLT_RANGE * 16.0:
			cr.take_hit(WeatherData.BOLT_DAMAGE, float(x * 16), 120.0)
	if _rng.randf() < 0.35:
		m.drops.spawn("fulgorite", 1, Vector2(c) * 16.0 + Vector2(8, 0))
	return c


## Gocce, fiocchi, cenere e nebbia attorno alla visuale.
func _visuals(st: Dictionary, out: bool) -> void:
	var cam: Camera2D = m.cam
	var view: Vector2 = m.get_viewport_rect().size / cam.zoom
	var ctr := cam.get_screen_center_position()
	var rain := float(st.get("rain", 0.0))
	var snow := float(st.get("snow", 0.0))
	var ash := float(st.get("ash", 0.0))
	var on := out and (rain > 0.0 or snow > 0.0 or ash > 0.0)
	_parts.emitting = on
	if on:
		_parts.position = ctr - Vector2(0, view.y * 0.6)
		_parts.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		_parts.emission_rect_extents = Vector2(view.x * 0.7, 4)
		var fall := 420.0 if rain > 0.0 else (60.0 if snow > 0.0 else 110.0)
		_parts.direction = Vector2(wind * 0.004, 1).normalized()
		_parts.initial_velocity_min = fall * 0.8
		_parts.initial_velocity_max = fall
		_parts.gravity = Vector2(wind * 0.5, 0)
		_parts.lifetime = view.y * 1.3 / fall
		_parts.texture = _tex["rain"] if rain > 0.0 else (_tex["snow"] if snow > 0.0 else _tex["ash"])
		_parts.scale_amount_min = 1.0
		_parts.scale_amount_max = 1.0 if rain > 0.0 else 1.6
		_parts.particle_flag_align_y = rain > 0.0          # le gocce seguono la direzione in cui cadono
		_parts.color = Color.WHITE
	var fog := float(st.get("fog", 0.0)) if out else 0.0
	_fog.color.a = move_toward(_fog.color.a, fog, 0.01)
	_fog.visible = _fog.color.a > 0.005
	if _fog.visible:
		_fog.color = Color(0.72, 0.78, 0.78, _fog.color.a) if ash <= 0.0 else Color(0.6, 0.5, 0.46, _fog.color.a)
		_fog.position = ctr - view * 0.6
		_fog.size = view * 1.2
