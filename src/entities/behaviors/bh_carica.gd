class_name BhCarica
extends Behavior
## Carica: quando il bersaglio è sulla sua linea (quasi alla stessa altezza e abbastanza vicino) si ferma un attimo,
## trema, poi scatta a testa bassa. Mentre carica gli altri comportamenti di movimento tacciono (`busy`).

var cool := 0.0
var phase := 0                        # 0 pronto · 1 prende la rincorsa · 2 carica
var timer := 0.0
var dir := 1.0


func tick(c: Creature, dt: float) -> void:
	cool = maxf(cool - dt, 0.0)
	match phase:
		0:
			if cool > 0.0 or not c.on_floor or c.target == null or not Behavior.may_attack(c):
				return
			var d := c.target.position - c.position
			if absf(d.y) < 20.0 and absf(d.x) < float(c.p.get("charge_range", 10)) * 16.0:
				phase = 1
				timer = 0.4 * float(c.p.get("windup", 1.0))
				c.telegraph(timer)                 # voce 127
				dir = signf(d.x)
				c.facing = int(dir)
				c.busy = true
		1:
			c.want_x = 0.0
			c.shake = 1.0
			timer -= dt
			if timer <= 0.0:
				phase = 2
				timer = float(c.p.get("charge_time", 0.8))
		2:
			c.shake = 0.0
			c.vel.x = dir * float(c.p.get("charge", 220.0))
			c.want_x = dir
			timer -= dt
			if timer <= 0.0 or c.wall_ahead(int(dir)):
				phase = 0
				cool = float(c.p.get("charge_cool", 3.0))
				c.busy = false
