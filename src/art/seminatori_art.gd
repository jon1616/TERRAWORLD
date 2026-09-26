class_name SeminatoriArt
extends RefCounted
## I manufatti dei Seminatori (Roadmap 9): la stele con le righe di glifi accese (voce 68); poi meccanismi e luoghi.
## `draw` restituisce true se l'id è suo (lo chiama `StationArt.make`).


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"stele":
			_stele(im, gm, w, h)
		"leggio":
			_leggio(im, gm, w, h)
		_:
			return false
	return true


## Una lastra di pietra dei Seminatori, stretta in cima, con tre righe di glifi turchesi che brillano al buio.
static func _stele(im: Image, gm: Image, w: int, h: int) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	var glyph := Color("#6ff0b8")
	for y in h:
		var inset := 0 if y > 10 else (10 - y) / 3
		for x in range(2 + inset, w - 2 - inset):
			var edge := x == 2 + inset or x == w - 3 - inset
			var c: Color = p[1] if edge else p[2 + ((x * 7 + y * 3) % 11 == 0 as int)]
			if y >= h - 3:
				c = p[0] if y == h - 1 else p[1]
			Px.put(im, x, y, c)
	# i glifi: tre righe di segni brevi, diversi ogni volta
	for row in 3:
		var y := 10 + row * 9
		var x := 7
		var k := row * 5
		while x < w - 8:
			var len := 2 + (k * 3 + row) % 3
			for dx in len:
				Px.put(im, x + dx, y, glyph)
				Px.put(gm, x + dx, y, glyph)
			if k % 2 == 0:
				Px.put(im, x, y - 1, glyph)
				Px.put(gm, x, y - 1, glyph)
			else:
				Px.put(im, x + len - 1, y + 1, glyph)
				Px.put(gm, x + len - 1, y + 1, glyph)
			x += len + 2
			k += 1


## Il leggio delle cripte (voce 69): una colonnina di pietra dei Seminatori con un libro di foglie aperto che brilla.
static func _leggio(im: Image, gm: Image, w: int, h: int) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	var cx := w / 2
	for y in range(h - 3, h):
		for x in range(cx - 7, cx + 7):
			Px.put(im, x, y, p[1] if y == h - 1 else p[2])
	for y in range(12, h - 3):
		for x in range(cx - 3, cx + 3):
			Px.put(im, x, y, p[2] if x > cx - 3 else p[1])
	# il piano inclinato e il libro
	for i in 22:
		var x := cx - 11 + i
		var y := 12 - i / 5
		Px.put(im, x, y, p[3])
		Px.put(im, x, y + 1, p[1])
	var page := Color("#e8f4d8")
	var glow := Color("#ffd24a")
	for i in 16:
		var x := cx - 8 + i
		var y := 9 - i / 5
		Px.put(im, x, y, page)
		Px.put(im, x, y - 1, page if i != 8 else Color("#8a7a5a"))
		if i % 3 == 1:
			Px.put(im, x, y - 1, glow)
			Px.put(gm, x, y - 1, glow)
