class_name TemperateDecorArt
extends RefCounted
## La vegetazione delle terre temperate (voce 92): 16×16 come quella di `BiomeDecorArt` (che chiama questa quando
## l'id non è suo). Restituisce true se va contornata, false se no (le erbe basse), null se l'id non è di qui.
##   46-48  Prati di vento: erba argentata, soffioni che perdono semi luminosi, cardo del vento
##   49-51  Selve di corteccia rossa: felce di rame, foglie cadute, fungo a mensola
##   52-54  Colline dei cappelli: muschio bruno, funghetti a grappolo, cappellino che brilla
##   55-57  Torbiere di Linfa: giunchi, ninfea di Linfa, bolla di torba


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		46:
			BiomeDecorArt._tufts(im, rng, ["#2a4a44", "#4a7a6e", "#7ab8a4", "#c8ece0"], 5.0)
			return false
		47:
			# soffioni: steli sottili con la testa di semi che brillano
			for k in 2:
				var x := 5 + k * 6
				var top := 5 + k * 2
				Px.line(im, Vector2(x, 15), Vector2(x, top), 1, Color("#4a7a6e"))
				for a in 6:
					var q := Vector2(x, top) + Vector2(cos(a * TAU / 6.0), sin(a * TAU / 6.0)) * 2.0
					Px.put(im, int(q.x), int(q.y), Color("#f0fff8"))
				Px.put(gm, x, top, Color(0.7, 0.9, 0.85))
			return true
		48:
			# cardo del vento: foglie a punta e un fiore azzurro
			Px.line(im, Vector2(8, 15), Vector2(8, 7), 1, Color("#2e5a50"))
			for s in [-1, 1]:
				Px.line(im, Vector2(8, 12), Vector2(8 + s * 4, 9), 1, Color("#4a8878"))
				Px.line(im, Vector2(8, 14), Vector2(8 + s * 5, 12), 1, Color("#4a8878"))
			Px.disc(im, 8, 5, 2.2, Color("#8ab8ff"))
			Px.put(gm, 8, 5, Color(0.4, 0.55, 0.9))
			return true
		49:
			# felce di rame: fronde arricciate arancio
			for s in [-1.0, 1.0]:
				Px.curve(im, Vector2(8, 15), Vector2(8 + s * 2.0, 9), Vector2(8 + s * 6.0, 6), 1, Color("#b0561e"))
				for k in 3:
					Px.put(im, int(8 + s * (2 + k * 1.5)), 10 - k, Color("#e0823a"))
			return true
		50:
			# foglie cadute di rame sul terreno
			for k in 6:
				var q := Vector2(rng.randf_range(1, 14), rng.randf_range(12, 15))
				Px.put(im, int(q.x), int(q.y), Color("#d8802a") if k % 2 else Color("#9a3420"))
				Px.put(im, int(q.x) + 1, int(q.y), Color("#a0521a"))
			return false
		51:
			# fungo a mensola: tre mezzelune bianche una sopra l'altra, il bordo acceso
			for k in 3:
				var y := 14 - k * 3
				for x in range(4 + k, 12 - k):
					Px.put(im, x, y, Color("#e8dcc4"))
				Px.put(im, 4 + k, y - 1, Color("#ffd8a0"))
				Px.put(gm, 4 + k, y - 1, Color(0.5, 0.35, 0.15))
			return true
		52:
			BiomeDecorArt._tufts(im, rng, ["#3a2a1a", "#5a4028", "#7a5a3a", "#a88460"], 3.0)
			return false
		53:
			# funghetti a grappolo, cappelli arancio
			for k in 3:
				var x := 4 + k * 4
				var hgt := 4 + (k % 2) * 3
				Px.line(im, Vector2(x, 15), Vector2(x, 15 - hgt), 1, Color("#d8c4a4"))
				Px.disc(im, x, 15 - hgt, 2.0, Color("#e0823a"))
				Px.put(im, x - 1, 15 - hgt - 1, Color("#ffc080"))
			return true
		54:
			# cappellino che brilla: un fungo solo con le lamelle accese
			Px.line(im, Vector2(8, 15), Vector2(8, 9), 2, Color("#d8c4a4"))
			Px.disc(im, 8, 8, 4.0, Color("#b0561e"))
			for x in range(5, 12):
				Px.put(im, x, 10, Color("#ffd8a0"))
				Px.put(gm, x, 10, Color(0.6, 0.45, 0.2))
			return true
		55:
			# giunchi della torba: steli dritti e scuri con la spiga
			for k in 4:
				var x := 3 + k * 3
				Px.line(im, Vector2(x, 15), Vector2(x + (k % 2), 4 + k % 3), 1, Color("#3a4a2c"))
				Px.put(im, x + (k % 2), 4 + k % 3, Color("#6a4a2a"))
			return true
		56:
			# ninfea di Linfa: foglia tonda e un fiore turchese acceso
			for x in range(2, 14):
				Px.put(im, x, 15, Color("#1e5240"))
				Px.put(im, x, 14, Color("#2e7a5e") if x % 3 else Color("#1e5240"))
			Px.disc(im, 8, 12, 2.2, Color("#5cf0d8"))
			Px.put(im, 8, 11, Color("#e8fff8"))
			Px.disc(gm, 8, 12, 2.0, Color(0.3, 0.9, 0.8))
			return true
		57:
			# bolla di torba: una cupoletta lucida con un riflesso
			Px.disc(im, 8, 13, 3.2, Color("#3a4a2c"))
			Px.disc(im, 8, 13, 2.2, Color("#566a3e"))
			Px.put(im, 7, 11, Color("#c8e0a0"))
			return true
	return null
