class_name RareDecorArt
extends RefCounted
## La vegetazione della voce 94 (sottosuolo e biomi rari), 16×16 come `BiomeDecorArt` (che la chiama per ultima).
## Restituisce true se va contornata, false se no, null se l'id non è di qui.
##   70-71  Giungle di radici: felce gigante, bulbo di radice che brilla
##   72     Caverne del cristallo cantante: germoglio di cristallo
##   73     Laghi sotterranei: fungo d'acqua che brilla
##   74-75  Prati iridati: erba iridata, fiore dell'iride
##   76-77  Radure stellari: erba stellata, stella caduta
##   78-79  Boschi dei sussurri: muschio d'argento, runa che germoglia


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		70:
			for s in [-1.0, 1.0, 0.0]:
				Px.curve(im, Vector2(8, 15), Vector2(8 + s * 3.0, 8), Vector2(8 + s * 7.0, 3 + absf(s) * 2.0), 1, Color("#3a8040"))
				Px.put(im, int(8 + s * 7.0), int(3 + absf(s) * 2.0), Color("#7ac070"))
			return true
		71:
			Px.line(im, Vector2(8, 15), Vector2(8, 11), 1, Color("#4a2c1a"))
			Px.disc(im, 8, 9, 2.6, Color("#22582a"))
			Px.disc(im, 8, 9, 1.4, Color("#9fe070"))
			Px.put(gm, 8, 9, Color(0.4, 0.8, 0.3))
			return true
		72:
			for k in 3:
				var x := 5 + k * 3
				var hgt := 3 + (k % 2) * 3
				Px.line(im, Vector2(x, 15), Vector2(x + (k - 1), 15 - hgt), 1, Color("#b880e0"))
				Px.put(im, x + (k - 1), 15 - hgt, Color("#f0d8ff"))
				Px.put(gm, x + (k - 1), 15 - hgt, Color(0.5, 0.3, 0.7))
			return true
		73:
			Px.line(im, Vector2(8, 15), Vector2(8, 10), 1, Color("#8a9a88"))
			Px.disc(im, 8, 9, 2.4, Color("#1f8a9a"))
			Px.put(im, 7, 8, Color("#b8f4f0"))
			Px.put(gm, 8, 9, Color(0.2, 0.6, 0.65))
			return true
		74:
			var p := ["#8a60a8", "#e0a0d8", "#ffe0a0", "#a0e0ff"]
			for k in 9:
				var x := rng.randi_range(1, 14)
				var hgt := rng.randi_range(1, 4)
				for s in hgt:
					Px.put(im, x, 15 - s, Color(p[(x + s) % p.size()]))
			return false
		75:
			Px.line(im, Vector2(8, 15), Vector2(8, 8), 1, Color("#4a3a6a"))
			var cols := ["#ff9ad8", "#ffe070", "#8ef0d8", "#a0b0ff", "#ffb070"]
			for a in 5:
				var q := Vector2(8, 6) + Vector2(cos(a * TAU / 5.0), sin(a * TAU / 5.0)) * 2.2
				Px.put(im, int(q.x), int(q.y), Color(cols[a]))
			Px.put(gm, 8, 6, Color(0.5, 0.35, 0.5))
			return true
		76:
			BiomeDecorArt._tufts(im, rng, ["#141e50", "#243470", "#4a60a8", "#c0d0ff"], 3.0)
			if rng.randf() < 0.7:
				var x := rng.randi_range(3, 12)
				Px.put(im, x, 13, Color("#ffffff"))
				Px.put(gm, x, 13, Color(0.6, 0.6, 0.8))
			return false
		77:
			for q in [Vector2i(8, 11), Vector2i(7, 12), Vector2i(9, 12), Vector2i(8, 13), Vector2i(8, 12), Vector2i(6, 12), Vector2i(10, 12), Vector2i(8, 10), Vector2i(8, 14)]:
				Px.put(im, q.x, q.y, Color("#fff0a0"))
				Px.put(gm, q.x, q.y, Color(0.9, 0.85, 0.5))
			return true
		78:
			BiomeDecorArt._tufts(im, rng, ["#2e4444", "#4a6a68", "#8ab0a8", "#e0fff4"], 2.0)
			return false
		79:
			Px.line(im, Vector2(8, 15), Vector2(8, 9), 1, Color("#4a6a68"))
			for q in [Vector2i(7, 8), Vector2i(9, 8), Vector2i(8, 7), Vector2i(6, 10), Vector2i(10, 10)]:
				Px.put(im, q.x, q.y, Color("#6ff0b8"))
				Px.put(gm, q.x, q.y, Color(0.3, 0.8, 0.6))
			return true
	return null
