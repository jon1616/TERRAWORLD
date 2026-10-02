class_name BackdropArt
extends RefCounted
## Roadmap 34, voce 329: i disegni degli sfondi dei biomi (dati in `BackdropData`), fatti dal codice come le colline e
## la foresta di `NatureArt`. Ogni immagine si ripete senza cuciture in orizzontale (le forme che passano il bordo
## rientrano dall'altra parte, il rumore è letto su un cerchio). Puro codice, niente file: si può fare in un thread.
## L'orizzonte nell'immagine è a `HORIZON` pixel dall'alto (lo stesso delle colline di prima).

const H := 420
const HORIZON := 190


## Un piano: [disegno, parallasse, spostamento, larghezza, colore, accento] → l'immagine.
static func layer(spec: Array, sd: int) -> Image:
	var kind := String(spec[0])
	var w := int(spec[3])
	var col := Color(String(spec[4]))
	var acc := Color(String(spec[5])) if String(spec[5]) != "" else col.lightened(0.25)
	match kind:
		"creste":
			return NatureArt.mountains(w, H, sd, 190.0, 45.0, 0.012, col, col.darkened(0.12), false, Color(0, 0, 0, 0))
		"mesa":
			return mesa(w, sd, col)
		"picchi":
			return peaks(w, sd, col, acc)
		"dune":
			return dunes(w, sd, col, acc)
		"archi":
			return arches(w, sd, col, acc)
		"coni":
			return cones(w, sd, col, acc)
		"lanterne":
			return NatureArt.lantern_forest(w, H, sd, col, acc)
	return trees(w, sd, kind, col, acc)


static func _put(im: Image, x: int, y: int, c: Color) -> void:
	if y >= 0 and y < im.get_height():
		im.set_pixel(posmod(x, im.get_width()), y, c)


## Il profilo del terreno sotto le forme (una linea che ondeggia piano, senza cuciture), riempito fino in fondo.
static func _ground(im: Image, sd: int, gy: float, amp: float, col: Color) -> PackedFloat32Array:
	var w := im.get_width()
	var n := FastNoiseLite.new()
	n.seed = sd
	n.frequency = 0.02
	var R := w / TAU
	var g := PackedFloat32Array()
	g.resize(w)
	for x in w:
		var a := float(x) / w * TAU
		g[x] = gy + n.get_noise_2d(cos(a) * R, sin(a) * R) * amp
		for y in range(int(g[x]), H):
			im.set_pixel(x, y, col)
	return g


## Altipiani dal tetto piatto (le Distese d'ambra): gradini lenti, i fianchi a strati più chiari.
static func mesa(w: int, sd: int, col: Color) -> Image:
	var im := Px.img(w, H)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var top := PackedFloat32Array()
	top.resize(w)
	top.fill(HORIZON + 20.0)
	var x := 0
	while x < w:
		var wd := rng.randi_range(40, 120)
		var ht := rng.randf_range(30.0, 90.0)
		for k in wd:
			var e := minf(float(k), float(wd - k)) / 6.0               # i fianchi scendono in pochi pixel
			top[posmod(x + k, w)] = minf(top[posmod(x + k, w)], HORIZON + 20.0 - ht * clampf(e, 0.0, 1.0))
		x += wd + rng.randi_range(10, 60)
	for xx in w:
		for y in range(int(top[xx]), H):
			var band := int((y - top[xx]) / 7.0) % 2 == 0
			im.set_pixel(xx, y, col.lightened(0.06) if band and y - top[xx] < 40.0 else col)
		_put(im, xx, int(top[xx]), col.lightened(0.18))
	return im


## Punte di cristallo o di ghiaccio sopra una catena di monti: gruppi di spire di altezze molto diverse (le grandi rade,
## le piccole attorno), i fianchi a gradini, una faccia illuminata e la neve sui monti.
static func peaks(w: int, sd: int, col: Color, lit: Color) -> Image:
	var im := NatureArt.mountains(w, H, sd, 200.0, 50.0, 0.014, col.darkened(0.06), col.darkened(0.18), true, Color(0, 0, 0, 0))
	var rng := RandomNumberGenerator.new()
	rng.seed = sd + 3
	var x := rng.randf_range(0.0, 60.0)
	while x < w:
		var group := rng.randi_range(2, 5)
		var big := rng.randf_range(70.0, 150.0)
		for g in group:
			var ht := big * (1.0 if g == 0 else rng.randf_range(0.3, 0.65))
			var hw := ht * rng.randf_range(0.12, 0.2)
			var cx := int(x + (0.0 if g == 0 else rng.randf_range(-hw * 3.0, hw * 3.0)))
			var base := HORIZON + 30 + rng.randi_range(-6, 8)
			var lean := rng.randf_range(-0.12, 0.12)
			for yy in int(ht):
				var half := hw * float(yy) / ht
				if yy % 9 == 8:
					half += 1.0                                  # i gradini del cristallo
				var y := base - int(ht) + yy
				var sx := cx + int((ht - yy) * lean)
				for dx in range(-int(half), int(half) + 1):
					var c := col
					if dx < 0:
						c = lit.lerp(col, 0.45)
					if dx == -int(half):
						c = lit
					_put(im, sx + dx, y, c)
		x += rng.randf_range(70.0, 180.0)
	return im


## Dune morbide (i Deserti di vetro): onde lente con la cresta chiara.
static func dunes(w: int, sd: int, col: Color, lit: Color) -> Image:
	var im := Px.img(w, H)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var k1 := rng.randi_range(2, 3)
	var k2 := rng.randi_range(5, 7)
	var p1 := rng.randf() * TAU
	var p2 := rng.randf() * TAU
	for x in w:
		var a := float(x) / w * TAU
		var y0 := HORIZON + 10.0 - (sin(a * k1 + p1) * 0.6 + sin(a * k2 + p2) * 0.4 + 1.0) * 26.0
		for y in range(int(y0), H):
			var d := y - y0
			im.set_pixel(x, y, lit if d < 2.0 else (col.lightened(0.08) if d < 9.0 else col))
	return im


## Archi di vetro (i Deserti di vetro): mezzi anelli lontani, il bordo che luccica.
static func arches(w: int, sd: int, col: Color, lit: Color) -> Image:
	var im := Px.img(w, H)
	var g := _ground(im, sd, HORIZON + 40.0, 6.0, col.darkened(0.15))
	var rng := RandomNumberGenerator.new()
	rng.seed = sd + 7
	var x := rng.randf_range(0.0, 80.0)
	while x < w:
		var r := rng.randf_range(26.0, 60.0)
		var th := rng.randf_range(5.0, 9.0)
		var cx := x + r
		var cy := g[posmod(int(cx), w)] + 2.0
		for yy in range(int(cy - r - th), int(cy) + 1):
			for xx in range(int(cx - r - th), int(cx + r + th) + 1):
				var d := Vector2(xx - cx, yy - cy).length()
				if d >= r and d <= r + th and yy <= cy:
					_put(im, xx, yy, lit if d > r + th - 1.5 else col)
		x += r * 2.0 + rng.randf_range(60.0, 200.0)
	return im


## Coni fumanti (le terre di brace e di cenere): vulcani lontani con il cratere acceso e un pennacchio fermo.
static func cones(w: int, sd: int, col: Color, glow: Color) -> Image:
	var im := Px.img(w, H)
	_ground(im, sd, HORIZON + 30.0, 8.0, col)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd + 5
	var x := rng.randf_range(0.0, 60.0)
	while x < w:
		var ht := rng.randf_range(60.0, 130.0)
		var hw := ht * rng.randf_range(1.1, 1.6)
		var top_w := hw * 0.12
		var cx := int(x + hw)
		var base := HORIZON + 34
		for yy in int(ht):
			var half := lerpf(top_w, hw, float(yy) / ht)
			var y := base - int(ht) + yy
			for dx in range(-int(half), int(half) + 1):
				var c := col.lightened(0.08) if dx < 0 else col
				if yy < 3 and absf(dx) < top_w:
					c = glow
				_put(im, cx + dx, y, c)
		# il pennacchio: sbuffi grigi che salgono e piegano
		var smoke := col.lightened(0.35)
		smoke.a = 0.55
		for k in 9:
			var sx := cx + int(k * k * 0.35)
			var sy := base - int(ht) - 6 - k * 9
			var rr := 4 + k
			for yy in range(-rr, rr + 1):
				for xx in range(-rr, rr + 1):
					if xx * xx + yy * yy <= rr * rr and sy + yy >= 0:
						var old := im.get_pixel(posmod(sx + xx, w), sy + yy)
						if old.a < 0.5:
							_put(im, sx + xx, sy + yy, smoke)
		x += hw * 2.0 + rng.randf_range(80.0, 260.0)
	return im


## Una fila di alberi della forma del bioma su un terreno che ondeggia.
static func trees(w: int, sd: int, shape: String, col: Color, acc: Color) -> Image:
	var im := Px.img(w, H)
	var g := _ground(im, sd, H * 0.64, 12.0, col)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd + 11
	var x := 0.0
	var step := {"canne": [5.0, 12.0], "cactus": [40.0, 110.0], "funghi": [30.0, 70.0], "pini": [12.0, 26.0]}.get(shape, [20.0, 40.0]) as Array
	while x < w:
		var cx := int(x)
		var base := int(g[posmod(cx, w)]) + 2
		match shape:
			"pini":
				_pine(im, cx, base, rng.randf_range(26.0, 60.0), col, acc, rng)
			"secchi":
				_dead(im, cx, base, rng.randf_range(30.0, 64.0), col, acc, rng)
			"pagode":
				_pagoda(im, cx, base, rng.randf_range(34.0, 70.0), col, acc, rng)
			"ombrelli":
				_umbrella(im, cx, base, rng.randf_range(30.0, 62.0), col, acc, rng)
			"canne":
				_reed(im, cx, base, rng.randf_range(12.0, 34.0), col, acc, rng)
			"cactus":
				_cactus(im, cx, base, rng.randf_range(26.0, 56.0), col, acc, rng)
			"funghi":
				_mushroom(im, cx, base, rng.randf_range(30.0, 80.0), col, acc, rng)
		x += rng.randf_range(float(step[0]), float(step[1]))
	return im


static func _trunk(im: Image, cx: int, base: int, ht: float, thick: int, col: Color) -> void:
	for y in range(base - int(ht), base):
		for t in thick:
			_put(im, cx + t, y, col)


static func _pine(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx, base, ht * 0.25, 2, col)
	var tiers := rng.randi_range(3, 4)
	for t in tiers:
		var top := base - ht + t * ht * 0.22
		var bot := top + ht * 0.4
		for y in range(int(top), int(bot)):
			var half := (y - top) / (bot - top) * (ht * 0.22 - t * 1.5)
			for dx in range(-int(half), int(half) + 1):
				_put(im, cx + dx, y, acc if y == int(top) + 1 and dx == 0 else col)
		if rng.randf() < 0.6:
			_put(im, cx - int((bot - top) * 0.3), int(bot) - 1, acc)            # neve sui rami


static func _dead(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx, base, ht, 2, col)
	for b in rng.randi_range(3, 5):
		var by := base - ht * rng.randf_range(0.4, 0.95)
		var dir := 1.0 if rng.randf() < 0.5 else -1.0
		var ln := rng.randi_range(6, int(ht * 0.4) + 6)
		for i in ln:
			_put(im, cx + int(dir * i), int(by - i * 0.6), col)
		if rng.randf() < 0.35:
			_put(im, cx + int(dir * ln), int(by - ln * 0.6) - 1, acc)            # una brace o un cristallo sulla punta


static func _pagoda(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx, base, ht, 2, col)
	var n := rng.randi_range(3, 5)
	for k in n:
		var cy := base - ht + k * (ht * 0.8 / n)
		var rx := 6.0 + k * 3.0
		for y in range(int(cy - 3), int(cy + 3)):
			for xx in range(int(cx - rx), int(cx + rx) + 1):
				var dx := (xx - cx) / rx
				var dy := (y - cy) / 3.0
				if dx * dx + dy * dy <= 1.0:
					_put(im, xx, y, acc if y == int(cy - 3) and k == 0 else col)


static func _umbrella(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx, base, ht, 2, col)
	var rx := rng.randf_range(12.0, 24.0)
	var cy := base - ht
	for y in range(int(cy - 4), int(cy + 3)):
		for xx in range(int(cx - rx), int(cx + rx) + 1):
			var dx := (xx - cx) / rx
			var dy := (y - cy) / (4.0 if y < cy else 3.0)
			if dx * dx + dy * dy <= 1.0:
				_put(im, xx, y, col)
	for k in 3:
		_put(im, cx + rng.randi_range(-int(rx), int(rx)), int(cy) + 2, acc)


static func _reed(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	var lean := rng.randf_range(-0.15, 0.15)
	for i in int(ht):
		_put(im, cx + int(i * lean), base - i, col)
	if rng.randf() < 0.5:
		for k in 3:
			_put(im, cx + int(ht * lean), base - int(ht) + k, acc)
			_put(im, cx + int(ht * lean) + 1, base - int(ht) + k, acc)


static func _cactus(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx - 2, base, ht, 5, col)
	_put(im, cx, base - int(ht), acc)
	for side in [-1, 1]:
		if rng.randf() < 0.75:
			var ay := base - int(ht * rng.randf_range(0.4, 0.7))
			var ln := rng.randi_range(5, 9)
			for i in ln:
				for t in 3:
					_put(im, cx + side * (3 + i), ay + t, col)
			for i in rng.randi_range(6, 12):
				for t in 3:
					_put(im, cx + side * (3 + ln) + t - 1, ay - i, col)


static func _mushroom(im: Image, cx: int, base: int, ht: float, col: Color, acc: Color, rng: RandomNumberGenerator) -> void:
	_trunk(im, cx - 1, base, ht, 3, col)
	var rx := ht * rng.randf_range(0.35, 0.55)
	var ry := rx * 0.55
	var cy := base - ht
	for y in range(int(cy - ry), int(cy + 2)):
		for xx in range(int(cx - rx), int(cx + rx) + 1):
			var dx := (xx - cx) / rx
			var dy := (y - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				_put(im, xx, y, acc.lerp(col, 0.45) if y > cy - ry * 0.35 else acc.lerp(col, 0.2))
	for k in 4:
		_put(im, cx + int(rng.randf_range(-rx * 0.6, rx * 0.6)), int(cy - ry * rng.randf_range(0.3, 0.8)), acc.lightened(0.4))
