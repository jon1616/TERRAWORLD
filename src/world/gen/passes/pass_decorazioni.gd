class_name PassDecorazioni
extends GenPass
## Fronde di muschio, felci e campanule luminose sulla superficie; sassi, funghi e sacche di spore sui pavimenti delle
## grotte, funghi luminosi nel profondo; radici con la punta accesa che pendono dai soffitti.

const GLOW_DEPTH := 300


func title() -> String:
	return "Decorazioni"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	for y in range(1, w.h - 1):
		for x in w.w:
			if w.tiles[y * w.w + x] != TileDefs.AIR:
				continue
			var below := w.tiles[(y + 1) * w.w + x]
			var above := w.tiles[(y - 1) * w.w + x]
			var dep := y - w.surface[x]
			var r := rng.randf()
			var d := 0
			if below == TileDefs.AIR or below == TileDefs.CRYSTAL:
				# niente pavimento: forse una radice che pende dal soffitto
				if above != TileDefs.AIR and dep > 3 and w.walls[y * w.w + x] != 0 and r < 0.16:
					d = TileDefs.DECOR_ROOTS[0] if rng.randf() < 0.5 else TileDefs.DECOR_ROOTS[1]
			elif below == TileDefs.GRASS:
				if r < 0.45:
					d = TileDefs.DECOR_GRASS[rng.randi_range(0, 2)]
				elif r < 0.55:
					d = TileDefs.DECOR_FERN
				elif r < 0.64:
					d = TileDefs.DECOR_FLOWERS[rng.randi_range(0, 2)]
			elif dep > GLOW_DEPTH and r < 0.1:
				d = TileDefs.DECOR_GLOW
			elif r < 0.05:
				d = TileDefs.DECOR_ROCKS[rng.randi_range(0, 1)]
			elif dep > 8 and dep < GLOW_DEPTH and r < 0.08:
				d = TileDefs.DECOR_MUSHROOM
			elif dep > 40 and r < 0.11:
				d = TileDefs.DECOR_SPORE
			w.decor[y * w.w + x] = d
	for k in w.trees:
		for t in w.trees[k]:
			w.set_decor(t.x, t.y, 0)
