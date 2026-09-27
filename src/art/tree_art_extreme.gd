class_name TreeArtExtreme
extends RefCounted
## Gli alberi delle terre estreme (voce 93), nello stile di `TreeArt` (che li chiama per nome dopo `TreeArtTemperate`):
##   vetrocacto      Deserti di vetro: colonne di vetro trasparente con le braccia, riflessi che brillano
##   cristallo_gelo  Ghiacciai di Linfa: un tronco di ghiaccio che si apre in punte di cristallo con la Linfa dentro
##   pietrificato    Foreste pietrificate: un albero diventato pietra, rami spezzati, muschio grigio sulle spalle
## (le Lande di brace viva usano il disegno del Tizzone.)

const OUT := Color("#05090c")


static func draw(species: String, im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> bool:
	match species:
		"vetrocacto":
			_vetrocacto(im, gm, w, h, rng)
		"cristallo_gelo":
			_cristallo(im, gm, w, h, rng)
		"pietrificato":
			_pietrificato(im, gm, w, h, rng)
		_:
			return false
	return true


## Una colonna arrotondata in cima, con i toni da sinistra (chiaro) a destra (scuro).
static func _column(im: Image, x0: float, y0: int, y1: int, hw: float, p: Array[Color]) -> void:
	for y in range(y0, y1):
		var r := hw if y > y0 + hw else sqrt(maxf(hw * hw - pow(y0 + hw - y, 2.0), 0.0))
		for x in range(int(x0 - r), int(x0 + r) + 1):
			var k := (x - (x0 - r)) / maxf(2.0 * r, 1.0)
			Px.put(im, x, y, p[3] if k < 0.25 else (p[2] if k < 0.7 else p[1]))


static func _vetrocacto(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var p := Px.pal(["#2a3a34", "#5a7a6e", "#9ac8b8", "#e0fff4", "#ffffff"])
	var sc := h / 124.0
	var cx := w / 2.0
	var hw := 2.5 + 2.5 * sc
	_column(im, cx, int(h * 0.12), h, hw, p)
	for side in [-1.0, 1.0]:
		if rng.randf() < 0.85:
			var ay := int(h * rng.randf_range(0.35, 0.6))
			var ax: float = cx + side * rng.randf_range(0.22, 0.32) * w
			for x in range(int(minf(cx, ax)), int(maxf(cx, ax)) + 1):
				for y in range(ay, ay + int(hw)):
					Px.put(im, x, y, p[2])
			_column(im, ax, ay - int(h * rng.randf_range(0.12, 0.22)), ay + int(hw), hw * 0.7, p)
	Px.outline(im, OUT)
	for k in int(3 + 4 * sc):
		var q := Vector2(cx + rng.randf_range(-0.3, 0.3) * w, rng.randf_range(h * 0.15, h * 0.9))
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.put(im, int(q.x), int(q.y), p[4])
			Px.put(gm, int(q.x), int(q.y), Color(0.7, 0.9, 0.8))


static func _cristallo(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var ice := Px.pal(["#1a3848", "#2a5a70", "#4a8aa0", "#8ad0e0", "#e8ffff"])
	var linfa := Color("#5cf0d8")
	var sc := h / 124.0
	var cx := w / 2.0
	var fork := int(h * 0.45)
	_column(im, cx, fork, h, 2.0 + 2.0 * sc, ice)
	# le punte: triangoli sottili che partono dal tronco a ventaglio
	for k in 5:
		var ang := -PI / 2.0 + (k - 2) * rng.randf_range(0.28, 0.36)
		var ln := h * rng.randf_range(0.3, 0.45)
		var tip := Vector2(cx, fork) + Vector2(cos(ang), sin(ang)) * ln
		var base_w := 2.0 + 2.0 * sc
		for t in int(ln):
			var q := Vector2(cx, fork).lerp(tip, t / ln)
			var ww := base_w * (1.0 - t / ln)
			for d in range(-int(ww), int(ww) + 1):
				var c := ice[3] if d < 0 else ice[2]
				Px.put(im, int(q.x + d), int(q.y), c)
		Px.put(im, int(tip.x), int(tip.y), ice[4])
	Px.outline(im, OUT)
	# la Linfa gelata dentro: una vena che brilla lungo il tronco e qualche goccia nelle punte
	for y in range(fork, h - 2, 2):
		Px.put(im, int(cx), y, linfa)
		Px.put(gm, int(cx), y, Color(0.3, 0.8, 0.75))
	for k in int(2 + 3 * sc):
		var q := Vector2(cx + rng.randf_range(-0.3, 0.3) * w, rng.randf_range(h * 0.1, fork))
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.put(im, int(q.x), int(q.y), linfa)
			Px.put(gm, int(q.x), int(q.y), linfa)


static func _pietrificato(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var stone := Px.pal(["#26262a", "#3e3e44", "#5e5e64", "#8a8a8a"])
	var moss := Color("#6a7a60")
	var sc := h / 124.0
	var cx := w / 2.0
	TreeArt._trunk(im, w, h, int(h * 0.4), stone, rng, 2.0 + 2.5 * sc)
	var tips: Array[Vector2] = []
	for s in [-1.0, 1.0]:
		TreeArt._branch(im, Vector2(cx, h * 0.42), -PI / 2.0 + s * rng.randf_range(0.3, 0.6), h * 0.28, 2.0 + sc,
			2, stone, rng, tips)
	# i rami spezzati: niente foglie, qualche moncone e il muschio grigio sulle spalle
	for t in tips:
		Px.put(im, int(t.x), int(t.y), stone[3])
	for k in int(4 + 6 * sc):
		var q := Vector2(cx + rng.randf_range(-0.3, 0.3) * w, rng.randf_range(h * 0.3, h * 0.9))
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.put(im, int(q.x), int(q.y), moss)
	Px.outline(im, OUT)
	# un'unica scintilla di Linfa rimasta dentro la pietra
	var e := Vector2(cx, h * rng.randf_range(0.5, 0.8))
	Px.put(im, int(e.x), int(e.y), Color("#8ef0d8"))
	Px.put(gm, int(e.x), int(e.y), Color(0.3, 0.8, 0.7))
