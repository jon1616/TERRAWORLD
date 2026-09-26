class_name BiomeDecorArt
extends RefCounted
## La vegetazione di ogni bioma di superficie (26 set 2026, richiesta dell'utente: «vegetazione in ogni bioma, ma l'erba
## sempre molto bassa»). Decorazioni da una cella (16×16) disegnate con la loro parte luminosa; l'erba non supera
## 4-5 pixel, i cespugli e le piante più alte stanno sotto la metà della cella. Le chiama `DecorPainter.decor` per gli
## id che non sono suoi (elenco in `TileDefs`):
##   33 cespuglio di bacche-lanterna (foresta)
##   34 erba di spore · 35 canne di palude · 36 funghetti a grappolo (paludi di spore)
##   37 erba dorata · 38 cardo d'ambra · 39 fiore di resina (distese d'ambra)
##   40 muschio gelato · 41 cristalli di brina · 42 cespuglio di brina (boschi di brina)
##   43 ciuffi bruciati · 44 braci nella cenere · 45 stecchi carbonizzati (cenerarie)
## Restituisce se disegnarci il contorno (le erbe no: resterebbero una riga nera).


static func draw(id: int, im: Image, gm: Image, rng: RandomNumberGenerator) -> Variant:
	match id:
		33:
			_bush(im, gm, rng, ["#0b2e30", "#134a48", "#1f6a60", "#339280"], Color("#ffb040"), 7.0)
			return true
		34:
			_tufts(im, rng, ["#3a1a4a", "#5a2a78", "#8a4ab0", "#b880e0"], 3.0)
			return false
		35:
			# canne di palude: steli sottili viola con la punta che brilla
			for k in 4:
				var x := 3 + k * 3 + rng.randi_range(0, 1)
				var hgt := rng.randi_range(5, 8)
				for s in hgt:
					Px.put(im, x + (1 if s > hgt - 3 and k % 2 == 0 else 0), 15 - s, Color("#4a2a60") if s < hgt - 2 else Color("#7a50a0"))
				Px.put(im, x, 15 - hgt, Color("#e0a8ff"))
				Px.put(gm, x, 15 - hgt, Color("#e0a8ff"))
			return false
		36:
			# funghetti a grappolo: cappellini viola accesi, bassi
			for q in [Vector2(5, 13), Vector2(8, 12), Vector2(11, 13.5), Vector2(7, 14)]:
				Px.put(im, int(q.x), int(q.y) + 1, Color("#c8b8d8"))
				Px.disc(im, q.x, q.y, 1.4, Color("#a060d8"))
				Px.put(im, int(q.x), int(q.y) - 1, Color("#e8c8ff"))
				Px.put(gm, int(q.x), int(q.y), Color("#c890ff"))
			return true
		37:
			_tufts(im, rng, ["#5a3a10", "#8a5a18", "#c08a28", "#f0c050"], 3.0)
			return false
		38:
			# cardo d'ambra: stelo con foglie a punta e un pennacchio d'ambra che brilla appena
			var st := Color("#6a4a18")
			Px.line(im, Vector2(8, 15), Vector2(8, 9), 1, st)
			Px.put(im, 7, 13, Color("#8a6a28"))
			Px.put(im, 9, 12, Color("#8a6a28"))
			Px.put(im, 6, 12, Color("#8a6a28"))
			Px.put(im, 10, 11, Color("#8a6a28"))
			Px.disc(im, 8, 8, 1.6, Color("#e89a30"))
			for q in [Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6), Vector2i(6, 7), Vector2i(10, 7)]:
				Px.put(im, q.x, q.y, Color("#ffd878"))
				Px.put(gm, q.x, q.y, Color("#ffc050"))
			return true
		39:
			# fiore di resina: rosetta bassa di petali arancio con una goccia accesa al centro
			for a in 5:
				var ang := a * TAU / 5.0
				Px.put(im, 8 + int(round(cos(ang) * 2.0)), 13 + int(round(sin(ang) * 1.2)), Color("#e07820"))
			Px.put(im, 8, 13, Color("#ffd060"))
			Px.put(gm, 8, 13, Color("#ffb040"))
			Px.put(im, 6, 15, Color("#5a6a20"))
			Px.put(im, 10, 15, Color("#5a6a20"))
			return true
		40:
			_tufts(im, rng, ["#0e2e3c", "#2e6e84", "#6ab0c8", "#e8f4ff"], 3.0)
			return false
		41:
			# cristalli di brina: tre punte di ghiaccio che spuntano, accese dentro
			for sh in [[8.0, 5.0, 1.4], [5.5, 3.0, 1.1], [10.5, 3.5, 1.1]]:
				var x0: float = sh[0]
				var hgt: float = sh[1]
				for y in int(hgt):
					var hw: float = sh[2] * (1.0 - y / hgt) + 0.3
					for x in range(int(x0 - hw), int(x0 + hw) + 1):
						var c := Color("#e8f8ff") if x < x0 else Color("#78c8f0")
						Px.put(im, x, 15 - y, c)
						if y > 0:
							Px.put(gm, x, 15 - y, Color("#a8ecff"))
			return true
		42:
			_bush(im, gm, rng, ["#0e2e3c", "#1c4a5e", "#2e6e84", "#5aa0b8"], Color("#d8f0ff"), 6.0)
			return true
		43:
			_tufts(im, rng, ["#161012", "#2a2226", "#4a4044", "#6a6064"], 2.5)
			return false
		44:
			# braci nella cenere: un mucchietto grigio con i tizzoni accesi
			for y in range(13, 16):
				for x in range(4, 13):
					if absf(x + 0.5 - 8.0) <= 4.5 - (15 - y) * 1.4:
						Px.put(im, x, y, Color("#4a4044") if (x + y) % 3 else Color("#6a6064"))
			for q in [Vector2i(6, 14), Vector2i(8, 13), Vector2i(10, 14), Vector2i(9, 15)]:
				Px.put(im, q.x, q.y, Color("#ff8a30"))
				Px.put(gm, q.x, q.y, Color("#ff7a20"))
			return true
		45:
			# stecchi carbonizzati: due rametti neri storti, uno con la punta ancora accesa
			Px.line(im, Vector2(6, 15), Vector2(4, 9), 1, Color("#1c1214"))
			Px.line(im, Vector2(5, 12), Vector2(3, 11), 1, Color("#1c1214"))
			Px.line(im, Vector2(10, 15), Vector2(11, 10), 1, Color("#2a1e20"))
			Px.put(im, 11, 9, Color("#ff9a40"))
			Px.put(gm, 11, 9, Color("#ff7a20"))
			return true
	return null


## Ciuffi d'erba bassissimi (al più `top` pixel più uno): tanti fili corti, i più alti con la punta chiara.
static func _tufts(im: Image, rng: RandomNumberGenerator, cols: Array, top: float) -> void:
	var p := Px.pal(cols)
	for k in 9:
		var x := rng.randi_range(1, 14)
		var hgt := int(rng.randf_range(1.0, top + 1.0))
		for s in hgt:
			Px.put(im, x + (1 if s == hgt - 1 and k % 3 == 0 else 0), 15 - s, p[clampi(1 + s, 1, 3)])
	for x in range(1, 15):
		if rng.randf() < 0.5:
			Px.put(im, x, 15, p[1])


## Un cespuglio basso: foglie a lobi (non una cupola liscia: sembrava un grumo con gli occhi), rametti che spuntano
## sotto, foglioline che sporgono dal bordo e tante bacche piccole sparse.
static func _bush(im: Image, gm: Image, rng: RandomNumberGenerator, cols: Array, berry: Color, hgt: float) -> void:
	var p := Px.pal(cols)
	var lobes: Array[Vector3] = []
	for k in 5:
		var lx := 3.5 + k * 2.2 + rng.randf_range(-0.8, 0.8)
		var r := rng.randf_range(2.2, 3.2) * (1.0 if k in [1, 2, 3] else 0.8)
		lobes.append(Vector3(lx, 16.0 - hgt + r + rng.randf_range(0.0, 1.5), r))
	for y in range(int(16 - hgt) - 1, 15):
		for x in range(1, 15):
			for l in lobes:
				var d := Vector2(x + 0.5 - l.x, y + 0.5 - l.y).length() / l.z
				if d <= 1.0:
					var t := 0.7 - (x + 0.5 - l.x) / l.z * 0.2 - (y + 0.5 - l.y) / l.z * 0.35 + rng.randf_range(-0.2, 0.2)
					Px.put(im, x, y, p[clampi(int(t * 4.0), 0, 3)])
					break
	# i rametti sotto e le foglioline che sporgono dal bordo
	for x in [5, 9, 11]:
		Px.put(im, x, 15, Color("#2a1a20"))
	for k in 6:
		var l: Vector3 = lobes[rng.randi_range(0, lobes.size() - 1)]
		var ang := rng.randf_range(PI * 1.1, PI * 1.9)
		Px.put(im, int(l.x + cos(ang) * (l.z + 0.8)), int(l.y + sin(ang) * (l.z + 0.8)), p[3])
	# bacche piccole, lontane tra loro (due vicine sembravano occhi)
	var placed: Array[Vector2i] = []
	for k in 30:
		if placed.size() >= 5:
			break
		var q := Vector2i(rng.randi_range(2, 13), rng.randi_range(int(16 - hgt) + 1, 14))
		if im.get_pixel(q.x, q.y).a < 0.5:
			continue
		var ok := true
		for o in placed:
			if absi(o.x - q.x) + absi(o.y - q.y) < 4:
				ok = false
		if ok:
			placed.append(q)
			Px.put(im, q.x, q.y, berry)
			Px.put(gm, q.x, q.y, berry)
