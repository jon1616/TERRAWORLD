class_name TerrainPainter
extends RefCounted
## Terreno dai contorni morbidi con la «doppia griglia»: le tessere logiche restano quadrate (scavo, collisioni), ma si
## disegna una seconda griglia spostata di mezza tessera. Ogni cella disegnata tocca i centri di 4 tessere e, a seconda di
## quali sono piene (16 combinazioni), traccia una forma con i bordi curvi. Il bordo è un po' irregolare (rumore legato
## alla posizione nel mondo) e la trama continua senza cuciture da una cella all'altra (trame da 64×64 che si ripetono).
##
## Atlante: una riga per strato di `TileDefs.TERRAIN_LAYERS`; in ogni riga 16 varianti (la posizione dentro la trama da
## 64) × 16 combinazioni di angoli.

const S := 16
const TEX := 64
const REP := 4                         # TEX / S
const VARIANTS := 16                   # REP × REP


static func coords(layer: int, variant: int, mask: int) -> Vector2i:
	return Vector2i(variant * 16 + mask, layer)


## Variante di una cella: quale pezzo della trama da 64 le tocca, così la trama continua da una cella all'altra.
static func variant_of(x: int, y: int) -> int:
	return posmod(x, REP) + REP * posmod(y, REP)


static func build() -> Dictionary:
	var layers: Array = TileDefs.TERRAIN_LAYERS
	var img := Px.img(VARIANTS * 16 * S, layers.size() * S)
	var glow := Px.img(VARIANTS * 16 * S, layers.size() * S)
	var jitter := wrap_noise(TEX, 8, 991)
	for li in layers.size():
		var L: Dictionary = layers[li]
		var tex := material(String(L["id"]), Px.pal(L["pal"]), 100 + li)
		var gl: Image = glow if L.get("glow", false) else null
		for v in VARIANTS:
			for k in range(1, 16):
				_shape(img, gl, (v * 16 + k) * S, li * S, v % REP, v / REP, k, tex, jitter, li == 0)
	return {"img": img, "glow": glow}


# ---------------------------------------------------------------- forme

## Valore «pieno» dentro la cella: interpolazione morbida tra i 4 angoli (1 sopra-sinistra, 2 sopra-destra,
## 4 sotto-sinistra, 8 sotto-destra).
static func _val(k: int, u: float, v: float) -> float:
	var a := float(k & 1)
	var b := float((k >> 1) & 1)
	var c := float((k >> 2) & 1)
	var d := float((k >> 3) & 1)
	u = clampf(u, 0.0, 1.0)
	v = clampf(v, 0.0, 1.0)
	u = u * u * (3.0 - 2.0 * u)
	v = v * v * (3.0 - 2.0 * v)
	return lerpf(lerpf(a, b, u), lerpf(c, d, u), v)


static func _shape(img: Image, glow: Image, ox: int, oy: int, vx: int, vy: int, k: int,
		tex: PackedColorArray, jit: PackedFloat32Array, silhouette: bool) -> void:
	var h := 0.5 / S
	for py in S:
		for px in S:
			var tx := posmod(vx * S - 8 + px, TEX)
			var ty := posmod(vy * S - 8 + py, TEX)
			var u := (px + 0.5) / S
			var v := (py + 0.5) / S
			var val := _val(k, u, v)
			var thr := 0.5 + (jit[ty * TEX + tx] - 0.5) * 0.3
			if val < thr:
				continue
			var gx := _val(k, u + h, v) - _val(k, u - h, v)
			var gy := _val(k, u, v + h) - _val(k, u, v - h)
			var g := sqrt(gx * gx + gy * gy)
			var d := 99.0 if g < 0.0001 else (val - thr) / g
			var c: Color = tex[ty * TEX + tx]
			if c.a < 0.5:
				continue                   # trama bucata (minerali): si vede la roccia sotto
			if c.a < 0.99:
				c.a = 1.0                  # pixel del minerale che non vuole bordi
				img.set_pixel(ox + px, oy + py, c)
				continue
			if d < 1.0:
				c = Px.sh(c, 0.4 if silhouette else 0.72)
			elif d < 2.6:
				if gy > 0.35 * g:
					c = Px.sh(c, 1.28 if silhouette else 1.12)
				elif silhouette:
					c = Px.sh(c, 0.8)
			img.set_pixel(ox + px, oy + py, c)
			if glow and d >= 1.0:
				glow.set_pixel(ox + px, oy + py, c)


# ---------------------------------------------------------------- trame senza cuciture

## Rumore liscio che si ripete ogni `size` pixel (griglia di `cells` celle con i bordi che si richiudono).
static func wrap_noise(size: int, cells: int, sd: int) -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var g := PackedFloat32Array()
	g.resize(cells * cells)
	for i in g.size():
		g[i] = rng.randf()
	var out := PackedFloat32Array()
	out.resize(size * size)
	var step := float(size) / cells
	for y in size:
		for x in size:
			var fx := x / step
			var fy := y / step
			var ix := int(fx)
			var iy := int(fy)
			var tx := fx - ix
			var ty := fy - iy
			tx = tx * tx * (3.0 - 2.0 * tx)
			ty = ty * ty * (3.0 - 2.0 * ty)
			var a := g[(iy % cells) * cells + ix % cells]
			var b := g[(iy % cells) * cells + (ix + 1) % cells]
			var c := g[((iy + 1) % cells) * cells + ix % cells]
			var d := g[((iy + 1) % cells) * cells + (ix + 1) % cells]
			out[y * size + x] = lerpf(lerpf(a, b, tx), lerpf(c, d, tx), ty)
	return out


## Trama di un materiale, 64×64, che si ripete senza cuciture.
static func material(id: String, p: Array[Color], sd: int) -> PackedColorArray:
	var rng := RandomNumberGenerator.new()
	rng.seed = sd
	var n8 := wrap_noise(TEX, 8, sd * 3 + 1)
	var n16 := wrap_noise(TEX, 16, sd * 3 + 2)
	var col := PackedColorArray()
	col.resize(TEX * TEX)
	for y in TEX:
		for x in TEX:
			var i := y * TEX + x
			var v := 0.55 * n8[i] + 0.3 * n16[i] + rng.randf_range(-0.08, 0.08)
			if id == "ardesia" or id == "scisto":
				v += 0.12 * sin((y + n8[i] * 10.0) * TAU * 3.0 / TEX)
			elif id == "radice":
				v += 0.22 * sin((y + n8[i] * 14.0) * TAU * 5.0 / TEX)   # venatura del legno, lungo la radice
			v = clampf((v - 0.15) / 0.7, 0.0, 0.999)
			var n := p.size() - 1 if id == "cristallo" else p.size()
			col[i] = p[mini(int(v * n), p.size() - 1)]
	match id:
		"humus":
			_fibers(col, rng, Px.pal(TileDefs.P_ROOT), 7, 28)
			_specks(col, rng, p[0], 40)
		"ardesia":
			_fibers(col, rng, [Px.sh(p[0], 0.8)], 3, 14)
		"muschio":
			_specks(col, rng, p[4], 90)
		"radice":
			_fibers(col, rng, [p[0]], 5, 20)
			_specks(col, rng, _linfa(p), 6)          # qualche goccia di Linfa nel legno
		"scisto":
			_fibers(col, rng, [_linfa(p)], 3, 16)    # vene di Linfa nella roccia
		"vuotite":
			_fibers(col, rng, [p[0]], 4, 16)
			_specks(col, rng, Color("#d8b0ff"), 14)   # scintille, come stelle del Vuoto
		"radicite", "legnoferro", "ambra":
			_nuggets(col, rng, p)
		"cristallo":
			_facets(col, rng, p)
	return col


## Il turchese della Linfa, chiaro quanto il tono più chiaro della tavolozza: vivo sulle tessere, spento sulle pareti
## (che nascono da una tavolozza scurita).
static func _linfa(p: Array[Color]) -> Color:
	var v := p[p.size() - 1].v
	return Color(0.3 * v, 1.05 * v, 0.95 * v).lerp(Color("#5ce0d0"), 0.4 * v)


## Fibre di radice: camminate casuali sottili che si richiudono sui bordi.
static func _fibers(col: PackedColorArray, rng: RandomNumberGenerator, cols: Array, count: int, length: int) -> void:
	for k in count:
		var x := rng.randi_range(0, TEX - 1)
		var y := rng.randi_range(0, TEX - 1)
		var dx := 1 if rng.randf() < 0.5 else -1
		var c: Color = cols[rng.randi_range(0, cols.size() - 1)]
		for s in length:
			col[posmod(y, TEX) * TEX + posmod(x, TEX)] = c
			if rng.randf() < 0.55:
				x += dx
			else:
				y += 1
			if rng.randf() < 0.1:
				dx = -dx


## Minerale: solo noduli di metallo sparsi (il resto è trasparente), ognuno con il suo contorno scuro, un lato in luce
## e un punto che luccica. Dentro la forma morbida della vena si vede la roccia (o la terra) che li contiene.
## Alfa 0.9 = pixel del minerale senza bordo di strato (vedi `_shape`).
static func _nuggets(col: PackedColorArray, rng: RandomNumberGenerator, p: Array[Color]) -> void:
	for i in col.size():
		col[i] = Color(0, 0, 0, 0)
	var edge := Color(0.03, 0.03, 0.05, 0.9)
	var placed: Array[Vector3] = []
	var tries := 0
	while placed.size() < 34 and tries < 600:
		tries += 1
		var n := Vector3(rng.randf() * TEX, rng.randf() * TEX, rng.randf_range(1.5, 3.0))
		var ok := true
		for q in placed:
			var dx := absf(n.x - q.x)
			var dy := absf(n.y - q.y)
			dx = minf(dx, TEX - dx)
			dy = minf(dy, TEX - dy)
			if Vector2(dx, dy).length() < n.z + q.z + 1.2:
				ok = false
				break
		if ok:
			placed.append(n)
	for n in placed:
		for dy in range(-5, 6):
			for dx in range(-5, 6):
				var d := Vector2(dx + 0.5, dy + 0.5).length()
				var i := posmod(int(n.y) + dy, TEX) * TEX + posmod(int(n.x) + dx, TEX)
				if d <= n.z:
					var t := 0.5 + (-dx - dy) / (2.4 * n.z)
					var c := p[clampi(int(t * p.size()), 0, p.size() - 1)]
					c.a = 0.9
					col[i] = c
				elif d <= n.z + 1.0 and col[i].a < 0.5:
					col[i] = edge
		var gl := p[p.size() - 1]
		gl.a = 0.9
		col[posmod(int(n.y) - 1, TEX) * TEX + posmod(int(n.x) - 1, TEX)] = gl


static func _specks(col: PackedColorArray, rng: RandomNumberGenerator, c: Color, count: int) -> void:
	for k in count:
		col[rng.randi_range(0, TEX * TEX - 1)] = c


## Faccette di cristallo: celle di Voronoi con i bordi chiari.
static func _facets(col: PackedColorArray, rng: RandomNumberGenerator, p: Array[Color]) -> void:
	var pts: Array[Vector2] = []
	for k in 9:
		pts.append(Vector2(rng.randf() * TEX, rng.randf() * TEX))
	for y in TEX:
		for x in TEX:
			var best := 1e9
			var second := 1e9
			var id := 0
			for i in pts.size():
				for oy in [-TEX, 0, TEX]:
					for ox in [-TEX, 0, TEX]:
						var d := Vector2(x + 0.5, y + 0.5).distance_to(pts[i] + Vector2(ox, oy))
						if d < best:
							second = best
							best = d
							id = i
						elif d < second:
							second = d
			var c := p[1 + id % 3]
			if second - best < 1.2:
				c = p[4]
			elif second - best < 2.4:
				c = p[3]
			col[y * TEX + x] = c
