class_name PassBaccelli
extends GenPass
## I baccelli dormienti (Roadmap 30, voce 301; dati in `PodsData`): sui pavimenti liberi delle grotte, secondo lo
## strato (`PodsData.DENSITY`), e qualche ceppo cavo sulla superficie all'aperto. Sono decorazioni: non tengono posto
## (non fanno `claim`), ma non nascono dentro le strutture, nell'acqua o sotto gli alberi. A fasce (`GenBands`).


func title() -> String:
	return "Baccelli"


func run(w: World, c: GenContext) -> void:
	var off := c.strata_off(w)
	var tops := c.strata_tops()
	var last := tops.size() - 1
	var tiles := w.tiles
	var decor := w.decor
	var liquid := w.liquid
	var surf := w.surface
	var ww := w.w
	var hh := w.h
	var by_stratum := []
	for s in last + 1:
		by_stratum.append(PodsData.kinds_for(s, false))
	# le celle scelte, fascia per fascia; il controllo delle strutture si fa dopo, una volta sola
	var parts := GenBands.run(c, hh, func(b: int, y0: int, y1: int) -> Array:
		var rng := c.band_rng(b)
		var out := []
		for y in range(maxi(y0, 2), mini(y1, hh - 2)):
			for x in range(2, ww - 2):
				var i := y * ww + x
				if tiles[i] != TileDefs.AIR or decor[i] != 0 or liquid[i] != 0:
					continue
				var below := tiles[i + ww]
				if below == TileDefs.AIR or below == TileDefs.CRYSTAL or tiles[i - ww] != TileDefs.AIR:
					continue
				var dep := y - surf[x]
				if dep < 6:
					continue                                  # sotto terra: la superficie ha i suoi ceppi
				var sk := last
				while sk > 0 and dep - off[x] < tops[sk]:
					sk -= 1
				if rng.randf() >= float(PodsData.DENSITY[sk]):
					continue
				var kinds: Array = by_stratum[sk]
				if kinds.is_empty():
					continue
				out.append([x, y, _pick(kinds, rng)])
		return out)
	var placed := 0
	for part in parts:
		for e in part:
			var x: int = e[0]
			var y: int = e[1]
			if c.is_free(Rect2i(x, y, 1, 1)):
				w.set_decor(x, y, int(e[2]))
				placed += 1
	# i ceppi cavi sulla superficie all'aperto (sopra l'erba, lontano dagli alberi)
	var rng := c.rng
	var surface_kinds := PodsData.kinds_for(0, true)
	for x in range(4, ww - 4):
		if rng.randf() >= PodsData.SURFACE_DENSITY or surface_kinds.is_empty():
			continue
		var y := int(surf[x]) - 1
		if y < 2 or w.tile(x, y) != TileDefs.AIR or w.liq(x, y) != 0 or not TileDefs.is_grass(w.tile(x, y + 1)):
			continue
		if w.tree_at(Vector2i(x, y)).x >= 0 or w.tree_at(Vector2i(x, y - 1)).x >= 0 or not c.is_free(Rect2i(x, y, 1, 1)):
			continue
		w.set_decor(x, y, _pick(surface_kinds, rng))
		placed += 1
	c.notes["baccelli"] = placed


static func _pick(kinds: Array, rng: RandomNumberGenerator) -> int:
	var tot := 0
	for k in kinds:
		tot += int(k[1])
	var r := rng.randi_range(1, tot)
	for k in kinds:
		r -= int(k[1])
		if r <= 0:
			return int(k[0])
	return int(kinds[0][0])
