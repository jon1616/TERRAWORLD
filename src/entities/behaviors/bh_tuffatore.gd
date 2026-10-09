class_name BhTuffatore
extends Behavior
## Tuffatore (voce 130): vive nel liquido (con «nuota», messo dopo di lui) e, quando sei vicino alla riva, fa le bolle
## (il segnale) e salta fuori verso di te, poi ricade. Si pesca, si prosciuga lo specchio o si aspetta lontano dalla
## riva. Parametri: leap_range, leap_cool.

var cool := 0.0
var phase := 0
var timer := 0.0


func tick(c: Creature, dt: float) -> void:
	cool = maxf(cool - dt, 0.0)
	var w := c.world
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	match phase:
		0:
			if cool > 0.0 or c.target == null or w.liq(cell.x, cell.y) < 3:
				return
			if c.target.position.distance_to(c.position) < float(c.p.get("leap_range", 9)) * 16.0 \
					and c.target.position.y < c.position.y:
				phase = 1
				timer = 0.5 * float(c.p.get("windup", 1.0))
				c.telegraph(timer, 0.0, c.target.position)      # voce 485
		1:
			c.want_fly = Vector2(0, -20)
			timer -= dt
			if timer <= 0.0:
				phase = 2
				timer = 0.45
		2:
			c.busy = true
			var to := c.target.position - c.position if c.target else Vector2.UP
			c.want_fly = Vector2(clampf(to.x * 2.0, -260.0, 260.0), -360.0)
			timer -= dt
			if timer <= 0.0:
				phase = 3
				timer = 0.9
		3:
			c.want_fly = Vector2(0, 300)           # ricade nel liquido
			timer -= dt
			if timer <= 0.0 or (w.liq(cell.x, cell.y) >= 3 and timer < 0.6):
				phase = 0
				c.busy = false
				cool = float(c.p.get("leap_cool", 4.0))
