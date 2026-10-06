class_name BhArrampica
extends Behavior
## Arrampica (voce 378, per chi cammina): se un muro gli sbarra la strada ci sale sopra invece di fermarsi. Così nessuna
## parete alta lo tiene lontano. Parametri: climb (velocità di salita).

const S := 16


func tick(c: Creature, _dt: float) -> void:
	if c.fly or c.want_x == 0.0:
		return
	var side := c.position.x + signf(c.want_x) * (c.half.x + 2.0)
	var cy := int(floorf(c.position.y / S))
	if c.world.solid(int(floorf(side / S)), cy) or c.world.solid(int(floorf(side / S)), cy + 1):
		c.vel.y = minf(c.vel.y, -float(c.p.get("climb", 110.0)))
