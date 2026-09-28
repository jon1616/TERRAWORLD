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
		"nido_tetto":
			# voce 146: un nido di rametti sul tetto, con un uovo chiaro
			var r2 := Px.pal(TileDefs.P_RADICE)
			for k in 9:
				Px.line(im, Vector2(1.0 + k * 3.0, h - 1.0), Vector2(4.0 + k * 3.0, h - 5.0 + (k % 2)), 1, r2[2 + k % 2])
			Px.line(im, Vector2(2.0, h - 4.0), Vector2(w - 3.0, h - 4.0), 1, r2[1])
			Px.disc(im, w / 2.0, h - 6.0, 2.2, Color("#e8f0f0"))
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
		"recinto":
			# voce 59: due pali di radice, due radici intrecciate come staccionata, la mangiatoia a conca in mezzo
			var r := Px.pal(TileDefs.P_RADICE)
			var g := Px.pal(TileDefs.P_GRASS)
			for px in [2, w - 3]:
				Px.line(im, Vector2(px, 4), Vector2(px, h - 1), 2, r[2])
				Px.put(im, px, 3, r[3])
			for k in 2:
				var y0 := 8.0 + k * 8.0
				Px.curve(im, Vector2(2, y0), Vector2(w / 2.0, y0 + 3.0), Vector2(w - 3, y0), 1, r[3 - k])
			for y in range(h - 8, h - 2):
				for x in range(w / 2 - 9, w / 2 + 10):
					var d := Vector2((x + 0.5 - w / 2.0) / 9.5, (y + 0.5 - (h - 8.0)) / 6.0)
					if d.length() <= 1.0 and d.y >= 0.0:
						Px.put(im, x, y, r[1] if d.length() > 0.75 else g[2])
		"incubatrice":
			# voce 59: un cuscino di muschio con tre uova tiepide che brillano appena
			var g := Px.pal(TileDefs.P_GRASS)
			for y in range(h / 2, h):
				for x in w:
					var d := Vector2((x + 0.5 - w / 2.0) / (w * 0.5), (y + 0.5 - h) / (h * 0.5))
					if d.length() <= 1.0:
						Px.put(im, x, y, g[1] if (x + y) % 4 else g[2])
			for q in [Vector2(w / 2.0 - 7, h - 11.0), Vector2(w / 2.0, h - 13.0), Vector2(w / 2.0 + 7, h - 11.0)]:
				Px.disc(im, q.x, q.y, 3.4, Color("#e8e0c8"))
				Px.put(im, int(q.x) - 1, int(q.y) - 1, Color("#fff8e0"))
				Px.disc(gm, q.x, q.y, 2.0, Color(0.5, 0.9, 0.7))
		_:
			return false
	return true
