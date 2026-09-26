class_name BiomeBeastArt
extends RefCounted
## Le creature dei biomi della voce 40, disegnate dal codice nello stile «Radici e Linfa»: ogni funzione riceve il
## fotogramma (0 o 1) e restituisce [immagine, parte luminosa]. Le chiama `CreatureArt.frames`.
##   cervo_brina       Boschi di brina: cervo dal vello azzurro, palchi di brina ramificati come radici
##   gufo_gelo         Boschi di brina: gufo tondo di piume ghiacciate, occhi di Linfa fredda
##   salamandra        Cenerarie: salamandra di cenere rosata con la schiena di braci accese
##   fatuo_cenere      Cenerarie: una fiammella di cenere che fluttua e si piega, con il cuore di brace

const OUT := Color("#050c10")
const BRINA := ["#1c3048", "#2a4a6a", "#44729a", "#7aaed0", "#d0f0ff"]
const CENERE := ["#3a2a30", "#5a3e44", "#7e565a", "#a8766e", "#e0a888"]
const EMBER := ["#9a2a1a", "#e0582a", "#ffb040", "#fff2a8"]


## Cervo di brina: corpo a goccia orizzontale, collo alto, palchi che si ramificano; zampe alternate nei fotogrammi.
static func cervo_brina(f: int) -> Array:
	var im := Px.img(24, 22)
	var gm := Px.img(24, 22)
	var p := Px.pal(BRINA)
	for y in 22:
		for x in 24:
			var d := Vector2((x + 0.5 - 11.0) / 7.5, (y + 0.5 - 13.0) / 3.8)
			if d.length() <= 1.0:
				Px.put(im, x, y, p[3] if d.y < -0.2 else p[2])
	# collo e testa
	Px.line(im, Vector2(16.0, 12.0), Vector2(18.5, 7.0), 3, p[2])
	Px.disc(im, 19.5, 6.5, 2.4, p[3])
	Px.line(im, Vector2(21.0, 7.0), Vector2(23.0, 8.0), 1, p[2])
	Px.put(im, 20, 6, Color("#8ef0d8"))
	Px.put(gm, 20, 6, Color("#8ef0d8"))
	# palchi di brina: rami che si aprono come radici capovolte
	var ant := p[4]
	Px.line(im, Vector2(18.5, 4.5), Vector2(16.5, 0.5), 1, ant)
	Px.line(im, Vector2(17.4, 2.5), Vector2(14.5, 1.5), 1, ant)
	Px.line(im, Vector2(20.0, 4.5), Vector2(22.0, 0.5), 1, ant)
	Px.line(im, Vector2(21.0, 2.5), Vector2(23.5, 2.0), 1, ant)
	Px.put(gm, 16, 0, Color(0.8, 0.95, 1.0))
	Px.put(gm, 22, 0, Color(0.8, 0.95, 1.0))
	# coda e zampe
	Px.line(im, Vector2(4.0, 11.0), Vector2(2.0, 9.5), 1, p[4])
	var s := 1.5 if f == 0 else -1.5
	for lx in [6.0, 9.0, 14.0, 17.0]:
		var sw: float = s if int(lx) % 2 == 0 else -s
		Px.line(im, Vector2(lx, 15.0), Vector2(lx + sw, 21.0), 1, p[1])
	# macchie di brina sul dorso
	for q in [Vector2(8, 11), Vector2(11, 10), Vector2(14, 11)]:
		Px.put(im, int(q.x), int(q.y), p[4])
	Px.outline(im, OUT)
	return [im, gm]


## Gufo del gelo: una palla di piume con le orecchie a punta e due grandi occhi turchesi; ali su e giù.
static func gufo_gelo(f: int) -> Array:
	var im := Px.img(20, 16)
	var gm := Px.img(20, 16)
	var p := Px.pal(BRINA)
	for y in 16:
		for x in 20:
			var d := Vector2((x + 0.5 - 10.0) / 5.2, (y + 0.5 - 9.0) / 5.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, p[3] if d.y < 0.1 else p[2])
	# ali ai lati
	var up := f == 0
	for side in [-1.0, 1.0]:
		var root := Vector2(10.0 + side * 4.5, 9.0)
		var tip := Vector2(10.0 + side * 9.5, 4.0 if up else 13.0)
		Px.curve(im, root, Vector2(10.0 + side * 8.0, 7.0 if up else 11.0), tip, 2, p[1])
		Px.put(im, int(tip.x), int(tip.y), p[4])
	# orecchie, occhi, becco
	Px.line(im, Vector2(7.0, 4.5), Vector2(6.0, 2.0), 1, p[4])
	Px.line(im, Vector2(13.0, 4.5), Vector2(14.0, 2.0), 1, p[4])
	for ex in [8.0, 12.0]:
		Px.disc(im, ex, 7.5, 1.6, Color("#0a2a36"))
		Px.put(im, int(ex), 7, Color("#8ef0d8"))
		Px.put(gm, int(ex), 7, Color("#8ef0d8"))
	Px.put(im, 10, 9, Color("#eec04a"))
	# petto a scaglie di brina
	for k in 3:
		Px.put(im, 8 + k * 2, 12, p[4])
	Px.outline(im, OUT)
	return [im, gm]


## Salamandra di brace: bassa e lunga, cenere rosata, una fila di braci accese sulla schiena; coda che ondeggia.
static func salamandra(f: int) -> Array:
	var im := Px.img(24, 11)
	var gm := Px.img(24, 11)
	var p := Px.pal(CENERE)
	var e := Px.pal(EMBER)
	for y in 11:
		for x in 24:
			var d := Vector2((x + 0.5 - 12.0) / 7.5, (y + 0.5 - 6.0) / 2.6)
			if d.length() <= 1.0:
				Px.put(im, x, y, p[3] if d.y < 0.0 else p[2])
	# testa
	Px.disc(im, 19.5, 5.5, 2.6, p[3])
	Px.put(im, 21, 4, Color("#fff2a8"))
	Px.put(gm, 21, 4, Color("#ffb040"))
	# coda che ondeggia
	var wv := 1.0 if f == 0 else -1.0
	Px.curve(im, Vector2(5.0, 6.0), Vector2(2.5, 6.0 + wv * 2.0), Vector2(0.5, 5.0 - wv), 1, p[2])
	# braci sulla schiena (parte luminosa)
	for k in 5:
		var bx := 8 + k * 2
		var c := e[2] if (k + f) % 2 == 0 else e[1]
		Px.put(im, bx, 3, c)
		Px.put(gm, bx, 3, c)
	# zampe
	for lx in [8.0, 16.0]:
		Px.line(im, Vector2(lx, 8.0), Vector2(lx + wv, 10.0), 1, p[1])
	Px.outline(im, OUT)
	return [im, gm]


## Fatuo di cenere: una fiammella di cenere che fluttua piegandosi, con un cuore di brace in basso.
static func fatuo_cenere(f: int) -> Array:
	var im := Px.img(12, 16)
	var gm := Px.img(12, 16)
	var p := Px.pal(CENERE)
	var e := Px.pal(EMBER)
	# una fiammella: punta in alto che si piega da una parte all'altra, fondo tondo
	for y in 16:
		var t := y / 15.0
		var hw := 4.8 * pow(t, 0.7) * clampf((1.0 - t) * 4.0, 0.0, 1.0)
		var cx := 6.0 + (1.0 - t) * (1.2 if f == 0 else -1.2)
		for x in 12:
			if absf(x + 0.5 - cx) <= hw:
				Px.put(im, x, y, p[3] if x + 0.5 < cx else p[2])
	# il cuore di brace, in basso dove la fiamma è più larga
	Px.disc(im, 6.0, 10.5, 2.2, e[1])
	Px.disc(gm, 6.0, 10.5, 2.2, e[1])
	Px.put(im, 6, 10, e[3])
	Px.put(gm, 6, 10, e[3])
	Px.put(im, 5, 11, e[2])
	Px.put(gm, 5, 11, e[2])
	# due faville sopra la punta
	var fy := 1 if f == 0 else 0
	Px.put(im, 4 + f * 4, fy, e[2])
	Px.put(gm, 4 + f * 4, fy, e[2])
	Px.outline(im, OUT)
	return [im, gm]
