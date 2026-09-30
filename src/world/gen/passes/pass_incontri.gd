class_name PassIncontri
extends GenPass
## I piccoli incontri (Roadmap 30, voce 303; dati in `EncountersData`): per ogni tipo, `n` luoghi nelle grotte degli
## strati giusti, lontani dalle strutture (`is_free`/`claim`).
##   zaino_perduto  sul pavimento di una grotta, con bottino, torce e una Pagina strappata del diario di Tessa
##   osso_tana      una camera scavata nella roccia (10×4) con il mucchio d'ossa in fondo, pieno di bottino
##   vena_madre     il cristallo sul pavimento e attorno, nella roccia, il minerale ricco dello strato
##   fungo_re       in una grotta ampia: il fungo re e attorno funghi luminosi, funghetti e radici che pendono


func title() -> String:
	return "Incontri"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	var placed := {}
	for k in EncountersData.KINDS:
		var e: Dictionary = EncountersData.KINDS[k]
		var n := 0
		var tries := 0
		while n < int(e["n"]) and tries < int(e["n"]) * 500:
			tries += 1
			var s: int = (e["strata"] as Array)[rng.randi_range(0, (e["strata"] as Array).size() - 1)]
			var x := rng.randi_range(60, w.w - 61)
			var top := int(w.surface[x]) + int(off[x]) + int(tops[s])
			var bottom := int(w.surface[x]) + int(off[x]) + (int(tops[s + 1]) if s + 1 < tops.size() else w.h)
			bottom = mini(bottom, w.h - 12)
			if bottom - top < 6:
				continue
			var fl := _floor(w, x, rng.randi_range(top, bottom - 1), mini(bottom, w.h - 12))
			if fl.x < 0 or StrataData.at(w, fl.x, fl.y) != s:
				continue
			if _build(w, c, String(k), fl, s, rng):
				n += 1
		placed[k] = n
	c.notes["incontri"] = placed


## Il primo pavimento (aria sopra una cella piena) scendendo da y, entro il fondo dello strato.
static func _floor(w: World, x: int, y: int, bottom: int) -> Vector2i:
	for yy in range(y, mini(y + 24, bottom)):
		if not w.solid(x, yy) and not w.solid(x, yy - 1) and w.solid(x, yy + 1) and w.liq(x, yy) == 0:
			return Vector2i(x, yy)
	return Vector2i(-1, -1)


static func _build(w: World, c: GenContext, k: String, p: Vector2i, s: int, rng: RandomNumberGenerator) -> bool:
	match k:
		"zaino_perduto":
			var r := Rect2i(p.x - 1, p.y - 1, 4, 3)
			if not c.is_free(r) or w.solid(p.x + 1, p.y) or not w.solid(p.x + 1, p.y + 1):
				return false
			_station(w, k, p)
			var chest := w.chest_at(p)
			var loot := LootData.roll_chest("rovina_%d" % clampi(s, 1, 4), rng, 2)
			for id in loot:
				chest.add(id, int(loot[id]))
			chest.add("torcia", rng.randi_range(4, 10))
			chest.add(EncountersData.PAGE_ITEM, 1)
			c.claim(r, "incontro")
			return true
		"osso_tana":
			# la camera si scava di lato, verso la roccia: 10 × 4 sopra il pavimento
			var dir := 1 if rng.randf() < 0.5 else -1
			var x0 := p.x if dir > 0 else p.x - 9
			var r := Rect2i(x0 - 1, p.y - 4, 12, 6)
			if not c.is_free(r) or x0 < 4 or x0 + 12 > w.w - 4:
				return false
			for y in range(p.y - 3, p.y + 1):
				for x in range(x0, x0 + 10):
					w.set_tile(x, y, TileDefs.AIR)
					w.set_decor(x, y, 0)
					w.liquid[y * w.w + x] = 0
			for x in range(x0, x0 + 10):
				if not w.solid(x, p.y + 1):
					w.set_tile(x, p.y + 1, TileDefs.STONE)
			var o := Vector2i(x0 + (7 if dir > 0 else 1), p.y)
			_station(w, k, o)
			var chest := w.chest_at(o)
			var loot := LootData.roll_chest("rovina_%d" % clampi(s, 1, 4), rng, 3)
			for id in loot:
				chest.add(id, int(loot[id]))
			chest.add("lumino", rng.randi_range(15, 40) * (1 + s))
			c.claim(r, "incontro")
			return true
		"vena_madre":
			var r := Rect2i(p.x - 5, p.y - 5, 11, 8)
			if not c.is_free(r):
				return false
			var ore := _ore(s)
			for y in range(p.y - 5, p.y + 3):
				for x in range(p.x - 5, p.x + 6):
					var t := w.tile(x, y)
					if t in [TileDefs.STONE, TileDefs.SCISTO, TileDefs.VUOTITE, TileDefs.RADICE, TileDefs.DIRT] and rng.randf() < 0.55:
						w.set_tile(x, y, ore)
			_station(w, k, p + Vector2i(0, -1))
			c.claim(r, "incontro")
			return true
		"fungo_re":
			var r := Rect2i(p.x - 10, p.y - 9, 22, 11)
			if not c.is_free(r) or w.solid(p.x + 1, p.y) or w.solid(p.x + 1, p.y - 1) or not w.solid(p.x + 1, p.y + 1):
				return false
			var air := 0
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					if not w.solid(x, y):
						air += 1
			if air < r.get_area() * 0.4:
				return false                               # una camera fungina vuole una grotta ampia
			for y in range(r.position.y, r.end.y):
				for x in range(r.position.x, r.end.x):
					if w.solid(x, y) or w.liq(x, y) != 0:
						continue
					var roll := rng.randf()
					if w.solid(x, y + 1):
						w.set_decor(x, y, 10 if roll < 0.35 else (9 if roll < 0.5 else (53 if roll < 0.62 else (54 if roll < 0.72 else 0))))
					elif w.solid(x, y - 1) and roll < 0.25:
						w.set_decor(x, y, TileDefs.DECOR_ROOTS[rng.randi_range(0, 1)])
			_station(w, k, p + Vector2i(0, -1))
			c.claim(r, "incontro")
			return true
	return false


## La stazione con l'angolo in alto a sinistra in `o` (la sua fila più bassa sul pavimento); via le decorazioni sotto.
static func _station(w: World, k: String, o: Vector2i) -> void:
	var sz: Array = EncountersData.KINDS[k]["size"]
	for y in int(sz[1]):
		for x in int(sz[0]):
			w.set_decor(o.x + x, o.y + y, 0)
	w.stations[o] = k


static func _ore(s: int) -> int:
	match s:
		2:
			return TileDefs.LEGNOFERRO
		3:
			return TileDefs.AMBRA
	return TileDefs.TIZZONITE
