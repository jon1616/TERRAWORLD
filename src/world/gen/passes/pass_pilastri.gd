class_name PassPilastri
extends GenPass
## Le cose delle sagome che vogliono le tessere (voce 459): dopo gli Strati e il Guscio.
## - **pilastri** (sagoma «pilastri»): 6-9 colonne di roccia larghe 14-22 che salgono dalla terra dentro il cielo di
##   mezzo (dove `PassCielo` mette i continenti; la cima è un piano su cui stare), lontane dalla partenza, con una cengia
##   ogni tanto. La superficie non cambia (le zone del cielo si misurano dalla terra). Appunti "pilastri" [[x0, w, cima]].
## Le liane (sul fianco dei pilastri e sulle alzate del canyon) le mette `PassRocce`, dopo le Decorazioni (che riscrivono
## ogni cella d'aria).

func title() -> String:
	return "Pilastri"


func run(w: World, c: GenContext) -> void:
	c.notes["pilastri"] = []
	if str(c.notes.get("sagoma", "")) != "pilastri":
		return
	var d: Dictionary = WorldShapesData.SHAPES["pilastri"]
	var n := c.rng.randi_range(int(d["n"][0]), int(d["n"][1]))
	var nz := c.noise("pilastri", 0.08, 2)
	var made := []
	for tries in n * 30:
		if made.size() >= n:
			break
		var pw := c.rng.randi_range(int(d["w"][0]), int(d["w"][1]))
		var x0 := c.rng.randi_range(40, w.w - 40 - pw)
		if absi(x0 + pw / 2 - w.spawn.x) < 120:
			continue
		var far := true
		for p in made:
			if absi(int(p[0]) - x0) < int(d["gap"]):
				far = false
		if not far:
			continue
		var ground := w.h
		for x in range(x0, x0 + pw):
			ground = mini(ground, int(w.surface[x]))
		var sky := ground - SkyData.LOW_GAP - SkyData.TOP
		var top := ground - SkyData.LOW_GAP - int(sky * float(SkyData.BAND_FRAC["basso"])) \
			- c.rng.randi_range(int(d["rise"][0]), int(d["rise"][1]))
		if top < SkyData.TOP + 20:
			continue
		var rect := Rect2i(x0 - 2, top, pw + 4, ground - top)
		if not c.is_free(rect):
			continue
		for x in range(x0, x0 + pw):
			# i fianchi un po' irregolari: la colonna si allarga alla base e sotto la cima
			for y in range(top, int(w.surface[x]) + 2):
				var t := float(y - top) / maxf(ground - top, 1.0)
				var bulge := 1.0 if t > 0.92 or t < 0.06 else 0.0
				var e := mini(x - x0, x0 + pw - 1 - x)
				if e + bulge * 2 + nz.get_noise_2d(x, y) * 1.5 < 0.0:
					continue
				w.set_tile(x, y, TileDefs.RADICE if nz.get_noise_2d(x * 2.0, y) > 0.35 else TileDefs.STONE)
		# le cenge, a destra e a sinistra, ogni 18-26 righe
		var y := ground - 14
		var right := c.rng.randf() < 0.5
		while y > top + 6:
			var lx := x0 + pw if right else x0 - 3
			for x in range(lx, lx + 3):
				if w.inside(x, y) and not w.solid(x, y):
					w.set_tile(x, y, TileDefs.STONE)
			right = not right
			y -= c.rng.randi_range(18, 26)
		c.claim(rect, "pilastro")
		made.append([x0, pw, top])
	c.notes["pilastri"] = made
