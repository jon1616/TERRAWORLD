class_name PassAlberi
extends GenPass
## Alberi sull'erba in piano, distanziati: la specie del bioma, una grandezza a caso (quanto lo spazio permette) e una
## forma (`TreesData`, disegni in `TreeArt`). I grandi stanno più lontani dai vicini.


func title() -> String:
	return "Alberi"


func run(w: World, c: GenContext) -> void:
	var last := -99
	var gap := 5
	for x in range(3, w.w - 3):
		var gy := w.surface[x]
		if not TileDefs.is_grass(w.tile(x, gy)) or w.surface[x - 1] != gy or w.surface[x + 1] != gy:
			continue
		var chance: float = float(BiomesData.BIOMES[w.biomes[x]]["trees"]) * float(c.genes()["trees"])   # geni di flora
		if x - last < gap or absi(x - w.spawn.x) < 4 or c.rng.randf() > chance:
			continue
		var room := w.free_above(Vector2i(x, gy - 1), FloraData.HEIGHT)
		if room < FloraData.ROOM:
			continue
		var v := TreesData.roll(c.rng, w.biomes[x], room)
		w.add_tree(Vector2i(x, gy - 1), v)
		last = x
		gap = 4 + int(TreesData.decode(v)[1]) * 2
