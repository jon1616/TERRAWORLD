class_name BhPicchiata
extends Behavior
## Picchiata (Roadmap 16, voce 160, i rapaci del cielo): sale sopra il bersaglio, si ferma un attimo (il «!» e il
## tremito: il segnale) e cala in linea retta. La contromossa: spostarsi di lato quando trema, o colpirla mentre
## risale. Mentre sale e cala gli altri movimenti tacciono (`busy`). Parametri: sight, rise (tessere sopra il bersaglio),
## dive_speed, dive_time, dive_every, windup.

var cool := 2.0
var phase := 0                         # 0 attesa · 1 salita · 2 segnale · 3 picchiata
var timer := 0.0
var dir := Vector2.ZERO


func tick(c: Creature, dt: float) -> void:
	match phase:
		0:
			cool -= dt * (1.4 if c.enraged else 1.0)
			if cool <= 0.0 and Behavior.may_attack(c) and Behavior.sees(c, float(c.p.get("sight", 26))):
				phase = 1
				timer = 2.5
				c.busy = true
		1:
			if c.target == null:
				_end(c)
				return
			var goal: Vector2 = c.target.position + Vector2(0, -float(c.p.get("rise", 7)) * 16.0)
			var to := goal - c.position
			c.want_fly = to.normalized() * c.speed * 1.4
			c.facing = 1 if c.target.position.x >= c.position.x else -1
			timer -= dt
			if to.length() < 28.0 or timer <= 0.0:
				phase = 2
				timer = 0.5 * float(c.p.get("windup", 1.0))
				c.telegraph(timer, 0.0, c.target.position)      # voce 485: dove piomba
		2:
			c.shake = 1.0
			c.want_fly = Vector2.ZERO
			timer -= dt
			if timer <= 0.0:
				phase = 3
				timer = float(c.p.get("dive_time", 0.6))
				dir = (c.target.position - c.position).normalized() if c.target else Vector2.DOWN
				c.facing = 1 if dir.x >= 0.0 else -1
		3:
			c.shake = 0.0
			c.vel = dir * float(c.p.get("dive_speed", 330.0))
			c.want_fly = c.vel
			timer -= dt
			if timer <= 0.0:
				_end(c)


func _end(c: Creature) -> void:
	phase = 0
	cool = float(c.p.get("dive_every", 5.0))
	c.busy = false
	c.shake = 0.0
