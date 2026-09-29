class_name VeinPainter
extends RefCounted
## Roadmap 19, voce 191: il disegno delle vene del Flusso e dei fili dell'Impulso, dal codice. Tre atlanti di 16
## colonne (le combinazioni dei 4 vicini: 1 su, 2 destra, 4 giù, 8 sinistra) per 4 righe:
##   img   il corpo delle vene, una riga per grado (radice, legnoferro, ambra, cristallo): radici curve con il bordo scuro
##   glow  l'anima luminosa delle vene (la Linfa che scorre; `WorldView` la fa pulsare con uno shader)
##   wires i fili, una riga per colore, ognuno sul suo binario (così quattro fili stanno nella stessa cella)
## Una vena arriva sempre al centro del lato della tessera, dritta: le tessere vicine si uniscono senza gradini.
## Lavoro di puro codice (gira nel thread di `ViewArt`).

const S := 16
const COLS := 16
const WIRE_TRACK := [-3, -1, 1, 3]          # dove passa ogni filo, rispetto al centro della tessera

const _DIRS := [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)]


static func build() -> Dictionary:
	var img := Image.create(S * COLS, S * 4, false, Image.FORMAT_RGBA8)
	var glow := Image.create(S * COLS, S * 4, false, Image.FORMAT_RGBA8)
	var wires := Image.create(S * COLS, S * 4, false, Image.FORMAT_RGBA8)
	for t in range(1, 5):
		var td: Dictionary = VeinsData.TIERS[t]
		for mask in 16:
			_vein(img, glow, Vector2i(mask * S, (t - 1) * S), mask, t, td)
	for c in 4:
		var col: Color = VeinsData.WIRES[c]["color"]
		for mask in 16:
			_wire(wires, Vector2i(mask * S, c * S), mask, c, col)
	return {"img": img, "glow": glow, "wires": wires}


## La cella dell'atlante per un grado (1-4) o un colore (0-3) e una combinazione di vicini.
static func coords(row: int, mask: int) -> Vector2i:
	return Vector2i(mask, row)


static func _disc(im: Image, o: Vector2i, p: Vector2, r: float, col: Color) -> void:
	for y in range(floori(p.y - r), ceili(p.y + r) + 1):
		for x in range(floori(p.x - r), ceili(p.x + r) + 1):
			if x < 0 or y < 0 or x >= S or y >= S:
				continue
			if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
				im.set_pixel(o.x + x, o.y + y, col)


## Il percorso di un ramo dal centro al lato d: dritto agli estremi, piegato di poco nel mezzo (curva di radice).
static func _path(d: int, mask: int, t: float) -> Vector2:
	var c := Vector2(8, 8)
	var dir: Vector2 = _DIRS[d]
	var e := c + dir * 8.5
	var perp := Vector2(-dir.y, dir.x)
	var bend := 1.2 if (mask + d * 3) % 2 == 0 else -1.2
	var s := sin(PI * t)
	return c.lerp(e, t) + perp * bend * s * s


static func _vein(im: Image, glow: Image, o: Vector2i, mask: int, tier: int, td: Dictionary) -> void:
	var r: float = [0.0, 1.7, 2.1, 2.1, 1.8][tier]
	var body: Color = td["body"]
	var dark: Color = td["dark"]
	var core: Color = td["core"]
	var arms := []
	for d in 4:
		if mask & (1 << d):
			arms.append(d)
	# il bordo scuro, poi il corpo, poi i segni del grado e l'anima
	for pass_i in 2:
		var col: Color = dark if pass_i == 0 else body
		var rr: float = r + 0.9 if pass_i == 0 else r
		_disc(im, o, Vector2(8, 8), rr + (0.6 if arms.size() != 2 else 0.0), col)
		for d in arms:
			for k in 21:
				_disc(im, o, _path(d, mask, k / 20.0), rr, col)
	# segni del grado
	for d in arms:
		match tier:
			1:
				# radici: una radichetta che spunta dal ramo
				var p := _path(d, mask, 0.55)
				var dir: Vector2 = _DIRS[d]
				var side := Vector2(-dir.y, dir.x) * (1.0 if mask % 2 == 0 else -1.0)
				_disc(im, o, p + side * (r + 0.8), 0.7, dark)
			2:
				# legnoferro: due anelli
				for t in [0.35, 0.75]:
					var q := _path(d, mask, t)
					var dir2: Vector2 = _DIRS[d]
					var side2 := Vector2(-dir2.y, dir2.x)
					for k2 in range(-2, 3):
						var pp := q + side2 * k2 * 0.8
						var px := Vector2i(floori(pp.x), floori(pp.y))
						if px.x >= 0 and px.y >= 0 and px.x < S and px.y < S:
							im.set_pixel(o.x + px.x, o.y + px.y, dark)
			_:
				pass
	# l'anima: nel corpo (ambra, cristallo) e sempre nella tavola del bagliore
	for d in arms:
		for k in 21:
			var p2 := _path(d, mask, k / 20.0)
			if tier >= 3:
				_disc(im, o, p2, 0.6, core.lerp(body, 0.3))
			_disc(glow, o, p2, 0.7, Color(core.r, core.g, core.b, 0.95))
	_disc(glow, o, Vector2(8, 8), 1.1 if arms.is_empty() else 0.8, Color(core.r, core.g, core.b, 0.95))


static func _wire(im: Image, o: Vector2i, mask: int, color: int, col: Color) -> void:
	var t: int = 8 + int(WIRE_TRACK[color])
	var shade := col.darkened(0.55)
	var cells := []
	cells.append(Vector2i(t, t))
	if mask & 1:
		for y in range(0, t):
			cells.append(Vector2i(t, y))
	if mask & 4:
		for y in range(t, S):
			cells.append(Vector2i(t, y))
	if mask & 8:
		for x in range(0, t):
			cells.append(Vector2i(x, t))
	if mask & 2:
		for x in range(t, S):
			cells.append(Vector2i(x, t))
	for q: Vector2i in cells:
		if q.y + 1 < S and im.get_pixel(o.x + q.x, o.y + q.y + 1).a == 0.0:
			im.set_pixel(o.x + q.x, o.y + q.y + 1, shade)
	for q: Vector2i in cells:
		im.set_pixel(o.x + q.x, o.y + q.y, col)
	if mask == 0:
		for d in [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1)]:
			var q2: Vector2i = Vector2i(t, t) + d
			im.set_pixel(o.x + q2.x, o.y + q2.y, col)
