class_name PassGuscio
extends GenPass
## Il Guscio (voce 76, gene di forma): la superficie è dentro il mondo. Un tetto di roccia spesso chiude il cielo a
## 30-50 tessere sopra il terreno; dietro l'aria della caverna c'è la parete, quindi è buio come sotto terra, e la luce
## viene dalle cose vive (gocce di Linfa e baccelli che pendono dal tetto) e dai **pozzi di sole**, buchi nel tetto da
## cui scende la luce del giorno (uno è sempre vicino alla partenza). Sotto il tetto non piove (`Weather`, `run.roof`).
## Negli appunti: "tetto" (la riga più bassa del tetto per ogni colonna) e "pozzi" [[x, mezza larghezza]].


func title() -> String:
	return "Guscio"


func run(w: World, c: GenContext) -> void:
	if not c.genes().get("roof", false):
		return
	var nz := c.noise("tetto", 0.02, 3)
	var ridge := c.noise("tetto_radici", 0.08, 2)
	var holes := [[w.spawn.x + 14, 3]]
	var hx := c.rng.randi_range(40, 120)
	while hx < w.w - 40:
		if absi(hx - int(holes[0][0])) > 60:
			holes.append([hx, c.rng.randi_range(3, 6)])
		hx += c.rng.randi_range(110, 190)
	var roof := PackedInt32Array()
	roof.resize(w.w)
	for x in w.w:
		var gap := 40 + int(nz.get_noise_1d(x) * 12.0) + int(ridge.get_noise_1d(x) * 3.0)
		roof[x] = maxi(w.surface[x] - gap, 6)
	for x in w.w:
		var hole := false
		for h in holes:
			if absi(x - int(h[0])) <= int(h[1]):
				hole = true
		for y in range(0, roof[x] + 1):
			if hole:
				continue
			w.set_tile(x, y, TileDefs.RADICE if ridge.get_noise_2d(x, y * 2.0) > 0.25 else TileDefs.STONE)
			w.walls[y * w.w + x] = TileDefs.WALL_STONE
		if hole:
			continue
		for y in range(roof[x] + 1, w.surface[x]):
			if w.walls[y * w.w + x] == 0:
				w.walls[y * w.w + x] = TileDefs.WALL_ROOT if ridge.get_noise_2d(x * 0.5, y) > 0.3 else TileDefs.WALL_STONE
		# le luci vive appese al tetto: gocce di Linfa e baccelli
		if c.rng.randf() < 0.14:
			w.set_decor(x, roof[x] + 1, [TileDefs.DECOR_LINFA, 11, 12, TileDefs.DECOR_STILLA if c.rng.randf() < 0.05 else TileDefs.DECOR_LINFA][c.rng.randi_range(0, 3)])
	c.notes["tetto"] = roof
	c.notes["pozzi"] = holes
