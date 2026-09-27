class_name ExtremeDecorArt
extends RefCounted
## La vegetazione delle terre estreme (voce 93), 16×16 come `BiomeDecorArt` (che la chiama dopo `TemperateDecorArt`).
## Restituisce true se va contornata, false se no, null se l'id non è di qui.
##   58-60  Deserti di vetro: ciuffi secchi, schegge di vetro che luccicano, ossa bianche
##   61-63  Ghiacciai di Linfa: brina a ciuffi, punte di ghiaccio con la Linfa, neve accumulata
##   64-66  Foreste pietrificate: muschio grigio, monconi di pietra, fiore di pietra con un filo di luce
##   67-69  Lande di brace viva: ciuffi carbonizzati, crepa di brace, fumarola


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		58:
			BiomeDecorArt._tufts(im, rng, ["#4a4028", "#6a5a38", "#9a8a58", "#c8b880"], 3.0)
			return false
		59:
			# schegge di vetro che spuntano dalla sabbia
			for k in 3:
				var x := 4 + k * 4
				var hgt := 3 + (k * 2) % 5
				Px.line(im, Vector2(x, 15), Vector2(x + 1, 15 - hgt), 1, Color("#c8f0e0"))
				Px.put(im, x + 1, 15 - hgt, Color("#ffffff"))
				Px.put(gm, x + 1, 15 - hgt, Color(0.6, 0.8, 0.7))
			return true
		60:
			# ossa bianche mezze sepolte
			Px.line(im, Vector2(3, 14), Vector2(12, 13), 1, Color("#e8e0c8"))
			Px.disc(im, 3, 14, 1.2, Color("#f4ecd8"))
			Px.disc(im, 12, 13, 1.2, Color("#f4ecd8"))
			return true
		61:
			BiomeDecorArt._tufts(im, rng, ["#2a5a70", "#4a8aa0", "#8ad0e0", "#e8ffff"], 2.0)
			return false
		62:
			# punte di ghiaccio con una goccia di Linfa
			for k in 2:
				var x := 5 + k * 6
				for t in 7 - k * 2:
					Px.put(im, x, 15 - t, Color("#8ad0e0") if t < 5 - k * 2 else Color("#e8ffff"))
					if t < 3:
						Px.put(im, x - 1, 15 - t, Color("#4a8aa0"))
				Px.put(im, x, 12, Color("#5cf0d8"))
				Px.put(gm, x, 12, Color(0.3, 0.8, 0.75))
			return true
		63:
			# neve accumulata: una cupoletta bianca
			for x in range(2, 14):
				var hgt := int(3.0 * sin((x - 2) / 12.0 * PI))
				for y in range(15 - hgt, 16):
					Px.put(im, x, y, Color("#e8ffff") if y == 15 - hgt else Color("#c0e4f0"))
			return true
		64:
			BiomeDecorArt._tufts(im, rng, ["#3e3e44", "#5e5e64", "#6a7a60", "#8a8a8a"], 2.0)
			return false
		65:
			# moncone di pietra: un ramo spezzato conficcato nel terreno
			Px.line(im, Vector2(7, 15), Vector2(9, 7), 2, Color("#5e5e64"))
			Px.line(im, Vector2(9, 9), Vector2(12, 7), 1, Color("#8a8a8a"))
			return true
		66:
			# fiore di pietra: petali grigi e un filo di luce al centro
			Px.line(im, Vector2(8, 15), Vector2(8, 9), 1, Color("#5e5e64"))
			for a in 5:
				var q := Vector2(8, 7) + Vector2(cos(a * TAU / 5.0), sin(a * TAU / 5.0)) * 2.0
				Px.put(im, int(q.x), int(q.y), Color("#b8b0a0"))
			Px.put(im, 8, 7, Color("#ffd24a"))
			Px.put(gm, 8, 7, Color(0.5, 0.4, 0.15))
			return true
		67:
			BiomeDecorArt._tufts(im, rng, ["#1a0c0a", "#2e1410", "#4a1e14", "#6a2a1a"], 2.0)
			return false
		68:
			# crepa di brace: una spaccatura nel terreno con la brace che brilla
			for x in range(3, 13):
				var y := 15 - int(abs(sin(x * 1.3)) * 1.5)
				Px.put(im, x, y, Color("#ffb040"))
				Px.put(gm, x, y, Color(0.9, 0.45, 0.1))
			return false
		69:
			# fumarola: un cono nero con il fumo rosso che sale
			for y in range(11, 16):
				var hw := (y - 10) * 0.8
				for x in range(int(8 - hw), int(8 + hw) + 1):
					Px.put(im, x, y, Color("#2e1410"))
			Px.put(im, 8, 10, Color("#ff7a3a"))
			Px.put(gm, 8, 10, Color(0.8, 0.3, 0.05))
			for k in 3:
				Px.put(im, 8 + (k % 2), 8 - k * 2, Color(0.6, 0.3, 0.25, 0.6))
			return true
	return null
