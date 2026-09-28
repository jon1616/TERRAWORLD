class_name FurnitureSeriesArt
extends RefCounted
## Gli arredi in serie (voce 141, dati in `FurnitureData`): ogni forma disegnata dal codice con la tavolozza del suo
## materiale (5 toni di `BuildData`, dal più scuro), nello stile «Radici e Linfa» (contorno scuro, luce dall'alto,
## parti che brillano dove c'è fuoco o Linfa). `draw` riempie l'immagine della stazione, `icon` la rimpicciolisce per
## la Bisaccia.

const S := 16


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	var st: Dictionary = FurnitureData.stations().get(id, {})
	if st.is_empty():
		return false
	var p := Px.pal(FurnitureData._mat(String(st["mat"]))["pal"])
	var glow := bool(FurnitureData._mat(String(st["mat"])).get("glow", false))
	match String(st["arredo"]):
		"tavolo":
			_rect(im, 1, h - 11, w - 2, 3, p, 3)
			for x in [3, w - 5]:
				_rect(im, x, h - 8, 2, 8, p, 1)
		"sedia":
			_rect(im, 3, h - 7, 9, 2, p, 3)
			_rect(im, 3, h - 5, 2, 5, p, 1)
			_rect(im, 10, h - 5, 2, 5, p, 1)
			_rect(im, 10, h - 15, 2, 8, p, 2)
		"letto":
			_rect(im, 1, h - 8, w - 2, 5, p, 2)
			_rect(im, 1, h - 3, 2, 3, p, 1)
			_rect(im, w - 3, h - 3, 2, 3, p, 1)
			_rect(im, 1, h - 14, 3, 6, p, 3)
			var cloth := Px.pal(["#2e5a4a", "#3e7a62", "#5aa080", "#8ad0a8"])
			for x in range(4, w - 3):
				Px.put(im, x, h - 9, cloth[2])
				Px.put(im, x, h - 10, cloth[1] if x > 9 else Color("#e8e0d0"))
		"armadio":
			_rect(im, 2, 1, w - 4, h - 1, p, 2)
			_rect(im, 3, 2, w / 2 - 3, h - 4, p, 1)
			_rect(im, w / 2 + 1, 2, w / 2 - 4, h - 4, p, 1)
			Px.put(im, w / 2 - 2, h / 2, p[4])
			Px.put(im, w / 2 + 1, h / 2, p[4])
			_rect(im, 1, 0, w - 2, 2, p, 3)
		"scaffale":
			for x in [2, w - 4]:
				_rect(im, x, 1, 2, h - 1, p, 1)
			for y in [4, h / 2 + 1, h - 3]:
				_rect(im, 2, y, w - 4, 2, p, 3)
			# qualche vasetto e un libro sui ripiani
			Px.put(im, 7, 3, Color("#8ad0a8"))
			Px.put(im, 8, 3, Color("#8ad0a8"))
			_rect(im, 13, h / 2 - 3, 2, 4, Px.pal(["#6a2a24", "#9a4034", "#d07060", "#f0c0a0"]), 2)
		"lampada":
			_rect(im, 6, h - 3, 5, 3, p, 1)
			_rect(im, 7, 8, 2, h - 11, p, 2)
			_rect(im, 3, 2, 10, 7, p, 3)
			for y in range(4, 8):
				for x in range(5, 11):
					Px.put(im, x, y, Color("#ffd890"))
					Px.put(gm, x, y, Color("#ffd890"))
		"lanterna":
			Px.line(im, Vector2(8, 0), Vector2(8, 3), 1, p[1])
			_rect(im, 4, 3, 8, 2, p, 3)
			_rect(im, 4, 12, 8, 2, p, 2)
			for y in range(5, 12):
				Px.put(im, 4, y, p[2])
				Px.put(im, 11, y, p[2])
				for x in range(5, 11):
					Px.put(im, x, y, Color("#ffd070"))
					Px.put(gm, x, y, Color("#ffc060"))
		"finestra":
			_rect(im, 2, 2, w - 4, h - 4, p, 2)
			for y in range(4, h - 4):
				for x in range(4, w - 4):
					var frame := x == w / 2 or y == h / 2
					Px.put(im, x, y, p[1] if frame else Color(0.55, 0.8, 0.9, 0.55))
			_rect(im, 1, h - 3, w - 2, 2, p, 3)
		"tappeto":
			var cl := Px.pal(["#4a1e2a", "#7a3040", "#b04a5a", "#e08a90"])
			_rect(im, 1, h - 3, w - 2, 3, p, 1)
			for x in range(2, w - 2):
				Px.put(im, x, h - 2, cl[2] if (x / 3) % 2 == 0 else cl[1])
			for x in [1, w - 2]:
				Px.put(im, x, h - 3, p[4])
		"quadro":
			_rect(im, 2, 2, w - 4, h - 6, p, 3)
			var sky := Px.pal(["#1e3a5a", "#2e5a7a", "#5a8aa0", "#a0d0d8"])
			for y in range(4, h - 6):
				for x in range(4, w - 4):
					var hill := y > h - 12 + int(sin(x * 0.6) * 2.0)
					Px.put(im, x, y, Color("#3a7a4a") if hill else sky[1 + int(y < 8)])
			Px.put(im, w - 8, 6, Color("#fff0a0"))
			Px.put(gm, w - 8, 6, Color("#fff0a0"))
		"vaso":
			_rect(im, 4, h - 7, 8, 7, p, 2)
			_rect(im, 3, h - 8, 10, 2, p, 3)
			var leaf := Px.pal(["#1a4a2a", "#2a6a3a", "#3e9050", "#70c070"])
			for i in 5:
				Px.line(im, Vector2(8, h - 8), Vector2(3 + i * 2.5, 2 + absf(i - 2) * 2.0), 1, leaf[1 + i % 3])
			Px.put(im, 8, 2, Color("#f0a0c0"))
		"camino":
			_rect(im, 1, 3, w - 2, h - 3, p, 2)
			_rect(im, 0, 1, w, 3, p, 3)
			for y in range(h - 12, h - 1):
				for x in range(7, w - 7):
					var t := float(y - (h - 12)) / 11.0
					var c := Color("#401010").lerp(Color("#ff9040"), t * (0.6 + 0.4 * sin(x * 1.7)))
					Px.put(im, x, y, c)
					if t > 0.4:
						Px.put(gm, x, y, c)
	if glow:
		# i materiali che brillano (ambra, tizzonite, Linfa, stellare): un filo di luce sui bordi chiari
		for y in h:
			for x in w:
				if im.get_pixel(x, y) == p[4]:
					gm.set_pixel(x, y, p[4])
	return true


static func _rect(im: Image, x: int, y: int, w: int, h: int, p: Array[Color], tone: int) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			if xx < 0 or yy < 0 or xx >= im.get_width() or yy >= im.get_height():
				continue
			var c := p[tone]
			if yy == y and tone + 1 < p.size():
				c = p[tone + 1]                          # luce dall'alto
			elif xx == x + w - 1 and tone > 0:
				c = p[tone - 1]
			im.set_pixel(xx, yy, c)


## L'icona di un arredo: la stazione disegnata, rimpicciolita dentro 16×16.
static func icon(id: String) -> Image:
	var st: Dictionary = FurnitureData.stations().get(id, {})
	var w := int(st["size"][0]) * S
	var h := int(st["size"][1]) * S
	var im := Px.img(w, h)
	var gm := Px.img(w, h)
	draw(id, im, gm, w, h)
	Px.outline(im, Color("#050c10"))
	var k := maxf(float(w) / S, float(h) / S)
	if k > 1.0:
		im.resize(maxi(1, int(w / k)), maxi(1, int(h / k)), Image.INTERPOLATE_NEAREST)
	var out := Px.img(S, S)
	out.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), Vector2i((S - im.get_width()) / 2, (S - im.get_height()) / 2))
	return out
