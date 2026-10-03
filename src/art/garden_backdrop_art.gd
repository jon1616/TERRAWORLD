class_name GardenBackdropArt
extends RefCounted
## Il cielo del Giardino (2 ott 2026, l'utente: «rilassante e armonioso»): i disegni dei piani, tutti dal codice e
## ripetibili in orizzontale senza cuciture. Colori del crepuscolo cosmico, pochi contrasti: indaco, lilla, turchese
## spento, qualche punto d'ambra. Li monta e li muove `GardenBackdrop`.

## Il cielo (dall'alto all'orizzonte), per `Background`.
const SKY := ["#1b2c5a", "#3a5690", "#7d8cc2", "#d6b8cc"]
const TEAL := Color("#6fd8cc")
const ROSE := Color("#d49ac0")
const AMBER := Color("#ffcf88")
const VIOLET := Color("#a99cf0")


## Le stelle: puntini fermi, qualcuna più grande a croce.
static func stars(w: int, h: int, sd: int) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	for i in int(w * h / 900.0):
		var x := rng.randi_range(0, w - 1)
		var y := rng.randi_range(0, h - 1)
		var c := Color(1, 1, 1).lerp([TEAL, VIOLET, AMBER][rng.randi_range(0, 2)], 0.35)
		c.a = rng.randf_range(0.35, 0.9)
		im.set_pixel(x, y, c)
		if rng.randf() < 0.06:
			var d := Color(c, c.a * 0.45)
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				im.set_pixel(posmod(x + o.x, w), clampi(y + o.y, 0, h - 1), d)
	return im


## La nebulosa: nubi morbide di turchese e rosa, a gradini (pixel art, non una sfumatura liscia).
static func nebula(w: int, h: int, sd: int) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var n := FastNoiseLite.new()
	n.seed = sd
	n.frequency = 0.008
	n.fractal_octaves = 3
	var n2 := FastNoiseLite.new()
	n2.seed = sd + 7
	n2.frequency = 0.004
	for y in h:
		var fade := sin(PI * float(y) / float(h))             # svanisce in alto e in basso
		for x in w:
			# rumore che si ripete in orizzontale: due campioni mescolati ai bordi
			# fasce allungate (il rumore stirato in orizzontale): veli tranquilli, non macchie
			var t := float(x) / float(w)
			var sy := float(y) * 2.6
			var v := lerpf(n.get_noise_2d(x, sy), n.get_noise_2d(x - w, sy), t)
			var hue := lerpf(n2.get_noise_2d(x, y), n2.get_noise_2d(x - w, y), t)
			var a := clampf((v + 0.15) * 1.3, 0.0, 1.0) * fade * fade
			a = floorf(a * 7.0) / 7.0 * 0.2                     # sette gradini leggeri, mai più di un quinto
			if a <= 0.0:
				continue
			var c := TEAL.lerp(ROSE, clampf(hue * 1.5 + 0.5, 0.0, 1.0))
			im.set_pixel(x, y, Color(c, a))
	return im


## I mondi-seme lontani: piccole sfere luminose, illuminate da sinistra, qualcuna con un anello sottile.
static func seeds(w: int, h: int, sd: int) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var cols := [TEAL, AMBER, VIOLET, ROSE]
	var x := rng.randf_range(40.0, 140.0)
	while x < w - 40:
		var r := rng.randf_range(4.0, 16.0)
		var cy := rng.randf_range(h * 0.2, h * 0.8)
		var c: Color = cols[rng.randi_range(0, cols.size() - 1)]
		_sphere(im, Vector2(x, cy), r, c, rng.randf() < 0.35)
		x += rng.randf_range(180.0, 380.0)
	return im


static func _sphere(im: Image, ctr: Vector2, r: float, c: Color, ring: bool) -> void:
	var w := im.get_width()
	var h := im.get_height()
	# l'alone: due cerchi tenui
	for k in [[r * 2.4, 0.06], [r * 1.6, 0.1]]:
		var rr := float(k[0])
		for yy in range(int(ctr.y - rr), int(ctr.y + rr) + 1):
			for xx in range(int(ctr.x - rr), int(ctr.x + rr) + 1):
				if Vector2(xx, yy).distance_to(ctr) <= rr and yy >= 0 and yy < h:
					_blend(im, posmod(xx, w), yy, Color(c, float(k[1])))
	# la sfera: tre toni (luce da sinistra in alto), l'orlo chiaro
	for yy in range(int(ctr.y - r), int(ctr.y + r) + 1):
		for xx in range(int(ctr.x - r), int(ctr.x + r) + 1):
			var d := Vector2(xx, yy) - ctr
			if d.length() > r or yy < 0 or yy >= h:
				continue
			var lit := (-d.x * 0.6 - d.y * 0.8) / r                 # da -1 a 1
			var tone := c.darkened(0.45)
			if lit > 0.35:
				tone = c.lightened(0.25)
			elif lit > -0.25:
				tone = c
			if d.length() > r - 1.0 and lit > 0.0:
				tone = c.lightened(0.5)
			im.set_pixel(posmod(xx, w), yy, tone)
	if ring:
		for i in 90:
			var a := TAU * float(i) / 90.0
			var p := ctr + Vector2(cos(a) * r * 1.9, sin(a) * r * 0.45)
			# dietro la sfera l'anello non si vede
			if sin(a) < 0.0 and p.distance_to(ctr) < r:
				continue
			if p.y >= 0 and p.y < h:
				_blend(im, posmod(int(p.x), w), int(p.y), Color(c.lightened(0.3), 0.7))


## Le isolette lontane: rocce sospese con l'erba sopra, le radici che pendono e un alberello con le lanterne accese.
## `haze` = quanto si confondono col cielo (la distanza).
static func islands(w: int, h: int, sd: int, haze: Color, k_haze: float) -> Image:
	var im := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var rock := Color("#4a2c48").lerp(haze, k_haze)
	var rock_d := Color("#2e1c32").lerp(haze, k_haze)
	var grass := Color("#3aa08a").lerp(haze, k_haze * 0.8)
	var root := Color("#3a2438").lerp(haze, k_haze)
	var x := rng.randf_range(60.0, 200.0)
	while x < w - 80:
		var iw := rng.randf_range(34.0, 80.0)
		var top := rng.randf_range(h * 0.25, h * 0.6)
		var deep := iw * rng.randf_range(0.45, 0.7)
		for xx in range(int(x - iw * 0.5), int(x + iw * 0.5) + 1):
			var t := absf(float(xx) - x) / (iw * 0.5)              # 0 al centro, 1 ai bordi
			var bottom := top + deep * (1.0 - t * t) + rng.randf_range(-1.0, 1.0)
			var y0 := top + t * t * 3.0
			for yy in range(int(y0), int(bottom)):
				if yy < 0 or yy >= h:
					continue
				var c := rock if float(yy - y0) < deep * 0.35 else rock_d
				if yy - int(y0) < 2:
					c = grass
				im.set_pixel(posmod(xx, w), yy, c)
			# radici che pendono, ogni tanto
			if rng.randf() < 0.12:
				var ln := rng.randi_range(4, 18)
				for k in ln:
					var yy := int(bottom) + k
					if yy < h:
						_blend(im, posmod(xx + (k / 6), w), yy, Color(root, 1.0 - float(k) / ln))
		# un alberello con le lanterne
		if iw > 46.0:
			var tx := int(x + rng.randf_range(-iw * 0.2, iw * 0.2))
			var ty := int(top)
			for k in 10:
				if ty - k >= 0:
					im.set_pixel(posmod(tx, w), ty - k, rock_d)
			for i in 26:
				var p := Vector2(tx + rng.randf_range(-7.0, 7.0), ty - 10 + rng.randf_range(-4.0, 3.0))
				if p.y >= 0:
					im.set_pixel(posmod(int(p.x), w), int(p.y), grass.darkened(0.2))
			for i in 4:
				var q := Vector2i(tx + rng.randi_range(-6, 6), ty - 8 + rng.randi_range(0, 5))
				if q.y >= 0:
					im.set_pixel(posmod(q.x, w), q.y, Color(AMBER.r * 1.6, AMBER.g * 1.6, AMBER.b * 1.6))
		x += iw + rng.randf_range(120.0, 300.0)
	return im


static func _blend(im: Image, x: int, y: int, c: Color) -> void:
	var o := im.get_pixel(x, y)
	if o.a <= 0.0:
		im.set_pixel(x, y, c)
		return
	var a := c.a + o.a * (1.0 - c.a)
	im.set_pixel(x, y, Color((c.r * c.a + o.r * o.a * (1.0 - c.a)) / a, (c.g * c.a + o.g * o.a * (1.0 - c.a)) / a,
		(c.b * c.a + o.b * o.a * (1.0 - c.a)) / a, a))
