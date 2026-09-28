class_name SkyDecorArt
extends RefCounted
## La vegetazione del cielo (Roadmap 16, voce 156), 16×16 come `BiomeDecorArt` (la chiama `RareDecorArt` per ultima).
## Restituisce true se va contornata, false se no, null se l'id non è di qui.
##   80-81  Radici sospese: felce d'aria, bulbo di cielo che brilla
##   82-83  Mare di nuvole: ciuffo di nuvola, fiore di pioggia
##   84-85  Giardini del vento: erba dorata piegata, fiore-girandola
##   86-87  Scogliere di cristallo: germoglio di cristallo celeste, eco di cristallo
##   88-89  Nidi di tempesta: ciuffo scuro con scintille, roccia carica
##   90-91  Il Firmamento: erba di stelle, stella caduta


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		80:
			# felce d'aria: fronde lunghe e sottili che si piegano verso l'alto, a volte una radichetta che pende
			for s in [-1.0, -0.4, 0.4, 1.0]:
				var tip := Vector2(8 + s * 6.0, 4 + absf(s) * 3.0)
				Px.curve(im, Vector2(8, 15), Vector2(8 + s * 2.0, 9), tip, 1, Color("#2f8a7c"))
				Px.put(im, int(tip.x), int(tip.y), Color("#a8f0d8"))
			return true
		81:
			# bulbo di cielo: una goccia turchese su un gambo, che brilla
			Px.line(im, Vector2(8, 15), Vector2(8, 10), 1, Color("#1f5c58"))
			Px.disc(im, 8, 8, 2.8, Color("#2f8a7c"))
			Px.disc(im, 8, 8, 1.6, Color("#a8f0d8"))
			Px.put(gm, 8, 8, Color(0.3, 0.8, 0.7))
			Px.put(gm, 7, 7, Color(0.2, 0.6, 0.55))
			return true
		82:
			# ciuffo di nuvola: batuffoli bianchi bassi
			for k in 3:
				var x := 4 + k * 4 + rng.randi_range(-1, 1)
				Px.disc(im, x, 13, 2.2, Color("#e4eefa"))
				Px.put(im, x - 1, 12, Color("#ffffff"))
			return false
		83:
			# fiore di pioggia: campanella azzurra che pende, con una goccia
			Px.curve(im, Vector2(8, 15), Vector2(6, 8), Vector2(10, 6), 1, Color("#6a7a98"))
			Px.disc(im, 10, 7, 1.8, Color("#78c0ff"))
			Px.put(im, 10, 9, Color("#d8f0ff"))
			Px.put(im, 10, 11, Color("#9ad8ff"))
			Px.put(gm, 10, 7, Color(0.25, 0.4, 0.6))
			return true
		84:
			# erba dorata piegata dal vento (tutta verso destra)
			for k in 10:
				var x := rng.randi_range(0, 12)
				var hgt := rng.randi_range(3, 7)
				for s in hgt:
					var bend := int(s * s / 10.0)
					Px.put(im, x + bend, 15 - s, Color("#e0c050") if s < hgt - 1 else Color("#fff0a0"))
			return false
		85:
			# fiore-girandola: quattro petali a spirale su un gambo alto
			Px.line(im, Vector2(8, 15), Vector2(8, 7), 1, Color("#7a6020"))
			var cols := ["#ff9a4a", "#ffe070", "#8ef0d8", "#ff6a78"]
			for a in 4:
				var d := Vector2(cos(a * TAU / 4.0 + 0.4), sin(a * TAU / 4.0 + 0.4))
				Px.put(im, int(8 + d.x * 2.0), int(6 + d.y * 2.0), Color(cols[a]))
				Px.put(im, int(8 + d.x * 3.0 + d.y), int(6 + d.y * 3.0 - d.x), Color(cols[a]))
			Px.put(im, 8, 6, Color("#fff0a0"))
			Px.put(gm, 8, 6, Color(0.4, 0.35, 0.15))
			return true
		86:
			# germoglio di cristallo celeste: tre punte
			for k in 3:
				var x := 5 + k * 3
				var hgt := 4 + (k % 2) * 4
				Px.line(im, Vector2(x, 15), Vector2(x, 15 - hgt), 1, Color("#4a90c8"))
				Px.put(im, x, 15 - hgt, Color("#e0f6ff"))
				Px.put(gm, x, 15 - hgt, Color(0.4, 0.7, 1.0))
			return true
		87:
			# eco di cristallo: un disco sottile che risuona
			Px.disc(im, 8, 11, 3.2, Color("#2a6090"))
			Px.disc(im, 8, 11, 2.0, Color("#8ac8f0"))
			Px.put(im, 8, 11, Color("#e0f6ff"))
			Px.put(gm, 8, 11, Color(0.5, 0.75, 1.0))
			Px.put(gm, 7, 10, Color(0.3, 0.5, 0.8))
			return true
		88:
			# ciuffo di tempesta: erba scura con qualche scintilla
			BiomeDecorArt._tufts(im, rng, ["#1a1e2e", "#2c3248", "#434c68", "#a0b0d8"], 3.0)
			if rng.randf() < 0.6:
				var x := rng.randi_range(3, 12)
				Px.put(im, x, 11, Color("#fffac0"))
				Px.put(gm, x, 11, Color(0.6, 0.6, 0.9))
			return false
		89:
			# roccia carica: un sasso scuro con una vena di luce
			Px.disc(im, 8, 13, 3.4, Color("#2c3248"))
			Px.disc(im, 7, 12, 2.0, Color("#434c68"))
			Px.line(im, Vector2(6, 11), Vector2(10, 14), 1, Color("#c0d0ff"))
			Px.put(gm, 8, 12, Color(0.45, 0.5, 0.9))
			return true
		90:
			# erba di stelle: fili blu con punte bianche
			BiomeDecorArt._tufts(im, rng, ["#101430", "#1c2450", "#2e3a78", "#c8d0ff"], 3.0)
			for k in 2:
				var x := rng.randi_range(2, 13)
				Px.put(im, x, 12, Color("#ffffff"))
				Px.put(gm, x, 12, Color(0.5, 0.5, 0.8))
			return false
		91:
			# stella caduta: una piccola stella a cinque punte, dorata
			for q in [Vector2i(8, 10), Vector2i(8, 11), Vector2i(8, 12), Vector2i(7, 12), Vector2i(9, 12), Vector2i(6, 12),
					Vector2i(10, 12), Vector2i(8, 13), Vector2i(7, 14), Vector2i(9, 14)]:
				Px.put(im, q.x, q.y, Color("#ffe890"))
				Px.put(gm, q.x, q.y, Color(0.9, 0.8, 0.4))
			return true
	return null
