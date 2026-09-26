class_name PassGiardinoRifinitura
extends GenPass
## Dopo alberi e piante del Giardino (voce 62): niente alberi né decorazioni sopra o accanto all'Albero-Madre,
## all'Aiuola e alla partenza, dove servono spazio e vista libera.


func title() -> String:
	return "Giardino, rifinitura"


func run(w: World, _c: GenContext) -> void:
	var keep: Array[Rect2i] = [Rect2i(w.spawn.x - 3, w.spawn.y - 4, 7, 5)]
	for o in w.stations:
		var size: Array = StationsData.STATIONS[w.stations[o]]["size"]
		keep.append(Rect2i(o, Vector2i(size[0], size[1])).grow(4))
	for k in w.trees:
		var left := []
		for t in w.trees[k]:
			var ok := true
			for r in keep:
				if r.has_point(Vector2i(t.x, t.y)):
					ok = false
			if ok:
				left.append(t)
		w.trees[k] = left
	for r in keep:
		for y in range(r.position.y, r.end.y):
			for x in range(r.position.x, r.end.x):
				if w.inside(x, y):
					w.set_decor(x, y, 0)
