class_name CreatureArt
extends RefCounted
## Le creature disegnate dal codice, nello stile «Radici e Linfa». `frames(forma, variante)` restituisce i fotogrammi
## dell'animazione (rivolti a destra) e, per ognuno, la parte luminosa da disegnare sopra il buio.

const OUT := Color("#050c10")
const GRUMI := [
	["#2fa89a", "#8ef0d8", "#145a54"],
	["#d88a30", "#ffd08a", "#7a4210"],
	["#9a4ad8", "#d8a0ff", "#4f1f86"],
]


static func frames(shape: String, variant: int) -> Dictionary:
	match shape:
		"grumo":
			var k: Array = GRUMI[variant % GRUMI.size()]
			return {"frames": [grumo(Color(k[0]), Color(k[1]), Color(k[2]))], "glow": [Px.img(16, 14)]}
		"falena":
			return _pair(func(f: int) -> Array: return _falena(f))
		"strisciaradice":
			return _pair(func(f: int) -> Array: return _strisciaradice(f))
		"scarabeo":
			return _pair(func(f: int) -> Array: return _scarabeo(f))
		"sputaspore":
			return _pair(func(f: int) -> Array: return _sputaspore(f))
		"vagavuoto":
			return _pair(func(f: int) -> Array: return _vagavuoto(f))
		"avvizzito":
			return _pair(func(f: int) -> Array: return _avvizzito(f))
		"guardiano":
			return _pair(func(f: int) -> Array: return _guardiano(f, variant == 1))
		"regina":
			return _pair(func(f: int) -> Array: return _regina(f, variant == 1))
		"colosso":
			return _pair(func(f: int) -> Array: return _colosso(f, variant == 1))
	return {"frames": [Px.img(8, 8)], "glow": [Px.img(8, 8)]}


static func _pair(draw: Callable) -> Dictionary:
	var fr := []
	var gl := []
	for f in 2:
		var r: Array = draw.call(f)
		fr.append(r[0])
		gl.append(r[1])
	return {"frames": fr, "glow": gl}


static func grumo(body: Color, light: Color, dark: Color) -> Image:
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
	Px.put(im, 9, 8, Px.OUTLINE)
	Px.put(im, 9, 9, Px.OUTLINE)
	Px.put(im, 12, 8, Px.OUTLINE)
	Px.put(im, 12, 9, Px.OUTLINE)
	Px.outline(im, Px.sh(dark, 0.45))
	return im


## Falena di brace: corpo acceso, ali che battono (fotogramma 0 su, 1 giù) con due occhi finti.
static func _falena(f: int) -> Array:
	var im := Px.img(20, 16)
	var gm := Px.img(20, 16)
	var wing := Px.pal(["#3a1a10", "#6a3218", "#a0552a", "#d88a4a"])
	var body := Px.pal(TileDefs.P_BRACE)
	var up := f == 0
	for side in [-1, 1]:
		for y in 16:
			for x in 20:
				var dx: float = (x + 0.5 - 10.0) * side
				if dx < 1.0:
					continue
				var cy := 5.0 if up else 10.0
				var d := Vector2((dx - 4.5) / 4.6, (y + 0.5 - cy) / (4.0 if up else 3.2))
				if d.length() <= 1.0:
					var c := wing[1] if d.length() > 0.7 else wing[2]
					if d.length() < 0.3:
						c = wing[3]
					Px.put(im, x, y, c)
		var spot := Vector2i(10 + side * 5, 5 if up else 10)
		Px.put(im, spot.x, spot.y, body[3])
		Px.put(gm, spot.x, spot.y, body[3])
	for y in range(5, 12):
		for x in range(9, 11):
			var c := body[3] if y < 8 else body[2]
			Px.put(im, x, y, c)
			Px.put(gm, x, y, c)
	Px.put(im, 8, 4, wing[0])
	Px.put(im, 11, 4, wing[0])
	Px.outline(im, OUT)
	return [im, gm]


## Strisciaradice: cinque segmenti di legno con foglie sul dorso e zampette-radice che si alternano, occhio d'ambra.
static func _strisciaradice(f: int) -> Array:
	var im := Px.img(24, 12)
	var gm := Px.img(24, 12)
	var bark := Px.pal(["#3a2430", "#5a3a48", "#7a5462", "#9a7080"])
	var leaf := Px.pal(TileDefs.P_GRASS)
	for s in 5:
		var cx := 4.0 + s * 4.0
		var cy := 7.0 + (0.6 if (s + f) % 2 == 0 else -0.3)
		var r := 3.2 if s < 4 else 3.8
		for y in 12:
			for x in 24:
				var d := Vector2(x + 0.5 - cx, y + 0.5 - cy)
				if d.length() <= r:
					Px.put(im, x, y, bark[3] if d.y < -1.0 else (bark[2] if d.x < 1.0 else bark[1]))
		var leg := 1 if (s + f) % 2 == 0 else -1
		Px.line(im, Vector2(cx, cy + 2.5), Vector2(cx + leg, 11.0), 1, bark[1])
		if s < 4 and s % 2 == 0:
			Px.put(im, int(cx), int(cy) - 4, leaf[3])
			Px.put(im, int(cx) + 1, int(cy) - 5, leaf[4])
		elif s < 4:
			# nodi di Linfa lungo il dorso: si vede anche al buio
			Px.put(im, int(cx), int(cy) - 2, Color("#6ff0d8"))
			Px.put(gm, int(cx), int(cy) - 2, Color("#6ff0d8"))
	Px.put(im, 21, 6, Color("#ffb040"))
	Px.put(gm, 21, 6, Color("#ffb040"))
	Px.outline(im, OUT)
	return [im, gm]


## Scarabeo d'ardesia: guscio di roccia a cupola con le giunture d'ambra che brillano, corno, zampe alternate.
static func _scarabeo(f: int) -> Array:
	var im := Px.img(24, 16)
	var gm := Px.img(24, 16)
	var st := Px.pal(TileDefs.P_STONE)
	var amber := Px.pal(TileDefs.P_BRACE)
	for k in 3:
		var lx := 6.0 + k * 5.0
		var dx := 1.5 if (k + f) % 2 == 0 else -1.5
		Px.line(im, Vector2(lx, 11.0), Vector2(lx + dx, 15.0), 1, st[0])
	for y in 16:
		for x in 24:
			var d := Vector2((x + 0.5 - 11.0) / 9.5, (y + 0.5 - 11.5) / 8.0)
			if d.length() <= 1.0 and y < 13:
				var c := st[clampi(int((0.65 - d.x * 0.3 - d.y * 0.5) * 5.0), 0, 4)]
				Px.put(im, x, y, c)
	for x in range(5, 18):
		Px.put(im, x, 8, amber[2])
		Px.put(gm, x, 8, amber[2])
	Px.line(im, Vector2(11.0, 4.0), Vector2(11.0, 12.0), 1, amber[1])
	Px.line(gm, Vector2(11.0, 4.0), Vector2(11.0, 12.0), 1, amber[1])
	# testa e corno
	for y in range(8, 13):
		for x in range(19, 23):
			Px.put(im, x, y, st[1])
	Px.line(im, Vector2(21.0, 8.0), Vector2(23.0, 4.0), 1, st[3])
	Px.put(im, 21, 10, amber[3])
	Px.put(gm, 21, 10, amber[3])
	Px.outline(im, OUT)
	return [im, gm]


## Sputaspore: un bulbo viola su un piede di radici, con la bocca chiusa (0) o aperta (1) e il cuore luminoso.
static func _sputaspore(f: int) -> Array:
	var im := Px.img(16, 18)
	var gm := Px.img(16, 18)
	var vi := Px.pal(["#2a1040", "#4f2280", "#7a44b8", "#b890ff", "#f0e0ff"])
	var root := Px.pal(TileDefs.P_ROOT)
	Px.line(im, Vector2(8.0, 17.0), Vector2(8.0, 12.0), 2, root[1])
	Px.line(im, Vector2(8.0, 17.0), Vector2(4.0, 17.0), 1, root[1])
	Px.line(im, Vector2(8.0, 17.0), Vector2(12.0, 17.0), 1, root[1])
	for y in 14:
		for x in 16:
			var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 7.5) / 6.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, vi[clampi(int((0.7 - d.x * 0.3 - d.y * 0.4) * 4.0), 0, 3)])
	# bocca in cima, aperta nel secondo fotogramma
	var open := 2 if f == 1 else 1
	for y in range(1, 1 + open + 1):
		for x in range(6, 10):
			Px.put(im, x, y, vi[0])
	for y in range(6, 10):
		for x in range(6, 10):
			var c := vi[4] if (x + y) % 3 != 0 else vi[3]
			Px.put(gm, x, y, c)
			Px.put(im, x, y, c)
	Px.outline(im, OUT)
	return [im, gm]


## Vagavuoto: un occhio di vuotite che fluttua, circondato da frange che ondeggiano (due fotogrammi), la pupilla viola
## accesa. Viene dal Fondo, dove il mondo confina con il Vuoto.
static func _vagavuoto(f: int) -> Array:
	var im := Px.img(20, 20)
	var gm := Px.img(20, 20)
	var vp := Px.pal(TileDefs.P_VUOTITE)
	# frange sotto il corpo
	for k in 5:
		var bx := 4.5 + k * 2.8
		var sway := (1.0 if (k + f) % 2 == 0 else -1.0)
		Px.curve(im, Vector2(bx, 12.0), Vector2(bx + sway * 1.5, 15.5), Vector2(bx - sway, 19.0), 1, vp[1 + k % 2])
	for y in 16:
		for x in 20:
			var d := Vector2((x + 0.5 - 10.0) / 7.0, (y + 0.5 - 8.5) / 6.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, vp[clampi(int((0.75 - d.x * 0.3 - d.y * 0.45) * 5.0), 0, 4)])
	# l'occhio: bianco violaceo, pupilla accesa che guarda avanti
	for y in range(6, 12):
		for x in range(9, 17):
			var e := Vector2((x + 0.5 - 13.0) / 3.6, (y + 0.5 - 9.0) / 2.6)
			if e.length() <= 1.0:
				var c := Color("#e8d8ff") if e.length() > 0.55 else Color("#c060ff")
				Px.put(im, x, y, c)
				if e.length() <= 0.55:
					Px.put(gm, x, y, c)
	Px.put(im, 14, 8, Color.WHITE)
	Px.put(gm, 14, 8, Color.WHITE)
	Px.outline(im, OUT)
	return [im, gm]


## Il Nodo Avvizzito, primo Guardiano: un gomitolo di radici grosse attorno a un occhio-cuore, con tentacoli di radice
## che ondeggiano sotto. Malato (0) è grigio-muffa con l'occhio d'ambra malata; guarito (1) torna radice viva con il
## cuore di Linfa turchese.
static func _guardiano(f: int, healed: bool) -> Array:
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


## Avvizzito errante: una figura curva fatta di radici grigie e secche, braccia lunghe che pendono, due occhi d'ambra
## malata che brillano nel buio. Due fotogrammi di passo.
static func _avvizzito(f: int) -> Array:
	var im := Px.img(14, 24)
	var gm := Px.img(14, 24)
	var bark := Px.pal(TileDefs.P_NODO)
	var rot := Color("#6a6a3a")
	# gambe che si alternano
	var st := 1.5 if f == 0 else -1.5
	Px.line(im, Vector2(6.0, 15.0), Vector2(5.0 - st, 23.0), 1, bark[1])
	Px.line(im, Vector2(8.0, 15.0), Vector2(9.0 + st, 23.0), 1, bark[2])
	# il corpo curvo, intrecciato
	for y in range(5, 17):
		var cx := 7.0 + (y - 11) * 0.12
		var hw := 2.6 if y > 8 else 2.0
		for x in 14:
			if absf(x + 0.5 - cx) <= hw:
				Px.put(im, x, y, bark[2] if (x + y) % 3 != 0 else bark[1])
	# la testa, un nodo
	Px.disc(im, 8.0, 4.0, 3.2, bark[3])
	Px.put(im, 6, 5, rot)
	Px.put(im, 10, 3, rot)
	# braccia lunghe che pendono
	var sw := 1.0 if f == 0 else -1.0
	Px.line(im, Vector2(5.0, 7.0), Vector2(3.0 + sw, 16.0), 1, bark[1])
	Px.line(im, Vector2(10.0, 7.0), Vector2(11.5 - sw, 16.0), 1, bark[1])
	# occhi d'ambra malata
	for q in [Vector2i(7, 4), Vector2i(10, 4)]:
		Px.put(im, q.x, q.y, Color("#f0b040"))
		Px.put(gm, q.x, q.y, Color("#f0b040"))
	Px.outline(im, OUT)
	return [im, gm]


## La Regina delle Spore: una grande cupola di fungo-medusa con la corona di spine, macchie di spore accese e lunghi
## filamenti che ondeggiano con le sacche in fondo. Malata viola scuro e grigio; guarita viola limpido e turchese.
static func _regina(f: int, healed: bool) -> Array:
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
static func _colosso(f: int, healed: bool) -> Array:
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
