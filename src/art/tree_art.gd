class_name TreeArt
extends RefCounted
## Gli alberi dei biomi (dati in `TreesData`), disegnati dal codice nello stile «Radici e Linfa», in ogni grandezza:
##   lanterna  Foresta-lanterna: tronco contorto, chioma a salice di fronde turchesi che pendono, baccelli d'ambra
##   fungo     Paludi di spore: gambo pallido e ricurvo, cappello viola a cupola con le lamelle e macchie che brillano
##   acacia    Distese d'ambra: tronco che si biforca, chioma piatta e larga di foglie dorate, gocce di resina accese
##   abete     Boschi di brina: palchi a punta di aghi blu-verdi con la neve sul bordo, scintille di ghiaccio
##   tizzone   Cenerarie: albero morto dai rami contorti, crepe di brace accese nel legno, ciuffi di cenere
## `make(specie, altezza, seme)` → {img, glow}: la base del tronco è in basso al centro dell'immagine.

const OUT := Color("#05090c")


static func make(species: String, h: int, sd: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var w := maxi(44, int(h * 0.62)) / 2 * 2
	if species in ["acacia", "ombrello", "cappellone"]:
		w = maxi(56, int(h * 0.9)) / 2 * 2
	var im := Px.img(w, h)
	var gm := Px.img(w, h)
	match species:
		"fungo":
			_fungo(im, gm, w, h, rng)
		"acacia":
			_acacia(im, gm, w, h, rng)
		"abete":
			_abete(im, gm, w, h, rng)
		"tizzone":
			_tizzone(im, gm, w, h, rng)
		_:
			if not TreeArtTemperate.draw(species, im, gm, w, h, rng):   # voce 92
				_lanterna(im, gm, w, h, rng)
	return {"img": im, "glow": gm}


## Un tronco dal basso fino a `top`, che ondeggia; restituisce la x del tronco a ogni riga.
static func _trunk(im: Image, w: int, h: int, top: int, bark: Array[Color], rng: RandomNumberGenerator, wide: float) -> PackedFloat32Array:
	var cx := w / 2.0
	var phase := rng.randf() * TAU
	var amp := rng.randf_range(1.5, 4.5) * h / 124.0
	var xs := PackedFloat32Array()
	xs.resize(h)
	for y in range(top, h):
		var t := float(h - 1 - y) / float(maxi(h - 1 - top, 1))
		var x := cx + sin(t * 3.2 + phase) * amp * t
		xs[y] = x
		var hw := lerpf(wide, wide * 0.4, t)
		for xx in range(int(x - hw), int(x + hw) + 1):
			var k := (xx - (x - hw)) / (2.0 * hw)
			var c := bark[2] if k < 0.35 else (bark[1] if k < 0.8 else bark[0])
			if (y * 5 + xx * 3) % 9 == 0:
				c = bark[3]
			Px.put(im, xx, y, c)
	for r in 4:
		var dir := -1.0 if r % 2 == 0 else 1.0
		Px.line(im, Vector2(cx, h - 4), Vector2(cx + dir * rng.randf_range(3.0, 8.0) * h / 124.0 + dir * 2.0, h - 1), 2, bark[1])
	return xs


static func _lanterna(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#140c14", "#241624", "#362234", "#4c3246"])
	var frond := Px.pal(["#0b2e30", "#134a48", "#1f6a60", "#339280", "#62c4a4"])
	var pod := Px.pal(TileDefs.P_BRACE)
	var sc := h / 124.0
	var cx := w / 2.0
	var top := int(h * rng.randf_range(0.32, 0.45))
	_trunk(im, w, h, top, bark, rng, 1.6 + 2.2 * sc)
	var cy := float(top)
	var rx := rng.randf_range(15.0, 20.0) * sc + 3.0
	var ry := rng.randf_range(9.0, 12.0) * sc + 2.0
	for y in range(int(cy - ry) - 1, int(cy + ry * 0.6)):
		for x in w:
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cy) / ry
			if dx * dx + dy * dy <= 1.0:
				var t := 0.62 - dx * 0.25 - dy * 0.45 + rng.randf_range(-0.1, 0.1)
				Px.put(im, x, y, frond[clampi(int(t * 5.0), 0, 4)])
	var strands: Array[Vector2] = []
	for s in int(18 + 14 * sc):
		var a := rng.randf_range(-1.0, 1.0)
		var sx := cx + a * rx * 0.95
		var sy := cy + sqrt(maxf(1.0 - a * a, 0.0)) * ry * 0.45
		var length := int(rng.randf_range(10.0, 32.0) * sc * (1.0 - absf(a) * 0.35)) + 4
		for i in length:
			var x := sx + a * i * 0.22 + sin(i * 0.3 + s) * 0.8
			var y := sy + i
			var c := frond[3] if i < length * 0.4 else (frond[2] if i < length * 0.8 else frond[1])
			Px.put(im, int(x), int(y), c)
			if i % 3 == 1:
				Px.put(im, int(x) + (1 if s % 2 == 0 else -1), int(y), frond[4] if i < length * 0.3 else frond[2])
			if i == length / 2:
				strands.append(Vector2(x, y))
	Px.outline(im, OUT)
	for k in mini(int(3 + 5 * sc), strands.size()):
		var q: Vector2 = strands[rng.randi_range(0, strands.size() - 1)]
		for dy in 3:
			for dx in 2:
				var c := pod[3] if dy == 0 else pod[2]
				Px.put(im, int(q.x) + dx, int(q.y) + dy, c)
				Px.put(gm, int(q.x) + dx, int(q.y) + dy, c)


static func _fungo(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var stem := Px.pal(["#4a3e58", "#7a6a8e", "#a898b8", "#cabcd8"])
	var cap := Px.pal(["#2a0e36", "#4a1a60", "#6a2c88", "#8e48b0", "#b876d8"])
	var spot := Color("#f0b8ff")
	var sc := h / 124.0
	var cx := w / 2.0
	var cap_y := int(h * rng.randf_range(0.28, 0.4))
	var lean := rng.randf_range(-6.0, 6.0) * sc
	var sw := 2.0 + 2.8 * sc
	# il gambo: ricurvo, più largo alla base, con gli anelli
	for y in range(cap_y, h):
		var t := float(h - 1 - y) / float(h - 1 - cap_y)
		var x := cx + lean * t * t
		var hw := sw * (1.25 - 0.35 * t) + (1.5 * sc if y > h - 6 else 0.0)
		for xx in range(int(x - hw), int(x + hw) + 1):
			var k := (xx - (x - hw)) / (2.0 * hw)
			var c := stem[3] if k < 0.3 else (stem[2] if k < 0.7 else stem[1])
			if (y * 3 + xx * 7) % 23 == 0:
				c = stem[0]                           # le venature del gambo, sparse
			Px.put(im, xx, y, c)
	# un anello (la «gonna» dei funghi) poco sotto il cappello
	var ring_y := cap_y + int((h - cap_y) * 0.18)
	var rxr := cx + lean * pow(float(h - 1 - ring_y) / float(h - 1 - cap_y), 2.0)
	Px.line(im, Vector2(rxr - sw * 1.6, ring_y), Vector2(rxr + sw * 1.6, ring_y), 1, stem[3])
	Px.line(im, Vector2(rxr - sw * 1.3, ring_y + 1), Vector2(rxr + sw * 1.3, ring_y + 1), 1, stem[1])

	var top_x := cx + lean
	# il cappello: una cupola, con le lamelle sotto
	var rx := rng.randf_range(0.36, 0.46) * w
	var ry := rng.randf_range(0.14, 0.2) * h * 0.9 + 3.0
	for y in range(int(cap_y - ry), cap_y + 3):
		for x in w:
			var dx := (x + 0.5 - top_x) / rx
			var dy := (y + 0.5 - cap_y) / ry
			if dx * dx + dy * dy <= 1.0 and dy <= 0.0:
				var t := 0.75 - dx * 0.2 + dy * 0.5
				Px.put(im, x, y, cap[clampi(int(t * 5.0), 0, 4)])
			elif dy > 0.0 and dy < 0.35 and absf(dx) <= 0.95:
				Px.put(im, x, y, cap[0] if x % 2 == 0 else cap[1])       # le lamelle
	Px.outline(im, OUT)
	# le macchie luminose e qualche filo di spore che pende
	for k in int(4 + 6 * sc):
		var a := rng.randf_range(-0.8, 0.8)
		var q := Vector2(top_x + a * rx, cap_y - sqrt(maxf(1.0 - a * a, 0.0)) * ry * rng.randf_range(0.3, 0.85))
		var r := rng.randf_range(0.8, 1.8) * maxf(sc, 0.7)
		Px.disc(im, q.x, q.y, r, spot)
		Px.disc(gm, q.x, q.y, r, spot)
	for k in int(2 + 3 * sc):
		var sx := top_x + rng.randf_range(-0.85, 0.85) * rx
		var n := int(rng.randf_range(4.0, 14.0) * sc) + 2
		for i in n:
			Px.put(im, int(sx), cap_y + 3 + i, cap[3] if i < n - 1 else spot)
		Px.put(gm, int(sx), cap_y + 3 + n - 1, spot)


static func _acacia(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#1a0e08", "#3a2412", "#5a3a1e", "#7a5230"])
	var leaf := Px.pal(["#4a2e0a", "#7a4e12", "#b07a1e", "#e0a830", "#ffd068"])
	var resin := Color("#ffb040")
	var sc := h / 124.0
	var cx := w / 2.0
	var fork := int(h * rng.randf_range(0.5, 0.62))
	var crown_y := int(h * rng.randf_range(0.14, 0.22)) + 4
	_trunk(im, w, h, fork, bark, rng, 1.4 + 2.2 * sc)
	# i rami: due o tre che salgono aperti fino alla chioma
	var ends: Array[Vector2] = []
	for b in rng.randi_range(2, 3):
		var ex := cx + (b - 1 if rng.randf() < 0.5 else 1 - b) * w * rng.randf_range(0.18, 0.34) + rng.randf_range(-4, 4)
		var end := Vector2(ex, crown_y + rng.randf_range(0.0, 6.0) * sc)
		Px.curve(im, Vector2(cx, fork), Vector2((cx + ex) * 0.5, fork - (fork - crown_y) * 0.2), end, int(1 + sc * 1.4), bark[2])
		ends.append(end)
	# la chioma piatta: ellissi schiacciate che si toccano
	var rx := w * 0.46
	for k in 5:
		var q := Vector2(cx + rng.randf_range(-0.35, 0.35) * rx, crown_y + rng.randf_range(-3.0, 2.0) * sc)
		var erx := rng.randf_range(0.45, 0.7) * rx
		var ery := rng.randf_range(4.0, 7.0) * sc + 2.0
		for y in range(int(q.y - ery), int(q.y + ery) + 1):
			for x in w:
				var dx := (x + 0.5 - q.x) / erx
				var dy := (y + 0.5 - q.y) / ery
				if dx * dx + dy * dy <= 1.0:
					var t := 0.6 - dy * 0.45 + rng.randf_range(-0.12, 0.12)
					Px.put(im, x, y, leaf[clampi(int(t * 5.0), 0, 4)])
	Px.outline(im, OUT)
	# gocce di resina che brillano sul tronco e sotto la chioma
	for k in int(2 + 3 * sc):
		var y := rng.randi_range(fork, h - 6)
		var q := Vector2(cx + rng.randf_range(-1.5, 1.5), y)
		Px.put(im, int(q.x), int(q.y), resin)
		Px.put(gm, int(q.x), int(q.y), resin)
	for e in ends:
		Px.put(gm, int(e.x), int(e.y) + 2, leaf[4])


static func _abete(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#140c14", "#241a22", "#362a30", "#4c3a40"])
	var needle := Px.pal(["#081c26", "#0e2e3c", "#1c4a5e", "#2e6e84", "#5aa0b8"])
	var snow := Color("#e8f4ff")
	var ice := Color("#a8ecff")
	var sc := h / 124.0
	var cx := w / 2.0
	var base := int(h * 0.86)
	_trunk(im, w, h, base - 6, bark, rng, 1.2 + 1.2 * sc)
	# i palchi: triangoli che si allargano dall'alto verso il basso, con la neve sul bordo di sopra
	var tiers := clampi(int(2 + 3 * sc), 2, 6)
	var top := 2
	var tier_h := float(base - top) / tiers
	for i in tiers:
		var y0 := top + int(i * tier_h * 0.82)
		var y1 := int(y0 + tier_h * 1.25)
		var half := (w * 0.2 + w * 0.3 * float(i + 1) / tiers) * rng.randf_range(0.9, 1.05)
		for y in range(y0, mini(y1, base)):
			var t := float(y - y0) / float(maxi(y1 - y0, 1))
			var hw := half * t + 1.0 + (1.0 if (y * 7 + i) % 3 == 0 else 0.0) - (1.0 if (y * 5 + i) % 4 == 0 else 0.0)
			for x in range(int(cx - hw), int(cx + hw) + 1):
				var k := (x - (cx - hw)) / (2.0 * hw)
				var c := needle[3] if k < 0.3 else (needle[2] if k < 0.75 else needle[1])
				if y == y1 - 1:
					c = needle[0]
				elif (x * 3 + y * 2) % 7 == 0:
					c = needle[4] if k < 0.4 else needle[1]
				Px.put(im, x, y, c)
			if t < 0.5 and (y + i) % 2 == 0:
				Px.put(im, int(cx - hw), y, snow)
				Px.put(im, int(cx + hw), y, snow)
		# la neve che pende dalle punte del palco
		for side in [-1.0, 1.0]:
			var tip := Vector2(cx + side * half, mini(y1, base) - 1)
			Px.put(im, int(tip.x), int(tip.y), snow)
			Px.put(im, int(tip.x - side), int(tip.y), snow)
	Px.put(im, int(cx), 1, snow)
	Px.outline(im, OUT)
	for k in int(3 + 5 * sc):
		var q := Vector2(cx + rng.randf_range(-0.4, 0.4) * w, rng.randf_range(4.0, base - 4.0))
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.put(im, int(q.x), int(q.y), ice)
			Px.put(gm, int(q.x), int(q.y), ice)


static func _tizzone(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#0e080a", "#1c1214", "#2c1e20", "#40302e"])
	var ember := Px.pal(TileDefs.P_BRACE)
	var ash := Px.pal(["#3a3438", "#5a5258", "#7e7478"])
	var sc := h / 124.0
	var cx := w / 2.0
	var top := int(h * rng.randf_range(0.4, 0.55))
	var xs := _trunk(im, w, h, top, bark, rng, 1.8 + 2.0 * sc)
	# i rami morti: si dividono due o tre volte, contorti
	var tips: Array[Vector2] = []
	_branch(im, Vector2(xs[top], top), -PI / 2.0 + rng.randf_range(-0.2, 0.2), h * 0.26, 1.5 + sc, 3, bark, rng, tips)
	for k in 2:
		var y := rng.randi_range(top + 4, int(top + (h - top) * 0.4))
		var side := -1.0 if k == 0 else 1.0
		_branch(im, Vector2(xs[y], y), -PI / 2.0 + side * rng.randf_range(0.6, 1.0), h * 0.16, 1.0 + sc * 0.6, 2, bark, rng, tips)
	# qualche ciuffo di cenere in cima ai rami
	for t in tips:
		if rng.randf() < 0.45:
			Px.disc(im, t.x, t.y, rng.randf_range(1.2, 2.6) * maxf(sc, 0.7), ash[rng.randi_range(0, 2)])
	Px.outline(im, OUT)
	# le crepe di brace nel legno
	for k in int(3 + 4 * sc):
		var y := rng.randi_range(top + 2, h - 4)
		var x := xs[y] + rng.randf_range(-1.0, 1.0)
		var n := rng.randi_range(2, 4)
		for i in n:
			var c := ember[3] if i == n / 2 else ember[2]
			Px.put(im, int(x), y + i, c)
			Px.put(gm, int(x), y + i, c)


static func _branch(im: Image, from: Vector2, ang: float, length: float, width: float, depth: int, bark: Array[Color],
		rng: RandomNumberGenerator, tips: Array[Vector2]) -> void:
	var to := from + Vector2(cos(ang), sin(ang)) * length
	var mid := (from + to) * 0.5 + Vector2(rng.randf_range(-3, 3), rng.randf_range(-3, 3))
	Px.curve(im, from, mid, to, maxi(1, int(width)), bark[2])
	if depth <= 0 or length < 6.0:
		tips.append(to)
		return
	for s in [-1.0, 1.0]:
		_branch(im, to, ang + s * rng.randf_range(0.3, 0.7), length * rng.randf_range(0.55, 0.75), width * 0.7, depth - 1,
			bark, rng, tips)
