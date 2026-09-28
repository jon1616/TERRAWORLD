class_name BhVola
extends Behavior
## Vola ondeggiando: verso il bersaglio se lo vede, altrimenti a zonzo attorno al punto in cui è nata.

var t := 0.0
var home := Vector2.INF
var drift := Vector2.ZERO


func tick(c: Creature, dt: float) -> void:
	t += dt
	if home == Vector2.INF:
		home = c.position
	if c.busy:
		return
	var goal: Vector2
	var leash: float = float(c.p.get("leash", 0)) * 16.0
	if leash > 0.0 and c.position.distance_to(home) > leash:
		goal = home                        # un Guardiano non si allontana dal suo Cuore
	elif Behavior.sees(c, float(c.p.get("sight", 24))):
		goal = c.target.position + Vector2(0, -float(c.p.get("hover", 10.0)))
	elif c.mind.goal != Vector2.INF and c.mind.wander_dir(c) != 0.0:
		goal = c.mind.goal + Vector2(0, -24.0)  # voce 129: va a vedere
	else:
		if drift == Vector2.ZERO or c.rng.randf() < dt * 0.3:
			drift = Vector2(c.rng.randf_range(-80, 80), c.rng.randf_range(-50, 30))
		goal = home + drift
	var to := goal - c.position
	var wob: float = c.p.get("wobble", 30.0)
	var side := Vector2(-to.y, to.x).normalized() * sin(t * 3.0) * wob
	c.want_fly = (to.normalized() * c.speed + side) if to.length() > 4.0 else side
	if absf(to.x) > 2.0:
		c.facing = 1 if to.x > 0.0 else -1
