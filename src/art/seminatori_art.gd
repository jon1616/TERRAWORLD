class_name SeminatoriArt
extends RefCounted
## I manufatti dei Seminatori (Roadmap 9): la stele con le righe di glifi accese (voce 68); poi meccanismi e luoghi.
## `draw` restituisce true se l'id è suo (lo chiama `StationArt.make`).


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"stele":
			_stele(im, gm, w, h)
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
