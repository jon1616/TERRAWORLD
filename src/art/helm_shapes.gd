class_name HelmShapes
extends RefCounted
## Le icone degli elmi degli stili (Roadmap 44, voce 389), nello stile di `ItemIcons`: metallo della tavolozza `p` del
## materiale, foglie e perle d'ambra. Ogni stile ha una sagoma che si riconosce anche piccola. `draw` restituisce false
## se la forma non è sua (la chiama `StyleShapes`).


static func draw(shape: String, im: Image, p: Array[Color]) -> bool:
	var hi := p[p.size() - 1]
	var leaf := ItemIcons.LEAF
	match shape:
		"celata":
			# un elmo chiuso, alto, con la fessura degli occhi e il cimiero di foglia
			for y in range(3, 14):
				for x in range(3, 13):
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 8.5) / 6.0)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if x < 8 else p[1])
			Px.line(im, Vector2(4.0, 8.0), Vector2(12.0, 8.0), 1, p[0])
			Px.line(im, Vector2(8.0, 9.0), Vector2(8.0, 13.0), 1, p[3])
			Px.line(im, Vector2(8.0, 3.0), Vector2(5.0, 0.5), 1, Color(leaf[1]))
			Px.put(im, 4, 0, Color(leaf[2]))
			Px.put(im, 5, 4, hi)
		"cappuccio_mira":
			# un cappuccio a punta, con l'orlo di metallo e la lente sull'occhio
			for y in range(2, 14):
				var hw := clampi((y - 1) / 2 + 1, 1, 5)
				for x in range(8 - hw, 8 + hw):
					Px.put(im, x, y, Color(ItemIcons.pal("seta")[1]) if x < 8 else Color(ItemIcons.pal("seta")[0]))
			Px.line(im, Vector2(3.0, 13.0), Vector2(12.0, 13.0), 1, p[2])
			Px.disc(im, 9.5, 9.0, 1.6, p[1])
			Px.put(im, 9, 8, hi)
		"tiara":
			# una corona sottile con tre punte e il cristallo di Linfa
			Px.line(im, Vector2(2.0, 11.0), Vector2(13.0, 11.0), 2, p[1])
			Px.line(im, Vector2(2.0, 10.0), Vector2(13.0, 10.0), 1, p[2])
			for q in [Vector2(3, 6), Vector2(8, 3), Vector2(13, 6)]:
				Px.line(im, Vector2(q.x, 10.0), q, 1, p[2])
				Px.put(im, int(q.x), int(q.y), hi)
			Px.disc(im, 8.0, 7.5, 1.6, Color("#5cf0d8"))
			Px.put(im, 7, 7, Color("#c8fff0"))
		"maschera":
			# il volto di una bestia: orecchie, occhi vuoti, muso
			for y in range(4, 13):
				for x in range(3, 13):
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 8.0) / 4.5)
					if d.length() <= 1.0:
						Px.put(im, x, y, p[2] if y < 8 else p[1])
			for side in [-1, 1]:
				Px.line(im, Vector2(8.0 + side * 4.0, 5.0), Vector2(8.0 + side * 5.5, 1.5), 2, p[1])
				Px.put(im, 8 + side * 2 - (1 if side < 0 else 0), 7, Color("#1a0e14"))
			Px.line(im, Vector2(7.0, 11.0), Vector2(9.0, 11.0), 1, p[3])
			Px.put(im, 6, 5, hi)
		"benda":
			# una fascia sulla fronte con i due lembi al vento e il nodo
			Px.line(im, Vector2(2.0, 7.0), Vector2(12.0, 7.0), 3, p[1])
			Px.line(im, Vector2(2.0, 6.0), Vector2(12.0, 6.0), 1, p[2])
			Px.line(im, Vector2(12.0, 7.0), Vector2(15.0, 11.0), 2, p[1])
			Px.line(im, Vector2(12.0, 8.0), Vector2(14.0, 14.0), 1, p[2])
			Px.disc(im, 12.0, 7.0, 1.5, p[3])
			Px.put(im, 4, 6, hi)
		"ghirlanda":
			# un cerchio di foglie di metallo, con una nota
			for k in 10:
				var a := TAU * k / 10.0
				var q := Vector2(8.0, 9.0) + Vector2(cos(a) * 5.0, sin(a) * 3.0)
				Px.put(im, int(q.x), int(q.y), p[2] if k % 2 == 0 else Color(leaf[1]))
				Px.put(im, int(q.x), int(q.y) - 1, p[1] if k % 2 == 0 else Color(leaf[2]))
			Px.line(im, Vector2(11.0, 1.0), Vector2(11.0, 5.0), 1, p[3])
			Px.disc(im, 10.0, 5.0, 1.0, p[3])
			Px.put(im, 12, 1, hi)
		"velo":
			# un velo che scende ai lati, con la goccia di Rugiada sulla fronte
			for y in range(3, 15):
				var hw := mini(3 + (y - 3) / 2, 6)
				for x in range(8 - hw, 8 + hw):
					if y < 6 or absi(x - 8) >= hw - 2:
						Px.put(im, x, y, Color(0.85, 0.95, 0.9, 0.75) if x < 8 else Color(0.7, 0.85, 0.8, 0.75))
			Px.line(im, Vector2(4.0, 4.0), Vector2(12.0, 4.0), 1, p[2])
			Px.disc(im, 8.0, 6.0, 1.3, Color("#9fe070"))
			Px.put(im, 8, 5, hi)
		"cappello_radice":
			# un cappello a tesa larga da cui spunta un germoglio
			Px.line(im, Vector2(1.0, 11.0), Vector2(14.0, 11.0), 2, p[1])
			for y in range(6, 11):
				for x in range(4, 12):
					Px.put(im, x, y, p[2] if x < 8 else p[1])
			Px.line(im, Vector2(4.0, 9.0), Vector2(11.0, 9.0), 1, Color(ItemIcons.pal("legno")[2]))
			Px.line(im, Vector2(8.0, 6.0), Vector2(8.0, 2.0), 1, Color(leaf[1]))
			Px.put(im, 9, 2, Color(leaf[2]))
			Px.put(im, 7, 3, Color(leaf[2]))
			Px.put(im, 5, 7, hi)
		_:
			return false
	return true
