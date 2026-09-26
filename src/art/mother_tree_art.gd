class_name MotherTreeArt
extends RefCounted
## L'Albero-Madre del Giardino (Roadmap 8), disegnato dal codice in cinque fasi (stazioni «albero_madre_0»…«_4»):
##   0  addormentato: tronco enorme e grigio, rami quasi spogli, due occhi chiusi nel legno
##   1  si scalda: le prime fronde turchesi, due venature di Linfa accese nel tronco
##   2  una chioma a salice, più venature, i primi baccelli d'ambra
##   3  chioma piena, baccelli, gli occhi socchiusi che brillano
##   4  sveglio: chioma grandissima e luminosa, occhi d'ambra aperti, un alone di fiori di Linfa
## Stile «Radici e Linfa»: le stesse fronde a salice degli alberi-lanterna, più grandi e più vecchie.


static func draw(stage: int, im: Image, gm: Image, w: int, h: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7719
	var life := clampf(stage / 4.0, 0.0, 1.0)
	var bark := Px.pal(["#1a1218", "#2e2230", "#443246", "#5c4660", "#7a6078"])
	var grey := Px.pal(["#1a1a1e", "#2c2c32", "#403e46", "#56545c", "#6e6c74"])
	var bk: Array[Color] = []
	for i in bark.size():
		bk.append(grey[i].lerp(bark[i], 0.35 + 0.65 * life))
	var frond := Px.pal(["#0b2e30", "#134a48", "#1f6a60", "#339280", "#62c4a4"])
	var dry := Px.pal(["#1c2626", "#2a3634", "#3c4a46", "#52625c", "#6a7a74"])
	var fr: Array[Color] = []
	for i in frond.size():
		fr.append(dry[i].lerp(frond[i], 0.3 + 0.7 * life))
	var linfa := Color("#6ff0d8")
	var amber := Px.pal(TileDefs.P_BRACE)
	var cx := w / 2.0
	var trunk_top := int(h * 0.42)
	# il tronco: largo e svasato in basso, con le radici che si allargano sul terreno
	var xs := PackedFloat32Array()
	xs.resize(h)
	for y in range(trunk_top, h):
		var t := float(y - trunk_top) / float(h - trunk_top)
		var x := cx + sin(t * 2.6 + 0.8) * 3.0
		xs[y] = x
		var hw := 9.0 + t * t * 16.0
		for xx in range(int(x - hw), int(x + hw) + 1):
			var k := (xx - (x - hw)) / (2.0 * hw)
			var c := bk[3] if k < 0.25 else (bk[2] if k < 0.6 else (bk[1] if k < 0.88 else bk[0]))
			if (y * 3 + xx * 7) % 11 == 0 or (xx + y / 3) % 9 == 0:
				c = bk[4] if k < 0.5 else bk[0]
			Px.put(im, xx, y, c)
	for r in 8:
		var dir := -1.0 if r % 2 == 0 else 1.0
		var reach := rng.randf_range(0.35, 0.5) * w
		Px.curve(im, Vector2(cx + dir * 10.0, h - 6.0), Vector2(cx + dir * reach * 0.6, h - 4.0), Vector2(cx + dir * reach, h - 1.0),
			3 if r < 4 else 2, bk[2 if r < 4 else 1])
	# i rami principali che salgono nella chioma
	var tips: Array[Vector2] = []
	for b in 5:
		var ang := -PI / 2.0 + (b - 2) * 0.42 + rng.randf_range(-0.1, 0.1)
		var from := Vector2(cx, trunk_top + 6)
		var length := h * rng.randf_range(0.2, 0.3) * (1.0 - 0.45 * life)   # sveglio: i rami restano dentro la chioma
		var to := from + Vector2(cos(ang), sin(ang)) * length
		Px.curve(im, from, (from + to) * 0.5 + Vector2(rng.randf_range(-5, 5), 0), to, 4 if b == 2 else 3, bk[2])
		tips.append(to)
		for s in 2:
			var a2 := ang + (s * 2 - 1) * rng.randf_range(0.35, 0.7)
			var t2 := to + Vector2(cos(a2), sin(a2)) * length * 0.45
			Px.line(im, to, t2, 2, bk[1])
			tips.append(t2)
	# la chioma: da poche fronde secche a un grande salice luminoso
	var cy := float(trunk_top) - h * 0.08
	var rx := w * (0.18 + 0.3 * life)
	var ry := h * (0.08 + 0.13 * life)
	if stage > 0:
		for y in range(int(cy - ry), int(cy + ry * 0.7)):
			for x in w:
				var dx := (x + 0.5 - cx) / rx
				var dy := (y + 0.5 - cy) / ry
				if dx * dx + dy * dy <= 1.0 and rng.randf() < 0.55 + 0.45 * life:
					var t := 0.62 - dx * 0.25 - dy * 0.45 + rng.randf_range(-0.12, 0.12)
					Px.put(im, x, y, fr[clampi(int(t * 5.0), 0, 4)])
	var strands: Array[Vector2] = []
	var n_str := 10 + int(60 * life)
	for s in n_str:
		var q: Vector2
		if stage == 0:
			q = tips[rng.randi_range(0, tips.size() - 1)]
		else:
			var a := rng.randf_range(-1.0, 1.0)
			q = Vector2(cx + a * rx * 0.95, cy + sqrt(maxf(1.0 - a * a, 0.0)) * ry * 0.5)
		var length := int(rng.randf_range(6.0, 16.0 + 40.0 * life))
		for i in length:
			var x := q.x + sin(i * 0.3 + s) * 0.9
			var y := q.y + i
			if y >= h - 8:
				break
			var c := fr[3] if i < length * 0.4 else (fr[2] if i < length * 0.8 else fr[1])
			Px.put(im, int(x), int(y), c)
			if i % 3 == 1 and stage > 0:
				Px.put(im, int(x) + (1 if s % 2 == 0 else -1), int(y), fr[4] if i < length * 0.3 else fr[2])
			if i == length / 2:
				strands.append(Vector2(x, y))
	Px.outline(im, Color("#05090c"))
	# le venature di Linfa nel tronco (una coppia per fase)
	for v in stage * 2:
		var x0 := cx + (v % 2 * 2 - 1) * rng.randf_range(2.0, 7.0)
		var y0 := rng.randi_range(trunk_top + 6, h - 20)
		for i in rng.randi_range(8, 18):
			var p := Vector2(x0 + sin(i * 0.7 + v) * 1.5, y0 + i)
			Px.put(im, int(p.x), int(p.y), linfa)
			Px.put(gm, int(p.x), int(p.y), linfa)
	# gli occhi nel legno: chiusi finché dorme, poi socchiusi, poi aperti d'ambra
	var ey := trunk_top + int((h - trunk_top) * 0.3)
	for side in [-1.0, 1.0]:
		var ex: float = cx + side * 5.0
		if stage < 3:
			Px.line(im, Vector2(ex - 2, ey), Vector2(ex + 2, ey + (1 if side < 0 else 0)), 1, bk[0])
		else:
			var col := amber[3] if stage == 4 else amber[2]
			for dx in range(-2, 3):
				for dy in range(0, 2 if stage == 3 else 3):
					Px.put(im, int(ex) + dx, ey + dy, col)
					Px.put(gm, int(ex) + dx, ey + dy, col)
	# i baccelli d'ambra (dalla fase 2) e l'alone di fiori di Linfa (sveglio)
	if stage >= 2:
		for k in mini(stage * 6, strands.size()):
			var q: Vector2 = strands[rng.randi_range(0, strands.size() - 1)]
			for dy in 3:
				for dx in 2:
					var c := amber[3] if dy == 0 else amber[2]
					Px.put(im, int(q.x) + dx, int(q.y) + dy, c)
					Px.put(gm, int(q.x) + dx, int(q.y) + dy, c)
	if stage == 4:
		for k in 24:
			var a := rng.randf() * TAU
			var q := Vector2(cx, cy) + Vector2(cos(a) * rx * rng.randf_range(0.7, 1.05), sin(a) * ry * rng.randf_range(0.7, 1.1))
			Px.put(im, int(q.x), int(q.y), Color("#e8fff8"))
			Px.put(gm, int(q.x), int(q.y), linfa)
