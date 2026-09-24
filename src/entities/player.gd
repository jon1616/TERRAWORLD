class_name Player
extends Node2D
## Il personaggio: movimento, salto e animazione. I fotogrammi non sono disegnati a mano: nascono da una posa
## (angoli di braccia e gambe) e vengono messi da parte la prima volta che servono.

const HALF := Vector2(5, 13)
# Valori di base, senza modificatori (24 set 2026, richiesta dell'utente: più lento, salto di 3 blocchi, più fluido).
const RUN := 95.0                      # velocità massima di corsa, px/s (~6 tessere al secondo)
const ACCEL_GROUND := 750.0            # accelerazione a terra: ~0,13 s per arrivare alla velocità piena
const DECEL_GROUND := 950.0            # frenata a terra quando si lasciano i tasti
const ACCEL_AIR := 520.0               # controllo in aria, un po' più morbido
const GRAV := 820.0
const JUMP := 288.0                    # salto pieno ~3,3 tessere: si sale su un gradino di 3 blocchi
const JUMP_CUT := 1.6                  # gravità in più in salita se si lascia il tasto (salto corto)
const MAX_FALL := 520.0
const MAX_DT := 1.0 / 30.0             # oltre questo passo il movimento si divide in più passi

var world: World
## Comandi simulati quando `control` è falso (prove automatiche, in futuro i bot): direzione -1/0/1 e salto tenuto.
var auto_dir := 0.0
var auto_jump := false
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
var eye: Sprite2D                      # l'occhio d'ambra, disegnato sopra il buio: brilla nelle grotte
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
	var ei := Image.create_empty(1, 2, false, Image.FORMAT_RGBA8)
	ei.fill(CharacterArt.EYE)
	eye = Sprite2D.new()
	eye.texture = ImageTexture.create_from_image(ei)
	eye.modulate = Color(2.4, 1.6, 0.7)
	eye.z_as_relative = false
	eye.z_index = 27
	rig.add_child(eye)


func _unhandled_input(e: InputEvent) -> void:
	if not control:
		return
	if e is InputEventKey and e.pressed and not e.echo and (e.keycode == KEY_SPACE or e.keycode == KEY_W or e.keycode == KEY_UP):
		jump_buf = 0.14


func _ready() -> void:
	process_priority = -1              # si muove prima che la scena sposti la camera: niente scatti di un fotogramma


## Il movimento gira a ogni fotogramma disegnato (non a 60 passi fissi): fluido anche sugli schermi a 120/144 Hz.
func _process(delta: float) -> void:
	var dir := auto_dir
	var held := auto_jump
	if control:
		dir = 0.0
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			dir -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			dir += 1.0
		held = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	elif auto_jump and on_floor:
		jump_buf = 0.14
	var left := delta
	while left > 0.0:
		var dt := minf(left, MAX_DT)
		left -= dt
		_step(dt, dir, held)
	step_vis = move_toward(step_vis, 0.0, 120.0 * delta)
	if dir != 0.0 and not swinging:
		facing = 1 if dir > 0.0 else -1
	_animate(delta)


func _step(dt: float, dir: float, held: bool) -> void:
	var target := dir * RUN
	var accel := ACCEL_AIR
	if on_floor:
		accel = ACCEL_GROUND if dir != 0.0 and signf(dir) == signf(vel.x if vel.x != 0.0 else dir) else DECEL_GROUND
	vel.x = move_toward(vel.x, target, accel * dt)
	vel.y = minf(vel.y + GRAV * dt, MAX_FALL)
	if vel.y < 0.0 and not held:
		vel.y += GRAV * (JUMP_CUT - 1.0) * dt
	jump_buf -= dt
	if jump_buf > 0.0 and coyote > 0.0:
		vel.y = -JUMP
		jump_buf = 0.0
		coyote = 0.0
	var through := control and (Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
	var r := TileBody.move(world, position, HALF, vel, dt, on_floor, through)
	position = r["pos"]
	vel = r["vel"]
	on_floor = r["floor"]
	step_vis += r["stepped"]
	coyote = 0.1 if on_floor else coyote - dt


func _animate(dt: float) -> void:
	var key := "idle"
	var pose: Dictionary
	if not on_floor and coyote <= 0.0:
		key = "jump" if vel.y < 0.0 else "fall"
		pose = CharacterArt.pose_jump() if vel.y < 0.0 else CharacterArt.pose_fall()
	elif absf(vel.x) > 12.0:
		anim_t += dt * absf(vel.x) / RUN * 20.0
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
		_cache[key] = {"tex": ImageTexture.create_from_image(d["img"]), "hand": d["hand"], "eye": d["eye"]}
	var entry: Dictionary = _cache[key]
	spr.texture = entry["tex"]
	spr.position = Vector2(0, -3 + step_vis)
	eye.position = spr.position + (entry["eye"] as Vector2) - Vector2(12, 16)
	rig.scale.x = facing
	tool.visible = sw and tool_tex != null
	if tool.visible:
		tool.texture = tool_tex
		var hand: Vector2 = entry["hand"]
		tool.position = spr.position + hand - Vector2(12, 16)
		tool.rotation = atan2(cos(a), sin(a)) + PI * 0.25
