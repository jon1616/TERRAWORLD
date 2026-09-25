class_name NatureArt
extends RefCounted
## Ambiente disegnato dal codice, stile «Radici e Linfa»: alberi-lanterna, torcia, colline e foreste ripetibili,
## le radici del cosmo nel cielo, il sole.

const WOOD := ["#3e2614", "#5e3a1e", "#7e5230", "#a0703f"]

## Albero-lanterna: tronco contorto, chioma a salice di fronde turchesi che pendono, baccelli d'ambra luminosi.
## Restituisce l'immagine e la sua parte luminosa (i baccelli), che va disegnata sopra il buio.
static func tree_linfa(sd: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var W := 64
	var H := 124
	var im := Px.img(W, H)
	var gm := Px.img(W, H)
	var bark := Px.pal(["#140c14", "#241624", "#362234", "#4c3246"])
	var frond := Px.pal(["#0b2e30", "#134a48", "#1f6a60", "#339280", "#62c4a4"])
	var pod := Px.pal(TileDefs.P_BRACE)
	var cx := W / 2.0
	var top := rng.randi_range(40, 56)
	var phase := rng.randf() * TAU
	var amp := rng.randf_range(2.0, 5.0)
	var trunk_x := PackedFloat32Array()
	trunk_x.resize(H)
	for y in range(top, H):
		var t := float(H - 1 - y) / float(H - 1 - top)
		var x := cx + sin(t * 3.2 + phase) * amp * t
		trunk_x[y] = x
		var hw := lerpf(3.6, 1.4, t)
		for xx in range(int(x - hw), int(x + hw) + 1):
			var k := (xx - (x - hw)) / (2.0 * hw)
			var c := bark[2] if k < 0.35 else (bark[1] if k < 0.8 else bark[0])
			if (y * 5 + xx * 3) % 9 == 0:
				c = bark[3]
			Px.put(im, xx, y, c)
	for r in 4:
		var dir := -1.0 if r % 2 == 0 else 1.0
		Px.line(im, Vector2(cx, H - 4), Vector2(cx + dir * rng.randf_range(4.0, 10.0), H - 1), 2, bark[1])
	var cy := float(top)
	var rx := rng.randf_range(15.0, 20.0)
	var ry := rng.randf_range(9.0, 12.0)
	for y in range(int(cy - ry) - 1, int(cy + ry * 0.6)):
		for x in W:
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				var t := 0.62 - dx * 0.25 - dy * 0.45 + rng.randf_range(-0.1, 0.1)
				Px.put(im, x, y, frond[clampi(int(t * 5.0), 0, 4)])
	var strands: Array[Vector2] = []
	for s in 30:
		var a := rng.randf_range(-1.0, 1.0)
		var sx := cx + a * rx * 0.95
		var sy := cy + sqrt(maxf(1.0 - a * a, 0.0)) * ry * 0.45
		var length := int(rng.randf_range(12.0, 36.0) * (1.0 - absf(a) * 0.35))
		for i in length:
			var x := sx + a * i * 0.22 + sin(i * 0.3 + s) * 0.8
			var y := sy + i
			var c := frond[3] if i < length * 0.4 else (frond[2] if i < length * 0.8 else frond[1])
			Px.put(im, int(x), int(y), c)
			if i % 3 == 1:
				Px.put(im, int(x) + (1 if s % 2 == 0 else -1), int(y), frond[4] if i < length * 0.3 else frond[2])
			if i == length / 2:
				strands.append(Vector2(x, y))
	Px.outline(im, Color("#05090c"))
	for k in mini(7, strands.size()):
		var q: Vector2 = strands[rng.randi_range(0, strands.size() - 1)]
		for dy in 3:
			for dx in 2:
				var c := pod[3] if dy == 0 else pod[2]
				Px.put(im, int(q.x) + dx, int(q.y) + dy, c)
				Px.put(gm, int(q.x) + dx, int(q.y) + dy, c)
	return {"img": im, "glow": gm}


static func torch_stick() -> Image:
	var w := Px.pal(WOOD)
	var im := Px.img(4, 10)
	for y in range(3, 10):
		Px.put(im, 1, y, w[2])
		Px.put(im, 2, y, w[1])
	Px.put(im, 1, 2, Color("#5a5a66"))
	Px.put(im, 2, 2, Color("#3a3a44"))
	return im


static func flame() -> Image:
	var im := Px.img(7, 10)
	Px.disc(im, 3.5, 6.2, 3.0, Color("#ff7a20"))
	Px.disc(im, 3.5, 6.6, 1.9, Color("#ffc840"))
	Px.disc(im, 3.5, 7.0, 0.9, Color("#fff8e0"))
	Px.put(im, 3, 1, Color("#ff7a20"))
	Px.put(im, 3, 2, Color("#ff7a20"))
	Px.put(im, 4, 2, Color("#ff9a30"))
	return im


## Montagne che si ripetono senza cuciture (il rumore è letto su un cerchio).
static func mountains(w: int, h: int, sd: int, base_y: float, amp: float, freq: float,
		top: Color, bottom: Color, snow: bool, pines: Color) -> Image:
	var n := FastNoiseLite.new()
	n.seed = sd
	n.frequency = freq
	n.fractal_octaves = 3
	var im := Px.img(w, h)
	var R := w / TAU
	var ridge := PackedFloat32Array()
	ridge.resize(w)
	for x in w:
		var a := float(x) / w * TAU
		ridge[x] = base_y - clampf(n.get_noise_2d(cos(a) * R, sin(a) * R) * 0.8 + 0.5, 0.0, 1.0) * amp
	for x in w:
		var r := int(ridge[x])
		for y in range(maxi(r, 0), h):
			var c := top.lerp(bottom, clampf(float(y - r) / 90.0, 0.0, 1.0))
			if y == r:
				c = c.lightened(0.12)
			if snow and y - r < 4 + (x * 7) % 3 and ridge[x] < base_y - amp * 0.62:
				c = Color("#e8e0f4")
			im.set_pixel(x, y, c)
	if pines.a > 0.0:
		var rng := RandomNumberGenerator.new()
		rng.seed = sd + 9
		var x := 0
		while x < w - 8:
			var ph := rng.randi_range(9, 18)
			var base := int(ridge[x + 3]) + 3
			for yy in ph:
				var hw := int((yy + 1) * 3.6 / ph)
				for dx in range(-hw, hw + 1):
					Px.put(im, x + 3 + dx, base - ph + yy, pines)
			for yy in range(base, mini(base + 6, h)):
				Px.put(im, x + 3, yy, pines)
			x += rng.randi_range(4, 9)
	return im


## Le radici del cosmo: archi enormi che attraversano il cielo, con viticci che pendono e isole sospese.
## Si ripete senza cuciture in orizzontale.
static func root_arches(w: int, h: int, sd: int, col: Color, rim: Color) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var im := Px.img(w, h)
	for k in 3:
		var x0 := rng.randf_range(0.0, w)
		var span := rng.randf_range(w * 0.35, w * 0.6)
		var peak := rng.randf_range(h * 0.45, h * 0.8)
		var a := Vector2(x0, h + 10)
		var b := Vector2(x0 + span, h + 10)
		var c1 := Vector2(x0 + span * 0.15, h - peak * 1.3)
		var c2 := Vector2(x0 + span * 0.85, h - peak * 1.1)
		var thick0 := rng.randf_range(12.0, 18.0)
		for i in 241:
			var t := i / 240.0
			var u := 1.0 - t
			var p := a * u * u * u + c1 * 3.0 * u * u * t + c2 * 3.0 * u * t * t + b * t * t * t
			var th := lerpf(thick0, 4.0, t)
			for dx in range(-int(th), int(th) + 1):
				for dy in range(-int(th), int(th) + 1):
					if dx * dx + dy * dy <= th * th:
						var y := int(p.y) + dy
						if y >= 0 and y < h:
							im.set_pixel(posmod(int(p.x) + dx, w), y, rim if dy < -th + 2.0 else col)
			if i % 17 == 5 and t > 0.15 and t < 0.9:
				var tl := rng.randi_range(8, 30)
				for j in tl:
					var y := int(p.y + th) + j
					if y < h:
						im.set_pixel(posmod(int(p.x + sin(j * 0.4) * 1.5), w), y, col)
	for k in 3:
		var ix := rng.randf_range(0.0, w)
		var iy := rng.randf_range(h * 0.15, h * 0.45)
		var r := rng.randf_range(10.0, 18.0)
		for y in range(int(iy - r * 0.4), int(iy + r)):
			for x in range(int(ix - r), int(ix + r)):
				var dx := (x - ix) / r
				var dy := (y - iy) / (r if y > iy else r * 0.4)
				if dx * dx + dy * dy <= 1.0 and y >= 0 and y < h:
					im.set_pixel(posmod(x, w), y, rim if y < iy - r * 0.3 else col)
		for j in 4:
			var rx := ix + rng.randf_range(-r * 0.6, r * 0.6)
			for y in range(int(iy + r * 0.6), int(iy + r * 0.6) + rng.randi_range(6, 16)):
				if y < h:
					im.set_pixel(posmod(int(rx), w), y, col)
	return im


## Sagome di alberi-lanterna sulla linea dell'orizzonte, ripetibili; qualche baccello acceso.
static func lantern_forest(w: int, h: int, sd: int, col: Color, pods: Color) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var im := Px.img(w, h)
	var n := FastNoiseLite.new()
	n.seed = sd
	n.frequency = 0.02
	var R := w / TAU
	for x in w:
		var a := float(x) / w * TAU
		var gy := int(h * 0.62 + n.get_noise_2d(cos(a) * R, sin(a) * R) * 14.0)
		for y in range(gy, h):
			im.set_pixel(x, y, col)
	var x := 0.0
	while x < w:
		var ht := rng.randf_range(34.0, 70.0)
		var base := h * 0.66
		var cx := int(x)
		for y in range(int(base - ht), int(base)):
			im.set_pixel(posmod(cx, w), y, col)
			im.set_pixel(posmod(cx + 1, w), y, col)
		var rx := rng.randf_range(9.0, 16.0)
		var ry := rx * 0.55
		var cy := base - ht
		for y in range(int(cy - ry), int(cy + ry * 0.5)):
			for xx in range(int(cx - rx), int(cx + rx) + 1):
				var dx := (xx - cx) / rx
				var dy := (y - cy) / ry
				if dx * dx + dy * dy <= 1.0:
					im.set_pixel(posmod(xx, w), y, col)
		for s in 12:
			var sa := rng.randf_range(-1.0, 1.0)
			var sx := cx + sa * rx
			var ln := rng.randi_range(6, int(ht * 0.6))
			for i in ln:
				var y := int(cy + ry * 0.3) + i
				if y < h:
					im.set_pixel(posmod(int(sx + sa * i * 0.2), w), y, col)
			if s % 4 == 0:
				var py := int(cy + ry * 0.3) + ln / 2
				if py < h:
					im.set_pixel(posmod(int(sx + sa * ln * 0.1), w), py, pods)
		x += rng.randf_range(18.0, 34.0)
	return im


static func sun() -> Image:
	var im := Px.img(40, 40)
	Px.disc(im, 20, 20, 16, Color(1.0, 0.9, 0.75, 0.25))
	Px.disc(im, 20, 20, 13, Color("#ffe8cc"))
	Px.disc(im, 20, 20, 11, Color("#fffaf0"))
	return im


## La luna del Giardino: un disco pallido turchese con le ombre di radici lontane.
static func moon() -> Image:
	var im := Px.img(32, 32)
	Px.disc(im, 16, 16, 13, Color(0.7, 0.95, 1.0, 0.2))
	Px.disc(im, 16, 16, 10, Color("#cfeeee"))
	Px.disc(im, 13, 13, 3, Color("#a8d4d8"))
	Px.disc(im, 19, 18, 2, Color("#a8d4d8"))
	Px.line(im, Vector2(9, 20), Vector2(15, 24), 1, Color("#9ac4c8"))
	return im


## Stelle sparse per il cielo di notte (alcune turchesi, alcune ambra, come la Linfa e le braci).
static func stars(w: int, h: int, sd: int) -> Image:
	var im := Px.img(w, h)
	var rng := RandomNumberGenerator.new()
	rng.seed = sd + 7
	for k in 260:
		var x := rng.randi_range(0, w - 1)
		var y := rng.randi_range(0, int(h * 0.75))
		var r := rng.randf()
		var c := Color(0.85, 0.95, 1.0) if r < 0.7 else (Color("#8ef0d8") if r < 0.85 else Color("#ffd08a"))
		c.a = rng.randf_range(0.4, 1.0)
		im.set_pixel(x, y, c)
		if rng.randf() < 0.08 and x + 1 < w:
			im.set_pixel(x + 1, y, c)
	return im
