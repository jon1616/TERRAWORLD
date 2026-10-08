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
		# nessuna stazione che copra la cella (un bozzolo dei Custodi è 3×3: il collaudatore ne toglierebbe una)
		if not ok or not w.station_at(Vector2i(x, y)).is_empty() or not c.is_free(Rect2i(x - 1, y - 1, 3, 3)):
			continue
		var far := true
		for p in made:
			if absi(p.x - x) + absi(p.y - y) < MIN_GAP:
				far = false
				break
		if not far:
			continue
		w.stations[Vector2i(x, y)] = "giacimento"
		c.claim(Rect2i(x - 1, y - 1, 3, 3), "giacimento")     # (voce 473) un incontro ci nasceva sopra
		made.append(Vector2i(x, y))
	c.notes["giacimenti"] = made.size()
