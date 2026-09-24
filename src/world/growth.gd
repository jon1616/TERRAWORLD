class_name Growth
extends RefCounted
## Ciò che cresce da solo nel mondo col passare del tempo (anche fuori dalla visuale). Per ora i germogli
## d'albero-lanterna: quando è il momento, se c'è spazio diventano alberi, altrimenti riprovano più tardi.


static func tick(world: World, view: WorldView, light: LightMap, dt: float) -> void:
	var rng := RandomNumberGenerator.new()
	for c in world.saplings.keys():
		if world.decor_at(c.x, c.y) != TileDefs.DECOR_SPROUT:
			world.saplings.erase(c)
			continue
		world.saplings[c] = float(world.saplings[c]) - dt
		if float(world.saplings[c]) > 0.0:
			continue
		if not world.tree_fits(c):
			world.saplings[c] = 30.0
			continue
		world.saplings.erase(c)
		world.set_decor(c.x, c.y, 0)
		var t := Vector3i(c.x, c.y, rng.randi_range(0, PassAlberi.VARIANTS - 1))
		world.add_tree(Vector2i(t.x, t.y), t.z)
		view.refresh_around(c)
		view.grow_tree(t)
		light.dirty = true
