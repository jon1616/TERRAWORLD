class_name BhRotola
extends Behavior
## Rotola (voce 378): si chiude a palla e rotola veloce verso il bersaglio, travolgendo; poi si riapre stordita un
## attimo (è il momento di colpirla). Parametri: roll_every, roll_speed, roll_time.

var t := 3.0
var phase := 0
var timer := 0.0
var dir := 1.0


func tick(c: Creature, dt: float) -> void:
	match phase:
		0:
			t -= dt * (1.4 if c.enraged else 1.0)
			if t <= 0.0 and c.on_floor and Behavior.sees(c, float(c.p.get("sight", 20))):
				phase = 1
				timer = 0.5
				c.busy = true
				dir = signf(c.target.position.x - c.position.x)
				c.telegraph(timer, dir)
		1:
			c.crouch = 1.0
			c.want_x = 0.0
			timer -= dt
			if timer <= 0.0:
				phase = 2
				timer = float(c.p.get("roll_time", 1.6))
		2:
			c.crouch = 1.0
			c.want_x = dir
			c.vel.x = dir * float(c.p.get("roll_speed", 260.0))
			c.facing = 1 if dir >= 0.0 else -1
			timer -= dt
			if timer <= 0.0:
				phase = 0
				t = float(c.p.get("roll_every", 5.0))
				c.crouch = 0.0
				c.busy = false
				c.stun = maxf(c.stun, 0.8)
