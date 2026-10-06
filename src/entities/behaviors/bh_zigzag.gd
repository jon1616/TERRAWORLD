class_name BhZigzag
extends Behavior
## Zigzag (voce 378, per chi vola): si avvicina a scatti di lato, difficile da prendere di mira. Va scritto dopo «vola».
## Parametri: zig (ampiezza in px al secondo), zig_rate.

var t := 0.0


func tick(c: Creature, dt: float) -> void:
	if c.busy or c.want_fly == Vector2.ZERO:
		return
	t += dt * float(c.p.get("zig_rate", 3.0))
	var perp := c.want_fly.normalized().orthogonal()
	c.want_fly += perp * signf(sin(t)) * float(c.p.get("zig", 90.0))
