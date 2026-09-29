class_name BhLucciolaVena
extends Behavior
## Lucciola di vena (Roadmap 19, voce 207): innocua, ama la Linfa che scorre. Se c'è una vena entro `smell` tessere ci
## volteggia sopra (dopo «deriva», che la fa ondeggiare); le reti grandi ne attirano sciami. Durante la Tempesta di Linfa
## nascono più spesso (il `pool` dell'evento).

var look_t := 0.0
var t := 0.0
var spot := Vector2.INF


func tick(c: Creature, dt: float) -> void:
	t += dt
	look_t -= dt
	if look_t <= 0.0:
		look_t = 2.0
		spot = _find(c)
	if spot == Vector2.INF or c.busy:
		return
	var goal := spot + Vector2(sin(t * 1.3) * 20.0, -20.0 + cos(t * 0.9) * 8.0)
	c.want_fly = (goal - c.position) * 1.5
	if absf(c.want_fly.x) > 2.0:
		c.facing = 1 if c.want_fly.x > 0.0 else -1


func _find(c: Creature) -> Vector2:
	var cx := floori(c.position.x / 16.0)
	var cy := floori(c.position.y / 16.0)
	var r := int(c.p.get("smell", 12))
	for d in range(0, r + 1, 2):
		for dy in range(-d, d + 1, 2):
			for dx in [-d, d]:
				if VeinsData.tier(c.world.vein_at(cx + dx, cy + dy)) > 0:
					return Vector2(cx + dx, cy + dy) * 16.0 + Vector2(8, 8)
	return Vector2.INF
