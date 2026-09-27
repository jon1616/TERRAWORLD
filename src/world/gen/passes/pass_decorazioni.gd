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
	var rng := c.rng
	var off := PackedInt32Array()
	off.resize(w.w)
	for x in w.w:
		off[x] = StrataData.offset(x, w.world_seed)
	var tops := PackedInt32Array()
	for st in StrataData.STRATA:
		tops.append(int(st["top"]))
	var last := tops.size() - 1
	var veg := {}
	for b in BiomesData.BIOMES:
		veg[int(b["grass"])] = b.get("veg", [])
	for u in BiomesData.UNDER:
		veg[int(u["floor"])] = u.get("veg", [])       # voce 94: i pavimenti dei biomi del sottosuolo
	for y in range(1, w.h - 1):
		for x in w.w:
			if w.tiles[y * w.w + x] != TileDefs.AIR:
				continue
			var below := w.tiles[(y + 1) * w.w + x]
			var above := w.tiles[(y - 1) * w.w + x]
			var dep := y - w.surface[x]
			var sk := last
			while sk > 0 and dep - off[x] < tops[sk]:
				sk -= 1
			var r := rng.randf()
			var d := 0
			if below == TileDefs.AIR or below == TileDefs.CRYSTAL:
				# niente pavimento: forse qualcosa che pende dal soffitto
				if above != TileDefs.AIR and dep > 3 and w.walls[y * w.w + x] != 0:
					if sk == 3 and r < 0.1:
						d = TileDefs.DECOR_LINFA
					elif r < (0.12 if sk == 1 else 0.06) and sk < 4:
						d = TileDefs.DECOR_ROOTS[0] if rng.randf() < 0.5 else TileDefs.DECOR_ROOTS[1]
			elif veg.has(below):
				d = _veg(veg[below], r, rng)            # voce 91: la vegetazione del bioma di quell'erba
			else:
				match sk:
					0, 1:
						if r < 0.05:
							d = TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
						elif dep > 8 and r < 0.09:
							d = TileDefs.DECOR_MUSHROOM
					2:
						if r < 0.06:
							d = TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
						elif r < 0.09:
							d = TileDefs.DECOR_MUSHROOM
						elif r < 0.13:
							d = TileDefs.DECOR_SPORE
					3:
						if r < 0.12:
							d = TileDefs.DECOR_GLOW
						elif r < 0.17:
							d = TileDefs.DECOR_SPORE
						elif r < 0.2:
							d = TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
					4:
						if r < 0.1:
							d = TileDefs.DECOR_SHARD
						elif r < 0.13:
							d = TileDefs.DECOR_GLOW
			w.decor[y * w.w + x] = d
	for k in w.trees:
		for t in w.trees[k]:
			w.set_decor(t.x, t.y, 0)



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
