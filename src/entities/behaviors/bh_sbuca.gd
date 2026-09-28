class_name BhSbuca
extends Behavior
## Sbuca da sotto (voce 130): aspetta nella terra, scivola sotto il Germogliato, la terra trema e si solleva polvere
## (il segnale: ci si sposta), poi salta fuori; dopo un po' torna a scavare. Parametri: sight, windup, out_time.

var phase := 0                        # 0 sotto terra · 1 annuncia · 2 fuori
var timer := 0.0
var _dust := 0.0


func tick(c: Creature, dt: float) -> void:
	var cell := Vector2i(floori(c.position.x / 16.0), floori(c.position.y / 16.0))
	var inside := c.world.solid(cell.x, cell.y)
	match phase:
		0:
			c.ghost = true
			c.buried = inside
			c.busy = true
			if not inside:
				c.want_fly = Vector2.ZERO
				return
			if Behavior.sees(c, float(c.p.get("sight", 14))):
				var goal := Vector2(c.target.position.x, c.target.position.y + 40.0)
				var to := goal - c.position
				c.want_fly = to.normalized() * c.speed * 1.3 if to.length() > 6.0 else Vector2.ZERO
				if absf(to.x) < 10.0:
					phase = 1
					timer = 0.7 * float(c.p.get("windup", 1.0))
					c.telegraph(timer)
			else:
				c.want_fly = Vector2.ZERO
		1:
			c.want_fly = Vector2.ZERO
			timer -= dt
			_dust -= dt
			if _dust <= 0.0 and c.get_parent():
				_dust = 0.12                     # la terra trema sopra di lei
				var up := cell
				for i in 6:
					if not c.world.solid(up.x, up.y - 1):
						break
					up.y -= 1
				Fx.dust(c.get_parent(), Vector2(up) * 16.0 + Vector2(8, 0), TileDefs.dust_colors(c.world.tile(up.x, up.y)))
			if timer <= 0.0:
				phase = 2
				timer = float(c.p.get("out_time", 5.0))
				c.want_fly = Vector2(0, -420)
				c.vel = Vector2(0, -420)
		2:
			if inside:
				c.want_fly = Vector2(0, -420)
				return
			c.ghost = false
			c.buried = false
			c.busy = false
			timer -= dt
			if timer <= 0.0 and c.on_floor:
				phase = 0                        # torna giù
