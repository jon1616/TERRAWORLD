class_name PassNero
extends GenPass
## Il mondo dove cadde il Seme Nero (voce 72, `params["nero"]`): attorno alla cupola del Cuore la roccia è tutta
## avvizzita, con punte di vuotite che salgono dal pavimento delle grotte. Il resto lo fa il gene Cuore nero (macchie di
## Avvizzimento ovunque) e il Guardiano, che qui è l'Avvizzitore (`Guardian.info`).


func title() -> String:
	return "Seme Nero"


func run(w: World, c: GenContext) -> void:
	if not bool(c.params.get("nero", false)):
		return
	var cu: Vector2i = c.notes.get("cuore", Vector2i(-1, -1))
	if cu.x < 0:
		return
	for y in range(cu.y - 55, cu.y + 35):
		for x in range(cu.x - 80, cu.x + 80):
			if not w.inside(x, y):
				continue
			var d := Vector2((x - cu.x) / 80.0, (y - cu.y) / 50.0).length()
			if d > 1.0:
				continue
			var t := w.tile(x, y)
			if t in [TileDefs.STONE, TileDefs.SCISTO, TileDefs.VUOTITE, TileDefs.RADICE]:
				w.set_tile(x, y, TileDefs.AVV_PIETRA)
			elif t == TileDefs.DIRT:
				w.set_tile(x, y, TileDefs.AVV_TERRA)
			elif t == TileDefs.AIR and d > 0.5 and w.solid(x, y + 1) and c.rng.randf() < 0.05:
				for k in c.rng.randi_range(1, 3):             # una punta di vuotite
					if w.inside(x, y - k) and w.tile(x, y - k) == TileDefs.AIR:
						w.set_tile(x, y - k + 1, TileDefs.VUOTITE)
	c.notes["nero"] = true
