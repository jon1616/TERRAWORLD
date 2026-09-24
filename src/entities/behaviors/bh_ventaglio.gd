class_name BhVentaglio
extends Behavior
## Ventaglio: ogni tanto apre la bocca e scaglia più colpi a ventaglio verso il bersaglio. Nella seconda fase (vedi
## `Creature.enraged`) tira più spesso e un colpo in più.

var t := 2.0


func tick(c: Creature, dt: float) -> void:
	t -= dt * (1.4 if c.enraged else 1.0)
	c.mouth = t < 0.4
	if t > 0.0:
		return
	t = float(c.p.get("fan_rate", 3.0))
	if not Behavior.sees(c, float(c.p.get("sight", 30))):
		return
	var from := c.position
	var aim := (c.target.position - from).normalized()
	var n: int = int(c.p.get("fan_n", 5)) + (1 if c.enraged else 0)
	var spread: float = c.p.get("fan_spread", 0.8)
	var speed: float = c.p.get("shot_speed", 170.0)
	for k in n:
		var a := -spread * 0.5 + spread * k / maxf(n - 1, 1)
		c.fire.append({"from": from + aim * c.half.x, "vel": aim.rotated(a) * speed,
			"grav": float(c.p.get("shot_grav", 40.0)), "damage": int(c.p.get("shot_damage", 12))})
