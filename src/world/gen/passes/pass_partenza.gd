class_name PassPartenza
extends GenPass
## Il punto di partenza del giocatore e le prime creature attorno.


func title() -> String:
	return "Partenza"


func run(w: World, c: GenContext) -> void:
	w.spawn.y = w.surface[w.spawn.x] - 1
	place_creatures(w, c.rng, c.notes.get("ingressi", []))


## Le creature non si salvano: si rimettono attorno alla partenza anche quando un mondo viene caricato.
static func place_creatures(w: World, rng: RandomNumberGenerator, cave_ends: Array = []) -> void:
	w.slimes.clear()
	for off in [-12, 11, -30, 34]:
		var x: int = clampi(w.spawn.x + off, 0, w.w - 1)
		var y := w.surface[x] - 2
		while y > 0 and w.solid(x, y):
			y -= 1
		w.slimes.append({"cell": Vector2i(x, y), "kind": rng.randi_range(0, 1)})
	if cave_ends.size() > 0:
		var e: Vector2i = cave_ends[0]
		w.slimes.append({"cell": e + Vector2i(2, -1), "kind": 2})
