class_name PassIngressi
extends GenPass
## Gallerie che scendono dalla superficie: una vicina alla partenza, le altre sparse lungo il mondo.
## Lascia in `c.notes["ingressi"]` la cella in fondo a ciascuna.


func title() -> String:
	return "Ingressi"


func run(w: World, c: GenContext) -> void:
	var ends: Array[Vector2i] = []
	ends.append(_dig(w, c.rng, w.spawn.x + 16, 75))
	var x := 120 + c.rng.randi_range(0, 150)
	while x < w.w - 120:
		if absi(x - w.spawn.x) > 40:
			ends.append(_dig(w, c.rng, x, c.rng.randi_range(60, 170)))
		x += c.rng.randi_range(220, 420)
	c.notes["ingressi"] = ends


func _dig(w: World, rng: RandomNumberGenerator, x0: int, steps: int) -> Vector2i:
	var p := Vector2(x0, w.surface[x0] - 1)
	var ang := PI * 0.5 + rng.randf_range(-0.4, 0.4)
	for step in steps:
		var r := rng.randf_range(1.7, 2.7)
		for y in range(int(p.y - r) - 1, int(p.y + r) + 2):
			for x in range(int(p.x - r) - 1, int(p.x + r) + 2):
				if x < 1 or x >= w.w - 1 or y < 0 or y >= w.h - 1:
					continue
				if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
					w.tiles[y * w.w + x] = TileDefs.AIR
		ang = clampf(ang + rng.randf_range(-0.3, 0.3), 0.45, 2.7)
		p += Vector2(cos(ang), sin(ang))
	var e := Vector2i(clampi(int(p.x), 1, w.w - 2), clampi(int(p.y), 0, w.h - 2))
	while e.y < w.h - 2 and w.tile(e.x, e.y + 1) == TileDefs.AIR:
		e.y += 1
	return e
