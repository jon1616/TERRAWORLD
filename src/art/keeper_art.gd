class_name KeeperArt
extends RefCounted
## I Custodi degli strati (voce 27), disegnati dal codice: più grandi delle creature, con la loro parte luminosa.
## Ogni funzione restituisce [immagine, parte luminosa] per il fotogramma f; le chiama `CreatureArt.frames`.

const OUT := Color("#050c10")


## La Madre dei grumi: un grumo enorme di muschio con una corona di fronde, piccoli grumi che nuotano dentro di lei.
static func madre_grumi(f: int) -> Array:
	var im := Px.img(48, 40)
	var gm := Px.img(48, 40)
	var body := Px.pal(["#145a54", "#2fa89a", "#5cd0bc", "#8ef0d8"])
	var sq := 1.0 if f == 0 else 0.93
	for y in 40:
		for x in 48:
			var d := Vector2((x + 0.5 - 24.0) / (22.0 / sq), (y + 0.5 - 39.0) / (30.0 * sq))
			if d.length() <= 1.0 and y < 39:
				var t := 0.55 - d.x * 0.3 - d.y * 0.5
				var c := body[0] if t < 0.45 else (body[1] if t < 0.75 else (body[2] if t < 0.95 else body[3]))
				c.a = 0.9
				Px.put(im, x, y, c)
	# i piccoli dentro: tre grumi più scuri che si vedono in trasparenza
	for g in [[14.0, 28.0], [30.0, 31.0], [22.0, 20.0]]:
		Px.disc(im, g[0] + (1.0 if f == 1 else 0.0), g[1], 3.4, Color(0.08, 0.32, 0.3, 0.95))
		Px.put(im, int(g[0]) + 1, int(g[1]) - 1, Color("#8ef0d8"))
		Px.put(gm, int(g[0]) + 1, int(g[1]) - 1, Color("#8ef0d8"))
	# occhi e bocca
	for q in [Vector2i(18, 22), Vector2i(29, 22)]:
		Px.disc(im, q.x, q.y, 2.2, Color.WHITE)
		Px.disc(im, q.x + 1, q.y, 1.0, OUT)
	Px.line(im, Vector2(20.0, 29.0), Vector2(28.0, 29.0), 1, Color("#0a3a36"))
	# la corona di fronde
	var leaf := Px.pal(TileDefs.P_GRASS)
	for k in 7:
		var bx := 12.0 + k * 4.0
		var top := 1.0 + absf(k - 3.0) * 1.3
		Px.line(im, Vector2(bx, 10.0 + absf(k - 3.0)), Vector2(bx + (1.0 if k % 2 == 0 else -1.0), top), 1, leaf[3 + k % 2])
		Px.put(gm, int(bx), int(top), Color("#72d4b0"))
	Px.outline(im, OUT)
	return [im, gm]


## La Tessitrice delle radici: un ragno enorme di radice antica, con il dorso d'oro a righe e otto occhi accesi.
static func tessitrice(f: int) -> Array:
	var im := Px.img(56, 28)
	var gm := Px.img(56, 28)
	var bark := Px.pal(TileDefs.P_RADICE)
	var gold := Px.pal(TileDefs.P_AMBRA)
	var legs := [[Vector2(22, 14), Vector2(12, 2), Vector2(1, 27)], [Vector2(24, 14), Vector2(17, 1), Vector2(9, 27)],
		[Vector2(30, 14), Vector2(38, 1), Vector2(45, 27)], [Vector2(32, 14), Vector2(44, 2), Vector2(55, 27)]]
	for k in legs.size():
		var l: Array = legs[k]
		var step := Vector2(2.0 if (k + f) % 2 == 0 else -2.0, 0.0)
		Px.line(im, l[0], l[1], 2, bark[2])
		Px.line(im, l[1], (l[2] as Vector2) + step, 2, bark[1])
		Px.put(im, int(l[1].x), int(l[1].y), gold[2])
	for y in 28:
		for x in 56:
			var d := Vector2((x + 0.5 - 22.0) / 12.0, (y + 0.5 - 14.0) / 8.0)
			if d.length() <= 1.0:
				var c := bark[3] if d.y < -0.2 else bark[2]
				if int(x + d.y * 3.0) % 6 < 2 and d.y < 0.3:
					c = gold[2]
				Px.put(im, x, y, c)
			var h := Vector2((x + 0.5 - 37.0) / 5.5, (y + 0.5 - 16.0) / 5.0)
			if h.length() <= 1.0:
				Px.put(im, x, y, bark[2])
	for q in [Vector2i(38, 13), Vector2i(40, 14), Vector2i(38, 16), Vector2i(40, 17), Vector2i(36, 14), Vector2i(36, 17),
			Vector2i(41, 15), Vector2i(39, 15)]:
		Px.put(im, q.x, q.y, Color("#ffb040"))
		Px.put(gm, q.x, q.y, Color("#ffb040"))
	Px.outline(im, OUT)
	return [im, gm]


## La Serpe madre: un serpente di Linfa lungo e spesso, con la cresta di cristalli accesi.
static func serpe_madre(f: int) -> Array:
	var im := Px.img(64, 22)
	var gm := Px.img(64, 22)
	var sk := Px.pal(["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc"])
	var cr := Px.pal(TileDefs.P_CRYSTAL)
	var ph := 0.0 if f == 0 else PI
	for x in 58:
		var t := x / 57.0
		var cy := 12.0 + sin(t * 8.0 + ph) * 4.0 * (1.0 - t * 0.5)
		var r := 2.4 + t * 3.2
		for y in 22:
			var d := absf(y + 0.5 - cy)
			if d <= r:
				var c := sk[2] if y < cy else sk[1]
				if d < 0.8 and x % 5 == 0:
					c = sk[3]
					Px.put(gm, x, y, c)
				Px.put(im, x, y, c)
		if x % 6 == 3 and x > 10:
			var top := int(cy - r)
			Px.put(im, x, top - 1, cr[4])
			Px.put(im, x, top - 2, cr[3])
			Px.put(gm, x, top - 1, cr[4])
	var hy := 12.0 + sin(8.0 + ph) * 2.0
	Px.disc(im, 58.0, hy, 5.0, sk[2])
	Px.disc(im, 61.0, hy + 1.0, 2.5, sk[1])
	Px.put(im, 59, int(hy) - 2, Color("#fff2a8"))
	Px.put(gm, 59, int(hy) - 2, Color("#fff2a8"))
	Px.outline(im, OUT)
	return [im, gm]


## Il Mietitore cavo: una figura altissima e vuota, un mantello di Vuoto aperto sul niente e una falce enorme.
static func mietitore(f: int) -> Array:
	var im := Px.img(34, 46)
	var gm := Px.img(34, 46)
	var vp := Px.pal(TileDefs.P_VUOTITE)
	var blade := Color("#d8a0ff")
	for y in range(8, 45):
		var hw := 3.0 + (y - 8) * 0.28
		for x in 34:
			var dx := x + 0.5 - 15.0 + (1.5 if f == 1 and y > 38 else 0.0)
			if absf(dx) <= hw:
				var c := vp[2] if dx < 0.0 else vp[1]
				if absf(dx) < hw * 0.35 and y > 14:
					c = Color(0.02, 0.01, 0.04)   # il vuoto dentro il mantello
				Px.put(im, x, y, c)
	Px.disc(im, 15.0, 6.5, 4.5, vp[3])
	Px.disc(im, 15.0, 7.5, 2.6, Color(0.02, 0.01, 0.04))
	for q in [Vector2i(14, 7), Vector2i(17, 7)]:
		Px.put(im, q.x, q.y, blade)
		Px.put(gm, q.x, q.y, blade)
	# la falce: manico lungo e lama curva accesa
	var sw := 0.0 if f == 0 else 2.0
	Px.line(im, Vector2(24.0, 44.0 - sw), Vector2(27.0, 6.0 - sw), 1, vp[1])
	Px.curve(im, Vector2(27.0, 6.0 - sw), Vector2(33.0, 12.0 - sw), Vector2(22.0, 18.0 - sw), 2, blade)
	Px.curve(gm, Vector2(27.0, 6.0 - sw), Vector2(33.0, 12.0 - sw), Vector2(22.0, 18.0 - sw), 1, blade)
	Px.line(im, Vector2(18.0, 16.0), Vector2(25.0, 22.0), 1, vp[2])
	Px.outline(im, OUT)
	return [im, gm]


## Il bozzolo di un Custode (stazione 3×3): un groviglio di radici attorno a un cuore del colore del Custode. Rotto,
## le radici sono aperte e il cuore spento.
static func bozzolo(im: Image, gm: Image, w: int, h: int, glow: Color, broken: bool) -> void:
	var root := Px.pal(TileDefs.P_RADICE)
	var c := Vector2(w / 2.0, h / 2.0 + 3.0)
	for y in h:
		for x in w:
			var d := Vector2((x + 0.5 - c.x) / (w * 0.42), (y + 0.5 - c.y) / (h * 0.46))
			if d.length() > 1.0:
				continue
			if broken and d.y < -0.1 and absf(d.x) < 0.55:
				continue                           # squarciato in cima
			var a := atan2(d.y, d.x)
			var band := int((a * 3.0 + d.length() * 6.0) * 1.3) % 3
			Px.put(im, x, y, root[2 + band % 2] if band != 0 else root[1])
	if not broken:
		for y in h:
			for x in w:
				var e := Vector2(x + 0.5, y + 0.5) - c
				if e.length() < 7.0 and (x + y) % 3 != 0:
					var col := glow.lerp(Color.WHITE, 0.3 if e.length() < 3.0 else 0.0)
					Px.put(im, x, y, col)
					Px.put(gm, x, y, col)
	for side in [-1.0, 1.0]:
		Px.line(im, Vector2(c.x + side * 12.0, h - 6.0), Vector2(c.x + side * 22.0, h - 1.0), 2, root[1])
