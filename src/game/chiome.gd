class_name Chiome
extends Node
## Le Chiome del cielo in partita (Roadmap 16): le zone del cielo (`World.sky`, fatte da `PassCielo`) si salvano in
## `world_meta["cielo"]` e si rimettono nel mondo a ogni ingresso; entrando in un bioma del cielo compare la sua scritta
## (come gli strati, `DepthWatch.banner`); `stats["cielo_max"]` ricorda la fascia più alta raggiunta (1 basso, 2 alto)
## per i consigli, il filo e gli obiettivi; `stats["cielo_<bioma>"]` = 1 per ogni bioma del cielo visto.
## Voce 157: il **Fagiolo di nuvola** (`plant_bean`): piantato a terra fa salire una liana di passerelle
## (`world_meta["fagioli"]`: [x, riga della cima, passerelle che mancano], cresce anche lontano, `grow_beans`).

const EVERY := 0.25

var m: Node2D
var here := ""                         # il bioma del cielo dove si trova il Germogliato ("" = non in cielo)
var _t := 0.0
var _bean_t := 0.0
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
			st["cielo_max"] = maxi(int(st.get("cielo_max", 0)), 2 if band == "alto" else 1)
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

