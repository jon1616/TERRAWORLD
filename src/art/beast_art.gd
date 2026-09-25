class_name BeastArt
extends RefCounted
## Le creature della voce 22 che vivono in alto (superficie e Sottobosco), disegnate dal codice nello stile «Radici e
## Linfa». Ogni funzione riceve il fotogramma e restituisce [immagine, parte luminosa]. Le chiama `CreatureArt.frames`.

const OUT := Color("#050c10")


## Corvo di corteccia: uccello di corteccia prugna con le penne orlate di foglia, becco d'ambra e occhio acceso.
## Fotogramma 0 ali su, 1 ali giù.
static func corvo(f: int) -> Array:
	var im := Px.img(22, 16)
	var gm := Px.img(22, 16)
	var bark := Px.pal(["#241624", "#362234", "#4c3246", "#644652"])
	var leaf := Px.pal(TileDefs.P_GRASS)
	# corpo: una goccia inclinata, la coda a sinistra
	for y in 16:
		for x in 22:
			var d := Vector2((x + 0.5 - 11.0) / 6.0, (y + 0.5 - 9.0) / 3.6)
			if d.length() <= 1.0:
				Px.put(im, x, y, bark[3] if d.y < -0.3 else bark[2])
	for k in 3:
		Px.line(im, Vector2(6.0, 9.0), Vector2(1.0, 7.0 + k * 2.0), 1, bark[1] if k != 1 else leaf[2])
	# ala: su o giù, con l'orlo di foglia
	var tip := Vector2(9.0, 1.0) if f == 0 else Vector2(8.0, 15.0)
	var mid := Vector2(12.0, 4.0) if f == 0 else Vector2(12.0, 13.0)
	Px.curve(im, Vector2(13.0, 8.0), mid, tip, 2, bark[1])
	Px.curve(im, Vector2(12.0, 8.0), mid + Vector2(-1, 0), tip + Vector2(1, 0), 1, leaf[3])
	# testa e becco
	Px.disc(im, 16.5, 6.5, 2.8, bark[3])
	Px.line(im, Vector2(19.0, 6.5), Vector2(21.5, 7.5), 1, Color("#eec04a"))
	Px.put(im, 17, 5, Color("#ffb040"))
	Px.put(gm, 17, 5, Color("#ffb040"))
	Px.outline(im, OUT)
	return [im, gm]


## Spinoriccio: una palla di aculei d'ambra con il musetto scuro e due zampette. Rotola quando carica.
static func spinoriccio(f: int) -> Array:
	var im := Px.img(16, 14)
	var gm := Px.img(16, 14)
	var sp := Px.pal(TileDefs.P_GRASS_AMBRA)
	var body := Px.pal(["#3a2418", "#5a3a26", "#7a5436"])
	for y in 14:
		for x in 16:
			var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 7.5) / 5.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, body[2] if d.y < 0.0 else body[1])
	# aculei a raggiera sul dorso
	for k in 11:
		var a := PI + k / 10.0 * PI * 1.1 - 0.05
		var from := Vector2(8.0, 7.5) + Vector2(cos(a), sin(a)) * 4.0
		var to := Vector2(8.0, 7.5) + Vector2(cos(a), sin(a)) * (7.5 if k % 2 == 0 else 6.2)
		Px.line(im, from, to, 1, sp[4] if k % 2 == 0 else sp[3])
	# musetto e occhio
	Px.disc(im, 13.0, 9.0, 2.0, body[0])
	Px.put(im, 14, 9, Color("#e8a0a0"))
	Px.put(im, 12, 7, Color("#fff2a8"))
	var st := 1 if f == 0 else -1
	Px.line(im, Vector2(5.0, 11.0), Vector2(5.0 + st, 13.0), 1, body[0])
	Px.line(im, Vector2(10.0, 11.0), Vector2(10.0 - st, 13.0), 1, body[0])
	Px.outline(im, OUT)
	return [im, gm]


## Lucciola vorace: un piccolo coleottero con l'addome acceso di verde-oro e le ali che vibrano.
static func lucciola(f: int) -> Array:
	var im := Px.img(10, 9)
	var gm := Px.img(10, 9)
	var glow := Color("#d8ff70")
	# ali trasparenti
	var wy := 1 if f == 0 else 3
	Px.line(im, Vector2(4.0, 4.0), Vector2(1.0, wy), 1, Color(0.8, 0.95, 1.0, 0.6))
	Px.line(im, Vector2(5.0, 4.0), Vector2(8.0, wy), 1, Color(0.8, 0.95, 1.0, 0.6))
	for y in range(3, 8):
		for x in range(2, 8):
			var d := Vector2((x + 0.5 - 4.5) / 2.8, (y + 0.5 - 5.5) / 2.2)
			if d.length() <= 1.0:
				var c := glow if x < 4 else Color("#2a2a1a")
				Px.put(im, x, y, c)
				if x < 4:
					Px.put(gm, x, y, glow)
	Px.put(im, 7, 5, Color("#ff5040"))
	Px.put(gm, 7, 5, Color("#ff5040"))
	return [im, gm]


## Tessiradice: un ragno fatto di radici, il corpo a bulbo prugna, otto zampe nodose, tre occhi d'ambra.
static func tessiradice(f: int) -> Array:
	var bark := Px.pal(TileDefs.P_RADICE)
	return spider(f, bark, Color("#ffb040"), Color("#6ff0d8"))


## Un ragno (anche il Tessivuoto del Fondo): addome e testa piccoli, otto zampe lunghe aperte a ventaglio con il
## ginocchio alto sopra il corpo, che si alternano camminando; gli occhi e un segno acceso sul dorso.
static func spider(f: int, pal: Array[Color], eye: Color, mark: Color) -> Array:
	var im := Px.img(24, 14)
	var gm := Px.img(24, 14)
	var legs := [[Vector2(9, 7), Vector2(4, 1), Vector2(0, 13)], [Vector2(10, 7), Vector2(7, 2), Vector2(4, 13)],
		[Vector2(13, 7), Vector2(17, 2), Vector2(19, 13)], [Vector2(14, 7), Vector2(20, 1), Vector2(23, 13)]]
	for k in legs.size():
		var l: Array = legs[k]
		var step := Vector2(1.0 if (k + f) % 2 == 0 else -1.0, 0.0)
		Px.line(im, l[0], l[1], 1, pal[2])
		Px.line(im, l[1], (l[2] as Vector2) + step, 1, pal[1])
	for y in 14:
		for x in 24:
			var d := Vector2((x + 0.5 - 9.5) / 4.6, (y + 0.5 - 7.0) / 3.4)
			if d.length() <= 1.0:
				Px.put(im, x, y, pal[3] if d.y < -0.3 else pal[2])
			var h := Vector2((x + 0.5 - 15.5) / 2.4, (y + 0.5 - 8.0) / 2.2)
			if h.length() <= 1.0:
				Px.put(im, x, y, pal[2])
	Px.put(im, 9, 5, mark)
	Px.put(gm, 9, 5, mark)
	Px.put(im, 8, 6, mark)
	Px.put(gm, 8, 6, mark)
	for q in [Vector2i(16, 7), Vector2i(17, 8), Vector2i(16, 9)]:
		Px.put(im, q.x, q.y, eye)
		Px.put(gm, q.x, q.y, eye)
	Px.outline(im, OUT)
	return [im, gm]


## Talpone di humus: una talpa enorme color terra, il muso rosa, due artigli chiari come il legnoferro.
static func talpone(f: int) -> Array:
	var im := Px.img(20, 14)
	var gm := Px.img(20, 14)
	var fur := Px.pal(TileDefs.P_DIRT)
	var claw := Px.pal(TileDefs.P_LEGNOFERRO)
	for y in 14:
		for x in 20:
			var d := Vector2((x + 0.5 - 9.0) / 8.0, (y + 0.5 - 8.0) / 5.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, fur[3] if d.y < -0.4 else (fur[2] if d.y < 0.4 else fur[1]))
	# muso a punta e occhietti
	Px.line(im, Vector2(16.0, 8.0), Vector2(19.0, 9.0), 2, Color("#c87a8a"))
	Px.put(im, 19, 9, Color("#ffb0c0"))
	Px.put(im, 14, 6, Color("#101010"))
	# artigli che scavano, alternati
	var a := 1.5 if f == 0 else -1.5
	for k in 2:
		var base := Vector2(12.0 + k * 3.0, 12.0)
		for t in 3:
			Px.line(im, base, base + Vector2(1.5 + t * 0.8, 1.8 + a * (1 if k == 0 else -1) * 0.4), 1, claw[3 - t % 2])
	Px.outline(im, OUT)
	return [im, gm]


## Saltafungo: un fungo di brace con due gambette che saltella; il cappello a pois accesi brilla nel buio.
static func saltafungo(f: int) -> Array:
	var im := Px.img(16, 16)
	var gm := Px.img(16, 16)
	var cap := Px.pal(["#6a2a3a", "#a0405a", "#d86a7a", "#ffb0b8"])
	var stem := Color("#e8d8c0")
	var st := 1 if f == 0 else 0
	Px.line(im, Vector2(6.0, 12.0), Vector2(5.0 - st, 15.0), 1, stem)
	Px.line(im, Vector2(10.0, 12.0), Vector2(11.0 + st, 15.0), 1, stem)
	for y in range(7, 13):
		for x in range(5, 11):
			Px.put(im, x, y, stem if x > 5 else Color("#b8a890"))
	Px.put(im, 7, 9, Color("#202020"))
	Px.put(im, 9, 9, Color("#202020"))
	for y in range(1, 8):
		for x in 16:
			var d := Vector2((x + 0.5 - 8.0) / 7.2, (y + 0.5 - 7.5) / 6.0)
			if d.length() <= 1.0:
				Px.put(im, x, y, cap[2] if d.x < 0.2 else cap[1])
	for q in [Vector2i(5, 3), Vector2i(9, 2), Vector2i(12, 5), Vector2i(3, 6), Vector2i(8, 5)]:
		Px.put(im, q.x, q.y, Color("#fff2a8"))
		Px.put(gm, q.x, q.y, Color("#fff2a8"))
	Px.outline(im, OUT)
	return [im, gm]
