class_name EncounterArt
extends RefCounted
## I luoghi dei piccoli incontri (voce 303, dati in `EncountersData`), disegnati come le stazioni (una cella = 16 pixel):
##   zaino_perduto  2×1  uno zaino di cuoio appoggiato a poche ossa, con la lanterna spenta
##   osso_tana      2×1  un mucchio d'ossa e di rami, con un luccichio dentro
##   vena_madre     1×2  un cristallo che spunta dalla roccia e pulsa
##   fungo_re       2×2  un fungo enorme con il cappello a lamelle luminose


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"zaino_perduto":
			_bones(im, 2, h - 2, 12)
			# lo zaino: un sacco di cuoio con la patta e una fibbia
			for y in range(h - 12, h):
				for x in range(12, 25):
					var d := Vector2((x + 0.5 - 18.5) / 6.5, (y + 0.5 - (h - 6.0)) / 6.2)
					if d.length() <= 1.0:
						Px.put(im, x, y, Color("#6a4028") if d.x < 0.2 else Color("#825234"))
			for x in range(13, 24):
				Px.put(im, x, h - 10, Color("#4a2a1a"))
			Px.put(im, 18, h - 8, Color("#e0b060"))
			Px.put(gm, 18, h - 8, Color(0.6, 0.45, 0.15))
			# la lanterna di Tessa, spenta, accanto
			Px.line(im, Vector2(27, h - 7), Vector2(27, h - 1), 2, Color("#3a2a20"))
			Px.put(im, 27, h - 5, Color("#ffcc70"))
			Px.put(gm, 27, h - 5, Color(0.5, 0.35, 0.1))
			return true
		"osso_tana":
			for k in 9:
				var x0 := 3 + k * 3
				var y0 := h - 1 - (k % 3)
				Px.line(im, Vector2(x0, y0), Vector2(x0 + 5, y0 - 4 + (k % 2) * 3), 1,
					[Color("#e8dcc0"), Color("#c8b898"), Color("#6a4a32")][k % 3])
			Px.disc(im, 16, h - 4, 3.0, Color("#d8ccb0"))
			Px.put(im, 15, h - 5, Color("#1a1210"))
			Px.put(im, 17, h - 5, Color("#1a1210"))
			Px.put(im, 22, h - 3, Color("#ffd060"))
			Px.put(gm, 22, h - 3, Color(0.7, 0.5, 0.1))
			return true
		"vena_madre":
			for y in range(h - 6, h):
				for x in range(1, w - 1):
					Px.put(im, x, y, Color("#50587a") if (x + y) % 3 else Color("#3a4058"))
			for y in range(6, h - 4):
				var half := 1.0 + (y - 6) * 0.22
				for x in range(int(8 - half), int(8 + half) + 1):
					var c := Color("#9ae8ff") if x < 8 else Color("#5ab0d8")
					Px.put(im, x, y, c)
					if absf(x - 8.0) < half * 0.5:
						Px.put(gm, x, y, Color(0.3, 0.6, 0.8))
			Px.put(im, 8, 5, Color("#e8ffff"))
			Px.put(gm, 8, 5, Color(0.6, 0.9, 1.0))
			return true
		"fungo_re":
			# il gambo
			for y in range(h - 14, h):
				for x in range(13, 19):
					Px.put(im, x, y, Color("#d8c8a8") if x < 17 else Color("#b0a080"))
			# il cappello: una cupola larga con le lamelle accese sotto
			for y in range(4, h - 13):
				for x in range(1, w - 1):
					var d := Vector2((x + 0.5 - 16.0) / 15.0, (y + 0.5 - (h - 13.0)) / 14.0)
					if d.length() <= 1.0 and y < h - 13:
						Px.put(im, x, y, Color("#2a6a78") if d.y < -0.5 else Color("#3a8a98"))
			for x in range(3, w - 3, 2):
				Px.put(im, x, h - 14, Color("#b8fff0"))
				Px.put(gm, x, h - 14, Color(0.3, 0.8, 0.75))
			for q in [Vector2i(9, 9), Vector2i(20, 7), Vector2i(14, 12), Vector2i(25, 11)]:
				Px.put(im, q.x, q.y, Color("#c8fff8"))
				Px.put(gm, q.x, q.y, Color(0.3, 0.7, 0.7))
			return true
	return false


static func _bones(im: Image, x0: int, y: int, n: int) -> void:
	for k in n / 3:
		Px.line(im, Vector2(x0 + k * 3, y), Vector2(x0 + k * 3 + 3, y - 1 - k % 2), 1, Color("#d8ccb0"))
