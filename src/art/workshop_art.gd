class_name WorkshopArt
extends RefCounted
## I banchi da lavoro della voce 25, disegnati dal codice (li chiama `StationArt.make`):
##   alambicco  due ampolle di cristallo su un treppiede di radice, la Linfa che bolle e brilla
##   telaio     un telaio di rami con i fili di seta tesi e una stoffa a metà
##   mola       una ruota d'ardesia su un cavalletto, con una gemma rossa appoggiata

const S := 16


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"alambicco":
			_alambicco(im, gm, w, h)
		"telaio":
			_telaio(im, w, h)
		"mola":
			_mola(im, gm, w, h)
		"altare":
			_altare(im, gm, w, h)
		"reliquiario":
			_reliquiario(im, gm, w, h)
		"bozzolo_rotto":
			KeeperArt.bozzolo(im, gm, w, h, Color.BLACK, true)
		_:
			if id.begins_with("bozzolo_"):
				KeeperArt.bozzolo(im, gm, w, h, StationsData.STATIONS[id]["light_color"] * 1.4, false)
			else:
				return false
	return true


static func _alambicco(im: Image, gm: Image, w: int, h: int) -> void:
	var bark := Px.pal(["#241624", "#362234", "#4c3246", "#644652"])
	var glass := Color(0.72, 0.95, 0.98, 0.55)
	var linfa := Px.pal(TileDefs.P_CRYSTAL)
	# treppiede
	for lx in [5.0, 16.0, 27.0]:
		Px.line(im, Vector2(lx, h - 1.0), Vector2(16.0, h - 12.0), 1, bark[2])
	Px.line(im, Vector2(6.0, h - 9.0), Vector2(26.0, h - 9.0), 2, bark[3])
	# la brace sotto l'ampolla grande
	for q in [Vector2i(13, h - 5), Vector2i(16, h - 4), Vector2i(19, h - 5)]:
		Px.put(im, q.x, q.y, Color("#ffb040"))
		Px.put(gm, q.x, q.y, Color("#ffb040"))
	# ampolla grande: pancia tonda con la Linfa, collo che piega verso quella piccola
	for y in h:
		for x in w:
			var d := Vector2((x + 0.5 - 12.0) / 7.5, (y + 0.5 - (h - 17.0)) / 6.5)
			if d.length() <= 1.0:
				var c := glass
				if y > h - 18:
					c = linfa[3] if d.x < -0.2 else linfa[2]
					Px.put(gm, x, y, c)
				Px.put(im, x, y, c)
	Px.line(im, Vector2(12.0, h - 23.0), Vector2(12.0, 3.0), 2, glass)
	Px.curve(im, Vector2(12.0, 3.0), Vector2(20.0, 0.0), Vector2(24.0, 10.0), 1, glass)
	# ampolla piccola che raccoglie le gocce
	Px.disc(im, 25.0, h - 17.0, 4.0, glass)
	Px.disc(im, 25.0, h - 16.0, 2.6, linfa[3])
	Px.disc(gm, 25.0, h - 16.0, 2.6, linfa[3])
	Px.put(im, 10, h - 20, Color.WHITE)


static func _telaio(im: Image, w: int, h: int) -> void:
	var bark := Px.pal(["#241624", "#362234", "#4c3246", "#644652"])
	var silk := Px.pal(["#9a9a8a", "#cacabc", "#f4f4ea"])
	var leaf := Px.pal(TileDefs.P_GRASS)
	# i due montanti e le traverse
	for x in [3, w - 4]:
		Px.line(im, Vector2(x, h - 1.0), Vector2(x, 2.0), 2, bark[2])
	Px.line(im, Vector2(2.0, 4.0), Vector2(w - 3.0, 4.0), 2, bark[3])
	Px.line(im, Vector2(2.0, h - 6.0), Vector2(w - 3.0, h - 6.0), 2, bark[3])
	# i fili tesi
	for x in range(7, w - 6, 3):
		Px.line(im, Vector2(x, 6.0), Vector2(x, h - 8.0), 1, silk[1])
	# la stoffa già tessuta, a righe di foglia
	for y in range(h - 16, h - 8):
		for x in range(6, w - 6):
			Px.put(im, x, y, leaf[3] if (y / 2) % 2 == 0 else silk[2])
	# la spola appoggiata sopra
	Px.line(im, Vector2(8.0, 1.0), Vector2(20.0, 1.0), 2, bark[1])
	Px.put(im, 14, 1, silk[2])


## L'Altare dei Seminatori: una lastra di pietra lavorata su due colonne, con le rune accese e una conca di Linfa.
static func _altare(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	var rune := Color("#6ff0d8")
	for x in [6, w - 7]:
		for y in range(12, h):
			for dx in range(-3, 4):
				Px.put(im, x + dx, y, st[2] if dx < 1 else st[1])
	for y in range(6, 13):
		for x in range(1, w - 1):
			Px.put(im, x, y, st[3] if y < 8 else st[2])
	for x in range(10, w - 10):
		Px.put(im, x, 5, st[4])
	for q in [Vector2i(5, 16), Vector2i(6, 18), Vector2i(7, 20), Vector2i(w - 8, 17), Vector2i(w - 7, 19), Vector2i(w - 6, 21)]:
		Px.put(im, q.x, q.y, rune)
		Px.put(gm, q.x, q.y, rune)
	for x in range(18, 30):
		Px.put(im, x, 4, rune)
		Px.put(gm, x, 4, rune)
	Px.put(im, 24, 3, Color.WHITE)
	Px.put(gm, 24, 3, Color.WHITE)


## Il reliquiario: un piccolo scrigno di pietra lavorata a forma di seme, con il coperchio d'ambra e una runa accesa.
static func _reliquiario(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	var amb := Px.pal(TileDefs.P_AMBRA)
	for y in range(8, h):
		for x in range(3, w - 3):
			Px.put(im, x, y, st[2] if x < w / 2 else st[1])
	for y in range(3, 9):
		var hw := 6.0 + (y - 3) * 1.4
		for x in w:
			if absf(x + 0.5 - w / 2.0) <= hw:
				Px.put(im, x, y, amb[2] if y > 4 else amb[3])
	Px.line(im, Vector2(3.0, 9.0), Vector2(w - 4.0, 9.0), 1, amb[1])
	for q in [Vector2i(w / 2 - 1, 14), Vector2i(w / 2, 13), Vector2i(w / 2 + 1, 14), Vector2i(w / 2, 15), Vector2i(w / 2, 17)]:
		Px.put(im, q.x, q.y, Color("#6ff0d8"))
		Px.put(gm, q.x, q.y, Color("#6ff0d8"))
	Px.put(gm, w / 2, 4, amb[3])


static func _mola(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var bark := Px.pal(["#241624", "#362234", "#4c3246", "#644652"])
	# cavalletto
	Px.line(im, Vector2(3.0, h - 1.0), Vector2(10.0, h - 14.0), 2, bark[2])
	Px.line(im, Vector2(w - 4.0, h - 1.0), Vector2(w - 11.0, h - 14.0), 2, bark[2])
	Px.line(im, Vector2(4.0, h - 5.0), Vector2(w - 5.0, h - 5.0), 1, bark[3])
	# la ruota d'ardesia, con i raggi incisi
	var c := Vector2(w / 2.0, h - 17.0)
	for y in h:
		for x in w:
			var d := Vector2(x + 0.5, y + 0.5) - c
			if d.length() <= 10.5:
				var col := st[3] if d.length() > 9.0 else (st[2] if int(d.angle() * 3.0 / PI + 6.0) % 2 == 0 else st[1])
				Px.put(im, x, y, col)
	Px.disc(im, c.x, c.y, 2.0, bark[3])
	# la manovella e la gemma appoggiata al piede
	Px.line(im, c, c + Vector2(8.0, -8.0), 1, bark[1])
	Px.disc(im, w - 6.0, h - 3.0, 2.0, Color("#c8283c"))
	Px.put(im, w - 7, h - 4, Color("#ffd0d4"))
	Px.put(gm, w - 7, h - 4, Color("#ff6a78"))
