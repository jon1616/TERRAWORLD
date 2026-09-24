class_name PassPartenza
extends GenPass
## Il punto di partenza del giocatore e le prime creature attorno.


func title() -> String:
	return "Partenza"


func run(w: World, c: GenContext) -> void:
	w.spawn.y = w.surface[w.spawn.x] - 1
	for off in [-12, 11, -30, 34]:
		var x: int = w.spawn.x + off
		w.slimes.append({"cell": Vector2i(x, w.surface[x] - 2), "kind": c.rng.randi_range(0, 1)})
	var ends: Array = c.notes.get("ingressi", [])
	if ends.size() > 0:
		var e: Vector2i = ends[0]
		w.slimes.append({"cell": e + Vector2i(2, -1), "kind": 2})
