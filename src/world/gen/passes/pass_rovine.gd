class_name PassRovine
extends GenPass
## Le rovine dei Seminatori (voce 10): stanze di pietra lavorata sparse negli strati sotto la superficie, un po'
## crollate, con le rune accese e uno **scrigno** al centro del pavimento. Il bottino dipende dallo strato
## (`LootData`, tabelle «rovina_N»). Non si sovrappongono tra loro né alla cupola del Cuore.

const PER_STRATUM := [0, 12, 12, 11, 9]   # quante in ogni strato (0 = superficie: nessuna)
const MIN_DIST := 60.0                 # tessere tra due rovine


func title() -> String:
	return "Rovine"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var placed: Array[Vector2i] = []
	var cuore: Vector2i = c.notes.get("cuore", Vector2i(-9999, -9999))
	for s in PER_STRATUM.size():
		var want: int = roundi(PER_STRATUM[s] * float(SpeciesData.effects(c.params.get("tratti", []), "gen")["ruins"]))
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
			_build(w, rng, p, s)
			placed.append(p)
			done += 1
	c.notes["rovine"] = placed


## Una stanza: guscio di pietra dei Seminatori (con qualche mattone crollato), dentro aria e parete lavorata,
## rune accese sul soffitto e uno scrigno pieno al centro del pavimento. p = angolo in basso a sinistra dell'interno.
func _build(w: World, rng: RandomNumberGenerator, p: Vector2i, s: int) -> void:
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
	var o := Vector2i(p.x + rw / 2 - 1, p.y - 1)
	w.set_decor(o.x, o.y, 0)
	w.set_decor(o.x + 1, o.y, 0)
	w.set_decor(o.x, o.y + 1, 0)
	w.set_decor(o.x + 1, o.y + 1, 0)
	w.stations[o] = "scrigno"
	var chest := w.chest_at(o)
	var loot := LootData.roll_chest("rovina_%d" % clampi(s, 1, 4), rng, 2 + s / 2)
	for id in loot:
		chest.add(id, int(loot[id]))
