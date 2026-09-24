class_name Art
extends RefCounted
## Tutta la grafica che non è una tessera: personaggio (a pezzi, con le pose calcolate), icone degli oggetti,
## slime, alberi, torcia, montagne, nuvole e sole. Nessuna immagine esterna.

const OUTL := Color(0.1, 0.08, 0.13, 1.0)

const SKIN := Color("#f2c49b")
const SKIN_D := Color("#cf9670")
const HAIR := Color("#7a3f1c")
const HAIR_L := Color("#9a5528")
const SHIRT := Color("#3d78b8")
const SHIRT_L := Color("#5592d2")
const SHIRT_D := Color("#2b5a8c")
const PANTS := Color("#4b4a5e")
const PANTS_D := Color("#35344a")
const BOOT := Color("#6b4526")
const BOOT_D := Color("#4a2e18")
const BELT := Color("#3a2614")
const BUCKLE := Color("#e6bd34")

const M_COPPER := ["#6e3818", "#a0542a", "#cf7a3e", "#f0a868"]
const M_IRON := ["#4a4b55", "#7d7e8a", "#b0b1bc", "#e4e5ee"]
const M_GOLD := ["#7a5a0c", "#b68a18", "#e6bd34", "#fff08a"]
const M_CRYSTAL := ["#4a2a90", "#7a52e0", "#a888ff", "#e8dcff"]
const WOOD := ["#3e2614", "#5e3a1e", "#7e5230", "#a0703f"]


# ---------------------------------------------------------------- personaggio

static func pose_idle() -> Dictionary:
	return {"bob": 0, "fl_t": 0.06, "fl_s": 0.0, "bl_t": -0.08, "bl_s": -0.02,
		"fa_u": 0.12, "fa_l": 0.3, "ba_u": -0.12, "ba_l": 0.05}


static func pose_run(k: int) -> Dictionary:
	var p := k / 8.0 * TAU
	var q := p + PI
	var fl_t := 0.62 * sin(p)
	var bl_t := 0.62 * sin(q)
	return {"bob": 0 if absf(sin(p)) < 0.5 else 1,
		"fl_t": fl_t, "fl_s": fl_t - 1.0 * maxf(0.0, cos(p)) - 0.1,
		"bl_t": bl_t, "bl_s": bl_t - 1.0 * maxf(0.0, cos(q)) - 0.1,
		"fa_u": -0.6 * sin(p), "fa_l": -0.6 * sin(p) + 0.7,
		"ba_u": 0.6 * sin(p), "ba_l": 0.6 * sin(p) + 0.7}


static func pose_jump() -> Dictionary:
	return {"bob": 0, "fl_t": 0.75, "fl_s": -0.15, "bl_t": -0.35, "bl_s": -1.1,
		"fa_u": 2.5, "fa_l": 2.7, "ba_u": -0.9, "ba_l": -0.5}


static func pose_fall() -> Dictionary:
	return {"bob": 0, "fl_t": 0.35, "fl_s": 0.1, "bl_t": -0.25, "bl_s": -0.6,
		"fa_u": 2.0, "fa_l": 2.4, "ba_u": -1.5, "ba_l": -1.2}


static func _limb(im: Image, root: Vector2, a1: float, a2: float, l1: float, l2: float, w: int, c1: Color, c2: Color) -> Vector2:
	var mid := root + Vector2(sin(a1), cos(a1)) * l1
	var end := mid + Vector2(sin(a2), cos(a2)) * l2
	Px.line(im, root, mid, w, c1)
	Px.line(im, mid, end, w, c2)
	return end


static func _leg(im: Image, hip: Vector2, t: float, s: float, col: Color, boot: Color) -> void:
	var knee := hip + Vector2(sin(t), cos(t)) * 5.0
	var foot := knee + Vector2(sin(s), cos(s)) * 5.5
	Px.line(im, hip, knee, 3, col)
	Px.line(im, knee, knee.lerp(foot, 0.35), 3, col)
	Px.line(im, knee.lerp(foot, 0.45), foot, 3, boot)
	Px.stamp(im, foot.x + 1.5, foot.y + 0.5, 2, boot)


## Un fotogramma del personaggio (24×32, rivolto a destra) a partire da una posa. Restituisce l'immagine
## e la posizione della mano davanti, dove si aggancia l'attrezzo.
static func character(pose: Dictionary) -> Dictionary:
	var im := Px.img(24, 32)
	var bob: int = pose["bob"]
	var hip := Vector2(12.0, 19.5 + bob)
	var sh_f := Vector2(12.5, 12.5 + bob)
	var sh_b := Vector2(11.0, 12.5 + bob)
	_limb(im, sh_b, pose["ba_u"], pose["ba_l"], 4.0, 4.0, 2, SHIRT_D, SKIN_D)
	_leg(im, hip + Vector2(-1.0, 0.0), pose["bl_t"], pose["bl_s"], PANTS_D, BOOT_D)
	# busto
	for y in range(11 + bob, 20 + bob):
		for x in range(9, 15):
			var c := SHIRT
			if x == 14:
				c = SHIRT_D
			elif x == 9 and y > 11 + bob:
				c = SHIRT_L
			if y == 18 + bob:
				c = BUCKLE if x == 13 else BELT
			if y == 19 + bob:
				c = PANTS
			Px.put(im, x, y, c)
	_leg(im, hip + Vector2(1.0, 0.0), pose["fl_t"], pose["fl_s"], PANTS, BOOT)
	# testa
	for y in range(3 + bob, 11 + bob):
		for x in range(8, 16):
			Px.put(im, x, y, SKIN_D if x == 15 or y == 10 + bob else SKIN)
	for x in range(7, 16):
		Px.put(im, x, 2 + bob, HAIR)
		Px.put(im, x, 3 + bob, HAIR_L if x % 3 == 0 else HAIR)
	for x in range(7, 14):
		Px.put(im, x, 4 + bob, HAIR)
	for y in range(4 + bob, 10 + bob):
		Px.put(im, 7, y, HAIR)
		Px.put(im, 8, y, HAIR)
	Px.put(im, 9, 5 + bob, HAIR)
	Px.put(im, 15, 4 + bob, HAIR)
	Px.put(im, 10, 7 + bob, SKIN_D)
	Px.put(im, 13, 6 + bob, OUTL)
	Px.put(im, 13, 7 + bob, OUTL)
	Px.put(im, 14, 9 + bob, SKIN_D)
	var hand := _limb(im, sh_f, pose["fa_u"], pose["fa_l"], 4.0, 4.0, 2, SHIRT_L, SKIN)
	Px.outline(im, OUTL)
	return {"img": im, "hand": hand}


# ---------------------------------------------------------------- icone degli oggetti

static func icon_sword(metal: Array) -> Image:
	var p := Px.pal(metal)
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(5.0, 10.0), Vector2(13.0, 2.0), 2, p[1])
	Px.line(im, Vector2(5.0, 9.5), Vector2(12.5, 2.0), 1, p[3])
	Px.put(im, 14, 1, p[3])
	Px.line(im, Vector2(2.5, 8.5), Vector2(6.5, 12.5), 2, p[0])
	Px.put(im, 4, 10, p[2])
	Px.line(im, Vector2(4.0, 11.5), Vector2(2.0, 13.5), 2, w[1])
	Px.stamp(im, 1.5, 14.0, 2, p[2])
	Px.outline(im, OUTL)
	return im


static func icon_pickaxe(metal: Array) -> Image:
	var p := Px.pal(metal)
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(2.0, 14.0), Vector2(10.5, 5.5), 2, w[2])
	Px.line(im, Vector2(2.5, 14.5), Vector2(10.5, 6.5), 1, w[1])
	Px.curve(im, Vector2(5.0, 2.5), Vector2(13.0, 2.0), Vector2(13.5, 10.5), 2, p[1])
	Px.curve(im, Vector2(5.0, 2.0), Vector2(12.5, 1.5), Vector2(13.0, 10.0), 1, p[2])
	Px.put(im, 4, 2, p[3])
	Px.put(im, 13, 11, p[3])
	Px.outline(im, OUTL)
	return im


static func icon_bow() -> Image:
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(3.5, 2.5), Vector2(13.5, 12.5), 1, Color("#d8d0c0"))
	Px.curve(im, Vector2(3.0, 2.0), Vector2(15.0, 0.5), Vector2(14.0, 13.0), 2, w[2])
	Px.curve(im, Vector2(3.0, 1.5), Vector2(14.5, 0.0), Vector2(14.5, 12.5), 1, w[3])
	Px.stamp(im, 11.0, 5.0, 2, Color("#b83a2a"))
	Px.outline(im, OUTL)
	return im


static func icon_torch() -> Image:
	var w := Px.pal(WOOD)
	var im := Px.img(16, 16)
	Px.line(im, Vector2(7.0, 14.0), Vector2(8.0, 7.0), 2, w[2])
	Px.disc(im, 7.8, 5.2, 2.6, Color("#ff8a2a"))
	Px.disc(im, 7.8, 5.6, 1.5, Color("#ffd24a"))
	Px.put(im, 7, 2, Color("#ff8a2a"))
	Px.put(im, 8, 5, Color("#fff6d0"))
	Px.outline(im, OUTL)
	return im


static func icon_bar(metal: Array) -> Image:
	var p := Px.pal(metal)
	var im := Px.img(16, 16)
	for y in range(6, 12):
		for x in range(2, 14):
			var c := p[2]
			if y <= 7:
				if x < 4 + (7 - y) or x > 11 - (7 - y) + 1:
					continue
				c = p[3]
			elif y == 11:
				c = p[0]
			elif x == 2:
				c = p[1]
			Px.put(im, x, y, c)
	Px.put(im, 5, 9, p[3])
	Px.put(im, 6, 9, p[3])
	Px.outline(im, OUTL)
	return im


static func icon_potion() -> Image:
	var im := Px.img(16, 16)
	var glass := Color(0.8, 0.9, 0.95, 0.9)
	Px.disc(im, 8.0, 10.0, 4.6, glass)
	for y in range(9, 15):
		for x in 16:
			if Px.alpha(im, x, y) > 0.5:
				Px.put(im, x, y, Color("#d8304a") if x > 5 else Color("#ff5a6e"))
	Px.line(im, Vector2(7.5, 3.0), Vector2(7.5, 5.5), 2, glass)
	Px.stamp(im, 7.5, 2.0, 2, Color("#8a5a30"))
	Px.put(im, 6, 8, Color.WHITE)
	Px.put(im, 5, 9, Color.WHITE)
	Px.outline(im, OUTL)
	return im


# ---------------------------------------------------------------- creature e ambiente

static func slime(body: Color, light: Color, dark: Color) -> Image:
	var im := Px.img(16, 14)
	for y in 13:
		for x in 16:
			var dx := (x + 0.5 - 8.0) / 7.0
			var dy := (y + 0.5 - 12.5) / 9.0
			if y <= 12 and dx * dx + dy * dy <= 1.0:
				var t := 0.5 - dx * 0.3 - dy * 0.55
				var c := dark if t < 0.45 else (body if t < 0.8 else light)
				c.a = 0.88
				Px.put(im, x, y, c)
	Px.put(im, 5, 6, Color(1, 1, 1, 0.95))
	Px.put(im, 4, 7, Color(1, 1, 1, 0.8))
	Px.put(im, 9, 8, OUTL)
	Px.put(im, 9, 9, OUTL)
	Px.put(im, 12, 8, OUTL)
	Px.put(im, 12, 9, OUTL)
	Px.outline(im, Px.sh(dark, 0.45))
	return im


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
