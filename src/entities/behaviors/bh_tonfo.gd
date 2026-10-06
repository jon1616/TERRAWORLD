class_name BhTonfo
extends Behavior
## Tonfo (voce 378): salta altissimo verso il bersaglio e ricade con un colpo che scuote il pavimento (due file di
## colpi bassi). Parametri: slam_every, slam_jump, shot_damage.

var t := 4.0
var air := false


func tick(c: Creature, dt: float) -> void:
	if air:
		if c.on_floor and c.vel.y >= 0.0:
			air = false
			c.busy = false
			var y := c.position.y + c.half.y - 4.0
			for side in [-1.0, 1.0]:
				for k in 3:
					c.fire.append({"from": Vector2(c.position.x + side * (c.half.x + 4.0 + k * 10.0), y),
						"vel": Vector2(side * 230.0, 0.0), "grav": 0.0, "damage": int(c.p.get("shot_damage", 12)), "look": "brace"})
		return
	t -= dt * (1.4 if c.enraged else 1.0)
	if t > 0.0 or not c.on_floor or not Behavior.sees(c, float(c.p.get("sight", 20))):
		return
	t = float(c.p.get("slam_every", 6.0))
	c.telegraph(0.4)
	var dx := clampf(c.target.position.x - c.position.x, -200.0, 200.0)
	c.vel = Vector2(dx * 1.1, -float(c.p.get("slam_jump", 420.0)))
	c.on_floor = false
	c.busy = true
	air = true
