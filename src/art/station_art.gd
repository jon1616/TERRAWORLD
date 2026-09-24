class_name StationArt
extends RefCounted
## Le stazioni di fabbricazione disegnate dal codice, nello stile «Radici e Linfa», con la loro parte luminosa:
##   ceppo             ceppo d'albero-lanterna intagliato in piano, anelli, radici, un germoglio e un coltellino
##   baccello_ardente  baccello di pietra ardesia con la bocca di brace accesa e crepe che brillano
##   maglio            blocco di legnoferro con il maglio appoggiato e rune dei Seminatori turchesi
## Restituisce {img, glow} della misura della stazione (16 px per tessera).

const S := 16
const OUT := Color("#050c10")


static func make(id: String) -> Dictionary:
	var size: Array = StationsData.STATIONS[id]["size"]
	var w: int = size[0] * S
	var h: int = size[1] * S
	var im := Px.img(w, h)
	var gm := Px.img(w, h)
	match id:
		"ceppo":
			_ceppo(im, w, h)
		"baccello_ardente":
			_baccello(im, gm, w, h)
		"maglio":
			_maglio(im, gm, w, h)
	Px.outline(im, OUT)
	return {"img": im, "glow": gm}


static func _ceppo(im: Image, w: int, h: int) -> void:
	var bark := Px.pal(["#140c14", "#241624", "#362234", "#4c3246", "#62405a"])
	var ring := Px.pal(["#6a4a3a", "#9a7258", "#c49a74", "#e2c09a"])
	var cx := w / 2.0
	# tronco: un po' più largo alla base, corteccia a righe verticali
	for y in range(8, h - 1):
		var hw := 15.0 + (y - 8) * 0.25
		for x in range(int(cx - hw), int(cx + hw)):
			var k := (x - (cx - hw)) / (2.0 * hw)
			var c := bark[3] if k < 0.3 else (bark[2] if k < 0.75 else bark[1])
			if (x * 5 + y) % 7 == 0:
				c = bark[4]
			Px.put(im, x, y, c)
	# radici che escono ai lati
	for side in [-1.0, 1.0]:
		Px.line(im, Vector2(cx + side * 13.0, h - 5.0), Vector2(cx + side * 22.0, h - 1.0), 2, bark[2])
	# piano di lavoro: la sezione con gli anelli
	for y in range(3, 10):
		for x in range(int(cx - 16), int(cx + 16)):
			var d := Vector2((x + 0.5 - cx) / 16.0, (y + 0.5 - 6.5) / 3.6)
			if d.length() <= 1.0:
				Px.put(im, x, y, ring[3 - clampi(int(d.length() * 4.0), 0, 3)] if int(d.length() * 8.0) % 2 == 0 else ring[1])
	# un germoglio sul bordo e un coltellino piantato
	for q in [Vector2i(int(cx) + 12, 2), Vector2i(int(cx) + 13, 1), Vector2i(int(cx) + 11, 1)]:
		Px.put(im, q.x, q.y, Color("#3aa08a"))
	Px.line(im, Vector2(cx - 8.0, 6.0), Vector2(cx - 5.0, 1.0), 1, Color("#dce6f2"))
	Px.put(im, int(cx) - 9, 7, bark[4])


static func _baccello(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var brace := Px.pal(TileDefs.P_BRACE)
	var cx := w / 2.0
	# il baccello: un'ellisse appoggiata, un po' appuntita in alto
	for y in h:
		for x in w:
			var dy := (y + 0.5 - (h - 1.0)) / (h - 2.0)
			var dx := (x + 0.5 - cx) / (w * 0.47 * (1.0 - maxf(-dy - 0.55, 0.0) * 1.2))
			if dx * dx + dy * dy <= 1.0 and y < h:
				var t := 0.6 - dx * 0.3 + dy * 0.2
				var c := st[clampi(int(t * 5.0), 0, 4)]
				if absi(x - int(cx)) == int(abs(dy) * 6.0) + 6:
					c = st[0]
				Px.put(im, x, y, c)
	# la bocca di brace
	for y in range(h - 14, h - 2):
		for x in range(int(cx - 7), int(cx + 7)):
			var d := Vector2((x + 0.5 - cx) / 6.5, (y + 0.5 - (h - 7.0)) / 6.0)
			if d.length() <= 1.0:
				var c := brace[3] if d.length() < 0.4 else (brace[2] if d.length() < 0.75 else brace[1])
				Px.put(im, x, y, c)
				Px.put(gm, x, y, c)
	# crepe che brillano
	for crack in [[Vector2(cx - 10.0, 10.0), Vector2(cx - 6.0, 16.0)], [Vector2(cx + 9.0, 8.0), Vector2(cx + 12.0, 15.0)]]:
		Px.line(im, crack[0], crack[1], 1, brace[2])
		Px.line(gm, crack[0], crack[1], 1, brace[2])


static func _maglio(im: Image, gm: Image, w: int, h: int) -> void:
	var fe := Px.pal(TileDefs.P_LEGNOFERRO)
	var bark := Px.pal(["#241624", "#362234", "#4c3246"])
	var cx := w / 2.0
	# blocco di legnoferro: largo sopra, stretto al centro, piede largo
	for y in range(10, h - 1):
		var hw := 14.0 if y < 15 else (8.0 if y < h - 6 else 12.0)
		for x in range(int(cx - hw), int(cx + hw)):
			var c := fe[2] if x < cx else fe[1]
			if y == 10:
				c = fe[3]
			Px.put(im, x, y, c)
	# rune dei Seminatori
	var rune := Color("#5cc8cc")
	for q in [Vector2i(int(cx) - 4, 18), Vector2i(int(cx) - 3, 19), Vector2i(int(cx) - 4, 20), Vector2i(int(cx) + 2, 18), Vector2i(int(cx) + 3, 20), Vector2i(int(cx) + 2, 21)]:
		Px.put(im, q.x, q.y, rune)
		Px.put(gm, q.x, q.y, rune)
	# il maglio appoggiato: manico di radice e testa di legnoferro
	Px.line(im, Vector2(cx - 12.0, 9.0), Vector2(cx + 8.0, 2.0), 2, bark[2])
	for y in range(0, 8):
		for x in range(int(cx + 6), int(cx + 14)):
			Px.put(im, x, y, fe[3] if y < 2 else fe[2])
