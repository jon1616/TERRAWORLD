class_name PassAffioramenti
extends GenPass
## I segni dei giacimenti (voce 456, Roadmap 58 «I tesori della roccia»): dove sotto la superficie (entro `DEPTH` righe)
## c'è un giacimento ricco, il metallo **affiora**: qualche tessera nella cima del terreno, che si vede passando. Si impara a
## leggere il mondo: un affioramento = scava qui. Al più uno ogni `GAP` colonne; mai sopra la partenza. Nelle grotte, sul
## pavimento accanto al cuore di un giacimento, qualche sasso luccicante (`DECOR_ROCKS`). Appunti "affioramenti".
## Dopo i minerali e l'erba (l'affioramento prende il posto della cima).

const DEPTH := 50
const MIN := 22                         # tessere di metallo nella finestra che fanno un affioramento
const HALF := 4                         # mezza larghezza della finestra
const GAP := 40


func title() -> String:
	return "Affioramenti"


func run(w: World, c: GenContext) -> void:
	var made := []
	if bool(c.params.get("giardino", false)):
		c.notes["affioramenti"] = made
		return
	var metals := {}
	for t in TileDefs.DEPOSIT_BASE:
		metals[int(t)] = true
	var last := -GAP
	var x := 8
	while x < w.w - 8:
		if x - last < GAP or absi(x - w.spawn.x) < 30:
			x += 2
			continue
		var counts := {}
		for xx in range(x - HALF, x + HALF + 1):
			for d in range(4, DEPTH):
				var t := w.tile(xx, int(w.surface[xx]) + d)
				if metals.has(t):
					counts[t] = int(counts.get(t, 0)) + 1
		var best := -1
		for t in counts:
			if int(counts[t]) >= MIN and (best < 0 or int(counts[t]) > int(counts[best])):
				best = int(t)
		if best >= 0:
			var n := c.rng.randi_range(2, 4)
			for k in n:
				var xx := x + c.rng.randi_range(-2, 2)
				var s := int(w.surface[xx])
				if w.solid(xx, s) and w.station_at(Vector2i(xx, s)).is_empty() and w.tree_at(Vector2i(xx, s - 1)).x < 0:
					w.set_tile(xx, s + (0 if k == 0 else c.rng.randi_range(0, 1)), best)
			made.append([x, best])
			last = x
		x += 2
	# nelle grotte: sassi luccicanti sul pavimento accanto a un cuore di giacimento (3+ tessere di metallo attorno)
	var glints := 0
	for k in 4000:
		var gx := c.rng.randi_range(10, w.w - 11)
		var gy := int(w.surface[gx]) + c.rng.randi_range(20, mini(500, w.h - int(w.surface[gx]) - 10))
		if w.solid(gx, gy) or not w.solid(gx, gy + 1) or w.decor_at(gx, gy) != 0:
			continue
		var n := 0
		for dy in range(1, 4):
			for dx in range(-2, 3):
				if metals.has(w.tile(gx + dx, gy + dy)):
					n += 1
		if n >= 3:
			w.set_decor(gx, gy, TileDefs.DECOR_ROCKS[c.rng.randi_range(0, 1)])
			glints += 1
	c.notes["affioramenti"] = made
	c.notes["luccichii"] = glints
