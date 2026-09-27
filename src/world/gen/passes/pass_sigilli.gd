class_name PassSigilli
extends GenPass
## I luoghi sigillati (voce 64, Roadmap 8): stanze chiuse da un **Sigillo** che solo un potere del Germogliato apre
## (`PowersData`), e nidi alti nel cielo. Dentro, uno scrigno con un bottino dello strato e un **Frammento
## dell'Albero**, che gli stadi dell'Albero-Madre chiedono più avanti (`MotherTreeData`): così i poteri aprono la
## strada ai frammenti, e i frammenti ai poteri dopo. Ogni stanza è un vuoto di 7×4 con il guscio di Sigillo spesso
## una tessera; il nido alto è un isolotto 30-40 tessere sopra la superficie.
##   velato  (Vista della Linfa)   nelle Caverne d'ardesia: sembra ardesia, la Vista la mostra
##   radice  (Canto delle radici)  nel Sottobosco di radici
##   vuoto   (Passo nel Vuoto)     nel Fondo
##   brace   (Pelle di brace)      nelle Profondità della Linfa
## Appunti: `notes["sigilli"]` = [[tipo, centro], …].

const KINDS := [["velato", 2, 3], ["radice", 1, 3], ["vuoto", 4, 3], ["brace", 3, 3]]   # tipo, strato, quante
const W := 7
const H := 4


func title() -> String:
	return "Sigilli"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var out := []
	for k in KINDS:
		var tile := int(TileDefs.SEALS[k[0]])
		var got := 0
		for tries in 400:
			if got >= int(k[2]):
				break
			var x := rng.randi_range(60, w.w - 60 - W)
			if absi(x - w.spawn.x) < 120:
				continue
			var t0 := StrataData.top(int(k[1]))
			var t1 := StrataData.top(int(k[1]) + 1) if int(k[1]) + 1 < StrataData.STRATA.size() else t0 + 150
			var y := w.surface[x] + rng.randi_range(t0 + 8, maxi(t1 - 8, t0 + 9))
			var vault := Rect2i(x - 2, y - 2, W + 4, H + 4)
			if y + H + 2 >= w.h - 4 or not c.is_free(vault) or not _free(w, x - 1, y - 1, W + 2, H + 2):
				continue
			_vault(w, x, y, tile, String(k[0]), int(k[1]), rng)
			c.claim(vault, "sigillo")
			out.append([k[0], Vector2i(x + W / 2, y + H / 2)])
			got += 1
	# i nidi alti: isolotti nel cielo con uno scrigno (Salto delle spore e Radici-ponte)
	var nests := 0
	for tries in 200:
		if nests >= 2:
			break
		var x := rng.randi_range(120, w.w - 120)
		if absi(x - w.spawn.x) < 150:
			continue
		var y := w.surface[x] - rng.randi_range(30, 40)
		var nest := Rect2i(x - 5, y - 4, 11, 7)
		if y < 12 or not c.is_free(nest) or not _open_sky(w, nest):
			continue
		c.claim(nest, "nido alto")
		for dx in range(-4, 5):
			w.set_tile(x + dx, y, TileDefs.PIETRA_SEM)
			if absi(dx) < 3:
				w.set_tile(x + dx, y + 1, TileDefs.PIETRA_SEM)
		var o := Vector2i(x - 1, y - int(StationsData.STATIONS["scrigno"]["size"][1]))
		w.stations[o] = "scrigno"
		_fill(w, o, 0, rng)
		out.append(["alto", Vector2i(x, y)])
		nests += 1
	c.notes["sigilli"] = out


func _free(w: World, x: int, y: int, ww: int, hh: int) -> bool:
	for yy in range(y, y + hh):
		for xx in range(x, x + ww):
			if not w.inside(xx, yy) or w.tile(xx, yy) == TileDefs.PIETRA_SEM or not w.station_at(Vector2i(xx, yy)).is_empty():
				return false
	return true


## La stanza: il guscio di Sigillo, dentro aria con la parete delle rovine, uno scrigno sul pavimento.
func _vault(w: World, x: int, y: int, tile: int, kind: String, stratum: int, rng: RandomNumberGenerator) -> void:
	for yy in range(y - 1, y + H + 1):
		for xx in range(x - 1, x + W + 1):
			var shell := yy == y - 1 or yy == y + H or xx == x - 1 or xx == x + W
			w.set_tile(xx, yy, tile if shell else TileDefs.AIR)
			w.walls[yy * w.w + xx] = TileDefs.WALL_SEM
			w.set_decor(xx, yy, 0)
	w.set_decor(x + 1, y, TileDefs.DECOR_RUNE)
	w.set_decor(x + W - 2, y, TileDefs.DECOR_RUNE)
	var o := Vector2i(x + W / 2 - 1, y + H - int(StationsData.STATIONS["scrigno"]["size"][1]))
	w.stations[o] = "scrigno"
	_fill(w, o, stratum, rng)


func _fill(w: World, o: Vector2i, stratum: int, rng: RandomNumberGenerator) -> void:
	var chest := w.chest_at(o)
	chest.add("frammento_albero", 1)
	var loot := LootData.roll_chest("rovina_%d" % clampi(maxi(stratum, 1), 1, 4), rng, 2)
	for id in loot:
		chest.add(id, int(loot[id]))


## Tutta aria (il nido alto sta nel cielo: non dentro il tetto del Guscio o una scogliera, dove lo scrigno restava murato).
func _open_sky(w: World, r: Rect2i) -> bool:
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			if not w.inside(x, y) or w.solid(x, y):
				return false
	return true
