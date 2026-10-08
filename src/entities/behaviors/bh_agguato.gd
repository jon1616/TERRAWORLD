class_name BhAgguato
extends Behavior
## Agguato dal soffitto (voce 22): la creatura nasce e sale ad appendersi alla roccia sopra di sé (a testa in giù),
## immobile; quando il bersaglio passa sotto (poche tessere di lato) si lascia cadere e da lì fanno gli altri
## comportamenti. Senza un soffitto vicino (in superficie) resta a terra.

var _ready := false


func tick(c: Creature, _dt: float) -> void:
	if not _ready:
		_ready = true
		# (Roadmap 54, voce 426) sale finché una tessera sopra il corpo, in tutta la sua larghezza, è roccia, e si
		# appende proprio sotto: prima guardava solo la colonna di mezzo e saliva a scatti di una tessera, così il
		# corpo finiva fino a 15 px dentro il soffitto
		var x0 := floori((c.position.x - c.half.x) / 16.0)
		var x1 := floori((c.position.x + c.half.x - 0.01) / 16.0)
		var head := floori((c.position.y - c.half.y) / 16.0)
		for k in range(1, 15):
			var row := head - k
			var hit := false
			for x in range(x0, x1 + 1):
				if c.world.solid(x, row):
					hit = true
			if hit:
				c.position.y = (row + 1) * 16.0 + c.half.y + 0.01
				c.anchored = true
				break
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
