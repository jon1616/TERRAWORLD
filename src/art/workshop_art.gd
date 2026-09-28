class_name WorkshopArt
extends RefCounted
## I banchi da lavoro della voce 25, disegnati dal codice (li chiama `StationArt.make`):
##   telaio     un telaio di rami con i fili di seta tesi e una stoffa a metà

const S := 16


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"telaio":
			_telaio(im, w, h)
		"scalpellino":
			_scalpellino(im, w, h)
		"altare":
			_altare(im, gm, w, h)
		"bozzolo_rotto":
			KeeperArt.bozzolo(im, gm, w, h, Color.BLACK, true)
		_:
			if id.begins_with("arredo_"):
				return FurnitureSeriesArt.draw(id, im, gm, w, h)   # voce 141
			if id.begins_with("nido_") or id in ["recinto", "incubatrice", "cuccia", "alveare_costruito"]:
				return NestArt.draw(id, im, gm, w, h)       # voce 58
			if id.begins_with("bozzolo_"):
				KeeperArt.bozzolo(im, gm, w, h, StationsData.STATIONS[id]["light_color"] * 1.4, false)
			else:
				return FurnitureArt.draw(id, im, gm, w, h)
	return true


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


## Il Banco dello scalpellino (voce 139): un piano di pietra su due gambe di radice, un blocco a metà lavoro con i
## segni dello scalpello, lo scalpello e la squadra appoggiati.
static func _scalpellino(im: Image, w: int, h: int) -> void:
	var bark := Px.pal(["#241624", "#362234", "#4c3246", "#644652"])
	var st := Px.pal(["#2a3650", "#3a4966", "#4c5e80", "#62779c", "#8298bc"])
	var metal := Px.pal(["#4a2a1a", "#965a38", "#e0a070"])
	# le gambe
	for x in [4, w - 5]:
		Px.line(im, Vector2(x, h - 1.0), Vector2(x, h - 11.0), 2, bark[2])
	# il piano di pietra
	for y in range(h - 14, h - 10):
		for x in range(1, w - 1):
			Px.put(im, x, y, st[3] if y == h - 14 else st[2])
	# il blocco a metà lavoro: squadrato a sinistra, grezzo a destra
	for y in range(h - 24, h - 14):
		for x in range(7, 19):
			var rough := x > 13 and ((x * 7 + y * 3) % 5 == 0)
			if rough and y < h - 20:
				continue
			Px.put(im, x, y, st[4] if y == h - 24 else (st[1] if x == 7 or (x == 13 and y % 3 == 0) else st[2]))
	# lo scalpello e la squadra
	Px.line(im, Vector2(21.0, h - 15.0), Vector2(27.0, h - 21.0), 1, metal[1])
	Px.put(im, 27, h - 21, metal[2])
	Px.line(im, Vector2(2.0, h - 15.0), Vector2(6.0, h - 15.0), 1, metal[2])
	Px.line(im, Vector2(2.0, h - 15.0), Vector2(2.0, h - 19.0), 1, metal[2])

