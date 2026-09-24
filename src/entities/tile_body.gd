class_name TileBody
extends RefCounted
## Movimento contro la griglia di tessere (prima in orizzontale, poi in verticale), con il gradino
## automatico di una tessera come in Terraria.

const S := 16.0


static func collides(world: World, c: Vector2, half: Vector2) -> bool:
	var x0 := int(floorf((c.x - half.x) / S))
	var x1 := int(floorf((c.x + half.x - 0.001) / S))
	var y0 := int(floorf((c.y - half.y) / S))
	var y1 := int(floorf((c.y + half.y - 0.001) / S))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if world.solid(x, y):
				return true
	return false


## Passerelle: reggono solo chi scende e aveva i piedi sopra la passerella prima del passo (`through` = ci si lascia
## cadere attraverso).
static func _plat_below(world: World, pos: Vector2, ny: float, half: Vector2) -> float:
	var feet0 := pos.y + half.y
	var feet1 := ny + half.y
	var row := int(floorf(feet1 / S))
	if feet0 > row * S + 0.5:
		return -1.0
	var x0 := int(floorf((pos.x - half.x) / S))
	var x1 := int(floorf((pos.x + half.x - 0.001) / S))
	for x in range(x0, x1 + 1):
		if world.plat(x, row):
			return row * S - half.y - 0.01
	return -1.0


static func move(world: World, pos: Vector2, half: Vector2, vel: Vector2, dt: float, was_on_floor: bool, through := false) -> Dictionary:
	var stepped := 0.0
	var nx := pos.x + vel.x * dt
	if collides(world, Vector2(nx, pos.y), half):
		if was_on_floor and not collides(world, Vector2(nx, pos.y - S - 0.5), half) \
				and not collides(world, Vector2(pos.x, pos.y - S - 0.5), half):
			# gradino: la base sale di una tessera
			var base := roundf((pos.y + half.y) / S) * S
			pos.y = base - S - half.y - 0.01
			stepped = S
		else:
			if vel.x > 0.0:
				nx = floorf((nx + half.x) / S) * S - half.x - 0.01
			else:
				nx = (floorf((nx - half.x) / S) + 1.0) * S + half.x + 0.01
			vel.x = 0.0
	pos.x = nx
	var on_floor := false
	var ny := pos.y + vel.y * dt
	if collides(world, Vector2(pos.x, ny), half):
		if vel.y > 0.0:
			ny = floorf((ny + half.y) / S) * S - half.y - 0.01
			on_floor = true
		else:
			ny = (floorf((ny - half.y) / S) + 1.0) * S + half.y + 0.01
		vel.y = 0.0
	elif vel.y > 0.0 and not through:
		var top := _plat_below(world, pos, ny, half)
		if top >= 0.0:
			ny = top
			vel.y = 0.0
			on_floor = true
	pos.y = ny
	return {"pos": pos, "vel": vel, "floor": on_floor, "stepped": stepped}
