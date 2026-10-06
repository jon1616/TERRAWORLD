class_name BhSpine
extends Behavior
## Cerchio di spine (voce 378): ogni tanto si gonfia e lancia spine tutto attorno. Parametri: ring_every, ring_n,
## shot_damage, shot_speed.

var t := 2.5


func tick(c: Creature, dt: float) -> void:
	t -= dt * (1.4 if c.enraged else 1.0)
	c.crouch = 0.6 if t < 0.4 else 0.0
	if t > 0.0:
		return
	t = float(c.p.get("ring_every", 4.5))
	if not Behavior.sees(c, float(c.p.get("sight", 16))):
		return
	var n := int(c.p.get("ring_n", 8))
	var off := c.rng.randf() * TAU
	for k in n:
		var d := Vector2.RIGHT.rotated(off + TAU * k / float(n))
		c.fire.append({"from": c.position + d * (c.half.x + 2.0), "vel": d * float(c.p.get("shot_speed", 160.0)),
			"grav": 0.0, "damage": int(c.p.get("shot_damage", 10)), "look": "scheggia"})
