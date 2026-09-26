class_name PassGiardino
extends GenPass
## Il Giardino (voce 62, Roadmap 8): il mondo casa di ogni partita, piccolo e sospeso nel Vuoto. Un'isola di terra e
## muschio con il cuore di pietra, le radici che pendono sotto, l'**Albero-Madre** addormentato al centro, la prima
## **Aiuola** accanto, la partenza dall'altra parte; due isolotti vicini (ci si arriva saltando). Tutto il resto è aria:
## chi cade nel Vuoto torna all'Albero (`Giardino`). Dopo questa passata girano Alberi e Decorazioni come nei mondi.
## Appunti: `notes["albero"]` (angolo della stazione), `notes["isola"]` = [x0, x1, fondo più basso].

const HALF := 88                       # mezza larghezza dell'isola grande
const TREE := "albero_madre_0"


func title() -> String:
	return "Giardino"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var cx := w.w / 2
	var top := int(w.h * 0.46)
	var n_top := c.noise("giardino_bordo", 0.05, 2)
	var n_bot := c.noise("giardino_fondo", 0.04, 2)
	for x in w.w:
		w.surface[x] = w.h - 2               # nel Vuoto: nessuna superficie
		w.biomes[x] = 0
	var lowest := 0
	lowest = maxi(lowest, _island(w, cx, top, HALF, n_top, n_bot, rng, true))
	# due isolotti ai lati, un po' più in alto e più in basso: ci si arriva saltando
	lowest = maxi(lowest, _island(w, cx - HALF - 22, top - 3, 14, n_top, n_bot, rng, false))
	lowest = maxi(lowest, _island(w, cx + HALF + 22, top + 2, 14, n_top, n_bot, rng, false))
	# la zona dell'Albero e della partenza: piana
	for x in range(cx - 24, cx + 25):
		_set_top(w, x, top)
	# l'Albero-Madre al centro, la prima Aiuola a destra, la partenza a sinistra
	var size: Array = StationsData.STATIONS[TREE]["size"]
	var o := Vector2i(cx - int(size[0]) / 2, top - int(size[1]))
	w.stations[o] = TREE
	var ai := Vector2i(cx + 11, top - int(StationsData.STATIONS["aiuola"]["size"][1]))
	w.stations[ai] = "aiuola"
	w.spawn = Vector2i(cx - 12, top - 1)
	# voce 67: la Bacheca dei Giardinieri, a sinistra della partenza
	w.stations[Vector2i(cx - 20, top - int(StationsData.STATIONS["bacheca"]["size"][1]))] = "bacheca"
	# voce 68: una stele dei Seminatori oltre l'Aiuola (un pezzo di storia: le prime parole si leggono qui)
	w.stations[Vector2i(cx + 18, top - int(StationsData.STATIONS["stele"]["size"][1]))] = "stele"
	c.notes["albero"] = o
	c.notes["isola"] = [cx - HALF, cx + HALF, lowest]


## Un'isola: la superficie ondeggia appena, il fondo è tondo e irregolare; muschio, humus, pietra con un po' di
## radicite, radici che pendono sotto. Restituisce la riga più bassa.
func _island(w: World, cx: int, top: int, half: int, n_top: FastNoiseLite, n_bot: FastNoiseLite, rng: RandomNumberGenerator,
		big: bool) -> int:
	var lowest := 0
	for x in range(cx - half, cx + half + 1):
		if x < 1 or x >= w.w - 1:
			continue
		var t := float(x - cx) / float(half)
		var surf := top + int(n_top.get_noise_1d(x) * (4.0 if big else 2.0) + t * t * (6.0 if big else 2.0))
		var depth := int((1.0 - t * t) * (34.0 if big else 9.0) + 3.0 + n_bot.get_noise_1d(x) * (6.0 if big else 2.0))
		var bottom := surf + maxi(depth, 2)
		lowest = maxi(lowest, bottom)
		w.surface[x] = surf
		for y in range(surf, bottom + 1):
			var d := y - surf
			var tile := TileDefs.GRASS if d == 0 else (TileDefs.DIRT if d < 7 + rng.randi_range(0, 2) else TileDefs.STONE)
			if tile == TileDefs.STONE and rng.randf() < 0.07:
				tile = TileDefs.RADICITE
			w.set_tile(x, y, tile)
			if d > 0 and y < bottom:
				w.walls[y * w.w + x] = TileDefs.WALL_DIRT if d < 8 else TileDefs.WALL_STONE
		# radici che pendono sotto l'isola
		if rng.randf() < (0.18 if big else 0.1):
			var n := rng.randi_range(4, 18 if big else 7)
			for k in n:
				if bottom + 1 + k < w.h - 3:
					w.set_tile(x, bottom + 1 + k, TileDefs.RADICE)
	return lowest


func _set_top(w: World, x: int, top: int) -> void:
	var s := w.surface[x]
	if s < top:
		for y in range(s, top):
			w.set_tile(x, y, TileDefs.AIR)
			w.walls[y * w.w + x] = 0
	elif s > top:
		for y in range(top, s):
			w.set_tile(x, y, TileDefs.DIRT)
	w.set_tile(x, top, TileDefs.GRASS)
	w.surface[x] = top
