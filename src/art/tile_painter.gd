class_name TilePainter
extends RefCounted
## Disegna le tessere del mondo nel codice: trame, bordi arrotondati, erba, minerali, cristalli, pareti di fondo e
## decorazioni. Tutto finisce in un atlante più una seconda immagine con le sole parti luminose (cristalli, funghi),
## disegnata sopra il buio. I dati (tipi, tavolozze) stanno in `TileDefs`.

const VARIANTS := 3
const COLS := 48            # 16 combinazioni di bordi × 3 varianti
const WALL_ROW := 7
const DECOR_ROW := 8
const ROWS := 9


## Coordinate nell'atlante di una tessera con i suoi bordi.
static func tile_coords(type: int, mask: int, variant: int) -> Vector2i:
	return Vector2i(mask * VARIANTS + variant, type - 1)


static func wall_coords(kind: int, variant: int) -> Vector2i:
	return Vector2i((kind - 1) * VARIANTS + variant, WALL_ROW)


static func decor_coords(id: int) -> Vector2i:
	return Vector2i(id - 1, DECOR_ROW)


static func _grid(rng: RandomNumberGenerator, n: int) -> PackedFloat32Array:
	var g := PackedFloat32Array()
	g.resize((n + 1) * (n + 1))
	for k in g.size():
		g[k] = rng.randf()
	for k in n + 1:
		g[k * (n + 1) + n] = g[k * (n + 1)]
		g[n * (n + 1) + k] = g[k]
	return g


static func _samp(g: PackedFloat32Array, n: int, x: int, y: int) -> float:
	var fx := (x + 0.5) / 16.0 * n
	var fy := (y + 0.5) / 16.0 * n
	var ix := mini(int(fx), n - 1)
	var iy := mini(int(fy), n - 1)
	var tx := fx - ix
	var ty := fy - iy
	tx = tx * tx * (3.0 - 2.0 * tx)
	ty = ty * ty * (3.0 - 2.0 * ty)
	var a := g[iy * (n + 1) + ix]
	var b := g[iy * (n + 1) + ix + 1]
	var c := g[(iy + 1) * (n + 1) + ix]
	var d := g[(iy + 1) * (n + 1) + ix + 1]
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)


## Trama interna di una tessera (senza bordi): colori e maschera delle parti luminose.
static func base(type: int, variant: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = type * 7919 + variant * 104729 + 12345
	var col := PackedColorArray()
	col.resize(256)
	var glow := PackedByteArray()
	glow.resize(256)
	var g4 := _grid(rng, 4)
	var g8 := _grid(rng, 8)
	var stone := Px.pal(TileDefs.P_STONE)
	var p: Array[Color] = stone
	if type == TileDefs.DIRT or type == TileDefs.GRASS:
		p = Px.pal(TileDefs.P_DIRT)
	elif type == TileDefs.CRYSTAL:
		var dark: Array[Color] = []
		for c in stone:
			dark.append(Px.sh(c, 0.72))
		p = dark
	for y in 16:
		for x in 16:
			var v := 0.5 * _samp(g4, 4, x, y) + 0.5 * _samp(g8, 8, x, y) + rng.randf_range(-0.1, 0.1)
			v = clampf((v - 0.2) / 0.6, 0.0, 0.999)
			col[y * 16 + x] = p[int(v * p.size())]
	if type == TileDefs.DIRT or type == TileDefs.GRASS:
		# sassolini e puntini scuri
		for k in 3:
			var px := rng.randi_range(1, 13)
			var py := rng.randi_range(1, 13)
			col[py * 16 + px] = stone[3]
			col[py * 16 + px + 1] = stone[2]
			if rng.randf() < 0.5:
				col[(py + 1) * 16 + px] = stone[1]
				col[(py + 1) * 16 + px + 1] = stone[1]
		for k in 4:
			col[rng.randi_range(0, 255)] = p[0]
	else:
		# una crepa ogni tanto
		if rng.randf() < 0.6:
			var cx := rng.randi_range(3, 12)
			var cy := rng.randi_range(2, 8)
			for k in rng.randi_range(4, 7):
				if cx < 0 or cx > 15 or cy > 15:
					break
				col[cy * 16 + cx] = p[0]
				if cy + 1 < 16:
					col[(cy + 1) * 16 + cx] = p[mini(3, p.size() - 1)]
				cx += rng.randi_range(-1, 1)
				cy += 1 if rng.randf() < 0.6 else 0
	if type == TileDefs.COPPER or type == TileDefs.IRON or type == TileDefs.GOLD:
		var op := TileDefs.palette_of(type)
		var nuggets: Array[Vector3] = []
		for k in rng.randi_range(3, 4):
			nuggets.append(Vector3(rng.randf_range(3.0, 13.0), rng.randf_range(3.0, 13.0), rng.randf_range(1.5, 2.4)))
		for pass_n in 2:
			for n in nuggets:
				for y in 16:
					for x in 16:
						var dx := x + 0.5 - n.x
						var dy := y + 0.5 - n.y
						var d := sqrt(dx * dx + dy * dy)
						if pass_n == 0 and d <= n.z + 0.9:
							col[y * 16 + x] = stone[0]
						elif pass_n == 1 and d <= n.z:
							var t := 0.55 + (-dx - dy) / (2.5 * n.z)
							col[y * 16 + x] = op[clampi(int(t * op.size()), 0, op.size() - 1)]
	if type == TileDefs.CRYSTAL:
		var cp := Px.pal(TileDefs.P_CRYSTAL)
		var shards: Array[Array] = []
		for k in rng.randi_range(2, 3):
			var b := Vector2(rng.randf_range(3.0, 13.0), rng.randf_range(7.0, 14.0))
			var ang := rng.randf_range(-2.4, -0.7)
			var tip := b + Vector2(cos(ang), sin(ang)) * rng.randf_range(6.0, 10.0)
			shards.append([b, tip])
		for pass_n in 2:
			for s in shards:
				var a: Vector2 = s[0]
				var t_end: Vector2 = s[1]
				var ab := t_end - a
				for y in 16:
					for x in 16:
						var pnt := Vector2(x + 0.5, y + 0.5)
						var t := clampf((pnt - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
						var q := a + ab * t
						var dist := pnt.distance_to(q)
						var half := lerpf(2.4, 0.4, t)
						var i := y * 16 + x
						if pass_n == 0 and dist <= half + 0.9 and glow[i] == 0:
							col[i] = cp[0]
						elif pass_n == 1 and dist <= half:
							var side := ab.x * (pnt.y - a.y) - ab.y * (pnt.x - a.x)
							var c: Color = cp[3] if side < 0.0 else cp[2]
							if dist < 0.5:
								c = cp[3]
							if t > 0.78:
								c = cp[4]
							col[i] = c
							glow[i] = 1
	return {"col": col, "glow": glow}


## Tessera con i bordi: `mask` dice quali lati toccano l'aria (1 sopra, 2 destra, 4 sotto, 8 sinistra).
static func paint(img: Image, glow_img: Image, ox: int, oy: int, type: int, variant: int, mask: int, b: Dictionary) -> void:
	var col: PackedColorArray = b["col"]
	var gl: PackedByteArray = b["glow"]
	var up := (mask & 1) != 0
	var right := (mask & 2) != 0
	var down := (mask & 4) != 0
	var left := (mask & 8) != 0
	var gp := Px.pal(TileDefs.P_GRASS)
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 31 + mask * 7 + 99
	var gdepth := PackedInt32Array()
	for x in 16:
		gdepth.append(3 + rng.randi_range(0, 2))
	for y in 16:
		for x in 16:
			var d := 99
			if up:
				d = mini(d, y)
			if down:
				d = mini(d, 15 - y)
			if left:
				d = mini(d, x)
			if right:
				d = mini(d, 15 - x)
			if up and left:
				d = mini(d, x + y - 2)
			if up and right:
				d = mini(d, (15 - x) + y - 2)
			if down and left:
				d = mini(d, x + (15 - y) - 2)
			if down and right:
				d = mini(d, (15 - x) + (15 - y) - 2)
			if d < 0:
				continue
			var i := y * 16 + x
			var c: Color = col[i]
			var grass := false
			if type == TileDefs.GRASS:
				if up and y < gdepth[x]:
					grass = true
					c = gp[clampi(4 - y + ((x + variant) % 2), 1, 4)]
					if y == gdepth[x] - 1:
						c = gp[1]
				elif (left and x < 2 and y < 6 + (x + variant) % 3) or (right and x > 13 and y < 6 + (x + variant) % 3):
					grass = true
					c = gp[2] if (x + y) % 3 != 0 else gp[3]
			if d == 0:
				c = gp[0] if grass else Px.sh(c, 0.42)
			elif d == 1:
				if up and y == 1:
					c = Px.sh(c, 1.18)
				else:
					c = Px.sh(c, 0.8)
			img.set_pixel(ox + x, oy + y, c)
			if gl[i] != 0 and d > 0:
				glow_img.set_pixel(ox + x, oy + y, c)


static func paint_wall(img: Image, ox: int, oy: int, kind: int, variant: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = kind * 555 + variant * 77 + 3
	var src := Px.pal(TileDefs.P_DIRT) if kind == TileDefs.WALL_DIRT else Px.pal(TileDefs.P_STONE)
	var p: Array[Color] = []
	for c in src:
		p.append(Px.sh(c, 0.5))
	var g4 := _grid(rng, 4)
	var g8 := _grid(rng, 8)
	for y in 16:
		for x in 16:
			var v := 0.45 * _samp(g4, 4, x, y) + 0.55 * _samp(g8, 8, x, y) + rng.randf_range(-0.08, 0.08)
			v = clampf((v - 0.2) / 0.6, 0.0, 0.999)
			img.set_pixel(ox + x, oy + y, p[int(v * (p.size() - 1))])
	if kind == TileDefs.WALL_STONE:
		# fessure tra le lastre di roccia
		var yy := rng.randi_range(5, 10)
		for x in 16:
			if rng.randf() < 0.85:
				img.set_pixel(ox + x, oy + yy, Px.sh(p[0], 0.7))
			if rng.randf() < 0.3:
				yy = clampi(yy + rng.randi_range(-1, 1), 3, 12)


static func paint_decor(img: Image, glow_img: Image, ox: int, oy: int, id: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = id * 1013 + 5
	var im := Px.img(16, 16)
	var gm := Px.img(16, 16)
	var gp := Px.pal(TileDefs.P_GRASS)
	var outl := true
	if id >= 1 and id <= 6:
		# ciuffi d'erba (anche sotto i fiori)
		outl = false
		for k in 4 + id % 3 * 2:
			var bx := rng.randi_range(2, 13)
			var hgt := rng.randi_range(3, 5 + (id % 3) * 3)
			var lean := rng.randf_range(-1.5, 1.5)
			for s in hgt:
				var x := bx + int(round(lean * s / float(hgt)))
				var c := gp[clampi(1 + s * 4 / hgt, 1, 4)]
				Px.put(im, x, 15 - s, c)
	if id >= 4 and id <= 6:
		var heads := [["#8a1a2a", "#e0404f", "#ffc8c8"], ["#a07808", "#f2cc2a", "#fff6c0"], ["#2a36a8", "#5a7aff", "#e0e8ff"]]
		var fp := Px.pal(heads[id - 4])
		var fx := 7 + id % 2
		Px.line(im, Vector2(fx, 15), Vector2(fx, 8), 1, gp[2])
		Px.put(im, fx - 1, 12, gp[3])
		Px.put(im, fx + 1, 11, gp[3])
		for o in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, -1), Vector2i(1, 1)]:
			Px.put(im, fx + o.x, 6 + o.y, fp[1])
		Px.put(im, fx + 1, 5, fp[0])
		Px.put(im, fx - 1, 7, fp[0])
		Px.put(im, fx, 6, fp[2])
		outl = false
	elif id == 7 or id == 8:
		var sp := Px.pal(TileDefs.P_STONE)
		var rx := 4.0 if id == 7 else 2.6
		var cx := 8.0 if id == 7 else 6.0
		for y in range(10, 16):
			for x in 16:
				var dx := (x + 0.5 - cx) / rx
				var dy := (y + 0.5 - 15.0) / 3.0
				if dx * dx + dy * dy <= 1.0:
					var t := 0.5 - dx * 0.35 - dy * 0.5
					Px.put(im, x, y, sp[clampi(int(t * 5.0), 1, 4)])
	elif id == 9 or id == 10:
		var stem := Color.html("#e8dcc8") if id == 9 else Color.html("#9ad8e8")
		var cap := Px.pal(["#8a1e1e", "#c83a3a", "#ff7060"]) if id == 9 else Px.pal(["#0a6a9a", "#28c0ff", "#b0f4ff"])
		Px.line(im, Vector2(8, 15), Vector2(8, 11), 2, stem)
		for y in range(6, 11):
			for x in 16:
				var dx := (x + 0.5 - 8.5) / 4.6
				var dy := (y + 0.5 - 10.5) / 4.0
				if dx * dx + dy * dy <= 1.0:
					var t := 0.55 - dx * 0.3 - dy * 0.5
					var c: Color = cap[clampi(int(t * 3.0), 0, 2)]
					Px.put(im, x, y, c)
					if id == 10:
						Px.put(gm, x, y, c)
		if id == 9:
			Px.put(im, 6, 8, Color.html("#fff4e0"))
			Px.put(im, 9, 7, Color.html("#fff4e0"))
			Px.put(im, 11, 9, Color.html("#fff4e0"))
	if outl:
		Px.outline(im, Color(0.08, 0.07, 0.1, 0.9))
	img.blit_rect(im, Rect2i(0, 0, 16, 16), Vector2i(ox, oy))
	glow_img.blit_rect(gm, Rect2i(0, 0, 16, 16), Vector2i(ox, oy))


static func build() -> Dictionary:
	var img := Px.img(COLS * 16, ROWS * 16)
	var glow := Px.img(COLS * 16, ROWS * 16)
	for t in range(1, TileDefs.TYPES + 1):
		for v in VARIANTS:
			var b := base(t, v)
			for m in 16:
				paint(img, glow, (m * VARIANTS + v) * 16, (t - 1) * 16, t, v, m, b)
	for k in [TileDefs.WALL_DIRT, TileDefs.WALL_STONE]:
		for v in VARIANTS:
			paint_wall(img, ((k - 1) * VARIANTS + v) * 16, WALL_ROW * 16, k, v)
	for d in range(1, TileDefs.DECOR_COUNT + 1):
		paint_decor(img, glow, (d - 1) * 16, DECOR_ROW * 16, d)
	return {"img": img, "glow": glow}
