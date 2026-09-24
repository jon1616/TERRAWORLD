class_name Px
extends RefCounted
## Attrezzi per disegnare pixel art nel codice: immagini vuote, linee spesse, dischi, contorno automatico.


static func img(w: int, h: int) -> Image:
	var i := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	i.fill(Color(0, 0, 0, 0))
	return i


static func put(i: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and y >= 0 and x < i.get_width() and y < i.get_height():
		i.set_pixel(x, y, c)


static func alpha(i: Image, x: int, y: int) -> float:
	if x < 0 or y < 0 or x >= i.get_width() or y >= i.get_height():
		return 0.0
	return i.get_pixel(x, y).a


static func sh(c: Color, f: float) -> Color:
	return Color(c.r * f, c.g * f, c.b * f, c.a)


static func pal(hexes: Array) -> Array[Color]:
	var out: Array[Color] = []
	for hx in hexes:
		out.append(Color.html(String(hx)))
	return out


## Contorno scuro attorno a tutto ciò che non è trasparente (lo «stile pixel art»).
static func outline(i: Image, col: Color) -> void:
	var w := i.get_width()
	var h := i.get_height()
	var marks: Array[Vector2i] = []
	for y in h:
		for x in w:
			if i.get_pixel(x, y).a > 0.1:
				continue
			if alpha(i, x - 1, y) > 0.1 or alpha(i, x + 1, y) > 0.1 or alpha(i, x, y - 1) > 0.1 or alpha(i, x, y + 1) > 0.1:
				marks.append(Vector2i(x, y))
	for m in marks:
		i.set_pixelv(m, col)


static func stamp(i: Image, cx: float, cy: float, w: int, c: Color) -> void:
	var x0 := int(floor(cx - (w - 1) * 0.5))
	var y0 := int(floor(cy - (w - 1) * 0.5))
	for dy in w:
		for dx in w:
			put(i, x0 + dx, y0 + dy, c)


static func line(i: Image, a: Vector2, b: Vector2, w: int, c: Color) -> void:
	var n := int(ceil(a.distance_to(b) * 2.0)) + 1
	for k in n + 1:
		var p := a.lerp(b, float(k) / float(n))
		stamp(i, p.x, p.y, w, c)


static func disc(i: Image, cx: float, cy: float, r: float, c: Color) -> void:
	for y in range(int(cy - r) - 1, int(cy + r) + 2):
		for x in range(int(cx - r) - 1, int(cx + r) + 2):
			var dx := x + 0.5 - cx
			var dy := y + 0.5 - cy
			if dx * dx + dy * dy <= r * r:
				put(i, x, y, c)


static func bezier(a: Vector2, ctrl: Vector2, b: Vector2, t: float) -> Vector2:
	return a.lerp(ctrl, t).lerp(ctrl.lerp(b, t), t)


static func curve(i: Image, a: Vector2, ctrl: Vector2, b: Vector2, w: int, c: Color) -> void:
	for k in 41:
		var p := bezier(a, ctrl, b, k / 40.0)
		stamp(i, p.x, p.y, w, c)
