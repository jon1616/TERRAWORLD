class_name BhAgguato
extends Behavior
## Agguato dal soffitto (voce 22): la creatura nasce e sale ad appendersi alla roccia sopra di sé (a testa in giù),
## immobile; quando il bersaglio passa sotto (poche tessere di lato) si lascia cadere e da lì fanno gli altri
## comportamenti. Senza un soffitto vicino (in superficie) resta a terra.

var _ready := false


func tick(c: Creature, _dt: float) -> void:
	if not _ready:
		_ready = true
		var start := c.position
		for k in 14:
			var top := floori((c.position.y - c.half.y - 1.0) / 16.0)
			if c.world.solid(floori(c.position.x / 16.0), top):
				c.anchored = true
				break
			c.position.y -= 16.0
		if not c.anchored:
			c.position = start
	if not c.anchored:
		return
	c.busy = true
	if c.target == null:
		return
	var d := c.target.position - c.position
	if absf(d.x) < float(c.p.get("drop_x", 3)) * 16.0 and d.y > 0.0 and d.y < 16.0 * 16.0:
		c.anchored = false
		c.busy = false
		c.vel = Vector2.ZERO
