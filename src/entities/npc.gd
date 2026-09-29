class_name Npc
extends Node2D
## Un abitante (voce 36): passeggia piano attorno al suo Focolare, si ferma e si gira verso il Germogliato quando gli
## è vicino. Le creature non lo attaccano e non si fa male. Con il clic destro si apre il commercio (`Villagers`).

const S := 16
const HALF := Vector2(6, 14)
const SPEED := 32.0

var id := ""
var world: World
var home := Vector2i.ZERO
var shelter_t := 0.0                     # Roadmap 19: la Campana d'allarme: per un po' si corre a casa
var player: Node2D
var vel := Vector2.ZERO
var on_floor := false
var _dir := 0.0
var _t := 0.0
var _anim := 0.0
var _spr: Sprite2D
var _frames: Array = []
var _label: Label


func setup(nid: String, w: World, h: Vector2i, p: Node2D) -> void:
	id = nid
	world = w
	home = h
	player = p
	_frames = NpcArt.frames(nid)
	_spr = Sprite2D.new()
	_spr.texture = _frames[0]
	_spr.offset = Vector2(0, -16)
	_spr.position = Vector2(0, HALF.y)
	add_child(_spr)
	_label = Label.new()
	_label.text = String(NpcData.NPCS[nid]["name"])
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.size = Vector2(120, 12)
	_label.position = Vector2(-60, -HALF.y - 16)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", Color("#ffe8b0"))
	_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.05))
	_label.add_theme_constant_override("outline_size", 4)
	_label.z_as_relative = false
	_label.z_index = 28
	add_child(_label)


func rect() -> Rect2:
	return Rect2(position - HALF, HALF * 2.0)


func _process(dt: float) -> void:
	dt = minf(dt, 1.0 / 30.0)
	_t -= dt
	var near := player.position.distance_to(position) < 3.5 * S
	shelter_t = maxf(shelter_t - dt, 0.0)
	if shelter_t > 0.0:
		var gx := home.x * S + 8.0
		_dir = 0.0 if absf(gx - position.x) < 6.0 else signf(gx - position.x)
		_t = 0.5
	elif near:
		_dir = 0.0
		_spr.scale.x = 1.0 if player.position.x >= position.x else -1.0
	elif _t <= 0.0:
		_t = randf_range(2.0, 5.0)
		_dir = [-1.0, 0.0, 1.0, 0.0][randi() % 4]
		# non allontanarsi troppo da casa
		var off := position.x / S - home.x
		if absf(off) > NpcData.WANDER:
			_dir = -signf(off)
	if _dir != 0.0:
		_spr.scale.x = _dir
		var ax := floori((position.x + _dir * (HALF.x + 2.0)) / S)
		var fy := floori((position.y + HALF.y + 2.0) / S)
		if not world.solid(ax, fy) and not world.solid(ax, fy + 1):
			_dir = 0.0                          # davanti c'è un burrone: si ferma
	vel.x = _dir * SPEED
	vel.y = minf(vel.y + 900.0 * dt, 500.0)
	var r := TileBody.move(world, position, HALF, vel, dt, on_floor)
	position = r["pos"]
	vel = r["vel"]
	on_floor = r["floor"]
	if on_floor and absf(vel.x) < 1.0 and _dir != 0.0:
		vel.y = -230.0                          # un gradino alto: un saltello
	_anim += dt
	_spr.texture = _frames[int(_anim * 5.0) % 2 if _dir != 0.0 else 0]
