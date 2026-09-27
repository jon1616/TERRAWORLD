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
		"braciere", "braciere_acceso":
			_braciere(im, gm, id == "braciere_acceso")
		"leva", "leva_su", "leva_trappole", "leva_trappole_su":
			_leva(im, gm, id.ends_with("_su"))
		"piastra", "piastra_premuta":
			_piastra(im, gm, id == "piastra_premuta")
		"cristallo_eco", "cristallo_eco_desto":
			_cristallo(im, gm, id == "cristallo_eco_desto")
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


## Voce 71: il braciere, una coppa di pietra su un piede; acceso, una fiamma d'oro che fa luce.
static func _braciere(im: Image, gm: Image, lit: bool) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	for x in range(6, 10):
		for y in range(11, 16):
			Px.put(im, x, y, p[1] if x == 6 else p[2])
	for x in range(2, 14):
		for y in range(7, 11):
			var inside: bool = y == 7 and x > 2 and x < 13
			Px.put(im, x, y, p[0] if inside else (p[3] if y == 8 else p[2]))
	if lit:
		var fl := [Color("#ff9a3a"), Color("#ffd24a"), Color("#fff2a8")]
		for i in 3:
			for x in range(4 + i, 12 - i):
				for y in range(6 - i * 2 - 1, 7 - i * 2 + 1):
					if (x + y + i) % 3 != 0 or i == 2:
						Px.put(im, x, y, fl[i])
						Px.put(gm, x, y, fl[i])


## La leva di radice: una base di pietra e un manico di legno, in giù o in su, con la runa accesa se alzata.
static func _leva(im: Image, gm: Image, up: bool) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	var wd := Px.pal(TileDefs.P_ROOT)
	for x in range(3, 13):
		for y in range(12, 16):
			Px.put(im, x, y, p[2] if y > 12 else p[3])
	var tip := Vector2(12.0, 3.0) if up else Vector2(4.0, 5.0)
	Px.line(im, Vector2(8.0, 12.0), tip, 2, wd[2])
	Px.disc(im, tip.x, tip.y, 2.0, wd[3])
	var rune := Color("#6ff0b8") if up else Color("#3a5a54")
	Px.put(im, 8, 14, rune)
	if up:
		Px.put(gm, 8, 14, rune)


## La piastra: una lastra bassa sul pavimento con una runa; premuta si abbassa e la runa si accende.
static func _piastra(im: Image, gm: Image, pressed: bool) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	var top := 13 if pressed else 11
	for x in range(1, 15):
		for y in range(top, 16):
			Px.put(im, x, y, p[3] if y == top else p[2])
	var rune := Color("#ffd24a") if pressed else Color("#587270")
	for x in range(6, 10):
		Px.put(im, x, top + 1, rune)
		if pressed:
			Px.put(gm, x, top + 1, rune)


## Il cristallo d'eco: una punta di cristallo su un basamento; risvegliato brilla forte.
static func _cristallo(im: Image, gm: Image, awake: bool) -> void:
	var p := Px.pal(TileDefs.P_SEM)
	var c := Px.pal(TileDefs.P_CRYSTAL)
	for x in range(3, 13):
		for y in range(13, 16):
			Px.put(im, x, y, p[2])
	for y in range(2, 13):
		var hw := int((y - 2) / 2.2) + 1
		for x in range(8 - hw, 8 + hw):
			var col: Color = c[3] if x < 8 else c[2]
			if not awake:
				col = col.darkened(0.45)
			Px.put(im, x, y, col)
			if awake and (x + y) % 2 == 0:
				Px.put(gm, x, y, c[4])
