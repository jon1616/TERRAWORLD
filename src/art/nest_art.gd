class_name NestArt
extends RefCounted
## I nidi e le tane delle famiglie (voce 58), disegnati dal codice come le altre stazioni: {img, glow} della misura della
## stazione. Le chiama `WorkshopArt.draw` per gli id che cominciano con «nido_».
##   nido_erba       un cerchio di fili d'erba e rametti intrecciati, con due uova chiare
##   nido_tana       una buca scura nella terra, con il mucchietto di terra smossa e due occhi che luccicano
##   nido_alveare    un tronco cavo con le celle di cera accese
##   nido_formicaio  un monticello di terra e resina con i buchi e le formiche


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"nido_erba":
			var g := Px.pal(TileDefs.P_GRASS)
			var r := Px.pal(TileDefs.P_RADICE)
			for x in range(1, w - 1):
				var y := h - 3 + int(absf(x - w / 2.0) / 5.0)
				Px.line(im, Vector2(x, y), Vector2(x, h - 1), 1, r[2] if x % 3 else g[2])
			for k in 6:
				Px.line(im, Vector2(2.0 + k * 5.0, h - 2.0), Vector2(5.0 + k * 5.0, h - 6.0), 1, g[3] if k % 2 else r[3])
			Px.disc(im, w / 2.0 - 3.0, h - 5.0, 2.2, Color("#e8e0c8"))
			Px.disc(im, w / 2.0 + 2.0, h - 5.5, 2.0, Color("#d8d0b0"))
		"nido_tana":
			var s := Px.pal(TileDefs.P_DIRT)
			for y in h:
				for x in w:
					var d := Vector2((x + 0.5 - w / 2.0) / (w * 0.5), (y + 0.5 - h) / (h * 0.9))
					if d.length() <= 1.0:
						Px.put(im, x, y, s[2] if d.length() > 0.62 else Color("#0a060a"))
			Px.put(im, w / 2 - 2, h - 5, Color("#ffd24a"))
			Px.put(im, w / 2 + 1, h - 5, Color("#ffd24a"))
			Px.put(gm, w / 2 - 2, h - 5, Color("#ffd24a"))
			Px.put(gm, w / 2 + 1, h - 5, Color("#ffd24a"))
		"nido_alveare":
			var b := Px.pal(TileDefs.P_RADICE)
			var a := Px.pal(TileDefs.P_AMBRA)
			for y in range(2, h):
				for x in range(4, w - 4):
					Px.put(im, x, y, b[2] if (x + y) % 5 else b[3])
			for k in 6:
				var q := Vector2(9.0 + (k % 3) * 7.0, 8.0 + (k / 3) * 8.0)
				Px.disc(im, q.x, q.y, 2.2, a[2])
				Px.disc(gm, q.x, q.y, 1.6, a[3])
		"nido_formicaio":
			var s := Px.pal(TileDefs.P_DIRT)
			var rs := Px.pal(["#5a2a0c", "#9a4a14", "#d8782a", "#ffc070"])
			for y in h:
				for x in w:
					var d := Vector2((x + 0.5 - w / 2.0) / (w * 0.5), (y + 0.5 - h) / (h * 0.95))
					if d.length() <= 1.0:
						Px.put(im, x, y, rs[2] if (x * 7 + y * 3) % 11 == 0 else s[2 if d.y > -0.5 else 3])
			for q in [Vector2i(w / 2, 3), Vector2i(w / 2 - 6, h - 5), Vector2i(w / 2 + 7, h - 4)]:
				Px.put(im, q.x, q.y, Color("#0a060a"))
		_:
			return false
	return true
