class_name DeepBeastArt
extends RefCounted
## Le creature della voce 22 che vivono nel profondo (Caverne d'ardesia, Profondità della Linfa, il Fondo), disegnate
## dal codice. Ogni funzione restituisce [immagine, parte luminosa]; le chiama `CreatureArt.frames`.

const OUT := Color("#050c10")


## Ala d'ardesia: una creatura di roccia con le ali di membrana blu tese tra dita di pietra, occhi turchesi.
static func ala_ardesia(f: int) -> Array:
	var im := Px.img(22, 13)
	var gm := Px.img(22, 13)
	var st := Px.pal(TileDefs.P_STONE)
	var up := f == 0
	for side in [-1, 1]:
		var tip := Vector2(11.0 + side * 10.0, 2.0 if up else 11.0)
		var elbow := Vector2(11.0 + side * 6.0, 1.0 if up else 9.0)
		Px.line(im, Vector2(11.0, 6.0), elbow, 1, st[1])
		Px.line(im, elbow, tip, 1, st[1])
		# la membrana: triangoli pieni tra il corpo, il gomito e la punta
		for k in 12:
			var t := k / 11.0
			Px.line(im, Vector2(11.0 + side * 1.5, 7.0), elbow.lerp(tip, t), 1, st[2] if k % 3 != 0 else st[3])
	for y in 13:
		for x in 22:
			var d := Vector2((x + 0.5 - 11.0) / 3.0, (y + 0.5 - 7.0) / 3.6)
			if d.length() <= 1.0:
				Px.put(im, x, y, st[4] if d.y < -0.2 else st[3])
	Px.put(im, 11, 3, st[3])
	Px.put(im, 10, 2, st[4])
	Px.put(im, 12, 2, st[4])
	for q in [Vector2i(10, 6), Vector2i(12, 6)]:
		Px.put(im, q.x, q.y, Color("#6ff0f0"))
		Px.put(gm, q.x, q.y, Color("#6ff0f0"))
	Px.outline(im, OUT)
	return [im, gm]


## Chiocciola di cristallo: corpo d'ardesia molle con il guscio a spirale di cristallo di Linfa che brilla.
## Fotogrammi: 0 e 1 camminando (il corpo si allunga), 2 chiusa nel guscio.
static func chiocciola(f: int) -> Array:
	var im := Px.img(20, 14)
	var gm := Px.img(20, 14)
	var body := Px.pal(["#3a4966", "#4c5e80", "#62779c", "#8298bc"])
	var cr := Px.pal(TileDefs.P_CRYSTAL)
	if f < 2:
		var reach := 18.0 if f == 0 else 16.5
		for y in range(10, 14):
			for x in range(3, int(reach) + 1):
				Px.put(im, x, y, body[2] if y < 12 else body[1])
		# testa con le antenne
		Px.line(im, Vector2(reach - 1.0, 10.0), Vector2(reach, 6.0), 1, body[3])
		Px.line(im, Vector2(reach - 3.0, 10.0), Vector2(reach - 3.5, 7.0), 1, body[3])
		Px.put(im, int(reach), 5, Color("#b8f4f0"))
		Px.put(gm, int(reach), 5, Color("#b8f4f0"))
	# il guscio a spirale
	for y in 14:
		for x in 20:
			var d := Vector2(x + 0.5 - 8.0, y + 0.5 - 7.0)
			if d.length() <= 6.2:
				var a := atan2(d.y, d.x)
				var ring := fmod(d.length() + a * 0.9 + TAU, 2.6)
				var c := cr[4] if ring < 0.7 else (cr[3] if ring < 1.6 else cr[2])
				Px.put(im, x, y, c)
				if ring < 0.7:
					Px.put(gm, x, y, c)
	Px.outline(im, OUT)
	return [im, gm]


## Geomimo: fotogramma 0 un mucchio di rocce con cristalli (il travestimento), 1 e 2 le stesse rocce sveglie con gli
## occhi viola e le zampe corte.
static func geomimo(f: int) -> Array:
	var im := Px.img(16, 16)
	var gm := Px.img(16, 16)
	var st := Px.pal(TileDefs.P_STONE)
	var cr := Px.pal(TileDefs.P_CRYSTAL)
	var lift := 0 if f == 0 else 2
	if f > 0:
		var s := 1 if f == 1 else -1
		Px.line(im, Vector2(4.0, 13.0), Vector2(3.0 + s, 15.0), 1, st[0])
		Px.line(im, Vector2(11.0, 13.0), Vector2(12.0 - s, 15.0), 1, st[0])
	for y in 16:
		for x in 16:
			var d := Vector2((x + 0.5 - 8.0) / 7.2, (y + 0.5 - 11.0 + lift) / 5.0)
			var wob := 0.1 * sin(x * 1.3) + 0.08 * cos(y * 2.1)
			if d.length() <= 1.0 + wob and y < 16 - lift:
				Px.put(im, x, y, st[clampi(int((0.6 - d.x * 0.3 - d.y * 0.4) * 5.0), 0, 4)])
	# cristalli sul dorso
	for c in [[5.0, 3.0], [9.0, 1.5], [11.5, 4.0]]:
		for y in range(int(c[1]) - lift, 9 - lift):
			var hw: float = (y - c[1] + lift) * 0.3
			for x in range(int(c[0] - hw), int(c[0] + hw) + 1):
				Px.put(im, x, y, cr[3] if x <= c[0] else cr[2])
				Px.put(gm, x, y, cr[3] if x <= c[0] else cr[2])
	if f > 0:
		for q in [Vector2i(5, 10 - lift), Vector2i(10, 10 - lift)]:
			Px.put(im, q.x, q.y, Color("#e060ff"))
			Px.put(gm, q.x, q.y, Color("#e060ff"))
	Px.outline(im, OUT)
	return [im, gm]


## Serpe di Linfa: un serpente che nuota nell'aria delle Profondità, turchese scuro con le strisce accese.
static func serpe(f: int) -> Array:
	var im := Px.img(28, 11)
	var gm := Px.img(28, 11)
	var sk := Px.pal(["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc"])
	var ph := 0.0 if f == 0 else PI
	for x in 26:
		var t := x / 25.0
		var cy := 5.5 + sin(t * 7.0 + ph) * 2.2 * (1.0 - t * 0.6)
		var r := 1.8 + t * 1.8
		for y in 11:
			var d := absf(y + 0.5 - cy)
			if d <= r:
				var c := sk[3] if d < 0.6 and x % 4 == 0 else (sk[2] if y < cy else sk[1])
				Px.put(im, x, y, c)
				if d < 0.6 and x % 4 == 0:
					Px.put(gm, x, y, c)
	# testa
	var hy := 5.5 + sin(7.0 + ph) * 0.9
	Px.disc(im, 25.0, hy, 2.6, sk[2])
	Px.put(im, 26, int(hy) - 1, Color("#fff2a8"))
	Px.put(gm, 26, int(hy) - 1, Color("#fff2a8"))
	Px.outline(im, OUT)
	return [im, gm]


## Campanula errante: una campanula enorme che fluttua a testa in giù con i viticci; dal cuore piove polline.
static func campanula(f: int) -> Array:
	var im := Px.img(18, 20)
	var gm := Px.img(18, 20)
	var pe := Px.pal(["#3a1a5a", "#6a3aa8", "#a878f0", "#e0c8ff"])
	var moss := Px.pal(TileDefs.P_GRASS)
	# stelo e foglie in cima
	Px.curve(im, Vector2(9.0, 0.0), Vector2(11.0, 2.0), Vector2(9.0, 4.0), 1, moss[2])
	Px.put(im, 11, 1, moss[4])
	Px.put(im, 7, 2, moss[3])
	# la corolla: una cupola tonda che si allarga in un orlo a festoni
	var open := 0.0 if f == 0 else 0.8
	for y in range(3, 15):
		var t := (y - 3) / 11.0
		var hw := 3.0 + 1.5 * sqrt(t) + 3.5 * pow(t, 3.0) * (1.0 + open * 0.3)
		for x in 18:
			var dx := x + 0.5 - 9.0
			if absf(dx) <= hw:
				if y == 14 and int(absf(dx)) % 3 == 1:
					continue                   # i festoni dell'orlo
				var c := pe[2] if dx < -0.5 else pe[1]
				if absf(dx) > hw - 1.0 or y >= 13:
					c = pe[3]
				Px.put(im, x, y, c)
	# viticci e il pistillo acceso
	for k in 3:
		var bx := 6.0 + k * 3.0
		Px.curve(im, Vector2(bx, 15.0), Vector2(bx + (1.5 if (k + f) % 2 == 0 else -1.5), 16.5), Vector2(bx, 19.0), 1, moss[3])
	for y in range(12, 18):
		Px.put(im, 9, y, Color("#fff2a8"))
		Px.put(gm, 9, y, Color("#fff2a8"))
	Px.outline(im, OUT)
	return [im, gm]


## Guizzalinfa: un folletto di Linfa trasparente, due grandi occhi accesi, le orecchie a foglia.
static func guizzalinfa(f: int) -> Array:
	var im := Px.img(12, 14)
	var gm := Px.img(12, 14)
	var lp := Px.pal(TileDefs.P_CRYSTAL)
	var st := 1 if f == 0 else -1
	Px.line(im, Vector2(4.0, 10.0), Vector2(4.0 - st, 13.0), 1, lp[2])
	Px.line(im, Vector2(8.0, 10.0), Vector2(8.0 + st, 13.0), 1, lp[2])
	for y in 12:
		for x in 12:
			var d := Vector2((x + 0.5 - 6.0) / 4.5, (y + 0.5 - 7.0) / 4.5)
			if d.length() <= 1.0:
				var c := lp[3] if d.y < 0.0 else lp[2]
				c.a = 0.85
				Px.put(im, x, y, c)
				Px.put(gm, x, y, Color(c.r, c.g, c.b, 0.35))
	Px.line(im, Vector2(2.5, 4.0), Vector2(0.0, 1.0), 1, lp[4])
	Px.line(im, Vector2(9.5, 4.0), Vector2(12.0, 1.0), 1, lp[4])
	for q in [Vector2i(4, 6), Vector2i(8, 6)]:
		Px.put(im, q.x, q.y, Color.WHITE)
		Px.put(gm, q.x, q.y, Color.WHITE)
		Px.put(im, q.x, q.y + 1, Color("#fff2a8"))
		Px.put(gm, q.x, q.y + 1, Color("#fff2a8"))
	Px.outline(im, OUT)
	return [im, gm]


## Mietivuoto: una figura alta e sottile avvolta nel Vuoto, due braccia a falce accese di viola.
static func mietivuoto(f: int) -> Array:
	var im := Px.img(18, 24)
	var gm := Px.img(18, 24)
	var vp := Px.pal(TileDefs.P_VUOTITE)
	var blade := Color("#d8a0ff")
	# mantello a campana
	for y in range(4, 23):
		var hw := 1.8 + (y - 4) * 0.22
		for x in 18:
			var dx := x + 0.5 - 9.0 + (1.0 if f == 1 and y > 18 else 0.0)
			if absf(dx) <= hw:
				Px.put(im, x, y, vp[2] if dx < 0.0 else vp[1])
	Px.disc(im, 9.0, 3.5, 2.6, vp[3])
	Px.put(im, 10, 3, blade)
	Px.put(gm, 10, 3, blade)
	# falci
	var sw := 0.0 if f == 0 else 2.0
	for side in [-1, 1]:
		var sh := Vector2(9.0 + side * 2.0, 8.0)
		var hand := Vector2(9.0 + side * 6.0, 12.0 - sw * side)
		Px.line(im, sh, hand, 1, vp[1])
		Px.curve(im, hand, hand + Vector2(side * 3.0, -6.0), hand + Vector2(-side * 1.0, -9.0), 1, blade)
		Px.curve(gm, hand, hand + Vector2(side * 3.0, -6.0), hand + Vector2(-side * 1.0, -9.0), 1, blade)
	Px.outline(im, OUT)
	return [im, gm]


## Tessivuoto: il ragno del Fondo, di vuotite con il segno acceso e gli occhi viola.
static func tessivuoto(f: int) -> Array:
	return BeastArt.spider(f, Px.pal(TileDefs.P_VUOTITE), Color("#e060ff"), Color("#d8b0ff"))


## Sciame di schegge: tre schegge del Vuoto che volano insieme ruotando.
static func sciame(f: int) -> Array:
	var im := Px.img(11, 11)
	var gm := Px.img(11, 11)
	var vp := Px.pal(TileDefs.P_VUOTITE)
	for k in 3:
		var a := k * TAU / 3.0 + (0.5 if f == 1 else 0.0)
		var c := Vector2(5.5, 5.5) + Vector2(cos(a), sin(a)) * 3.0
		Px.line(im, c - Vector2(cos(a + 1.2), sin(a + 1.2)) * 2.0, c + Vector2(cos(a + 1.2), sin(a + 1.2)) * 2.0, 1, vp[4])
		Px.put(gm, int(c.x), int(c.y), Color("#d8b0ff"))
	Px.disc(im, 5.5, 5.5, 1.2, Color("#d8b0ff"))
	Px.disc(gm, 5.5, 5.5, 1.2, Color("#d8b0ff"))
	return [im, gm]
