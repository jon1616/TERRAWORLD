class_name PassSegretiStanze
extends GenPass
## I segreti del primo ciclo (voce 96): costruiti apposta per essere trovati solo da chi guarda bene. Usa un generatore
## di numeri suo (dal seme del mondo), così non sposta ciò che le altre passate hanno fatto.
##   stanza_murata   una stanzetta chiusa nella roccia accanto a una grotta, con uno scrigno; la si raggiunge da una
##                   **parete finta** (tessera `FINTA`: sembra ardesia, sulla mappa e nella scheda è ardesia, ma crolla
##                   appena ci spingi contro: `Secrets`)
##   passaggio       un cunicolo tra due grotte, chiuso alle due bocche da pareti finte
##   tesoro_sepolto  uno scrigno sotto terra, pochi passi sotto la superficie; la **Mappa del tesoro** che lo indica sta in
##                   uno scrigno di un'altra stanza murata dello stesso mondo
##   nido_nascosto   una tana chiusa: entrandoci si sveglia una creatura rara dello strato (`Secrets`)
## Appunti: `notes["stanze_murate"]`, `["passaggi"]`, `["tesori"]`, `["nidi_nascosti"]` = [[x, y, w, h], …] (letti da
## `PassSegreti` come gli altri posti nascosti).

const ROOMS := 10
const PASSAGES := 6
const TREASURES := 4
const NESTS := 4

var _rng := RandomNumberGenerator.new()


var _c: GenContext                      # la mappa dei posti (`GenContext.claim`)


func title() -> String:
	return "Stanze segrete"


func run(w: World, c: GenContext) -> void:
	_rng.seed = hash([c.world_seed, "segreti_stanze"])
	_c = c
	var rooms := []
	var chests := []
	for k in ROOMS * 12:
		if rooms.size() >= ROOMS:
			break
		var r := _room(w)
		if not r.is_empty():
			rooms.append(r[0])
			chests.append(r[1])
	var passages := []
	for k in PASSAGES * 15:
		if passages.size() >= PASSAGES:
			break
		var p := _passage(w)
		if not p.is_empty():
			passages.append(p)
	var treasures := []
	for k in TREASURES * 10:
		if treasures.size() >= TREASURES:
			break
		var t := _treasure(w, chests)
		if not t.is_empty():
			treasures.append(t)
	var nests := []
	for k in NESTS * 12:
		if nests.size() >= NESTS:
			break
		var n := _nest(w)
		if not n.is_empty():
			nests.append(n)
	c.notes["stanze_murate"] = rooms
	c.notes["passaggi"] = passages
	c.notes["tesori"] = treasures
	c.notes["nidi_nascosti"] = nests


## Una cella d'aria di una grotta (con la parete dietro) fra le profondità date, o (-1, -1).
func _cave_cell(w: World, dmin: int, dmax: int) -> Vector2i:
	for k in 30:
		var x := _rng.randi_range(40, w.w - 41)
		var y := w.surface[x] + _rng.randi_range(dmin, dmax)
		if w.inside(x, y) and w.tile(x, y) == TileDefs.AIR and w.walls[y * w.w + x] != 0 				and w.walls[y * w.w + x] != TileDefs.WALL_SEM and w.solid(x, y + 1):   # (non nei luoghi e nelle rovine)
			return Vector2i(x, y)
	return Vector2i(-1, -1)


## Tutto pieno di roccia (niente aria, niente stazioni) nel riquadro?
func _solid_box(w: World, x0: int, y0: int, bw: int, bh: int) -> bool:
	for y in range(y0, y0 + bh):
		for x in range(x0, x0 + bw):
			if not w.inside(x, y) or not w.solid(x, y) or w.tile(x, y) in [TileDefs.NODO, TileDefs.PIETRA_SEM, TileDefs.SIG_VELATO] 					or w.walls[y * w.w + x] == TileDefs.WALL_SEM:
				return false
	return true


func _room(w: World) -> Array:
	var cave := _cave_cell(w, 30, 400)
	if cave.x < 0:
		return []
	var dir := -1 if _rng.randf() < 0.5 else 1
	# la stanza (6×4 d'aria) a 2 tessere dalla grotta, con il suo guscio di roccia
	var x0 := cave.x + dir * 3 if dir > 0 else cave.x - 3 - 7
	var y0 := cave.y - 3
	var area := Rect2i(x0 - 2, y0 - 2, 10, 8).merge(Rect2i(cave.x - 1, cave.y - 2, 3, 4))
	if not _c.is_free(area) or not _solid_box(w, x0 - 1, y0 - 1, 9, 7):
		return []
	_c.claim(area, "stanza murata")
	for y in range(y0, y0 + 4):
		for x in range(x0, x0 + 6):
			w.set_tile(x, y, TileDefs.AIR)
			w.walls[y * w.w + x] = TileDefs.WALL_STONE
	# la parete finta tra la grotta e la stanza (2 alta)
	var fx0 := mini(cave.x, x0) + 1 if dir > 0 else x0 + 6
	var fx1 := x0 - 1 if dir > 0 else cave.x - 1
	for x in range(fx0, fx1 + 1):
		for y in [cave.y - 1, cave.y]:
			if w.solid(x, y):
				w.set_tile(x, y, TileDefs.FINTA)
	# lo scrigno
	var o := Vector2i(x0 + 2, y0 + 3 - int(StationsData.STATIONS["scrigno"]["size"][1]) + 1)
	w.stations[o] = "scrigno"
	var chest := w.chest_at(o)
	var st := StrataData.at(w, o.x, o.y)
	var loot := LootData.roll_chest("rovina_%d" % clampi(st, 1, 4), _rng, 2)
	for id in loot:
		chest.add(String(id), int(loot[id]))
	return [[x0, y0, 6, 4], chest]


func _passage(w: World) -> Array:
	var a := _cave_cell(w, 25, 350)
	if a.x < 0:
		return []
	var dir := -1 if _rng.randf() < 0.5 else 1
	# cerca un'altra grotta alla stessa altezza, tra 8 e 30 tessere, con roccia in mezzo
	var b := Vector2i(-1, -1)
	var x := a.x + dir
	var rock := 0
	while absi(x - a.x) < 30 and w.inside(x, a.y):
		if w.solid(x, a.y) and w.solid(x, a.y - 1):
			rock += 1
		elif rock >= 8:
			b = Vector2i(x, a.y)
			break
		elif rock > 0:
			return []
		x += dir
	if b.x < 0:
		return []
	var xs := mini(a.x, b.x) + 1
	var xe := maxi(a.x, b.x) - 1
	var area := Rect2i(xs - 1, a.y - 2, xe - xs + 3, 4)
	if not _c.is_free(area):
		return []
	for xx in range(xs, xe + 1):
		for y in [a.y - 1, a.y]:
			if w.walls[y * w.w + xx] == TileDefs.WALL_SEM or w.tile(xx, y) in [TileDefs.PIETRA_SEM, TileDefs.PORTA_SEM, TileDefs.NODO]:
				return []                                  # non si buca un luogo dei Seminatori
	for xx in range(xs, xe + 1):
		for y in [a.y - 1, a.y]:
			var end := xx == xs or xx == xe
			w.set_tile(xx, y, TileDefs.FINTA if end else TileDefs.AIR)
			w.walls[y * w.w + xx] = TileDefs.WALL_STONE
	_c.claim(area, "passaggio")
	return [xs + 1, a.y - 1, maxi(xe - xs - 1, 1), 2]


func _treasure(w: World, chests: Array) -> Array:
	if chests.is_empty():
		return []
	var x := _rng.randi_range(60, w.w - 61)
	if absi(x - w.spawn.x) < 80:
		return []
	var y := w.surface[x] + _rng.randi_range(5, 9)
	var area := Rect2i(x - 2, y - 3, 5, 5)
	if not _c.is_free(area) or not _solid_box(w, x - 1, y - 1, 4, 4):
		return []
	_c.claim(area, "tesoro")
	w.set_tile(x, y, TileDefs.AIR)
	w.set_tile(x + 1, y, TileDefs.AIR)
	w.set_tile(x, y - 1, TileDefs.AIR)
	w.set_tile(x + 1, y - 1, TileDefs.AIR)
	var o := Vector2i(x, y - int(StationsData.STATIONS["scrigno"]["size"][1]) + 1)
	w.stations[o] = "scrigno"
	var chest := w.chest_at(o)
	var loot := LootData.roll_chest("rovina_3", _rng, 3)
	for id in loot:
		chest.add(String(id), int(loot[id]))
	chest.add("linfa_antica", 1)
	# la mappa che lo indica, in una stanza murata a caso
	var holder: Bisaccia = chests[_rng.randi_range(0, chests.size() - 1)]
	holder.add_stack({"id": "mappa_tesoro", "n": 1, "dati": {"x": x, "y": y}})
	return [x - 1, y - 2, 4, 4]


func _nest(w: World) -> Array:
	var x := _rng.randi_range(60, w.w - 61)
	var y := w.surface[x] + _rng.randi_range(40, 380)
	var area := Rect2i(x - 5, y - 4, 11, 9)
	if not _c.is_free(area) or not _solid_box(w, x - 5, y - 4, 11, 9):
		return []
	_c.claim(area, "nido nascosto")
	for yy in range(y - 2, y + 3):
		for xx in range(x - 3, x + 4):
			if Vector2(xx - x, (yy - y) * 1.3).length() <= 3.2:
				w.set_tile(xx, yy, TileDefs.AIR)
				w.walls[yy * w.w + xx] = TileDefs.WALL_DIRT
	return [x - 3, y - 2, 7, 5]
