class_name BhOnda
extends Behavior
## Onda d'urto (voce 378): ogni tanto si annuncia e batte a terra: due file di colpi bassi corrono sul pavimento, una
## per parte. Si salta. Parametri: wave_every, wave_n, shot_damage, shot_speed.

var t := 3.0
var wind := 0.0


func tick(c: Creature, dt: float) -> void:
	if wind > 0.0:
		wind -= dt
		c.shake = 1.0
		if wind <= 0.0:
			c.shake = 0.0
			c.busy = false
			var y := c.position.y + c.half.y - 4.0
			for side in [-1.0, 1.0]:
				for k in int(c.p.get("wave_n", 3)):
					c.fire.append({"from": Vector2(c.position.x + side * (c.half.x + 4.0 + k * 10.0), y),
						"vel": Vector2(side * float(c.p.get("shot_speed", 200.0)), 0.0), "grav": 0.0,
						"damage": int(c.p.get("shot_damage", 12)), "look": "brace"})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0 or not c.on_floor or not Behavior.sees(c, float(c.p.get("sight", 20))):
		return
	t = float(c.p.get("wave_every", 5.0))
	wind = 0.6
	c.busy = true
	c.want_x = 0.0
	c.telegraph(wind)
