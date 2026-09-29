class_name PassCentrali
extends GenPass
## Le Centrali dei Seminatori (Roadmap 19, voce 206): 3-6 sale per mondo (una in più per punto di vigore oltre il primo,
## due in più con il gene «Vene del mondo») nelle Caverne d'ardesia e più giù. Ogni sala è un enigma di Linfa:
##   - il **Cuore della centrale** dorme: un cristallo di Linfa lo risveglia;
##   - la vena d'ambra sul pavimento è **spezzata** in tre punti: si ripara con la Pinza (lo scrigno all'ingresso ha le
##     vene che servono);
##   - tre **leve** (fili turchese, ambra e corallo) arrivano a un **nodo E**, che col filo viola apre la **porta** della
##     sala interna; la porta si muove solo se la rete ha Linfa.
## Aperta la porta la prima volta, la Centrale dona un progetto, un unico «Ingegni dei Seminatori» e Linfa antica
## (`MbPortaCentrale`). Leve, nodo, porta e cuore non si riprendono (`fixed`); le lampade sì.
## `build(…, intatta = true)` è la firma «la Centrale intatta» (`PassFirma`): cuore sveglio, vene sane, più grande.
## Appunti: `notes["centrali"]` = [[angolo della sala, intatta], …].

const W := 26
const H := 7
const LEVERS := [8, 11, 14]
const NODE_X := 18


func title() -> String:
	return "Centrali"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var want := 3 + clampi(int(c.params.get("vigore", 1)) - 1, 0, 3)
	if "vene_mondo" in c.genes():
		want += 2
	var out: Array = c.notes.get("centrali", [])
	for tries in 500:
		if out.size() >= want:
			break
		var x := rng.randi_range(60, w.w - 60 - W)
		if absi(x - w.spawn.x) < 100:
			continue
		var stratum := rng.randi_range(2, 4)
		var t0 := StrataData.top(stratum)
		var t1 := StrataData.top(stratum + 1) if stratum + 1 < StrataData.STRATA.size() else t0 + 150
		var y := w.surface[x] + rng.randi_range(t0 + 6, maxi(t1 - 10, t0 + 7))
		var room := Rect2i(x - 3, y - 3, W + 6, H + 6)
		if y + H + 3 >= w.h - 4 or not c.is_free(room) or not _free(w, room):
			continue
		build(w, x, y, rng, false)
		c.claim(room, "centrale")
		out.append([Vector2i(x, y), false])
	c.notes["centrali"] = out


func _free(w: World, r: Rect2i) -> bool:
	for yy in range(r.position.y, r.end.y):
		for xx in range(r.position.x, r.end.x):
			# (le stazioni stanno nei posti già presi: `station_at` qui costa, il generatore non ha ancora l'indice)
			if not w.inside(xx, yy) or w.tile(xx, yy) == TileDefs.PIETRA_SEM or w.walls[yy * w.w + xx] == TileDefs.WALL_SEM:
				return false
	return true


static func _wire(k: int) -> int:
	return 1 << (VeinsData.WIRE_SHIFT + k)


static func _add_vein(w: World, x: int, y: int, bits: int) -> void:
	w.set_vein(x, y, w.vein_at(x, y) | bits)


## Costruisce la sala con l'angolo interno in alto a sinistra in (x, y).
static func build(w: World, x: int, y: int, rng: RandomNumberGenerator, intatta: bool) -> void:
	var yb := y + H - 1
	for yy in range(y - 1, y + H + 1):
		for xx in range(x - 1, x + W + 1):
			var shell := yy == y - 1 or yy == y + H or xx == x - 1 or xx == x + W
			w.set_tile(xx, yy, TileDefs.PIETRA_SEM if shell else TileDefs.AIR)
			w.walls[yy * w.w + xx] = TileDefs.WALL_SEM
			w.set_decor(xx, yy, 0)
			w.set_liq(xx, yy, 0, 0)
			w.set_vein(xx, yy, 0)
	var door_x := x + W - 6
	for yy in range(y, yb - 1):                        # il muro della sala interna, sopra la porta
		w.set_tile(door_x, yy, TileDefs.PIETRA_SEM)
	# le macchine
	w.stations[Vector2i(x + 1, yb - 1)] = "cuore_centrale_vivo" if intatta else "cuore_centrale"
	var ch_h := int(StationsData.STATIONS["scrigno"]["size"][1])
	var chest_o := Vector2i(x + 4, yb - ch_h + 1)
	w.stations[chest_o] = "scrigno"
	var box := w.chest_at(chest_o)
	box.add("vena_ambra", 8)
	box.add("pinza_vene", 1)
	box.add("cristallo_linfa", 1)
	for lx in LEVERS:
		w.stations[Vector2i(x + int(lx), yb)] = "leva_centrale"
	w.stations[Vector2i(x + NODE_X, y + 1)] = "nodo_centrale"
	w.stations[Vector2i(door_x, yb - 1)] = "porta_centrale"
	w.stations[Vector2i(x + 7, yb)] = "lampada_baccello"
	w.stations[Vector2i(x + 16, yb)] = "lampada_baccello"
	# la vena d'ambra sul pavimento, dal cuore alla porta, spezzata in tre punti dove non c'è niente
	var gaps: Array = []
	if not intatta:
		var free_x := [6, 9, 10, 12, 13, 15, 17, 18, 19]
		while gaps.size() < 3:
			var g: int = free_x[rng.randi_range(0, free_x.size() - 1)]
			if not g in gaps:
				gaps.append(g)
	for ix in range(1, W - 5):
		if not ix in gaps:
			_add_vein(w, x + ix, yb, 3)
	# i fili: la leva k sale fino alla riga y+1+k, va al nodo e sale al nodo
	for k in 3:
		var lx := x + int(LEVERS[k])
		var r := y + 1 + k
		for yy in range(r, yb + 1):
			_add_vein(w, lx, yy, _wire(k))
		for xx in range(lx, x + NODE_X + 1):
			_add_vein(w, xx, r, _wire(k))
		for yy in range(y + 1, r + 1):
			_add_vein(w, x + NODE_X, yy, _wire(k))
	# il filo viola dal nodo alla porta
	for xx in range(x + NODE_X, door_x + 1):
		_add_vein(w, xx, y + 1, _wire(3))
	for yy in range(y + 1, yb):
		_add_vein(w, door_x, yy, _wire(3))
	# le rune alle pareti
	for ix in [0, 3, 9, 15, 22, 25]:
		w.set_decor(x + int(ix), y, TileDefs.DECOR_RUNE)
