class_name Tides
extends Node
## Le maree del mondo (voce 137, dati in `TidesData`, premi in `src/data/bestiary/maree.gd`). Al calar della notte, al
## sorgere del giorno o quando comincia un'eclissi si tira se arriva una marea; prima si **annuncia** (scritta, segno
## sulla mappa), poi arrivano le **ondate** (la seguente quando la precedente è quasi finita o dopo un po'), poi il
## **capo**; sconfitto il capo, il premio. L'**assedio** nasce attorno alla base e fa rosicchiare le porte
## (`Wiles.siege`); una volta a stagione (`world_meta["assedio"]`), e mai con l'opzione «assedi» spenta.

const S := 16

var m: Node2D
var active := ""                         # la marea in corso
var pending := ""                        # annunciata, sta per cominciare
var wave := 0
var won := false
var paused := false                      # le prove la comandano a mano
var boss: Creature
var center := Vector2i(-1, -1)
var _wave_list: Array[Creature] = []
var _wave_t := 0.0
var _announce_t := 0.0
var _night := false
var _eclipse := false
var _boss_spawned := false
var _label: Label
var _rng := RandomNumberGenerator.new()
var wins := 0                            # (prove)
var spawned := 0

signal finished(id: String, won: bool)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	_night = m.day.is_night()
	_label = Label.new()
	_label.position = Vector2(1600 - 420, 238)           # sotto la scritta degli eventi
	_label.size = Vector2(400, 24)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)
	m.fauna.killed.connect(_on_killed)


func _exit_tree() -> void:
	Wiles.siege = false


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	var night: bool = m.day.is_night()
	var ecl: bool = m.day.eclipse_on
	if not paused and night != _night:
		_night = night
		if active != "":
			_end(false)                              # una marea dura al più una notte o un giorno
		_roll("notte" if night else "giorno")
	if not paused and ecl and not _eclipse:
		_roll("eclissi")
	_eclipse = ecl
	if pending != "":
		_announce_t -= dt
		_label.text = "%s · tra %d s" % [TidesData.TIDES[pending]["name"], ceili(_announce_t)]
		_label.add_theme_color_override("font_color", Color(TidesData.TIDES[pending]["color"]))
		if _announce_t <= 0.0:
			start(pending)
		return
	if active == "":
		_label.text = ""
		return
	_tick(dt)


## Tira se arriva una marea in questo momento (notte, giorno, eclissi).
func _roll(when: String) -> void:
	if active != "" or pending != "" or m.giardino.active:
		return
	if when == "notte" and siege_allowed() and _rng.randf() < float(TidesData.TIDES["assedio"]["chance"]):
		announce("assedio")
		return
	var season := CreaturesData.now_season
	var pc: Vector2i = m.player_cell()
	var in_sky := SkyData.zone_at(m.world, pc.x, pc.y) != ""
	for id in TidesData.for_time(when):
		var td: Dictionary = TidesData.TIDES[id]
		if td.get("siege", false) or bool(td.get("sky", false)) != in_sky:
			continue                                 # Roadmap 16: in cielo solo le maree del cielo
		var ch := float(td["chance"]) * float((td["seasons"] as Dictionary).get(season, 1.0)) * float(m.events.chance_mult)
		if _rng.randf() < ch:
			announce(String(id))
			return


## L'assedio si può? (opzione accesa, una base, non già in questa stagione)
func siege_allowed() -> bool:
	if not bool(Settings.v("assedi")):
		return false
	if _base().x < 0:
		return false
	var rec: Dictionary = m.world_meta.get("assedio", {})
	if rec.is_empty():
		return true
	var day: int = m.day.day
	return day - int(rec.get("giorno", -99)) >= 3 and (m.seasons.current != int(rec.get("stagione", -1)) or day - int(rec["giorno"]) >= 12)


## La base: un Focolare con una porta entro 30 tessere (uno qualunque: prima guardava solo il primo Focolare del mondo).
func _base() -> Vector2i:
	var hearths: Array[Vector2i] = []
	var doors: Array[Vector2i] = []
	for o: Vector2i in m.world.stations:
		var id := String(m.world.stations[o])
		if id == "focolare":
			hearths.append(o)
		elif StationsData.role(id) in ["porta", "porta_aperta"] or bool(MachinesData.get_machine(id).get("porta", false)):
			doors.append(o)
	for h in hearths:
		for d in doors:
			if Vector2(d - h).length() < 30.0:
				return h
	return Vector2i(-1, -1)


func announce(id: String) -> void:
	pending = id
	_announce_t = TidesData.ANNOUNCE
	m.events.stop()
	var td: Dictionary = TidesData.TIDES[id]
	center = _base() if td.get("siege", false) else m.player_cell()
	m.depth_watch.banner.show_stratum("Si avvicina: " + String(td["name"]), String(td["desc"]), Color(td["color"]))
	m.hud.toast("%s tra poco: preparati" % td["name"])
	m.language.add_mark(center, String(td["name"]), Color(td["color"]))
	m.sfx.play("presenza")


func start(id: String) -> void:
	pending = ""
	active = id
	wave = 0
	won = false
	boss = null
	_boss_spawned = false
	_wave_list.clear()
	var td: Dictionary = TidesData.TIDES[id]
	if center.x < 0:
		center = m.player_cell()
	if td.get("siege", false):
		Wiles.siege = true
		m.world_meta["assedio"] = {"giorno": m.day.day, "stagione": m.seasons.current}
	m.objectives.bump("maree")
	_next_wave()


func _tick(dt: float) -> void:
	var td: Dictionary = TidesData.TIDES[active]
	_wave_list = _wave_list.filter(func(c: Creature) -> bool: return is_instance_valid(c) and m.fauna.list.has(c))
	var n: int = int(td["waves"][0])
	if not _boss_spawned:
		_wave_t -= dt
		var per := int(td["waves"][1])
		var cleared := float(per - _wave_list.size()) / float(maxi(per, 1)) >= TidesData.WAVE_CLEAR
		if cleared or _wave_t <= 0.0:
			if wave < n:
				_next_wave()
			else:
				_spawn_boss()
	var left := _wave_list.size()
	if _boss_spawned:
		_label.text = "%s · il capo: %s" % [td["name"], String(boss.data["name"]) if is_instance_valid(boss) else "…"]
	else:
		_label.text = "%s · ondata %d/%d · %d rimaste" % [td["name"], wave, n, left]
	_label.add_theme_color_override("font_color", Color(td["color"]))


func _next_wave() -> void:
	var td: Dictionary = TidesData.TIDES[active]
	wave += 1
	_wave_t = TidesData.WAVE_TIME
	var pool: Array = td["pool"]
	for i in int(td["waves"][1]):
		var at := _spawn_pos()
		if at.x < 0.0:
			continue
		var cid := String(pool[_rng.randi_range(0, pool.size() - 1)])
		var cr: Creature = m.fauna.add(cid, at)
		cr.strengthen(m.fauna.vigor_mult * (1.0 + 0.1 * wave))
		cr.provoke()
		cr.mind.brave = true
		cr.mind.alarm(m.player.position)
		cr.extra = true
		_wave_list.append(cr)
		spawned += 1
	if td.has("herd"):
		# la Migrazione: un branco attraversa il mondo (da proteggere o da cacciare)
		var herd: Array = td["herd"]
		var hid := String(herd[_rng.randi_range(0, herd.size() - 1)])
		var at := _spawn_pos()
		for k in 3:
			if at.x >= 0.0:
				var h: Creature = m.fauna.add(hid, at + Vector2(k * 20.0, 0))
				h.extra = true
	m.hud.toast("%s: ondata %d" % [td["name"], wave])


func _spawn_boss() -> void:
	var td: Dictionary = TidesData.TIDES[active]
	_boss_spawned = true
	var at := _spawn_pos()
	if at.x < 0.0:
		at = m.player.position + Vector2(10.0 * S, -3.0 * S)
	boss = m.fauna.add(String(td["boss"]), at)
	boss.strengthen(m.fauna.vigor_mult)
	boss.provoke()
	m.lords.bar.follow(boss)
	m.depth_watch.banner.show_stratum(String(boss.data["name"]), "Il capo della marea", Color(td["color"]))
	m.sfx.play("guardiano")


## Un punto dove far nascere una creatura dell'ondata: attorno al centro, sul terreno (in superficie) o in una cella
## libera con il pavimento sotto (sotto terra).
func _spawn_pos() -> Vector2:
	var w: World = m.world
	for tries in 20:
		var r := _rng.randi_range(TidesData.SPAWN_R[0], TidesData.SPAWN_R[1]) * (1 if _rng.randf() < 0.5 else -1)
		var x := clampi(center.x + r, 2, w.w - 3)
		if TidesData.TIDES[active if active != "" else pending].get("sky", false):
			var ys := center.y + _rng.randi_range(-10, 3)          # Roadmap 16: in cielo, nell'aria attorno
			if w.inside(x, ys) and not w.solid(x, ys) and not w.solid(x, ys + 1):
				return Vector2(x * S + 8, ys * S)
			continue
		if StrataData.at(w, center.x, center.y) == 0 or TidesData.TIDES[active if active != "" else pending].get("siege", false):
			var y: int = w.surface[x] - 1
			while y > 1 and w.solid(x, y):
				y -= 1
			return Vector2(x * S + 8, y * S)
		var y2 := center.y + _rng.randi_range(-8, 8)
		if w.inside(x, y2) and not w.solid(x, y2) and w.solid(x, y2 + 1):
			return Vector2(x * S + 8, y2 * S)
	return Vector2(-1, -1)


func _on_killed(c: Creature) -> void:
	if active == "" or c != boss:
		return
	_end(true)


func _end(win: bool) -> void:
	var id := active
	var td: Dictionary = TidesData.TIDES[id]
	active = ""
	Wiles.siege = false
	m.lords.bar.follow(null)
	var marks: Array = m.world_meta.get("segni", [])
	for i in range(marks.size() - 1, -1, -1):
		if String(marks[i][2]) == String(td["name"]):
			marks.remove_at(i)
	if win:
		won = true
		wins += 1
		for r in int(td.get("rolls", 1)):
			var loot := LootData.roll(String(td["reward"]), _rng)
			for item in loot:
				m.drops.spawn(item, int(loot[item]), m.player.position + Vector2(0, -12))
		m.hud.toast("%s: vinta! Il premio è ai tuoi piedi" % td["name"])
		m.objectives.bump("maree_vinte")
		m.sfx.play("dono")
	else:
		m.hud.toast("%s si ritira" % td["name"])
	finished.emit(id, win)
