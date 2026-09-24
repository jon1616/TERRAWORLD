class_name PassTorceProva
extends GenPass
## PROVVISORIA: torce già accese nelle grotte, per mostrare la luce finché non esistono scrigni, rovine e oggetti da
## trovare. Una in fondo a ogni galleria d'ingresso, poi altre sparse e distanziate.

const MIN_DIST := 16.0
const MAX_DEPTH := 400


func title() -> String:
	return "Torce (prova)"


func run(w: World, c: GenContext) -> void:
	for e in c.notes.get("ingressi", []):
		w.add_torch(e)
		w.set_decor(e.x, e.y, 0)
	for y in range(1, w.h - 1):
		for x in w.w:
			var i := y * w.w + x
			if w.tiles[i] != TileDefs.AIR or w.walls[i] == 0 or w.tiles[i + w.w] == TileDefs.AIR:
				continue
			var dep := y - w.surface[x]
			if dep < 10 or dep > MAX_DEPTH or c.rng.randf() > 0.03:
				continue
			var cell := Vector2i(x, y)
			if w.torch_near(cell, MIN_DIST):
				continue
			w.add_torch(cell)
			w.set_decor(x, y, 0)
