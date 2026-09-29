class_name PassGiacimenti
extends GenPass
## I giacimenti fossili (Roadmap 26, voce 254; dati in `ArchaeologyData`): sul pavimento delle grotte degli strati 1-4,
## `PER_WORLD` stazioni `giacimento`, lontane tra loro. Non occupano posti grandi (una tessera), ma chiedono `is_free`.

const MIN_GAP := 40


func title() -> String:
	return "Giacimenti"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var made: Array[Vector2i] = []
	for tries in ArchaeologyData.PER_WORLD * 80:
		if made.size() >= ArchaeologyData.PER_WORLD:
			break
		var x := rng.randi_range(30, w.w - 31)
		var st := rng.randi_range(1, 4)
		var top := w.surface[x] + StrataData.top(st) + 4
		var bot := mini(w.surface[x] + (StrataData.top(st + 1) if st + 1 < StrataData.STRATA.size() else w.h), w.h - 10)
		if bot <= top:
			continue
		var y := rng.randi_range(top, bot)
		# scende fino al primo pavimento con aria sopra
		var ok := false
		for dy in 30:
			if not w.solid(x, y + dy) and w.solid(x, y + dy + 1) and w.liq(x, y + dy) == 0:
				y += dy
				ok = true
				break
		if not ok or w.stations.has(Vector2i(x, y)) or not c.is_free(Rect2i(x, y, 1, 1)):
			continue
		var far := true
		for p in made:
			if absi(p.x - x) + absi(p.y - y) < MIN_GAP:
				far = false
				break
		if not far:
			continue
		w.stations[Vector2i(x, y)] = "giacimento"
		made.append(Vector2i(x, y))
	c.notes["giacimenti"] = made.size()
