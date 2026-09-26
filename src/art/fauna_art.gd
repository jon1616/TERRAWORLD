class_name FaunaArt
extends RefCounted
## Le famiglie nuove della voce 56, disegnate dal codice nello stile «Radici e Linfa»: ogni funzione riceve il
## fotogramma (0 o 1) e restituisce [immagine, parte luminosa]. Le chiama `CreatureArt.frames`.
##   pecora_muschio   una pecora dal vello di muschio turchese, muso scuro e zampe corte
##   cornoradice      un grande erbivoro con le corna di radice e la gobba di corteccia (si cavalca, voce 59)
##   lepre_linfa      lepre dalle orecchie lunghe con le punte di Linfa accese
##   bruco_lanterna   bruco a segmenti verdi con le sacche di luce d'ambra
##   ape_lume         ape tonda d'ambra con le ali di vetro e il pungiglione acceso
##   formica_resina   formica di resina lucida, a tre segmenti
##   pipistrello      pipistrello di corteccia con le ali di membrana e gli occhi d'ambra
##   libellula_brina  libellula lunga con quattro ali di brina
##   volpe_ambra      volpe dal pelo d'ambra con la coda folta e la punta chiara
##   lince_ardesia    lince d'ardesia a macchie, con i ciuffi sulle orecchie e gli occhi di Linfa

const OUT := Color("#050c10")
const LINFA := Color("#8ef0d8")


static func _legs(im: Image, xs: Array, y0: float, y1: float, f: int, c: Color) -> void:
	var s := 1.2 if f == 0 else -1.2
	for k in xs.size():
		var sw: float = s if k % 2 == 0 else -s
		Px.line(im, Vector2(float(xs[k]), y0), Vector2(float(xs[k]) + sw, y1), 1, c)


static func pecora_muschio(f: int) -> Array:
	var im := Px.img(20, 16)
	var gm := Px.img(20, 16)
	var w := Px.pal(TileDefs.P_GRASS)
	for k in 7:
		Px.disc(im, 5.0 + k * 1.6, 8.0 + sin(k * 1.7) * 0.8, 3.4, w[2] if k % 2 == 0 else w[3])
	Px.disc(im, 9.0, 6.6, 2.4, w[4])
	Px.disc(im, 16.5, 8.5, 2.3, Color("#2a1c24"))                 # il muso scuro
	Px.put(im, 17, 8, Color("#e8d8c0"))
	Px.put(im, 15, 6, Color("#3aa08a"))                          # l'orecchio di foglia
	_legs(im, [6, 9, 12, 14], 11.0, 15.0, f, Color("#2a1c24"))
	Px.outline(im, OUT)
	return [im, gm]


static func cornoradice(f: int) -> Array:
	var im := Px.img(28, 22)
	var gm := Px.img(28, 22)
	var b := Px.pal(TileDefs.P_RADICE)
	for y in 22:
		for x in 28:
			var d := Vector2((x + 0.5 - 12.0) / 9.0, (y + 0.5 - 12.5) / 4.8)
			if d.length() <= 1.0:
				Px.put(im, x, y, b[3] if d.y < -0.3 else b[2])
	Px.disc(im, 10.0, 8.5, 3.6, b[1])                              # la gobba di corteccia
	Px.line(im, Vector2(19.0, 11.0), Vector2(23.0, 11.5), 4, b[2])  # collo e testa bassa
	Px.disc(im, 24.0, 12.0, 2.6, b[3])
	Px.put(im, 25, 11, LINFA)
	Px.put(gm, 25, 11, LINFA)
	# le corna: radici che si torcono in avanti
	Px.curve(im, Vector2(23.0, 9.5), Vector2(21.0, 3.0), Vector2(26.0, 2.0), 1, b[4])
	Px.curve(im, Vector2(24.5, 9.5), Vector2(27.0, 5.0), Vector2(27.5, 1.0), 1, b[4])
	Px.put(im, 26, 2, Color(TileDefs.P_GRASS[3]))
	_legs(im, [6, 9, 15, 18], 16.0, 21.0, f, b[0])
	Px.line(im, Vector2(3.0, 11.0), Vector2(1.0, 13.0), 1, b[1])  # la coda
	Px.outline(im, OUT)
	return [im, gm]


static func lepre_linfa(f: int) -> Array:
	var im := Px.img(16, 16)
	var gm := Px.img(16, 16)
	var fur := Px.pal(["#4a3a40", "#7a6468", "#a89094", "#d4c4c0"])
	for y in 16:
		for x in 16:
			var d := Vector2((x + 0.5 - 7.0) / 4.8, (y + 0.5 - 11.0) / 3.4)
			if d.length() <= 1.0:
				Px.put(im, x, y, fur[2] if d.y < 0.0 else fur[1])
	Px.disc(im, 11.5, 8.5, 2.4, fur[2])
	var up := 0.0 if f == 0 else 1.0
	Px.line(im, Vector2(11.0, 6.5), Vector2(9.5 - up, 1.0), 1, fur[3])
	Px.line(im, Vector2(12.0, 6.5), Vector2(12.5 + up, 1.0), 1, fur[3])
	Px.put(im, 9 - int(up), 1, LINFA)
	Px.put(im, 12 + int(up), 1, LINFA)
	Px.put(gm, 9 - int(up), 1, LINFA)
	Px.put(gm, 12 + int(up), 1, LINFA)
	Px.put(im, 12, 8, Color("#101018"))
	Px.disc(im, 2.5, 10.0, 1.3, fur[3])                              # la coda a batuffolo
	_legs(im, [5, 9], 13.0, 15.5, f, fur[0])
	Px.outline(im, OUT)
	return [im, gm]


static func bruco_lanterna(f: int) -> Array:
	var im := Px.img(22, 12)
	var gm := Px.img(22, 12)
	var g := Px.pal(TileDefs.P_GRASS)
	var a := Px.pal(TileDefs.P_AMBRA)
	for k in 6:
		var x := 3.0 + k * 3.0
		var y := 7.0 + (sin(k + f * PI) * 1.2)
		Px.disc(im, x, y, 2.6, g[2] if k % 2 == 0 else g[3])
		if k % 2 == 1:
			Px.put(im, int(x), int(y) - 1, a[2])
			Px.put(gm, int(x), int(y) - 1, a[3])
	Px.disc(im, 20.0, 6.5, 2.4, g[1])                                # la testa
	Px.put(im, 21, 6, Color("#101018"))
	Px.line(im, Vector2(20.0, 4.0), Vector2(21.0, 1.5), 1, g[4])     # l'antenna
	Px.outline(im, OUT)
	return [im, gm]


static func ape_lume(f: int) -> Array:
	var im := Px.img(14, 12)
	var gm := Px.img(14, 12)
	var a := Px.pal(TileDefs.P_AMBRA)
	Px.disc(im, 7.0, 7.0, 3.6, a[2])
	for x in [5, 8]:
		Px.line(im, Vector2(x, 4.0), Vector2(x, 10.0), 1, Color("#2a1c10"))   # le strisce
	Px.disc(im, 11.0, 6.5, 1.8, a[1])
	Px.put(im, 12, 6, Color("#101018"))
	Px.put(im, 2, 8, a[3])                                               # il pungiglione acceso
	Px.put(gm, 2, 8, a[3])
	var wy := 1.0 if f == 0 else 3.0
	Px.disc(im, 6.0, wy + 1.0, 2.0, Color(0.85, 0.95, 1.0, 0.6))
	Px.disc(im, 9.0, wy + 1.5, 1.6, Color(0.85, 0.95, 1.0, 0.5))
	Px.outline(im, OUT)
	return [im, gm]


static func formica_resina(f: int) -> Array:
	var im := Px.img(14, 9)
	var gm := Px.img(14, 9)
	var r := Px.pal(["#5a2a0c", "#9a4a14", "#d8782a", "#ffc070"])
	Px.disc(im, 3.5, 4.5, 2.4, r[1])
	Px.disc(im, 7.0, 4.5, 1.6, r[2])
	Px.disc(im, 10.5, 4.0, 2.0, r[2])
	Px.put(im, 3, 3, r[3])
	Px.put(im, 11, 3, Color("#101018"))
	Px.line(im, Vector2(11.5, 2.5), Vector2(13.0, 0.5), 1, r[0])
	_legs(im, [5, 7, 9], 6.0, 8.5, f, r[0])
	Px.outline(im, OUT)
	return [im, gm]


static func pipistrello(f: int) -> Array:
	var im := Px.img(20, 12)
	var gm := Px.img(20, 12)
	var b := Px.pal(TileDefs.P_RADICE)
	var m := Px.pal(["#2a1a24", "#4a2e3c", "#6a4450"])
	var up := f == 0
	for side in [-1, 1]:
		var tip := Vector2(10.0 + side * 9.0, 2.0 if up else 9.0)
		Px.line(im, Vector2(10.0 + side * 2.0, 5.0), tip, 1, b[1])
		for k in 5:
			var q := Vector2(10.0 + side * 2.0, 6.0).lerp(tip, k / 4.0)
			Px.line(im, q, q + Vector2(0, 2.5), 1, m[1 + k % 2])
	Px.disc(im, 10.0, 6.0, 2.6, b[2])
	Px.put(im, 9, 3, b[3])
	Px.put(im, 11, 3, b[3])
	Px.put(im, 9, 6, Color("#ffb040"))
	Px.put(im, 11, 6, Color("#ffb040"))
	Px.put(gm, 9, 6, Color("#ffb040"))
	Px.put(gm, 11, 6, Color("#ffb040"))
	Px.outline(im, OUT)
	return [im, gm]


static func libellula_brina(f: int) -> Array:
	var im := Px.img(22, 12)
	var gm := Px.img(22, 12)
	var p := Px.pal(BiomeBeastArt.BRINA)
	Px.line(im, Vector2(2.0, 7.0), Vector2(16.0, 7.0), 1, p[2])       # il corpo lungo
	Px.disc(im, 17.5, 7.0, 2.0, p[3])
	Px.put(im, 18, 6, LINFA)
	Px.put(gm, 18, 6, LINFA)
	var wy := 3.0 if f == 0 else 5.0
	for wx in [9.0, 13.0]:
		Px.line(im, Vector2(wx, 6.0), Vector2(wx - 3.0, wy - 2.0), 2, Color(0.8, 0.95, 1.0, 0.55))
		Px.line(im, Vector2(wx, 8.0), Vector2(wx - 2.0, 12.0 - (wy - 3.0)), 2, Color(0.8, 0.95, 1.0, 0.45))
	Px.outline(im, OUT)
	return [im, gm]


static func volpe_ambra(f: int) -> Array:
	var im := Px.img(24, 16)
	var gm := Px.img(24, 16)
	var a := Px.pal(["#6a3010", "#b0601c", "#e8943a", "#ffd08a"])
	for y in 16:
		for x in 24:
			var d := Vector2((x + 0.5 - 12.0) / 6.0, (y + 0.5 - 9.5) / 3.0)
			if d.length() <= 1.0:
				Px.put(im, x, y, a[2] if d.y < 0.0 else a[1])
	Px.disc(im, 18.5, 7.5, 2.6, a[2])
	Px.line(im, Vector2(20.0, 8.0), Vector2(23.0, 8.5), 1, a[1])      # il muso
	Px.put(im, 17, 4, a[1])
	Px.put(im, 19, 4, a[1])
	Px.put(im, 19, 7, Color("#101018"))
	var tail := 1.0 if f == 0 else -1.0
	Px.curve(im, Vector2(6.0, 9.0), Vector2(1.0, 7.0 + tail), Vector2(1.5, 3.0 + tail), 3, a[2])
	Px.put(im, 1, 3 + int(tail), a[3])
	_legs(im, [8, 11, 14, 17], 12.0, 15.5, f, a[0])
	Px.outline(im, OUT)
	return [im, gm]


static func lince_ardesia(f: int) -> Array:
	var im := Px.img(24, 18)
	var gm := Px.img(24, 18)
	var p := Px.pal(TileDefs.P_STONE)
	for y in 18:
		for x in 24:
			var d := Vector2((x + 0.5 - 11.0) / 6.6, (y + 0.5 - 10.5) / 3.4)
			if d.length() <= 1.0:
				Px.put(im, x, y, p[3] if d.y < 0.0 else p[2])
	for q in [Vector2(8, 9), Vector2(11, 10), Vector2(14, 9), Vector2(9, 11)]:
		Px.put(im, int(q.x), int(q.y), p[1])                          # le macchie
	Px.disc(im, 18.5, 8.0, 3.0, p[3])
	Px.line(im, Vector2(17.0, 5.5), Vector2(16.5, 2.5), 1, p[4])       # i ciuffi
	Px.line(im, Vector2(20.0, 5.5), Vector2(20.5, 2.5), 1, p[4])
	Px.put(im, 20, 7, LINFA)
	Px.put(gm, 20, 7, LINFA)
	Px.line(im, Vector2(5.0, 10.0), Vector2(3.0, 11.5), 2, p[2])      # la coda corta
	_legs(im, [7, 10, 13, 16], 13.0, 17.5, f, p[1])
	Px.outline(im, OUT)
	return [im, gm]
