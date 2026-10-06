class_name BhPioggia
extends Behavior
## Pioggia di colpi (voce 378): ogni tanto chiama dall'alto una pioggia di colpi sopra il bersaglio. Si vede arrivare
## e ci si sposta. Parametri: rain_every, rain_n, shot_damage.

var t := 3.0


func tick(c: Creature, dt: float) -> void:
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0:
		return
	t = float(c.p.get("rain_every", 6.0))
	if not Behavior.sees(c, float(c.p.get("sight", 24))):
		return
	c.telegraph(0.5)
	var n := int(c.p.get("rain_n", 5)) + (2 if c.enraged else 0)
	for k in n:
		var x := c.target.position.x + c.rng.randf_range(-56.0, 56.0)
		c.fire.append({"from": Vector2(x, c.target.position.y - 170.0 - k * 22.0), "vel": Vector2(0.0, 160.0),
			"grav": 140.0, "damage": int(c.p.get("shot_damage", 12)), "look": "polline"})
