class_name PassRilievo
extends GenPass
## Il rilievo (voce 465, Roadmap 60 «La superficie da cartolina»): dopo la Sagoma e i Mari, solo la superficie.
## - **massicci**: 1-3 montagne per mondo (`MASSIF`), alte 60-110 righe sopra la terra attorno e larghe 120-220 colonne,
##   lontane dalla partenza e dai mari; la loro parte alta è a **pareti e cenge** (gradini di 7-10 righe con ripiani di
##   almeno 5 colonne). Le pareti più alte del salto avranno le liane (`PassRocce`): si sale sempre.
## - una semplice **erosione**: gli spuntoni di una colonna sola si spianano (mai sulle terrazze, nel canyon e nel mare).
## Niente sulle sagome che hanno già la loro forma (guscio, arcipelago, terrazze). Appunti "massicci" [[x, larghezza, altezza]].

const MASSIF := {"n": [1, 3], "w": [120, 220], "h": [60, 110], "step": [7, 10], "ledge": 5, "spawn": 260}


func title() -> String:
	return "Rilievo"


func run(w: World, c: GenContext) -> void:
	c.notes["massicci"] = []
	if bool(c.params.get("giardino", false)):
		return
	var shape := str(c.notes.get("sagoma", "continente"))
	if shape in ["guscio", "arcipelago", "terrazze"]:
		return
	var keep := _kept(w, c)
	_massifs(w, c, keep)
	_erode(w, keep)


## Le colonne da non toccare: la partenza, i mari, il canyon.
func _kept(w: World, c: GenContext) -> PackedByteArray:
	var keep := PackedByteArray()
	keep.resize(w.w)
	for x in range(maxi(w.spawn.x - 10, 0), mini(w.spawn.x + 11, w.w)):
		keep[x] = 1
	for sea in c.notes.get("mari", []):
		for x in range(maxi(int(sea[0]) - 20, 0), mini(int(sea[1]) + 20, w.w)):
			keep[x] = 1
	if c.notes.has("canyon"):
		var cn: Array = c.notes["canyon"]
		for x in range(maxi(int(cn[0]) - 4, 0), mini(int(cn[1]) + 4, w.w)):
			keep[x] = 1
	return keep


func _massifs(w: World, c: GenContext, keep: PackedByteArray) -> void:
	var made := []
	var nz := c.noise("massicci", 0.03, 3)
	for tries in 40:
		if made.size() >= c.rng.randi_range(int(MASSIF["n"][0]), int(MASSIF["n"][1])) and made.size() > 0:
			break
		var mw := c.rng.randi_range(int(MASSIF["w"][0]), int(MASSIF["w"][1]))
		var cx := c.rng.randi_range(mw, w.w - mw)
		if absi(cx - w.spawn.x) < int(MASSIF["spawn"]) + mw / 2:
			continue
		var bad := false
		for x in range(cx - mw / 2 - 10, cx + mw / 2 + 10):
			if keep[clampi(x, 0, w.w - 1)] == 1:
				bad = true
				break
		for o in made:
			if absi(int(o[0]) - cx) < (int(o[1]) + mw) / 2 + 60:
				bad = true
		if bad:
			continue
		var mh := c.rng.randi_range(int(MASSIF["h"][0]), int(MASSIF["h"][1]))
		var step := c.rng.randi_range(int(MASSIF["step"][0]), int(MASSIF["step"][1]))
		var base := float(w.surface[cx - mw / 2] + w.surface[cx + mw / 2]) * 0.5
		var x0 := cx - mw / 2
		var x1 := cx + mw / 2
		for x in range(x0, x1):
			var t := absf(float(x - cx)) / (mw / 2.0)
			var bell := pow(maxf(1.0 - t * t, 0.0), 1.4)
			var h := mh * bell * (0.9 + nz.get_noise_1d(x) * 0.25)
			# la parte alta a pareti e cenge: l'altezza arrotondata a gradini (sotto i 25 righe resta un pendio)
			if h > 25.0:
				h = 25.0 + floorf((h - 25.0) / step) * step
			w.surface[x] = mini(int(w.surface[x]), int(base - h))
		_ledges(w, x0, x1, int(MASSIF["ledge"]))
		made.append([cx, mw, mh])
	c.notes["massicci"] = made


## Un ripiano più corto di `ledge` colonne tra due pareti si allarga prendendo dal gradino sopra (le cenge su cui stare).
static func _ledges(w: World, x0: int, x1: int, ledge: int) -> void:
	var x := x0 + 1
	while x < x1 - 1:
		var run := 1
		while x + run < x1 and w.surface[x + run] == w.surface[x]:
			run += 1
		if run < ledge and x + run < x1:
			for k in range(run, mini(ledge, x1 - x)):
				w.surface[x + k] = w.surface[x]
			run = ledge
		x += run


## Gli spuntoni (una colonna più alta di entrambe le vicine di oltre 3 righe) e i buchi stretti si spianano.
static func _erode(w: World, keep: PackedByteArray) -> void:
	for it in 2:
		for x in range(1, w.w - 1):
			if keep[x] == 1:
				continue
			var l := int(w.surface[x - 1])
			var r := int(w.surface[x + 1])
			var s := int(w.surface[x])
			if s < mini(l, r) - 3 or s > maxi(l, r) + 3:
				w.surface[x] = (l + r) / 2
