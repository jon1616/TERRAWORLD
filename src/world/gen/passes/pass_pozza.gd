class_name PassPozza
extends GenPass
## La Pozza di Linfa antica (Roadmap 45, voce 396; la usa `Finds`, le trasformazioni in `TransmuteData`): una per mondo,
## nelle Profondità della Linfa, in una piccola camera dei Seminatori scavata apposta (pavimento e pareti di pietra
## dei Seminatori, due rune accese), lontana dalla partenza. Chiede `is_free` e fa `claim`; se non trova un posto
## libero dopo molte prove la mette dove capita (è una promessa di ogni mondo, come la firma).

const ROOM := Vector2i(13, 7)


func title() -> String:
	return "Pozza di Linfa antica"


func run(w: World, c: GenContext) -> void:
	if bool(c.params.get("giardino", false)):
		return
	var rng := c.rng
	for tries in 400:
		var strict := tries < 300
		var x := rng.randi_range(80, w.w - 81 - ROOM.x)
		var st := 3
		var top := w.surface[x] + StrataData.top(st) + 8
		var bot := mini(w.surface[x] + StrataData.top(st + 1) - 8, w.h - 20)
		if bot <= top:
			continue
		var y := rng.randi_range(top, bot)          # il pavimento della camera
		var area := Rect2i(x - 1, y - ROOM.y - 1, ROOM.x + 2, ROOM.y + 3)
		if strict and not c.is_free(area):
			continue
		if not w.inside(area.position.x, area.position.y) or not w.inside(area.end.x, area.end.y):
			continue
		_build(w, Vector2i(x, y))
		c.claim(area, "pozza")
		c.notes["pozza"] = Vector2i(x + ROOM.x / 2 - 1, y)
		return
	c.notes["pozza"] = null


func _build(w: World, p: Vector2i) -> void:
	for yy in range(p.y - ROOM.y, p.y + 2):
		for xx in range(p.x - 1, p.x + ROOM.x + 1):
			var i := yy * w.w + xx
			var shell := yy == p.y - ROOM.y or yy >= p.y + 1 or xx == p.x - 1 or xx == p.x + ROOM.x
			w.tiles[i] = TileDefs.PIETRA_SEM if shell else TileDefs.AIR
			w.walls[i] = TileDefs.WALL_SEM
			w.decor[i] = 0
			w.liquid[i] = 0
	# due aperture ai lati, per entrare anche senza scavare
	for yy in range(p.y - 2, p.y + 1):
		w.set_tile(p.x - 1, yy, TileDefs.AIR)
		w.set_tile(p.x + ROOM.x, yy, TileDefs.AIR)
	for xx in [p.x + 1, p.x + ROOM.x - 2]:
		w.set_decor(xx, p.y - ROOM.y + 1, TileDefs.DECOR_RUNE)
	var o := Vector2i(p.x + ROOM.x / 2 - 1, p.y)
	w.stations[o] = "pozza_linfa"
