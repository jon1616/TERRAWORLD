class_name NatureArt
extends RefCounted
## Ambiente disegnato dal codice: alberi, torcia, montagne ripetibili, nuvole, sole.

const WOOD := ItemIcons.WOOD

static func tree(sd: int) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var W := 56
	var H := 110
	var im := Px.img(W, H)
	var bark := Px.pal(["#3e2818", "#553622", "#6e4a2e", "#86603c"])
	var leaf := Px.pal(["#1c4020", "#2a5e2a", "#3a7e34", "#52a040", "#74c050"])
	var top := rng.randi_range(34, 50)
	var cx := W / 2
	for y in range(top, H):
		var hw := 3
		if y >= H - 3:
			hw = 3 + (y - (H - 4))
		for x in range(cx - hw, cx + hw):
			var k := x - (cx - hw)
			var c := bark[2]
			if k == 0:
				c = bark[3]
			elif k >= 2 * hw - 2:
				c = bark[1]
			if (y * 7 + x * 3) % 11 == 0:
				c = bark[0]
			Px.put(im, x, y, c)
	# un ramo corto con un ciuffo
	var by := rng.randi_range(top + 20, H - 25)
	var dir := 1 if rng.randf() < 0.5 else -1
	Px.line(im, Vector2(cx, by), Vector2(cx + dir * 8, by - 5), 2, bark[1])
	var blobs: Array[Vector3] = [Vector3(cx + dir * 9, by - 7, 4.5)]
	blobs.append(Vector3(cx, top - 4, 15))
	blobs.append(Vector3(cx - 11, top + 2, 10))
	blobs.append(Vector3(cx + 11, top + 1, 10))
	blobs.append(Vector3(cx - 5, top - 15, 10))
	blobs.append(Vector3(cx + 6, top - 14, 10))
	for k in blobs.size():
		blobs[k] += Vector3(rng.randf_range(-2, 2), rng.randf_range(-2, 2), 0.0)
	for y in H:
		for x in W:
			var best := -1.0
			var shade := 0.0
			for b in blobs:
				var dx := (x + 0.5 - b.x) / b.z
				var dy := (y + 0.5 - b.y) / b.z
				var d := dx * dx + dy * dy
				if d <= 1.0:
					var t := 0.55 - dx * 0.35 - dy * 0.45 + rng.randf_range(-0.12, 0.12)
					if best < 0.0 or t > shade:
						shade = t
					best = 1.0
			if best > 0.0:
				var c := leaf[clampi(int(shade * 5.0), 0, 4)]
				if rng.randf() < 0.06:
					c = leaf[0]
				Px.put(im, x, y, c)
	Px.outline(im, Color("#10220f"))
	return im


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


static func cloud(sd: int) -> Image:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var im := Px.img(96, 34)
	var cols := Px.pal(["#d8a4b4", "#f0c4c0", "#ffe6da", "#fff6ee"])
	var blobs: Array[Vector3] = []
	for k in rng.randi_range(5, 7):
		blobs.append(Vector3(rng.randf_range(16, 80), rng.randf_range(14, 22), rng.randf_range(7, 13)))
	for y in 28:
		for x in 96:
			for b in blobs:
				var dx := x + 0.5 - b.x
				var dy := y + 0.5 - b.y
				if dx * dx + dy * dy <= b.z * b.z:
					var t := 1.0 - float(y) / 28.0 + rng.randf_range(-0.06, 0.06)
					im.set_pixel(x, y, cols[clampi(int(t * 4.0), 0, 3)])
					break
	return im


static func sun() -> Image:
	var im := Px.img(40, 40)
	Px.disc(im, 20, 20, 15, Color(1.0, 0.85, 0.6, 0.35))
	Px.disc(im, 20, 20, 12, Color("#ffe6b0"))
	Px.disc(im, 20, 20, 10, Color("#fff8e6"))
	return im
