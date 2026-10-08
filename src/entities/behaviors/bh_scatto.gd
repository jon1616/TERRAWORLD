class_name BhScatto
extends Behavior
## Scatto (per chi vola): ogni tanto si ferma, trema e si lancia in linea retta verso il bersaglio. Mentre scatta gli
## altri movimenti tacciono (`busy`). Nella seconda fase scatta più spesso.

var t := 4.0
var phase := 0                         # 0 attesa · 1 rincorsa · 2 scatto
var timer := 0.0
var dir := Vector2.ZERO


func tick(c: Creature, dt: float) -> void:
	match phase:
		0:
			t -= dt * (1.5 if c.enraged else 1.0)
			if t <= 0.0 and Behavior.may_attack(c) and Behavior.sees(c, float(c.p.get("sight", 30))):
				phase = 1
				timer = 0.5 * float(c.p.get("windup", 1.0))
				c.telegraph(timer)                 # voce 127
				c.busy = true
				c.want_fly = Vector2.ZERO
		1:
			c.shake = 1.0
			c.want_fly = Vector2.ZERO
			timer -= dt
			if timer <= 0.0:
				phase = 2
				timer = float(c.p.get("dash_time", 0.5))
				dir = (c.target.position - c.position).normalized()
				if not c.fly:
					dir = Vector2(1.0 if dir.x >= 0.0 else -1.0, 0.0)   # chi cammina scatta rasoterra
				c.facing = 1 if dir.x >= 0.0 else -1
		2:
			c.shake = 0.0
			if c.fly:
				c.vel = dir * float(c.p.get("dash_speed", 280.0))
			else:
				c.vel.x = dir.x * float(c.p.get("dash_speed", 280.0))
			c.want_fly = c.vel
			timer -= dt
			if timer <= 0.0:
				phase = 0
				t = float(c.p.get("dash_every", 6.0))
				c.busy = false
