class_name Events
extends Node
## Gli eventi del mondo (voce 34, dati in `EventsData`): al calar della notte e al sorgere del giorno si tira se
## comincia un evento; dura fino al cambio successivo. Mentre dura cambia la fauna (pericolo, creature rare, creature
## preferite), fa cadere stelle, conta le creature sconfitte verso un premio. Non si salva: un evento finisce con la
## notte o il giorno in cui è nato.

const S := 16

var m: Node2D
var active := ""                       # l'evento in corso ("" = nessuno)
var kills := 0
var won := false
var paused := false                    # le prove lo comandano a mano
var chance_mult := 1.0                 # tratto «Stellato» del mondo (voce 39)
var season_mult := 1.0                 # voce 66: la stagione
var stars := 0                         # stelle cadute (per le prove)
var _night := false
var _star_t := 5.0
var _label: Label
var _rng := RandomNumberGenerator.new()

signal started(id: String)
signal ended(id: String)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	_night = m.day.is_night()
	_label = Label.new()
	_label.position = Vector2(1600 - 420, 214)           # sotto la minimappa
	_label.size = Vector2(400, 24)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_label.add_theme_constant_override("outline_size", 5)
	m.hud.add_child(_label)
	m.fauna.killed.connect(_on_killed)


func _process(dt: float) -> void:
	if not m.built:
		return
	var night: bool = m.day.is_night()
	if night != _night and not paused:
		_night = night
		stop()
		var pool := EventsData.for_time("notte" if night else "giorno")
		for id in pool:
			if _rng.randf() < float(EventsData.EVENTS[id]["chance"]) * chance_mult * season_mult:
				start(String(id))
				break
	if active == "":
		_label.text = ""
		return
	var ev: Dictionary = EventsData.EVENTS[active]
	var text := String(ev["name"])
	if ev.has("goal"):
		text += "  ·  %d / %d" % [mini(kills, int(ev["goal"])), int(ev["goal"])] if not won else "  ·  vinta!"
	_label.text = text
	_label.add_theme_color_override("font_color", Color(ev["color"]))
	if ev.has("stars"):
		_star_t -= dt
		if _star_t <= 0.0:
			var span: Array = ev["stars"]
			_star_t = _rng.randf_range(float(span[0]), float(span[1]))
			fall_star()


## Comincia un evento: scritta, suono, effetti sulla fauna e sul giardino.
func start(id: String) -> void:
	stop()
	active = id
	kills = 0
	won = false
	var ev: Dictionary = EventsData.EVENTS[id]
	m.fauna.event_danger = float(ev.get("danger", 0.0))
	m.fauna.event_rare = float(ev.get("rare", 1.0))
	m.fauna.event_pool = ev.get("pool", [])
	m.garden.wild_mult = float(ev.get("wild", 1.0))
	_star_t = 3.0
	m.depth_watch.banner.show_stratum(String(ev["name"]), String(ev["desc"]), Color(ev["color"]))
	m.sfx.play("presenza")
	m.objectives.bump("eventi")
	started.emit(id)


func stop() -> void:
	if active == "":
		return
	var id := active
	active = ""
	m.fauna.event_danger = 0.0
	m.fauna.event_rare = 1.0
	m.fauna.event_pool = []
	m.garden.wild_mult = 1.0
	ended.emit(id)


## Una stella cadente: una scia dal cielo fino al terreno vicino al Germogliato, dove resta una Stellina caduta.
func fall_star() -> void:
	var px: int = floori(m.player.position.x / S) + _rng.randi_range(-45, 45)
	px = clampi(px, 2, m.world.w - 3)
	var gy: int = m.world.surface[px]
	while gy > 1 and m.world.solid(px, gy - 1):
		gy -= 1
	var land := Vector2(px * S + 8, gy * S - 6)
	var sp := Sprite2D.new()
	sp.texture = SlotView.icon("stellina")
	sp.modulate = Color(2.4, 2.2, 1.4)
	sp.z_as_relative = false
	sp.z_index = 26
	sp.position = land + Vector2(-260, -520)
	m.fx.add_child(sp)
	var tw := sp.create_tween()
	tw.tween_property(sp, "position", land, 1.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var fx: Node2D = m.fx
	var drops: Drops = m.drops
	tw.finished.connect(func() -> void:
		Fx.puff(fx, land, Color(2.4, 2.2, 1.4))
		drops.spawn("stellina", 1, land)
		sp.queue_free())
	m.sfx.play("stella", land)
	stars += 1


func _on_killed(c: Creature) -> void:
	if active == "" or won:
		return
	var ev: Dictionary = EventsData.EVENTS[active]
	if not ev.has("goal") or c.boss:
		return
	kills += 1
	if kills >= int(ev["goal"]):
		won = true
		for r in int(ev.get("rolls", 1)):
			var loot := LootData.roll(String(ev["reward"]), _rng)
			for id in loot:
				m.drops.spawn(id, int(loot[id]), m.player.position + Vector2(0, -20))
		m.hud.toast("%s vinta! Il Giardino ti ricompensa" % ev["name"])
		m.sfx.play("obiettivo")
		m.objectives.bump("eventi_vinti")
