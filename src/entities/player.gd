class_name Player
extends Node2D
## Il personaggio: movimento, salto e animazione. I fotogrammi non sono disegnati a mano: nascono da una posa
## (angoli di braccia e gambe) e vengono messi da parte la prima volta che servono.

const HALF := Vector2(5, 13)
const GRAV := 950.0
const RUN := 150.0
const JUMP := 345.0
const MAX_FALL := 560.0

var world: World
var vel := Vector2.ZERO
var on_floor := false
var facing := 1
var control := true
var swinging := false
var force_swing := false
var tool_tex: Texture2D
var rig: Node2D
var spr: Sprite2D
var tool: Sprite2D
var anim_t := 0.0
var swing_t := 0.0
var coyote := 0.0
var jump_buf := 0.0
var step_vis := 0.0
var _cache := {}


func setup(wd: World) -> void:
	world = wd
	rig = Node2D.new()
	add_child(rig)
	tool = Sprite2D.new()
	tool.offset = Vector2(4.5, -4.5)
	tool.visible = false
	rig.add_child(tool)
	spr = Sprite2D.new()
	spr.position = Vector2(0, -3)
	rig.add_child(spr)
	rig.move_child(tool, 1)


func _unhandled_input(e: InputEvent) -> void:
	if not control:
		return
	if e is InputEventKey and e.pressed and not e.echo and (e.keycode == KEY_SPACE or e.keycode == KEY_W or e.keycode == KEY_UP):
		jump_buf = 0.14


func _physics_process(dt: float) -> void:
	var dir := 0.0
	if control:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			dir -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			dir += 1.0
	var accel := 1400.0 if on_floor else 800.0
	vel.x = move_toward(vel.x, dir * RUN, accel * dt)
	vel.y = minf(vel.y + GRAV * dt, MAX_FALL)
	var held := control and (Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
	if vel.y < 0.0 and not held:
		vel.y += GRAV * 1.3 * dt
	jump_buf -= dt
	if jump_buf > 0.0 and coyote > 0.0:
		vel.y = -JUMP
		jump_buf = 0.0
		coyote = 0.0
	var r := TileBody.move(world, position, HALF, vel, dt, on_floor)
	position = r["pos"]
	vel = r["vel"]
	on_floor = r["floor"]
	step_vis += r["stepped"]
	step_vis = move_toward(step_vis, 0.0, 160.0 * dt)
	coyote = 0.1 if on_floor else coyote - dt
	if dir != 0.0 and not swinging:
		facing = 1 if dir > 0.0 else -1
	_animate(dt)


func _animate(dt: float) -> void:
	var key := "idle"
	var pose: Dictionary
	if not on_floor and coyote <= 0.0:
		key = "jump" if vel.y < 0.0 else "fall"
		pose = CharacterArt.pose_jump() if vel.y < 0.0 else CharacterArt.pose_fall()
	elif absf(vel.x) > 12.0:
		anim_t += dt * absf(vel.x) / RUN * 13.0
		var k := int(anim_t) % 8
		key = "run%d" % k
		pose = CharacterArt.pose_run(k)
	else:
		anim_t = 0.0
		pose = CharacterArt.pose_idle()
	var a := 0.0
	var sw := swinging or force_swing
	if sw:
		swing_t += dt
		var ph := fmod(swing_t, 0.3) / 0.3
		var step := int(ph * 7.0)
		a = lerpf(3.3, 0.35, step / 6.0)
		pose["fa_u"] = a
		pose["fa_l"] = a
		key += "_s%d" % step
	else:
		swing_t = 0.0
	if not _cache.has(key):
		var d := CharacterArt.character(pose)
		_cache[key] = {"tex": ImageTexture.create_from_image(d["img"]), "hand": d["hand"]}
	var entry: Dictionary = _cache[key]
	spr.texture = entry["tex"]
	spr.position = Vector2(0, -3 + step_vis)
	rig.scale.x = facing
	tool.visible = sw and tool_tex != null
	if tool.visible:
		tool.texture = tool_tex
		var hand: Vector2 = entry["hand"]
		tool.position = spr.position + hand - Vector2(12, 16)
		tool.rotation = atan2(cos(a), sin(a)) + PI * 0.25
