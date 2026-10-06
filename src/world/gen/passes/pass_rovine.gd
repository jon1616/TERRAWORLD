class_name PassRovine
extends GenPass
## Le rovine dei Seminatori (voce 10): stanze di pietra lavorata sparse negli strati sotto la superficie, un po'
## crollate, con le rune accese e uno **scrigno** al centro del pavimento. Il bottino dipende dallo strato
## (`LootData`, tabelle «rovina_N»). Non si sovrappongono tra loro né alla cupola del Cuore.

const PER_STRATUM := [0, 12, 12, 11, 9]   # quante in ogni strato (0 = superficie: nessuna)
const MIN_DIST := 60.0                 # tessere tra due rovine


func title() -> String:
	return "Rovine"


var _vigor := 1                          # voce 370: per le armi firma degli scrigni

func run(w: World, c: GenContext) -> void:
	_vigor = int(c.params.get("vigore", 1))
	var rng := c.rng
	var placed: Array[Vector2i] = []
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	for s in PER_STRATUM.size():
		var want: int = roundi(PER_STRATUM[s] * float(c.genes()["ruins"]))
		var tries := 0
		var done := 0
		while done < want and tries < want * 40:
			tries += 1
			var x := rng.randi_range(40, w.w - 60)
			var t0 := StrataData.top(s)
			var t1 := StrataData.top(s + 1) if s + 1 < StrataData.STRATA.size() else w.h - w.surface[x] - 20
			var dep := rng.randi_range(t0 + 8, maxi(t1 - 12, t0 + 9))
			var y := w.surface[x] + dep
			if y > w.h - 20:
				continue
			var p := Vector2i(x, y)
			if Vector2(p - cuore).length() < 70.0:
				continue
			var ok := true
			for q in placed:
				if Vector2(p - q).length() < MIN_DIST:
					ok = false
					break
			if not ok:
				continue
			if StrataData.at(w, x, y) != s:
				continue
			var room := Rect2i(x - 2, y - 10, 22, 13)        # la stanza più grande possibile (18×8 più il guscio)
			if not c.is_free(room):
				continue
			_build(w, rng, p, s, int(c.genes()["rich"]))       # gene «Rovine sepolte» (voce 43)
			c.claim(room, "rovina")
			placed.append(p)
			done += 1
	c.notes["rovine"] = placed
	if bool(c.genes()["city"]):
		c.notes["citta"] = _city(w, c)


## Una stanza: guscio di pietra dei Seminatori (con qualche mattone crollato), dentro aria e parete lavorata,
## rune accese sul soffitto e uno scrigno pieno al centro del pavimento. p = angolo in basso a sinistra dell'interno.
func _build(w: World, rng: RandomNumberGenerator, p: Vector2i, s: int, rich := 0) -> void:
	var rw := rng.randi_range(12, 18)
	var rh := rng.randi_range(6, 8)
	for y in range(p.y - rh - 1, p.y + 2):
		for x in range(p.x - 1, p.x + rw + 1):
			if not w.inside(x, y):
				continue
			var i := y * w.w + x
			var shell := y == p.y - rh - 1 or y == p.y + 1 or x == p.x - 1 or x == p.x + rw
			if shell:
				# i muri: pietra dei Seminatori, con qualche buco dove il tempo l'ha fatta cadere
				w.tiles[i] = TileDefs.AIR if (rng.randf() < 0.12 and y != p.y + 1) else TileDefs.PIETRA_SEM
			else:
				w.tiles[i] = TileDefs.AIR
			w.walls[i] = TileDefs.WALL_SEM
			w.decor[i] = 0
	# un'apertura su un lato, per entrare anche senza scavare
	var side := p.x - 1 if rng.randf() < 0.5 else p.x + rw
	for y in range(p.y - 2, p.y + 1):
		w.set_tile(side, y, TileDefs.AIR)
	# rune accese appese al soffitto
	for x in range(p.x + 1, p.x + rw - 1, 4):
		w.set_decor(x, p.y - rh, TileDefs.DECOR_RUNE)
	# lo scrigno al centro del pavimento, con il bottino dello strato
	var o := Vector2i(p.x + rw / 2 - 1, p.y - int(StationsData.STATIONS["scrigno"]["size"][1]) + 1)
	w.set_decor(o.x, o.y, 0)
	w.set_decor(o.x + 1, o.y, 0)
	w.set_decor(o.x, o.y + 1, 0)
	w.set_decor(o.x + 1, o.y + 1, 0)
	# 28 set 2026: più in basso, scrigni più capienti (i gradi trovati di `ChestsData`)
	var sid := "scrigno"
	for e in ChestsData.FOUND:
		if e.has("strata") and s >= int(e["strata"]) and rng.randf() < float(e["chance"]):
			sid = String(e["id"])
	w.stations[o] = sid
	var chest := w.chest_at(o)
	var loot := LootData.roll_chest("rovina_%d" % clampi(s, 1, 4), rng, 2 + s / 2 + rich)
	for id in loot:
		chest.add(id, int(loot[id]))
	if ChestsData.is_found(sid) and sid != "scrigno":
		var r2 := RandomNumberGenerator.new()                # voce 98: gli unici delle rovine profonde
		r2.seed = hash([o.x, o.y, w.world_seed])
		if r2.randf() < float(UniqueSeriesData.POOL_CHANCE["profondo"]):
			chest.add(UniquesData.roll("profondo", r2), 1)
	var r3 := RandomNumberGenerator.new()                    # voce 370: un'arma firma della fase del posto
	r3.seed = hash([o.x, o.y, w.world_seed, "firma"])
	if r3.randf() < SpineData.FIRMA_CHEST:
		var fl := LootData.roll("firma_f%d" % SpineData.zone_phase(_vigor, s), r3)
		for id in fl:
			chest.add(String(id), 1)
	if r3.randf() < SpineData.FIRMA_CHEST * 1.5:                # voce 383: un accessorio firma della fase
		var al := LootData.roll("accessori_f%d" % SpineData.zone_phase(_vigor, s), r3)
		for id in al:
			chest.add(String(id), 1)
	if rng.randf() < 0.25:                    # voce 46: una Fiala di un gene qualunque, anche di altri mondi
		var g := Genome.random_gene(rng, 2 + s)
		if g != "":
			chest.add(GenesData.vial_of(g), 1)


## La Città sepolta (voce 48, gene «Città sepolta»): una griglia di 4×3 stanze dei Seminatori nelle Caverne d'ardesia,
## muro contro muro, con le porte tra una stanza e l'altra e uno scrigno in ognuna. Restituisce l'angolo in basso a
## sinistra della prima stanza.
func _city(w: World, c: GenContext) -> Vector2i:
	var rng := c.rng
	var rw := 14
	var rh := 7
	for tries in 40:
		var x := rng.randi_range(200, w.w - 200 - 4 * (rw + 1))
		if absi(x - w.spawn.x) < 150:
			continue
		var y0 := w.surface[x] + StrataData.top(2) + 40
		if y0 + 3 * (rh + 3) > w.h - 30:
			continue
		var area := Rect2i(x - 2, y0 - rh - 3, 4 * (rw + 1) + 4, 3 * (rh + 3) + 4)
		if not c.is_free(area):
			continue
		c.claim(area, "città")
		for row in 3:
			for col in 4:
				var p := Vector2i(x + col * (rw + 1), y0 + row * (rh + 3))
				_build(w, rng, p, 3, 1)
		# le porte tra le stanze, orizzontali e verticali
		for row in 3:
			for col in 4:
				var p := Vector2i(x + col * (rw + 1), y0 + row * (rh + 3))
				if col < 3:
					for dy in range(-2, 1):
						w.set_tile(p.x + rw, p.y + dy, TileDefs.AIR)
				if row < 2:
					for dx in range(2, 5):
						w.set_tile(p.x + dx, p.y + 1, TileDefs.AIR)
						w.set_tile(p.x + dx, p.y + 2, TileDefs.AIR)
		return Vector2i(x, y0)
	return Vector2i(-1, -1)
