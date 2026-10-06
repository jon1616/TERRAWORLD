class_name BhMolla
extends Behavior
## Salto a molla (voce 378): non cammina, rimbalza: appena tocca terra salta di nuovo, verso il bersaglio se lo vede.
## Parametri: spring (spinta in alto), spring_x, spring_every.

var t := 0.5


func tick(c: Creature, dt: float) -> void:
	if c.busy:
		return
	t -= dt
	c.crouch = 0.8 if c.on_floor and t < 0.2 else 0.0
	if not c.on_floor or t > 0.0:
		return
	t = float(c.p.get("spring_every", 1.0)) * (0.7 if c.enraged else 1.0)
	var dir := 0.0
	if c.target != null and Behavior.sees(c, float(c.p.get("sight", 18))):
		dir = signf(c.target.position.x - c.position.x)
	else:
		dir = 1.0 if c.rng.randf() < 0.5 else -1.0
	c.facing = 1 if dir >= 0.0 else -1
	c.vel = Vector2(dir * float(c.p.get("spring_x", 120.0)), -float(c.p.get("spring", 360.0)))
	c.on_floor = false
