class_name PassPericoli
extends GenPass
## I pericoli dell'ambiente (voce 20c): rovi spinosi sui pavimenti delle grotte dalle Caverne d'ardesia in giù (più fitti
## scendendo) e nelle terre avvizzite; rune trappola sui pavimenti delle rovine dei Seminatori. Chi li tocca lo decide
## `Hazards`. Viene dopo Decorazioni, Avvizzimento e Rovine: si mette dove c'è posto.

## Probabilità di un rovo su un pavimento libero, per strato (`StrataData`).
const ROVO := [0.0, 0.0, 0.04, 0.06, 0.08]
const ROVO_BLIGHT := 0.12
const TRAPS_PER_RUIN := 2


func title() -> String:
	return "Pericoli"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	var last := tops.size() - 1
	var blighted := PackedByteArray()
	blighted.resize(TileDefs.TYPES + 1)
	for t in TileDefs.BLIGHTED:
		blighted[t] = 1
	var tiles := w.tiles
	var walls := w.walls
	var decor := w.decor
	var surf := w.surface
	var ww := w.w
	var hh := w.h
	# a fasce di righe su più processori (`GenBands`), ognuna con il suo caso; un cespuglio resta nella sua riga
	var parts := GenBands.run(hh, func(b: int, y0: int, y1: int) -> Array:
		var r := c.band_rng(b)
		var out: PackedByteArray = decor.slice(y0 * ww, y1 * ww)
		for y in range(maxi(y0, 2), mini(y1, hh - 1)):
			var base := (y - y0) * ww
			for x in range(1, ww - 1):
				var i := y * ww + x
				if tiles[i] != TileDefs.AIR or out[base + x] != 0 or tiles[i + ww] == TileDefs.AIR:
					continue
				var below := tiles[i + ww]
				var chance := 0.0
				if blighted[below] == 1:
					chance = ROVO_BLIGHT
				elif walls[i] != 0 and below != TileDefs.PIETRA_SEM:
					var sk := last
					while sk > 0 and y - surf[x] - off[x] < tops[sk]:
						sk -= 1
					chance = ROVO[sk]
				if chance > 0.0 and r.randf() < chance:
					# un cespuglio: la tessera e qualcuna accanto sullo stesso pavimento
					for dx in r.randi_range(1, 3):
						if x + dx >= ww:
							break
						var j := i + dx
						if tiles[j] == TileDefs.AIR and out[base + x + dx] == 0 and tiles[j + ww] != TileDefs.AIR:
							out[base + x + dx] = TileDefs.DECOR_ROVO
		return [out])
	w.decor = GenBands.join(parts, 0)
	# rune trappola: sul pavimento di ogni rovina, lontano dallo scrigno
	for p in c.notes.get("rovine", []):
		var cells: Array[Vector2i] = []
		for x in range(p.x, p.x + 18):
			if w.tile(x, p.y) == TileDefs.AIR and w.tile(x, p.y + 1) == TileDefs.PIETRA_SEM and w.decor_at(x, p.y) == 0 \
					and w.station_at(Vector2i(x, p.y)).is_empty():
				cells.append(Vector2i(x, p.y))
		for k in mini(TRAPS_PER_RUIN, cells.size()):
			var q: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
			w.set_decor(q.x, q.y, TileDefs.DECOR_TRAP)
