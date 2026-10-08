class_name BhTeletrasporto
extends Behavior
## Teletrasporto (voce 22): quando vede il bersaglio lontano, ogni tanto svanisce (un attimo in cui si fa trasparente)
## e ricompare a poche tessere da lui, su un pavimento libero.

var cool := 2.0
var fading := 0.0


func tick(c: Creature, dt: float) -> void:
	cool -= dt
	if fading > 0.0:
		fading -= dt
		c.want_x = 0.0
		c.modulate.a = clampf(fading / 0.45, 0.1, 1.0)
		if fading <= 0.0:
			_jump(c)
			c.modulate.a = 1.0
			c.busy = false
		return
	if cool > 0.0 or not Behavior.sees(c, float(c.p.get("sight", 26))):
		return
	if c.position.distance_to(c.target.position) < 4.0 * 16.0:
		return
	fading = 0.45
	cool = float(c.p.get("blink_every", 3.5))
	c.busy = true


## Ricompare accanto al bersaglio, da un lato o dall'altro, dove c'è posto e pavimento.
func _jump(c: Creature) -> void:
	var tc := Vector2i(floori(c.target.position.x / 16.0), floori(c.target.position.y / 16.0))
	for k in 12:
		var dx := c.rng.randi_range(2, 4) * (1 if c.rng.randf() < 0.5 else -1)
		for dy in range(-2, 4):
			var q := tc + Vector2i(dx, dy)
			if not c.world.solid(q.x, q.y) and not c.world.solid(q.x, q.y - 1) and c.world.solid(q.x, q.y + 1):
				if c.get_parent():
					Fx.puff(c.get_parent(), c.position, Color(0.8, 1.6, 1.7))
				var to := Vector2(q.x * 16 + 8, (q.y + 1) * 16 - c.half.y - 0.1)
				if not c.fly and TileBody.collides(c.world, to, c.half - Vector2(1, 1)):
					continue                          # (voce 426) il corpo intero non ci sta
				c.position = to
				c.vel = Vector2.ZERO
				c.facing = 1 if tc.x > q.x else -1
				if c.get_parent():
					Fx.puff(c.get_parent(), c.position, Color(0.8, 1.6, 1.7))
				return
