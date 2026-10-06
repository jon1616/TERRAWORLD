class_name StyleShapes
extends RefCounted
## Le icone delle forme degli stili (Roadmap 40, voce 368), nello stile di `ItemIcons` e `WeaponShapes`: manici di
## radice, metallo della tavolozza `p` del materiale, perle d'ambra. `draw` restituisce false se la forma non è sua.

const S := 16


static func draw(shape: String, im: Image, p: Array[Color]) -> bool:
	var hi := p[p.size() - 1]
	var w := ItemIcons.pal("legno")
	match shape:
		"falcelunga":
			ItemIcons._handle(im, Vector2(2.0, 15.0), Vector2(8.0, 2.0))
			Px.curve(im, Vector2(8.0, 2.0), Vector2(15.5, 1.0), Vector2(15.0, 11.0), 2, p[1])
			Px.curve(im, Vector2(8.5, 1.5), Vector2(15.0, 0.5), Vector2(14.5, 10.5), 1, p[3])
			Px.put(im, 15, 11, hi)
		"manopole":
			for k in 2:
				var x0 := 3 + k * 6
				for y in range(5, 12):
					for x in range(x0, x0 + 5):
						Px.put(im, x, y, p[2] if y < 7 else p[1])
				for x in range(x0, x0 + 5):
					Px.put(im, x, 5, p[3])
				Px.put(im, x0 + 1, 6, hi)
				Px.line(im, Vector2(x0, 12.5), Vector2(x0 + 4, 12.5), 1, Color(ItemIcons.LEAF[1]))
		"egida":
			for y in range(1, 15):
				for x in range(2, 14):
					var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 6.0) / 9.0)
					if y < 7 or d.length() <= 1.0:
						Px.put(im, x, y, p[2] if x < 8 else p[1])
			Px.line(im, Vector2(8.0, 2.0), Vector2(8.0, 13.0), 1, p[3])
			ItemIcons._bead(im, 7, 6)
			Px.put(im, 4, 3, hi)
		"bipenne":
			ItemIcons._handle(im, Vector2(3.0, 15.0), Vector2(10.0, 2.0))
			for side in [-1, 1]:
				for k in 5:
					var c := Vector2(9.0, 4.0) + Vector2(side * (2.0 + k * 0.8), k * 0.2)
					Px.line(im, c + Vector2(0, -2.5 - k * 0.5), c + Vector2(0, 2.5 + k * 0.5), 1, p[1] if k < 4 else p[3])
			Px.put(im, 13, 2, hi)
		"randello":
			ItemIcons._handle(im, Vector2(2.0, 15.0), Vector2(7.0, 10.0))
			Px.line(im, Vector2(6.5, 10.5), Vector2(13.0, 3.0), 3, w[2])
			for q in [Vector2(9, 6), Vector2(11, 5), Vector2(12, 7), Vector2(10, 8), Vector2(13, 3)]:
				Px.put(im, int(q.x), int(q.y), p[2])
			Px.put(im, 12, 4, hi)
		"fionda":
			Px.line(im, Vector2(8.0, 15.0), Vector2(8.0, 9.0), 2, w[3])
			Px.line(im, Vector2(8.0, 9.0), Vector2(3.5, 3.0), 2, w[3])
			Px.line(im, Vector2(8.0, 9.0), Vector2(12.5, 3.0), 2, w[3])
			Px.put(im, 3, 3, p[2])
			Px.put(im, 13, 3, p[2])
			Px.curve(im, Vector2(3.5, 3.0), Vector2(8.0, 8.0), Vector2(12.5, 3.0), 1, Color("#e8dcc0"))
			Px.disc(im, 8.0, 5.5, 1.4, p[1])
			Px.put(im, 8, 5, hi)
		"cerbottana":
			Px.line(im, Vector2(1.0, 13.0), Vector2(15.0, 3.0), 2, p[1])
			Px.line(im, Vector2(1.5, 12.0), Vector2(14.5, 2.5), 1, p[3])
			Px.put(im, 6, 9, Color(ItemIcons.LEAF[1]))
			Px.put(im, 10, 6, Color(ItemIcons.LEAF[2]))
			Px.put(im, 15, 3, hi)
		"lanciaspore":
			Px.line(im, Vector2(2.0, 13.0), Vector2(10.0, 7.0), 3, p[1])
			Px.line(im, Vector2(2.5, 12.0), Vector2(9.5, 6.5), 1, p[3])
			for q in [Vector2(12.5, 4.0), Vector2(14.0, 7.5), Vector2(11.0, 2.0)]:
				Px.disc(im, q.x, q.y, 1.3, Color("#b88af0"))
			Px.line(im, Vector2(4.0, 13.0), Vector2(4.0, 15.0), 2, w[3])
		"tomo":
			for y in range(2, 14):
				for x in range(3, 13):
					Px.put(im, x, y, p[1] if x < 5 else p[2])
			for y in range(3, 13):
				Px.put(im, 12, y, Color("#f0e6d0"))
			Px.line(im, Vector2(4.5, 2.5), Vector2(4.5, 13.5), 1, p[3])
			Px.disc(im, 8.5, 7.5, 1.8, Color("#5cf0d8"))
			Px.put(im, 8, 7, Color.WHITE)
		"sfera":
			for y in S:
				for x in S:
					var d := Vector2(x + 0.5 - 8.0, y + 0.5 - 7.0)
					if d.length() <= 5.5:
						Px.put(im, x, y, p[3] if d.x + d.y < -3.0 else (p[2] if d.length() < 3.5 else p[1]))
			Px.line(im, Vector2(5.0, 14.5), Vector2(11.0, 14.5), 1, w[3])
			Px.put(im, 6, 4, Color.WHITE)
		"scettro":
			ItemIcons._handle(im, Vector2(3.0, 15.0), Vector2(10.0, 6.0))
			Px.curve(im, Vector2(10.0, 6.0), Vector2(15.0, 3.0), Vector2(12.0, 0.5), 1, p[2])
			Px.curve(im, Vector2(10.0, 6.0), Vector2(8.0, 1.0), Vector2(12.0, 0.5), 1, p[1])
			Px.disc(im, 11.5, 3.5, 1.5, Color("#c89aff"))
			Px.put(im, 11, 3, hi)
		"dischi":
			for q in [Vector2(5.0, 5.0), Vector2(11.0, 6.0), Vector2(7.5, 11.0)]:
				Px.disc(im, q.x, q.y, 3.0, p[1])
				Px.disc(im, q.x, q.y, 1.2, p[3])
				Px.put(im, int(q.x) - 1, int(q.y) - 2, hi)
		"girandola":
			Px.curve(im, Vector2(2.0, 13.0), Vector2(3.0, 3.0), Vector2(8.0, 3.0), 2, p[1])
			Px.curve(im, Vector2(8.0, 3.0), Vector2(13.0, 3.0), Vector2(14.0, 13.0), 2, p[2])
			Px.put(im, 8, 3, hi)
			ItemIcons._bead(im, 8, 4)
		"buccina":
			for k in 12:
				var t := k / 11.0
				var q := Vector2(2.0, 12.0).lerp(Vector2(13.0, 4.0), t)
				Px.stamp(im, q.x, q.y, maxi(int(round(1.0 + t * 3.0)), 1), p[1] if k % 3 else p[2])
			Px.disc(im, 13.0, 4.0, 2.5, p[3])
			Px.put(im, 13, 4, p[0])
		"flauto":
			Px.line(im, Vector2(2.0, 14.0), Vector2(14.0, 2.0), 2, w[2])
			for k in 4:
				var q := Vector2(5.0, 11.0).lerp(Vector2(11.0, 5.0), k / 3.0)
				Px.put(im, int(q.x), int(q.y), p[0])
			Px.line(im, Vector2(12.0, 4.0), Vector2(14.0, 2.0), 2, p[2])
			Px.put(im, 14, 2, hi)
		"tamburo":
			for y in range(4, 14):
				for x in range(2, 14):
					Px.put(im, x, y, w[2] if (x + y) % 4 else w[3])
			for x in range(2, 14):
				Px.put(im, x, 4, Color("#f0e6d0"))
				Px.put(im, x, 13, p[1])
				Px.put(im, x, 5, p[2])
			Px.line(im, Vector2(10.0, 3.0), Vector2(14.5, 0.5), 1, p[3])
			Px.put(im, 15, 0, hi)
		"virgulto":
			Px.line(im, Vector2(3.0, 15.0), Vector2(11.0, 3.0), 2, w[3])
			for q in [Vector2(6, 9), Vector2(9, 6), Vector2(12, 2)]:
				Px.put(im, int(q.x) + 1, int(q.y), Color(ItemIcons.LEAF[1]))
				Px.put(im, int(q.x) + 2, int(q.y) - 1, Color(ItemIcons.LEAF[2]))
			Px.disc(im, 11.5, 3.0, 1.4, p[2])
			Px.put(im, 11, 2, Color("#c8fff0"))
		"semetorre":
			Px.disc(im, 8.0, 10.0, 4.5, p[1])
			Px.disc(im, 8.0, 9.5, 2.8, p[2])
			for q in [Vector2(8, 2), Vector2(3, 5), Vector2(13, 5)]:
				Px.line(im, Vector2(8.0, 7.0), q, 1, p[3])
			Px.put(im, 7, 8, hi)
		"semebomba":
			Px.disc(im, 8.0, 9.0, 5.0, p[1])
			Px.disc(im, 7.0, 8.0, 3.0, p[2])
			Px.line(im, Vector2(9.0, 4.0), Vector2(12.0, 1.0), 1, Color(ItemIcons.LEAF[1]))
			Px.put(im, 12, 1, Color("#ffd040"))
			Px.put(im, 6, 7, hi)
		_:
			return HelmShapes.draw(shape, im, p)          # Roadmap 44: gli elmi degli stili
	return true
