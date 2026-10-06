class_name BhRaggio
extends Behavior
## Raggio (voce 378): si ferma, punta il bersaglio (si annuncia) e scaglia una fila dritta di colpi velocissimi, come
## un raggio. Parametri: beam_every, beam_n, shot_damage.

var t := 3.0
var wind := 0.0
var aim := Vector2.RIGHT


func tick(c: Creature, dt: float) -> void:
	if wind > 0.0:
		wind -= dt
		c.want_x = 0.0
		c.want_fly = Vector2.ZERO
		if wind <= 0.0:
			c.busy = false
			for k in int(c.p.get("beam_n", 6)):
				c.fire.append({"from": c.position + aim * (c.half.x + 2.0), "vel": aim * (320.0 + k * 45.0), "grav": 0.0,
					"damage": int(c.p.get("shot_damage", 12)), "look": "scheggia_nera"})
		return
	t -= dt * (1.3 if c.enraged else 1.0)
	if t > 0.0 or not Behavior.sees(c, float(c.p.get("sight", 26))):
		return
	t = float(c.p.get("beam_every", 5.0))
	aim = (c.target.position - c.position).normalized()
	c.facing = 1 if aim.x >= 0.0 else -1
	wind = 0.8
	c.busy = true
	c.telegraph(wind)
