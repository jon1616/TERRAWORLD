class_name BhBombarda
extends Behavior
## Bombarda (voce 22, per chi vola): quando è quasi sopra il bersaglio lascia cadere un colpo che precipita (polline,
## schegge). Va con «vola» e il parametro `hover` (quanto sta alta sopra il bersaglio).

var t := 1.5


func tick(c: Creature, dt: float) -> void:
	var was := t
	t -= dt
	c.mouth = t < 0.3
	if was >= 0.4 and t < 0.4:
		c.telegraph(0.4)                           # voce 127
	if t > 0.0 or c.target == null:
		return
	var d := c.target.position - c.position
	if absf(d.x) > 48.0 or d.y < 0.0 or not Behavior.sees(c, float(c.p.get("sight", 20))):
		t = 0.3
		return
	t = float(c.p.get("rate", 2.0))
	c.fire.append({"from": c.position + Vector2(0, c.half.y), "vel": Vector2(d.x * 0.4, 40.0),
		"grav": float(c.p.get("shot_grav", 420.0)), "damage": int(c.p.get("shot_damage", 12)),
		"look": String(c.p.get("shot_look", "spora"))})
