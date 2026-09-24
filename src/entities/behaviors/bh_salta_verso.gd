class_name BhSaltaVerso
extends Behavior
## Aspetta a terra schiacciandosi, poi salta: verso il bersaglio se lo vede, altrimenti a caso (i grumi).

var wait := 1.0


func tick(c: Creature, dt: float) -> void:
	if not c.on_floor:
		return
	c.want_x = 0.0
	wait -= dt
	c.crouch = clampf(1.0 - wait * 3.0, 0.0, 1.0)
	if wait > 0.0:
		return
	var dir := 1.0 if c.rng.randf() < 0.5 else -1.0
	if Behavior.sees(c, float(c.p.get("sight", 20))):
		dir = signf(c.target.position.x - c.position.x)
	var jump: float = c.p.get("jump", 260.0)
	c.vel = Vector2(dir * c.speed * c.rng.randf_range(0.8, 1.15), -jump * c.rng.randf_range(0.85, 1.1))
	c.facing = int(dir)
	c.on_floor = false
	wait = c.rng.randf_range(0.8, 2.0)
	c.crouch = 0.0
