class_name Chiome
extends Node
## Le Chiome del cielo in partita (Roadmap 16): le zone del cielo (`World.sky`, fatte da `PassCielo`) si salvano in
## `world_meta["cielo"]` e si rimettono nel mondo a ogni ingresso; entrando in un bioma del cielo compare la sua scritta
## (come gli strati, `DepthWatch.banner`); `stats["cielo_max"]` ricorda la fascia più alta raggiunta (1 basso, 2 medio, 3 alto: voce 442)
## per i consigli, il filo e gli obiettivi; `stats["cielo_<bioma>"]` = 1 per ogni bioma del cielo visto.
## Voce 157: il **Fagiolo di nuvola** (`plant_bean`): piantato a terra fa salire una liana di passerelle
## (`world_meta["fagioli"]`: [x, riga della cima, passerelle che mancano], cresce anche lontano, `grow_beans`).

const EVERY := 0.25

var m: Node2D
var here := ""                         # il bioma del cielo dove si trova il Germogliato ("" = non in cielo)
var _t := 0.0
var _bean_t := 0.0
var _bolt_t := 6.0
var _gust_t := 7.0
var _rained := false
var bolts := 0                         # (prove) i fulmini da soli dei Nidi di tempesta
var gusts := 0                         # (prove) le raffiche dei Giardini del vento
var extra_dark := 0.0                  # voce 162: l'Occhio della Tempesta in furia oscura il cielo (`GreatGuardians`)


func setup(main: Node2D) -> void:
	m = main
	if m.world.sky.is_empty() and m.world_meta.has("cielo"):
		m.world.sky = (m.world_meta["cielo"] as Array).duplicate(true)
	elif not m.world.sky.is_empty():
		m.world_meta["cielo"] = m.world.sky.duplicate(true)


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	# il Firmamento: la notte anche di giorno (si sfuma entrando e uscendo)
	var dark := float(SkyData.get_biome(here).get("dark", 0.0)) if here != "" else 0.0
	dark = maxf(dark, extra_dark)
	if absf(m.day.high_dark - dark) > 0.001:
		m.day.high_dark = move_toward(m.day.high_dark, dark, dt * 0.6)
		m.day.apply()
	_sky_weather(dt)
	_bean_t += dt
	if _bean_t >= SkyData.BEAN_EVERY:
		_bean_t = 0.0
		grow_beans()
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	var c: Vector2i = m.player_cell()
	var id := SkyData.zone_at(m.world, c.x, c.y)
	# un piccolo margine sul confine: si cambia solo se anche 4 tessere più in là è lo stesso
	if id != here and SkyData.zone_at(m.world, c.x, c.y + (4 if id != "" else -4)) != here:
		here = id
		if id != "":
			var b := SkyData.get_biome(id)
			var band := String(b["band"])
			m.depth_watch.banner.show_stratum(String(b["name"]), String(b["desc"]), Color(String(b["color"])))
			var st: Dictionary = m.character.stats
			st["cielo_max"] = maxi(int(st.get("cielo_max", 0)), SkyData.band_level(band))
			st["cielo_" + id] = 1                   # le statistiche sono solo numeri (il salvataggio le rilegge con int)


## Pianta un Fagiolo di nuvola sopra la cella c (d'aria, con la terra sotto e un po' di cielo libero sopra).
func plant_bean(c: Vector2i, id: String) -> bool:
	var w: World = m.world
	if not m.actions.in_reach(c) or not w.inside(c.x, c.y) or w.solid(c.x, c.y) or not w.solid(c.x, c.y + 1):
		return false
	for dy in range(1, 7):
		if w.solid(c.x, c.y - dy):
			m.hud.toast("Il Fagiolo vuole il cielo libero sopra di sé")
			return false
	if not m.character.bisaccia.remove(id, 1):
		return false
	var beans: Array = m.world_meta.get("fagioli", [])
	beans.append([c.x, c.y + 1, SkyData.BEAN_H / SkyData.BEAN_STEP])
	m.world_meta["fagioli"] = beans
	w.set_decor(c.x, c.y, 81)                     # il germoglio: un bulbo di cielo
	m.view.refresh_around(c)
	m.hud.toast("Il Fagiolo di nuvola mette radici: la liana salirà verso il cielo")
	return true


## Una passerella in più per ogni liana che cresce (si fermano contro la roccia o al bordo del mondo).
func grow_beans() -> void:
	var beans: Array = m.world_meta.get("fagioli", [])
	if beans.is_empty():
		return
	var w: World = m.world
	var keep := []
	for b in beans:
		var x := int(b[0])
		var y := int(b[1]) - SkyData.BEAN_STEP
		var left := int(b[2]) - 1
		if y < 3 or w.solid(x, y) or w.solid(x, y - 1):
			continue
		w.set_plat(x, y, true)
		if w.decor_at(x - 1, y) == 0 and not w.solid(x - 1, y):
			w.set_decor(x - 1, y, 80 if (y / 3) % 2 == 0 else 0)
		m.view.refresh_around(Vector2i(x, y))
		if left > 0:
			keep.append([x, y, left])
	m.world_meta["fagioli"] = keep


## Voce 164: il tempo del cielo. Nei Nidi di tempesta i fulmini cadono da soli attorno al Germogliato (annunciati come
## quelli delle creature); nei Giardini del vento ogni tanto una raffica spinge; quando smette di piovere, a volte,
## l'arcobaleno (un evento: le creature rare del cielo).
func _sky_weather(dt: float) -> void:
	var w_state: Dictionary = m.weather.state() if m.weather != null else {}
	var raining := float(w_state.get("rain", 0.0)) > 0.0
	if _rained and not raining and m.events.active == "" and not m.events.paused and randf() < 0.5:
		m.events.start("arcobaleno")
	_rained = raining
	if here == "":
		return
	var b := SkyData.get_biome(here)
	if b.has("bolts") and not m.weather.roofed:
		_bolt_t -= dt
		if _bolt_t <= 0.0:
			_bolt_t = randf_range(6.0, 12.0)
			bolts += 1
			m.strikes.bolt(m.player.position.x + randf_range(-90.0, 90.0), 1.3, 14)
	if b.has("gusts"):
		_gust_t -= dt
		if _gust_t <= 0.0:
			_gust_t = randf_range(7.0, 12.0)
			gusts += 1
			var dir := -1.0 if randf() < 0.5 else 1.0
			m.player.vel.x += dir * 190.0
			m.player.vel.y = minf(m.player.vel.y, -70.0)
			Fx.puff(m.fx, m.player.position + Vector2(-dir * 20.0, 0), Color(1.4, 1.5, 1.2))
			m.sfx.play("soffio", m.player.position)

