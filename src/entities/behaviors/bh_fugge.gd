class_name BhFugge
extends Behavior
## Fugge (voce 23, le creature iridate): quando vede il Germogliato scappa dalla parte opposta, saltando i muri; chi
## vola scappa verso l'alto e lontano. Non attacca. Se non la si prende in tempo svanisce (`Ancient.tick`).

var wander := 0.0
var dir := 1.0
var _back := 0.0                       # (voce 425) torna indietro da un muro troppo alto per tanto


func tick(c: Creature, dt: float) -> void:
	var scared := Behavior.sees(c, float(c.p.get("flee", 16)))
	_back = maxf(_back - dt, 0.0)
	if scared and _back > 0.0:
		pass
	elif scared:
		dir = -signf(c.target.position.x - c.position.x)
		if dir == 0.0:
			dir = 1.0
	else:
		wander -= dt
		if wander <= 0.0:
			wander = c.rng.randf_range(1.5, 3.5)
			dir = [-1.0, 1.0, 0.0][c.rng.randi_range(0, 2)]
	c.facing = int(dir) if dir != 0.0 else c.facing
	if c.fly:
		var away := Vector2(dir, -0.6 if scared else c.rng.randf_range(-0.3, 0.3)).normalized()
		c.want_fly = away * c.speed * (1.3 if scared else 0.5)
		return
	if c.on_floor and dir != 0.0 and c.wall_ahead(int(dir)) and not c.can_hop(int(dir), 300.0):
		dir = -dir                             # (voce 425) un muro troppo alto: torna indietro, ti scarta di lato
		c.facing = int(dir)
		_back = 1.5
	c.want_x = dir * (1.3 if scared else 0.5)
	if c.on_floor and dir != 0.0 and (c.wall_ahead(int(dir)) or (scared and c.rng.randf() < dt * 1.5)):
		c.vel.y = -300.0
		c.on_floor = false
