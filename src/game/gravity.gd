class_name Gravity
extends Node
## La gravità e le correnti d'aria (voce 76, Roadmap 10). Due leggi dei mondi, entrambe geni di forma:
##   il peso (`run.grav` dei geni: Lieve 0,55, Arcipelago 0,85) vale per il Germogliato (`Player.grav_mult`: salti
##   più alti, cadute più lente e meno dannose), per le creature, gli oggetti a terra, i dardi e le bombe
##   (`Creature.grav`, letto da tutti);
##   le correnti ascensionali dell'Arcipelago (appunti del generatore → `world_meta["correnti"]`): colonne d'aria che
##   sollevano chi ci entra tenendo premuto Salto (`Player.lift`; senza, ci si passa attraverso) fino sopra le voragini. Si vedono: foglie e scintille che salgono.
## Il Guscio (tetto di roccia) non ha codice qui: è tutto nel generatore (`PassGuscio`), e `Weather` sa che sotto il
## tetto non piove (`run.roof`).

const LIFT := 240.0                    # velocità di salita dentro una corrente, px/s
const SHOW := 70                       # tessere: le correnti più lontane non hanno particelle

var m: Node2D
var grav := 1.0
var currents: Array = []               # [{x, w, y0, y1}] in tessere
var columns := {}                      # Roadmap 19: le colonne di bolle degli ascensori accesi (chiave -> Rect2i di celle)
var _fx := {}                          # indice della corrente → CPUParticles2D


func setup(main: Node2D) -> void:
	m = main
	if m.world.gen_notes.has("correnti") and not m.world_meta.has("correnti"):
		var out := []
		for cu in m.world.gen_notes["correnti"]:
			out.append((cu as Dictionary).duplicate())
		m.world_meta["correnti"] = out
	currents = m.world_meta.get("correnti", [])
	apply()


func apply() -> void:
	var e := Genome.effects(m.world_meta.get("geni", []), "run")
	grav = float(e.get("grav", 1.0))
	if m.giardino != null and m.giardino.active:
		grav = 1.0
	m.player.grav_mult = grav
	Creature.grav = grav


func _exit_tree() -> void:
	Creature.grav = 1.0                # il prossimo mondo (o il menu) riparte dal peso normale


## La corrente che contiene questa cella (-1 = nessuna).
func current_at(c: Vector2i) -> int:
	for i in currents.size():
		var cu: Dictionary = currents[i]
		if absi(c.x - int(cu["x"])) <= int(cu["w"]) and c.y >= int(cu["y0"]) and c.y <= int(cu["y1"]):
			return i
	return -1


## Roadmap 19: la cella è nella colonna di un ascensore a bolla acceso?
func in_column(c: Vector2i) -> bool:
	for r: Rect2i in columns.values():
		if r.has_point(c):
			return true
	return false


func _process(_dt: float) -> void:
	if not m.built:
		return
	var p: Player = m.player
	p.lift = LIFT if current_at(m.player_cell()) >= 0 or in_column(m.player_cell()) else 0.0
	_visuals()


## Particelle che salgono nelle correnti vicine alla visuale: create quando servono, tolte quando si va lontano.
func _visuals() -> void:
	var pc: Vector2i = m.player_cell()
	for i in currents.size():
		var cu: Dictionary = currents[i]
		var near := absi(int(cu["x"]) - pc.x) < SHOW
		if near and not _fx.has(i):
			_fx[i] = _make(cu)
		elif not near and _fx.has(i):
			(_fx[i] as Node).queue_free()
			_fx.erase(i)


func _make(cu: Dictionary) -> CPUParticles2D:
	var y0 := int(cu["y0"])
	var y1 := int(cu["y1"])
	var p := CPUParticles2D.new()
	p.z_as_relative = false
	p.z_index = 19
	p.amount = clampi((y1 - y0) * 2, 30, 160)
	p.lifetime = 2.2
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2((int(cu["w"]) + 0.5) * 16.0, (y1 - y0) * 8.0)
	p.position = Vector2(int(cu["x"]) * 16.0 + 8.0, (y0 + y1) * 8.0)
	p.direction = Vector2(0, -1)
	p.spread = 8.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 90.0
	p.initial_velocity_max = 150.0
	var im := Image.create_empty(2, 4, false, Image.FORMAT_RGBA8)
	im.fill(Color(0.7, 1.0, 0.92, 0.75))
	p.texture = ImageTexture.create_from_image(im)
	p.color_ramp = Gradient.new()
	p.color_ramp.set_color(0, Color(1, 1, 1, 0.0))
	p.color_ramp.add_point(0.2, Color(1, 1, 1, 0.8))
	p.color_ramp.set_color(p.color_ramp.get_point_count() - 1, Color(1, 1, 1, 0.0))
	m.fx.add_child(p)
	return p
