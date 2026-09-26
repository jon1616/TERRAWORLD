class_name PassRadici
extends GenPass
## Le radici enormi del Sottobosco: partono poco sotto la superficie e scendono serpeggiando, spesse 2-4 tessere, fino
## alle Caverne d'ardesia. Attraversano tutto, anche le grotte: dove passano nel vuoto diventano ponti e appigli.
## Viene dopo le grotte proprio per questo.

const EVERY := 34                      # in media una radice ogni tante colonne


func title() -> String:
	return "Radici"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var n_bend := c.noise("radici_curve", 0.03, 2)
	var bottom := StrataData.top(2) + 30
	var count := roundi(w.w / EVERY * float(c.genes()["roots"]))     # gene «Radici giganti» (voce 43)
	for r in count:
		var x := float(rng.randi_range(8, w.w - 9))
		var y := float(w.surface[int(x)] + rng.randi_range(8, 16))
		var ang := PI * 0.5 + rng.randf_range(-0.7, 0.7)
		var thick := rng.randf_range(1.6, 2.4)
		var length := rng.randi_range(90, 220)
		for s in length:
			var dep := int(y) - w.surface[clampi(int(x), 0, w.w - 1)]
			if dep > bottom or x < 3 or x > w.w - 4:
				break
			ang += n_bend.get_noise_2d(r * 50.0, s) * 0.18
			ang = clampf(ang, 0.25, PI - 0.25)          # scende sempre, a volte quasi in orizzontale
			x += cos(ang)
			y += sin(ang) * 0.8
			var th := thick * (1.0 - 0.55 * s / length)
			_disc(w, x, y, th)
			# qualche radice secondaria che si stacca
			if rng.randf() < 0.012 and th > 1.2:
				_branch(w, rng, x, y, ang + (0.9 if rng.randf() < 0.5 else -0.9), th * 0.6)


func _branch(w: World, rng: RandomNumberGenerator, x: float, y: float, ang: float, th: float) -> void:
	for s in rng.randi_range(15, 40):
		x += cos(ang)
		y += sin(ang) * 0.8
		ang += rng.randf_range(-0.15, 0.15)
		_disc(w, x, y, th * (1.0 - s / 45.0))


func _disc(w: World, cx: float, cy: float, r: float) -> void:
	var ri := int(ceil(r))
	for dy in range(-ri, ri + 1):
		for dx in range(-ri, ri + 1):
			if dx * dx + dy * dy > r * r + 0.3:
				continue
			var x := int(cx) + dx
			var y := int(cy) + dy
			if not w.inside(x, y) or y - w.surface[x] < 4:
				continue
			var i := y * w.w + x
			w.tiles[i] = TileDefs.RADICE
			if w.walls[i] != 0:
				w.walls[i] = TileDefs.WALL_ROOT
