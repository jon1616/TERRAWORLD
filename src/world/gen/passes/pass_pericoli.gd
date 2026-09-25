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
	var off := PackedInt32Array()
	off.resize(w.w)
	for x in w.w:
		off[x] = StrataData.offset(x, w.world_seed)
	var tops := PackedInt32Array()
	for st in StrataData.STRATA:
		tops.append(int(st["top"]))
	var last := tops.size() - 1
	for y in range(2, w.h - 1):
		for x in range(1, w.w - 1):
			var i := y * w.w + x
			if w.tiles[i] != TileDefs.AIR or w.decor[i] != 0 or w.tiles[i + w.w] == TileDefs.AIR:
				continue
			var below := w.tiles[i + w.w]
			var chance := 0.0
			if below in TileDefs.BLIGHTED:
				chance = ROVO_BLIGHT
			elif w.walls[i] != 0 and below != TileDefs.PIETRA_SEM:
				var sk := last
				while sk > 0 and y - w.surface[x] - off[x] < tops[sk]:
					sk -= 1
				chance = ROVO[sk]
			if chance > 0.0 and rng.randf() < chance:
				# un cespuglio: la tessera e qualcuna accanto sullo stesso pavimento
				for dx in rng.randi_range(1, 3):
					var j := i + dx
					if w.tiles[j] == TileDefs.AIR and w.decor[j] == 0 and w.tiles[j + w.w] != TileDefs.AIR:
						w.decor[j] = TileDefs.DECOR_ROVO
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
