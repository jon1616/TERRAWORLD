class_name PassAlberi
extends GenPass
## Alberi sull'erba in piano, distanziati: la specie del bioma, una grandezza a caso (quanto lo spazio permette) e una
## forma (`TreesData`, disegni in `TreeArt`). I grandi stanno più lontani dai vicini. Voce 462: nei passaggi tra due
## biomi la specie del vicino a chiazze (`BiomesData.mix_at`), e dentro i biomi le radure (niente alberi) e i boschetti
## (alberi fitti), da un rumore lento.


func title() -> String:
	return "Alberi"


func run(w: World, c: GenContext) -> void:
	var last := -99
	var gap := 5
	var n := c.noise("biomi_chiazze", 0.09, 2)
	var glade := c.noise("radure", 0.012, 2)
	for x in range(3, w.w - 3):
		var gy := w.surface[x]
		if not TileDefs.is_grass(w.tile(x, gy)) or w.surface[x - 1] != gy or w.surface[x + 1] != gy:
			continue
		var bm := BiomesData.mix_at(w, x, n)
		var chance: float = float(BiomesData.BIOMES[bm]["trees"]) * float(c.genes()["trees"])   # geni di flora
		var gv := glade.get_noise_1d(x)
		if gv > 0.42:
			chance = 0.0                                 # una radura
		elif gv < -0.45:
			chance = minf(chance * 2.5 + 0.1, 0.9)        # un boschetto
		if x - last < gap or absi(x - w.spawn.x) < 4 or c.rng.randf() > chance:
			continue
		var room := w.free_above(Vector2i(x, gy - 1), FloraData.HEIGHT)
		if room < FloraData.ROOM:
			continue
		var v := TreesData.roll(c.rng, bm, room)
		w.add_tree(Vector2i(x, gy - 1), v)
		last = x
		gap = 4 + int(TreesData.decode(v)[1]) * 2
