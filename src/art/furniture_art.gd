class_name FurnitureArt
extends RefCounted
## Porte e arredi della voce 35, disegnati dal codice nello stile «Radici e Linfa» (li chiama `WorkshopArt`):
##   porta / porta_aperta   assi di legno di lanterna legate con radici, maniglia a foglia; aperta si vede di taglio
##   lampada                un paralume a campanula su uno stelo di radice, acceso d'ambra
##   tavolo, sedia          legno di lanterna con le venature e le giunture di radice
##   letto                  un giaciglio di foglie grandi su un'intelaiatura di radici
##   radice_viandante       (voce 38) un arco di radici con un nodo di Linfa acceso

const WOOD := ["#241624", "#362234", "#4c3246", "#644652", "#86606e"]


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	var wd := Px.pal(WOOD)
	match id:
		"porta":
			for y in h:
				for x in range(2, w - 2):
					var c := wd[3] if (x - 2) % 4 != 0 else wd[1]
					if y % 12 == 0:
						c = wd[4]
					Px.put(im, x, y, c)
			for y in [6, h - 8]:
				Px.line(im, Vector2(2, y), Vector2(w - 3, y), 1, Color("#3aa08a"))
			Px.disc(im, w - 5.0, h / 2.0, 1.4, Color("#72d4b0"))
		"porta_aperta":
			for y in h:
				Px.put(im, 1, y, wd[2])
				Px.put(im, 2, y, wd[3])
				Px.put(im, 3, y, wd[1])
			Px.put(im, 3, h / 2, Color("#72d4b0"))
		"lampada":
			Px.line(im, Vector2(w / 2.0, h - 1.0), Vector2(w / 2.0, 12.0), 1, wd[3])
			Px.line(im, Vector2(w / 2.0 - 4.0, h - 1.0), Vector2(w / 2.0 + 4.0, h - 1.0), 1, wd[2])
			for y in range(3, 12):
				var hw := 2.0 + (y - 3) * 0.55
				for x in w:
					if absf(x + 0.5 - w / 2.0) <= hw:
						var c := Color("#ffc060") if y > 8 else Color("#e89a40")
						Px.put(im, x, y, c)
						Px.put(gm, x, y, c)
			Px.put(im, w / 2, 2, Color("#3aa08a"))
		"letto":
			for x in range(1, w - 1):
				Px.put(im, x, h - 6, wd[3])
				Px.put(im, x, h - 5, wd[2])
			for lx in [2, w - 3]:
				Px.line(im, Vector2(lx, h - 5.0), Vector2(lx, h - 1.0), 2, wd[1])
			Px.line(im, Vector2(2, h - 6.0), Vector2(2, h - 16.0), 2, wd[3])
			# le foglie del giaciglio, a scaglie
			var leaf := Px.pal(TileDefs.P_GRASS)
			for k in 7:
				var cx := 6.0 + k * 5.5
				for y in range(h - 12, h - 6):
					for x in range(int(cx) - 4, int(cx) + 4):
						var d := Vector2((x + 0.5 - cx) / 4.2, (y + 0.5 - (h - 8.0)) / 2.6)
						if d.length() <= 1.0:
							Px.put(im, x, y, leaf[3] if d.y < 0.0 else leaf[2])
			Px.disc(im, 7.0, h - 11.0, 3.0, Color("#d8944a"))
		"radice_viandante":
			# un arco di radici intrecciate piantato nella terra; al centro un nodo di Linfa che pulsa (parte luminosa)
			var rt := Px.pal(["#2a1a2c", "#3e2840", "#58384e", "#744c5e"])
			for side in [-1.0, 1.0]:
				for k in 3:
					var x0: float = w / 2.0 + side * (w / 2.0 - 3.0 - k)
					Px.curve(im, Vector2(x0, h - 1.0), Vector2(x0 + side * 2.0, 6.0), Vector2(w / 2.0, 3.0 + k), 2 if k == 0 else 1, rt[3 - k])
			for k in 5:
				Px.put(im, 4 + k * 6, h - 2, Color("#3aa08a"))
			var lf := Px.pal(["#1c6a60", "#3aa08a", "#8ef0d8", "#e0fff8"])
			for y in range(h / 2 - 6, h / 2 + 7):
				for x in w:
					var d := Vector2((x + 0.5 - w / 2.0) / 5.0, (y + 0.5 - h / 2.0) / 6.5).length()
					if d <= 1.0:
						var c := lf[3] if d < 0.3 else (lf[2] if d < 0.65 else lf[1])
						Px.put(im, x, y, c)
						Px.put(gm, x, y, c)
		"focolare":
			# un cerchio di pietre con il fuoco acceso e le braci
			var st := Px.pal(TileDefs.P_STONE)
			for k in 6:
				Px.disc(im, 4.0 + k * 4.8, h - 3.0, 2.6, st[1 + k % 3])
			var fire := Px.pal(["#9a2a1a", "#e0582a", "#ffb040", "#fff2a8"])
			var top := 8 if h > 16 else 1              # il focolare basso (una tessera): la fiamma parte più in alto
			for y in range(top, h - 4):
				var t := (y - float(top)) / (h - 4.0 - top)
				var hw := 1.0 + t * 7.0
				for x in w:
					var dx := absf(x + 0.5 - w / 2.0 + sin(y * 0.9) * 1.2)
					if dx <= hw:
						var c := fire[3] if dx < hw * 0.3 else (fire[2] if dx < hw * 0.6 else fire[1])
						Px.put(im, x, y, c)
						Px.put(gm, x, y, c)
		_:
			return false
	return true
