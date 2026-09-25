class_name BossArt
extends RefCounted
## I Guardiani disegnati dal codice (tolti da `CreatureArt` per tenere i file piccoli): il Nodo Avvizzito, la Regina
## delle Spore, il Colosso d'Ardesia. Ognuno malato (variante 0) o guarito (1), in due fotogrammi, con la parte
## luminosa. `CreatureArt.frames` li chiama per le forme "guardiano", "regina", "colosso".

const OUT := CreatureArt.OUT


## Il Nodo Avvizzito, primo Guardiano: un gomitolo di radici grosse attorno a un occhio-cuore, con tentacoli di radice
## che ondeggiano sotto. Malato (0) è grigio-muffa con l'occhio d'ambra malata; guarito (1) torna radice viva con il
## cuore di Linfa turchese.
static func guardiano(f: int, healed: bool) -> Array:
	var sz := 48
	var im := Px.img(sz, sz)
	var gm := Px.img(sz, sz)
	var bark := Px.pal(TileDefs.P_RADICE if healed else TileDefs.P_NODO)
	var rot := Color("#6a6a3a") if not healed else Color("#3aa08a")
	var eye := Px.pal(TileDefs.P_CRYSTAL) if healed else Px.pal(["#3a1a08", "#7a3a10", "#c07020", "#f0b040", "#fff0b0"])
	var rng := RandomNumberGenerator.new()
	rng.seed = 404
	var c := Vector2(24.0, 21.0)
	# tentacoli sotto, che ondeggiano (due fotogrammi)
	for k in 6:
		var bx := 9.0 + k * 6.0
		var sway := 3.0 if (k + f) % 2 == 0 else -3.0
		Px.curve(im, Vector2(bx, 30.0), Vector2(bx + sway, 38.0), Vector2(bx - sway * 0.6, 47.0), 2, bark[1])
		Px.curve(im, Vector2(bx, 30.0), Vector2(bx + sway, 38.0), Vector2(bx - sway * 0.6, 47.0), 1, bark[2])
	# il gomitolo: tante radici curve attorno al centro
	for y in sz:
		for x in sz:
			var d := Vector2((x + 0.5 - c.x) / 19.0, (y + 0.5 - c.y) / 16.0)
			if d.length() <= 1.0:
				Px.put(im, x, y, bark[clampi(int((0.75 - d.x * 0.3 - d.y * 0.4) * 5.0), 0, 4)])
	for k in 14:
		var a0 := rng.randf_range(0.0, TAU)
		var r0 := rng.randf_range(8.0, 17.0)
		var from := c + Vector2(cos(a0) * r0, sin(a0) * r0 * 0.8)
		var a1 := a0 + rng.randf_range(0.8, 1.6)
		var to := c + Vector2(cos(a1) * r0, sin(a1) * r0 * 0.8)
		var mid := c + (from + to - c * 2.0) * 0.75
		Px.curve(im, from, mid, to, 1, bark[0] if k % 2 == 0 else bark[3])
	# muffa dell'Avvizzimento (o foglie, se guarito)
	for k in 22:
		var q := c + Vector2(rng.randf_range(-17, 17), rng.randf_range(-13, 13))
		if Vector2((q.x - c.x) / 19.0, (q.y - c.y) / 16.0).length() < 0.95:
			Px.put(im, int(q.x), int(q.y), rot)
	# l'occhio-cuore al centro
	for y in range(int(c.y) - 7, int(c.y) + 8):
		for x in range(int(c.x) - 9, int(c.x) + 10):
			var e := Vector2((x + 0.5 - c.x) / 8.5, (y + 0.5 - c.y) / 6.5)
			if e.length() <= 1.0:
				var col := eye[clampi(int((1.0 - e.length()) * 4.5), 0, 4)]
				Px.put(im, x, y, col)
				Px.put(gm, x, y, col)
	var pupil := Color("#1a0a04") if not healed else Color("#e8ffff")
	for y in range(int(c.y) - 3, int(c.y) + 4):
		Px.put(im, int(c.x) + 2, y, pupil)
		if healed:
			Px.put(gm, int(c.x) + 2, y, pupil)
	Px.outline(im, OUT)
	return [im, gm]


## La Regina delle Spore: una grande cupola di fungo-medusa con la corona di spine, macchie di spore accese e lunghi
## filamenti che ondeggiano con le sacche in fondo. Malata viola scuro e grigio; guarita viola limpido e turchese.
static func regina(f: int, healed: bool) -> Array:
	var W := 52
	var H := 50
	var im := Px.img(W, H)
	var gm := Px.img(W, H)
	var cap := Px.pal(["#2a1440", "#4a2470", "#6e3aa0", "#9a64d0", "#c8a0f0"]) if healed else 			Px.pal(["#231a2c", "#3a2c46", "#554262", "#6e5a7a", "#8a7892"])
	var glow := Color("#8ef0d8") if healed else Color("#d8a0ff")
	var rng := RandomNumberGenerator.new()
	rng.seed = 505
	# filamenti che ondeggiano, con le sacche di spore in fondo
	for k in 7:
		var bx := 8.0 + k * 6.0
		var sway := 3.5 if (k + f) % 2 == 0 else -3.5
		var tip := Vector2(bx - sway * 0.7, 44.0 + (k % 3) * 2.0)
		Px.curve(im, Vector2(bx, 24.0), Vector2(bx + sway, 34.0), tip, 1, cap[2])
		Px.disc(im, tip.x, tip.y, 1.8, cap[3])
		Px.put(gm, int(tip.x), int(tip.y), glow)
		Px.put(im, int(tip.x), int(tip.y), glow)
	# la cupola
	for y in 28:
		for x in W:
			var d := Vector2((x + 0.5 - W / 2.0) / 24.0, (y + 0.5 - 24.0) / 20.0)
			if d.length() <= 1.0 and y < 26:
				Px.put(im, x, y, cap[clampi(int((0.85 - d.y * 0.5 - d.x * 0.2) * 4.0), 0, 4)])
	# orlo ondulato sotto la cupola
	for x in range(3, W - 3):
		Px.put(im, x, 25 + int(sin(x * 0.8 + f) * 1.2), cap[1])
	# macchie di spore accese
	for k in 9:
		var q := Vector2(rng.randf_range(10, W - 10), rng.randf_range(8, 21))
		Px.disc(im, q.x, q.y, 1.6, glow)
		Px.disc(gm, q.x, q.y, 1.6, glow)
	# la corona di spine
	for k in 5:
		var cx := 14.0 + k * 6.0
		Px.line(im, Vector2(cx, 7.0), Vector2(cx + (k - 2) * 0.8, 0.0), 1, cap[4])
		Px.put(gm, int(cx + (k - 2) * 0.8), 0, glow)
	Px.outline(im, OUT)
	return [im, gm]


## Il Colosso d'Ardesia: una montagna di scaglie a cupola su zampe massicce, le giunture d'ambra accese, il corno e gli
## occhi. Malato con la muffa grigia sulle scaglie; guarito le giunture diventano Linfa turchese.
static func colosso(f: int, healed: bool) -> Array:
	var W := 56
	var H := 48
	var im := Px.img(W, H)
	var gm := Px.img(W, H)
	var st := Px.pal(TileDefs.P_STONE)
	var joint := Color("#6ff0d8") if healed else Color("#f0b040")
	var rot := Color("#6a6a3a")
	# zampe massicce, alternate nel passo
	for k in 3:
		var lx := 12.0 + k * 14.0
		var step := 2.5 if (k + f) % 2 == 0 else -2.5
		for y in range(32, 48):
			for x in range(int(lx - 4 + step * (y - 32) / 16.0), int(lx + 4 + step * (y - 32) / 16.0)):
				Px.put(im, x, y, st[1] if x % 3 != 0 else st[0])
		Px.put(im, int(lx + step), 38, joint)
		Px.put(gm, int(lx + step), 38, joint)
	# la cupola di scaglie
	for y in 36:
		for x in W:
			var d := Vector2((x + 0.5 - 26.0) / 25.0, (y + 0.5 - 34.0) / 26.0)
			if d.length() <= 1.0:
				var c := st[clampi(int((0.8 - d.y * 0.45 - d.x * 0.25) * 5.0), 0, 4)]
				# file di scaglie
				if (x + (y / 6) * 3) % 9 == 0 or y % 6 == 0:
					c = st[0]
				Px.put(im, x, y, c)
	# giunture d'ambra (o di Linfa) tra le scaglie
	for k in 6:
		var y := 12 + k * 4
		for x in range(8 + k, 44 - k, 7):
			Px.put(im, x, y, joint)
			Px.put(gm, x, y, joint)
	if not healed:
		var rng := RandomNumberGenerator.new()
		rng.seed = 606
		for k in 26:
			Px.put(im, rng.randi_range(6, 46), rng.randi_range(10, 32), rot)
	# la testa con il corno e gli occhi, davanti (a destra)
	for y in range(20, 34):
		for x in range(44, 56):
			var d := Vector2((x + 0.5 - 49.0) / 6.5, (y + 0.5 - 27.0) / 7.0)
			if d.length() <= 1.0:
				Px.put(im, x, y, st[3] if d.y < 0.0 else st[2])
	Px.line(im, Vector2(52.0, 21.0), Vector2(55.0, 12.0), 2, st[4])
	for q in [Vector2i(50, 25), Vector2i(53, 26)]:
		Px.put(im, q.x, q.y, joint)
		Px.put(gm, q.x, q.y, joint)
	Px.outline(im, OUT)
	return [im, gm]
