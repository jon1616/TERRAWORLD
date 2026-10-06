class_name BhRaffica
extends Behavior
## Raffica (voce 378): tre colpi mirati uno dopo l'altro, veloci. Parametri: burst_every, burst_n, shot_damage,
## shot_speed.

var t := 2.5
var left := 0
var gap := 0.0


func tick(c: Creature, dt: float) -> void:
	if left > 0:
		gap -= dt
		if gap <= 0.0 and c.target != null:
			gap = 0.15
			left -= 1
			var aim := (c.target.position - c.position).normalized()
			c.fire.append({"from": c.position + aim * (c.half.x + 2.0), "vel": aim * float(c.p.get("shot_speed", 260.0)),
				"grav": 0.0, "damage": int(c.p.get("shot_damage", 10)), "look": "spora"})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	c.mouth = t < 0.3
	if t > 0.0:
		return
	t = float(c.p.get("burst_every", 4.0))
	if Behavior.sees(c, float(c.p.get("sight", 22))):
		c.telegraph(0.3)
		left = int(c.p.get("burst_n", 3))
		gap = 0.3
