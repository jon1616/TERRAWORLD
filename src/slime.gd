class_name Slime
extends Node2D
## Uno slime che saltella: aspetta, si schiaccia, salta verso il giocatore se è vicino.

const HALF := Vector2(6, 5)
const KINDS := [
	["#3fa83a", "#8ee070", "#22641f"],
	["#3a7ad8", "#8ac0ff", "#1f3f86"],
	["#9a4ad8", "#d8a0ff", "#4f1f86"],
]

var world: World
var target: Node2D
var vel := Vector2.ZERO
var on_floor := false
var wait := 1.0
var spr: Sprite2D
var squash := 0.0
var rng := RandomNumberGenerator.new()


func setup(wd: World, kind: int, tgt: Node2D, s: int) -> void:
	world = wd
	target = tgt
	rng.seed = s
	var k: Array = KINDS[kind]
	spr = Sprite2D.new()
	spr.texture = ImageTexture.create_from_image(Art.slime(Color(k[0]), Color(k[1]), Color(k[2])))
	spr.offset = Vector2(0, -7)
	spr.position = Vector2(0, HALF.y)
	add_child(spr)
	wait = rng.randf_range(0.5, 2.0)


func _physics_process(dt: float) -> void:
	vel.y = minf(vel.y + 900.0 * dt, 520.0)
	if on_floor:
		vel.x = move_toward(vel.x, 0.0, 900.0 * dt)
		wait -= dt
		if wait <= 0.0:
			var dir := 1.0 if rng.randf() < 0.5 else -1.0
			if target and target.position.distance_to(position) < 16.0 * 20.0:
				dir = signf(target.position.x - position.x)
			vel = Vector2(dir * rng.randf_range(60.0, 95.0), -rng.randf_range(220.0, 300.0))
			wait = rng.randf_range(0.8, 2.2)
			on_floor = false
	var was := on_floor
	var r := TileBody.move(world, position, HALF, vel, dt, false)
	position = r["pos"]
	vel = r["vel"]
	on_floor = r["floor"]
	if on_floor and not was:
		squash = 1.0
	squash = move_toward(squash, 0.0, dt * 5.0)
	if on_floor:
		var pre := clampf(1.0 - wait * 3.0, 0.0, 1.0) * 0.25
		spr.scale = Vector2(1.0 + squash * 0.3 + pre, 1.0 - squash * 0.3 - pre)
	else:
		spr.scale = Vector2(0.85, 1.18)
