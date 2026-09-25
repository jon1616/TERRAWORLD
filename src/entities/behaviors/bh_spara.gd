class_name BhSpara
extends Behavior
## Spara: se il bersaglio è abbastanza vicino, ogni tanto apre la bocca e lancia un colpo verso di lui (con un po'
## di anticipo sulla caduta del colpo). Il colpo lo crea la fauna (`c.fire`).

var t := 1.0


func tick(c: Creature, dt: float) -> void:
	t -= dt
	c.mouth = t < 0.35
	if t > 0.0:
		return
	t = float(c.p.get("rate", 2.5))
	if not Behavior.sees(c, float(c.p.get("sight", 18))):
		return
	var from := c.position + Vector2(0, -c.half.y)
	var to := c.target.position - from
	var speed: float = c.p.get("shot_speed", 190.0)
	var grav: float = c.p.get("shot_grav", 180.0)
	var flight := to.length() / speed
	var v := to / maxf(flight, 0.05)
	v.y -= 0.5 * grav * flight
	c.facing = 1 if to.x > 0.0 else -1
	c.fire.append({"from": from, "vel": v, "grav": grav, "damage": int(c.p.get("shot_damage", 10)),
		"look": String(c.p.get("shot_look", "spora")), "slow": float(c.p.get("slow", 0.0))})
