class_name PassPianteSeme
extends GenPass
## Le piante-seme selvatiche (voce 46): piante rare con un baccello luminoso, sull'erba della superficie e sui pavimenti
## delle grotte, lontane dalla partenza e tra loro. Clic destro = una Fiala di un gene del mondo o un Seme selvatico
## (vedi `Sampling.harvest`). Stazione `pianta_seme` (1×2): nasce dal mondo, non si fabbrica.

const SURFACE := 8
const CAVES := 10
const MIN_DIST := 90.0


func title() -> String:
	return "Piante-seme"


func run(w: World, c: GenContext) -> void:
	var placed: Array[Vector2i] = []
	_scatter(w, c, SURFACE, true, placed)
	_scatter(w, c, CAVES, false, placed)
	c.notes["piante_seme"] = placed


func _scatter(w: World, c: GenContext, n: int, surface: bool, placed: Array[Vector2i]) -> void:
	var got := 0
	for tries in n * 200:
		if got >= n:
			return
		var x := c.rng.randi_range(20, w.w - 21)
		if absi(x - w.spawn.x) < 40:
			continue
		var y := w.surface[x] - 1 if surface else w.surface[x] + c.rng.randi_range(30, mini(700, w.h - w.surface[x] - 20))
		# scende fino al primo pavimento
		for k in 30:
			if w.solid(x, y + 1):
				break
			y += 1
		var o := Vector2i(x, y - 1)
		if not w.station_fits("pianta_seme", o) or not c.is_free(Rect2i(o.x, o.y, 1, 2)) or (surface and not TileDefs.is_grass(w.tile(x, y + 1))):
			continue
		var far := true
		for q in placed:
			if Vector2(q - o).length() < MIN_DIST:
				far = false
				break
		if not far:
			continue
		w.set_decor(o.x, o.y, 0)
		w.set_decor(o.x, o.y + 1, 0)
		w.stations[o] = "pianta_seme"
		c.claim(Rect2i(o.x, o.y, 1, 2), "pianta_seme")    # voce 441: un incontro nato dopo le finiva sopra
		placed.append(o)
		got += 1
