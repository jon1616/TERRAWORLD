class_name PassDecorazioni
extends GenPass
## Decorazioni secondo lo strato (`StrataData`):
## - Superficie: la vegetazione del bioma (erba bassissima, piante e cespugli: `BiomeDecorArt`), campanule, sassi;
## - Sottobosco di radici: tante radici con la punta accesa che pendono, funghi di brace;
## - Caverne d'ardesia: sassi, funghi di brace, sacche di spore;
## - Profondità della Linfa: funghi luminosi, sacche di spore, gocce di Linfa che pendono dai soffitti;
## - Il Fondo: schegge del Vuoto e qualche fungo luminoso.


func title() -> String:
	return "Decorazioni"


func run(w: World, c: GenContext) -> void:
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	var last := tops.size() - 1
	var veg := {}
	for b in BiomesData.BIOMES:
		veg[int(b["grass"])] = b.get("veg", [])
	for u in BiomesData.UNDER + BiomesData.SKY:
		veg[int(u["floor"])] = u.get("veg", [])       # voce 94 e Roadmap 16: i pavimenti del sottosuolo e del cielo
	var tiles := w.tiles
	var walls := w.walls
	var decor := w.decor
	var surf := w.surface
	var ww := w.w
	var hh := w.h
	# a fasce di righe su più processori (`GenBands`), ognuna con il suo caso (`GenContext.band_rng`)
	var parts := GenBands.run(c, hh, func(b: int, y0: int, y1: int) -> Array:
		var rng := c.band_rng(b)
		var out: PackedByteArray = decor.slice(y0 * ww, y1 * ww)
		for y in range(maxi(y0, 1), mini(y1, hh - 1)):
			for x in ww:
				var i := y * ww + x
				if tiles[i] != TileDefs.AIR:
					continue
				var below := tiles[i + ww]
				var above := tiles[i - ww]
				var dep := y - surf[x]
				var sk := last
				while sk > 0 and dep - off[x] < tops[sk]:
					sk -= 1
				var r := rng.randf()
				var d := 0
				if below == TileDefs.AIR or below == TileDefs.CRYSTAL:
					# niente pavimento: forse qualcosa che pende dal soffitto
					if above != TileDefs.AIR and dep > 3 and walls[i] != 0:
						if sk == 3 and r < 0.1:
							d = TileDefs.DECOR_LINFA
						elif r < (0.12 if sk == 1 else 0.06) and sk < 4:
							d = TileDefs.DECOR_ROOTS[0] if rng.randf() < 0.5 else TileDefs.DECOR_ROOTS[1]
				elif veg.has(below):
					d = _veg(veg[below], r, rng)            # voce 91: la vegetazione del bioma di quell'erba
				else:
					d = _deep(sk, dep, r, rng)
				out[i - y0 * ww] = d
		return [out])
	w.decor = GenBands.join(parts, 0)
	for k in w.trees:
		for t in w.trees[k]:
			w.set_decor(t.x, t.y, 0)


## Le decorazioni di un pavimento senza vegetazione, secondo lo strato (0 = niente).
static func _deep(sk: int, dep: int, r: float, rng: RandomNumberGenerator) -> int:
	match sk:
		0, 1:
			if r < 0.05:
				return TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
			elif dep > 8 and r < 0.09:
				return TileDefs.DECOR_MUSHROOM
		2:
			if r < 0.06:
				return TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
			elif r < 0.09:
				return TileDefs.DECOR_MUSHROOM
			elif r < 0.13:
				return TileDefs.DECOR_SPORE
		3:
			if r < 0.12:
				return TileDefs.DECOR_GLOW
			elif r < 0.17:
				return TileDefs.DECOR_SPORE
			elif r < 0.2:
				return TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
		4:
			if r < 0.1:
				return TileDefs.DECOR_SHARD
			elif r < 0.13:
				return TileDefs.DECOR_GLOW
	return 0


## Voce 91: una pianta dalla tabella `veg` di un bioma ([[fino a, cosa], …]); 0 = niente.
static func _veg(table: Array, r: float, rng: RandomNumberGenerator) -> int:
	for e in table:
		if r < float(e[0]):
			var what: Variant = e[1]
			if what is int:
				return what
			match String(what):
				"fronda":
					return TileDefs.DECOR_GRASS[rng.randi_range(0, 2)]
				"felce":
					return TileDefs.DECOR_FERN
				"fiori":
					return TileDefs.DECOR_FLOWERS[rng.randi_range(0, 2)]
				"sassi":
					return TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
				"spora":
					return TileDefs.DECOR_SPORE
				"bagliore":
					return TileDefs.DECOR_GLOW
				"fungo":
					return TileDefs.DECOR_MUSHROOM
				_:
					if String(what).begins_with("fiore_"):
						return TileDefs.DECOR_FLOWERS[int(String(what).get_slice("_", 1))]
			return 0
	return 0
