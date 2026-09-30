class_name PodArt
extends RefCounted
## I baccelli dormienti (voce 301, dati in `PodsData`), 16×16 come la vegetazione: appoggiati al pavimento, con una
## piccola parte luminosa perché nel buio si notino da vicino. Li chiama `SkyDecorArt` per gli id che non sono suoi.
##   92 baccello dormiente · 93 nido di radice · 94 urna dei Seminatori · 95 geode dormiente · 96 bozzolo di Linfa
##   97 ceppo cavo


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		92:
			# un baccello verde-turchese coricato, con la cucitura che brilla
			for y in range(8, 16):
				for x in range(2, 14):
					var d := Vector2((x + 0.5 - 8.0) / 6.0, (y + 0.5 - 12.0) / 3.8)
					if d.length() <= 1.0:
						var t := 0.5 - d.y * 0.35 - d.x * 0.1
						Px.put(im, x, y, [Color("#1e4a40"), Color("#2c6a58"), Color("#3e8a70"), Color("#5aac88")][clampi(int(t * 4.0), 0, 3)])
			for x in range(4, 12):
				Px.put(im, x, 11, Color("#8ef0d8"))
				Px.put(gm, x, 11, Color(0.2, 0.6, 0.5))
			Px.line(im, Vector2(13, 12), Vector2(15, 9), 1, Color("#3a2630"))
			return true
		93:
			# un nido di radici intrecciate
			for k in 7:
				var a := rng.randf() * PI
				var c := Vector2(8, 12)
				Px.curve(im, c + Vector2(cos(a), sin(a) * 0.5) * -6.0, c + Vector2(rng.randf_range(-2, 2), -5),
					c + Vector2(cos(a), sin(a) * 0.5) * 6.0, 1, [Color("#4a2c22"), Color("#6a4232"), Color("#8a5a40")][k % 3])
			Px.disc(im, 8, 13, 2.4, Color("#2a1a18"))
			# dentro, un uovo pallido (due puntini sembravano gli occhi di una creatura)
			for q in [Vector2i(8, 11), Vector2i(7, 12), Vector2i(8, 12), Vector2i(9, 12), Vector2i(7, 13), Vector2i(8, 13), Vector2i(9, 13)]:
				Px.put(im, q.x, q.y, Color("#e8dcb8") if q.x != 9 else Color("#b8a888"))
			return true
		94:
			# un'urna d'argilla dei Seminatori con una runa d'ambra
			for y in range(6, 16):
				var half := 2.0 + sin((y - 6) / 10.0 * PI) * 3.5
				for x in range(int(8 - half), int(8 + half) + 1):
					Px.put(im, x, y, Color("#7a4a34") if x < 8 else Color("#9a6040"))
			for x in range(6, 11):
				Px.put(im, x, 5, Color("#5a3424"))
			for q in [Vector2i(8, 9), Vector2i(7, 10), Vector2i(9, 10), Vector2i(8, 11), Vector2i(8, 12)]:
				Px.put(im, q.x, q.y, Color("#ffc860"))
				Px.put(gm, q.x, q.y, Color(0.7, 0.45, 0.1))
			return true
		95:
			# un sasso a uovo con una crepa da cui brilla il cristallo
			for y in range(7, 16):
				for x in range(3, 13):
					var d := Vector2((x + 0.5 - 8.0) / 5.0, (y + 0.5 - 11.5) / 4.6)
					if d.length() <= 1.0:
						Px.put(im, x, y, [Color("#3a4058"), Color("#50587a"), Color("#687298")][clampi(int((0.6 - d.y * 0.3 - d.x * 0.2) * 3.0), 0, 2)])
			for q in [Vector2i(8, 8), Vector2i(8, 9), Vector2i(9, 10), Vector2i(8, 11), Vector2i(9, 12), Vector2i(9, 13)]:
				Px.put(im, q.x, q.y, Color("#d890ff"))
				Px.put(gm, q.x, q.y, Color(0.5, 0.25, 0.7))
			return true
		96:
			# un bozzolo di Linfa, chiaro, appeso a un filo al pavimento
			for y in range(5, 16):
				for x in range(4, 12):
					var d := Vector2((x + 0.5 - 8.0) / 3.6, (y + 0.5 - 10.5) / 5.4)
					if d.length() <= 1.0:
						var c := Color("#2a8a90") if d.length() > 0.7 else Color("#5ad0c8")
						Px.put(im, x, y, c)
						if d.length() < 0.45:
							Px.put(gm, x, y, Color(0.15, 0.55, 0.55))
			for y in range(6, 15, 3):
				Px.put(im, 6, y, Color("#b8fff0"))
			return true
		97:
			# un ceppo cavo, con il buio dentro e un germoglio sopra
			for y in range(8, 16):
				for x in range(3, 13):
					Px.put(im, x, y, Color("#4a2e2a") if (x + y) % 3 else Color("#5e3c34"))
			for x in range(3, 13):
				Px.put(im, x, 8, Color("#7a5444"))
			Px.disc(im, 8, 12, 2.2, Color("#120a0c"))
			Px.line(im, Vector2(11, 8), Vector2(12, 5), 1, Color("#3aa08a"))
			Px.put(im, 12, 4, Color("#8ef0d8"))
			return true
	return null
