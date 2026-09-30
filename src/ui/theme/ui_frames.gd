class_name UiFrames
extends RefCounted
## Le cornici dell'interfaccia disegnate dal codice (voci 270-271, guida `ARTE.md` §4): immagini a 9 pezzi a pixel
## doppi (un pixel della cornice = 2 dello schermo, come il resto del gioco), che si allungano senza deformare gli
## angoli; il centro si ripete (la trama di fibre non si stira). Legno di radice e un filo di Linfa, non plastica:
## rilievo (luce in alto a sinistra, ombra in basso a destra), nodi di radice agli angoli, il filo con le gocce sul
## bordo alto, un'ombra morbida fuori.
##
## `box(tipo, stato, accento)`:
##   riquadro     i pannelli e i riquadri
##   forte        i pannelli principali (bordo doppio, testata più chiara, foglie agli angoli alti, filo d'ambra)
##   suggerimento le schede che seguono il mouse (compatta, senza nodi)
##   casella      le caselle degli oggetti (stati: normale, sopra, scelto)
##   pulsante     i pulsanti (stati: normale, sopra, premuto, spento, scelto)
##   campo        i campi di testo (stato "scelto" quando si scrive)
## L'accento (facoltativo) tinge bordo e fondo: le categorie di Creare, i tipi d'oggetto nelle caselle.

const S := 2                  # pixel dello schermo per pixel della cornice

static var _cache := {}


static func box(kind: String, state := "normale", accent := Color(0, 0, 0, 0)) -> StyleBoxTexture:
	var key := "%s|%s|%s" % [kind, state, accent.to_html()]
	if _cache.has(key):
		return _cache[key]
	var spec := _spec(kind, state, accent)
	var b: int = spec["b"]
	var m: int = spec["m"]
	var img := _paint(spec)
	img.resize(b * S, b * S, Image.INTERPOLATE_NEAREST)
	var sb := StyleBoxTexture.new()
	sb.texture = ImageTexture.create_from_image(img)
	sb.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	sb.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE_FIT
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		sb.set_texture_margin(side, m * S)
		sb.set_expand_margin(side, int(spec["sh"]) * S)
	var pad: Vector2 = spec["pad"]
	sb.content_margin_left = pad.x
	sb.content_margin_right = pad.x
	sb.content_margin_top = pad.y
	sb.content_margin_bottom = pad.y
	if kind == "pulsante" and state == "premuto":
		sb.content_margin_top = pad.y + 2
		sb.content_margin_bottom = pad.y - 2
	_cache[key] = sb
	return sb


## Le scelte di ogni tipo e stato.
static func _spec(kind: String, state: String, accent: Color) -> Dictionary:
	var P := UiPalette
	var s := {"b": 32, "m": 11, "r": 3, "sh": 2, "fill": P.PANNELLO, "border": P.BORDO, "border2": Color(0, 0, 0, 0),
		"band": Color(0, 0, 0, 0), "thread": Color(P.LINFA, 0.35), "corners": "radice", "glow": Color(0, 0, 0, 0),
		"bevel": 1.0, "pattern": true, "pad": Vector2(16, 14)}
	match kind:
		"forte":
			s["border2"] = P.BORDO.darkened(0.4)
			s["band"] = P.PANNELLO_ALTO
			s["thread"] = Color(P.AMBRA, 0.45)
			s["corners"] = "foglia"
			s["pad"] = Vector2(18, 16)
		"suggerimento":
			s["b"] = 24
			s["m"] = 8
			s["corners"] = ""
			s["thread"] = Color(P.LINFA, 0.25)
			s["fill"] = Color(P.PANNELLO, 0.97)
			s["pad"] = Vector2(12, 9)
		"casella", "pulsante", "campo":
			s["b"] = 16
			s["m"] = 5
			s["r"] = 2
			s["sh"] = 1 if kind == "casella" else 0
			s["corners"] = ""
			s["pattern"] = false
			s["thread"] = Color(0, 0, 0, 0)
			s["fill"] = P.PANNELLO_ALTO
			s["border"] = Color(P.BORDO, 0.8)
			s["pad"] = Vector2(0, 0) if kind == "casella" else (Vector2(12, 5) if kind == "pulsante" else Vector2(10, 6))
	if kind == "casella":
		match state:
			"sopra":
				s["border"] = P.BORDO_CHIARO
				s["fill"] = P.PANNELLO_VIVO
			"scelto":
				s["border"] = P.AMBRA
				s["fill"] = P.PANNELLO_VIVO
				s["glow"] = Color(P.AMBRA, 0.4)
	elif kind == "pulsante":
		s["thread"] = Color(P.LINFA, 0.10)
		match state:
			"sopra":
				s["fill"] = P.PANNELLO_VIVO
				s["border"] = P.BORDO_CHIARO
				s["thread"] = Color(P.LINFA, 0.25)
			"premuto":
				s["fill"] = P.PANNELLO.darkened(0.25)
				s["border"] = P.AMBRA
				s["bevel"] = -1.0
				s["thread"] = Color(0, 0, 0, 0)
			"spento":
				s["fill"] = Color(P.PANNELLO_ALTO, 0.5)
				s["border"] = Color(P.BORDO, 0.3)
				s["bevel"] = 0.3
				s["thread"] = Color(0, 0, 0, 0)
			"scelto":
				s["fill"] = P.PANNELLO_VIVO
				s["border"] = P.AMBRA
				s["thread"] = Color(P.AMBRA, 0.3)
	elif kind == "campo":
		s["fill"] = Color("#081211")
		s["border"] = Color(P.BORDO, 0.6) if state != "scelto" else P.LINFA
		s["bevel"] = -1.0
	if accent.a > 0.0:
		s["fill"] = (s["fill"] as Color).lerp(accent, 0.10 if kind != "casella" else 0.16)
		if kind != "casella" or state == "normale":
			s["border"] = (s["border"] as Color).lerp(accent, 0.55)
	s["kind"] = kind
	return s


static func _paint(s: Dictionary) -> Image:
	var b: int = s["b"]
	var m: int = s["m"]
	var r: int = s["r"]
	var sh: int = s["sh"]
	var fill: Color = s["fill"]
	var border: Color = s["border"]
	var border2: Color = s["border2"]
	var band: Color = s["band"]
	var thread: Color = s["thread"]
	var glow: Color = s["glow"]
	var bevel: float = s["bevel"]
	var img := Image.create(b, b, false, Image.FORMAT_RGBA8)
	var a0 := sh                                # primo pixel del riquadro
	var a1 := b - 1 - sh                        # ultimo pixel del riquadro
	for y in b:
		for x in b:
			var out := _outside(x, y, a0, a1, r)
			if out > 0:
				if out <= sh:
					if glow.a > 0.0:
						img.set_pixel(x, y, Color(glow.r, glow.g, glow.b, glow.a * (1.0 if out == 1 else 0.4)))
					else:
						img.set_pixel(x, y, Color(0, 0, 0, 0.30 if out == 1 else 0.13))
				continue
			var d := _depth(x, y, a0, a1, r)        # 0 = sul bordo, 1 = subito dentro…
			var c := fill
			if d == 0:
				c = border
			elif d == 1 and border2.a > 0.0:
				c = border2
			else:
				# la trama di fibre (solo nella parte che si ripete, così combacia da una ripetizione all'altra)
				if bool(s["pattern"]) and (x * 3 + y * 5) % 9 == 0:
					c = c.lightened(0.03)
				# la testata del riquadro forte
				if band.a > 0.0 and y < m - 1 and d > 1:
					c = band
				# il rilievo: luce in alto e a sinistra, ombra in basso e a destra, subito dentro il bordo
				var inner := 1 if border2.a <= 0.0 else 2
				if d == inner and bevel != 0.0:
					var lit := (y - a0) <= (x - a0) and (y - a0) + (x - a0) < b - 2 * sh     # lato alto o sinistro
					if bevel > 0.0:
						c = c.lerp(Color.WHITE, 0.06 * bevel) if lit else c.lerp(Color.BLACK, 0.28 * bevel)
					else:
						c = c.lerp(Color.BLACK, 0.35) if lit else c.lerp(Color.WHITE, 0.04)
				# il filo di Linfa (o d'ambra) sotto il bordo alto, con una goccia ogni 5 pixel
				if thread.a > 0.0 and y == a0 + inner + 1 and d >= inner + 1:
					var drop := (x % 5) == 2
					c = c.blend(Color(thread.r, thread.g, thread.b, minf(thread.a * (1.8 if drop else 1.0), 1.0)))
			img.set_pixel(x, y, c)
	match String(s["corners"]):
		"radice":
			_knots(img, a0, a1, false)
		"foglia":
			_knots(img, a0, a1, true)
	return img


## I nodi di radice agli angoli: un nodo prugna con la luce, due radichette lungo i lati; con le foglie, una foglia di
## muschio sugli angoli alti.
static func _knots(img: Image, a0: int, a1: int, leaves: bool) -> void:
	var P := UiPalette
	for corner: Vector2i in [Vector2i(a0, a0), Vector2i(a1, a0), Vector2i(a0, a1), Vector2i(a1, a1)]:
		var dx := 1 if corner.x == a0 else -1
		var dy := 1 if corner.y == a0 else -1
		var knot := [[0, 0, P.RADICE], [1, 0, P.RADICE_CHIARA], [0, 1, P.RADICE_CHIARA], [1, 1, P.RADICE],
			[2, 0, P.RADICE], [0, 2, P.RADICE], [3, 0, P.RADICE.darkened(0.2)], [0, 3, P.RADICE.darkened(0.2)],
			[2, 1, P.RADICE.darkened(0.3)], [1, 2, P.RADICE.darkened(0.3)]]
		for k in knot:
			img.set_pixel(corner.x + dx * int(k[0]), corner.y + dy * int(k[1]), k[2])
		# una gemma di Linfa sul nodo
		img.set_pixel(corner.x + dx, corner.y + dy, P.LINFA.darkened(0.15))
		if leaves and dy == 1:
			for q in [[4, 0], [5, 0], [5, -1], [6, -1], [4, 1]]:
				var px: int = corner.x + dx * int(q[0])
				var py: int = corner.y + int(q[1])
				if py >= 0:
					img.set_pixel(px, py, P.FOGLIA if int(q[1]) >= 0 else P.FOGLIA.lightened(0.35))


## Quanti pixel un punto sta fuori dal rettangolo [a, b]² con gli angoli arrotondati a gradini di raggio r (0 = dentro).
static func _outside(x: int, y: int, a: int, b: int, r: int) -> int:
	var dx := maxi(a - x, x - b)
	var dy := maxi(a - y, y - b)
	if dx > 0 or dy > 0:
		return maxi(dx, 0) + maxi(dy, 0) if dx > 0 and dy > 0 else maxi(dx, dy)
	var cx := a + r if x < a + r else (b - r if x > b - r else x)
	var cy := a + r if y < a + r else (b - r if y > b - r else y)
	return 1 if Vector2(x - cx, y - cy).length() > float(r) + 0.35 else 0


## Quanto un punto dentro la forma sta lontano dal bordo (0 = sul bordo).
static func _depth(x: int, y: int, a: int, b: int, r: int) -> int:
	for k in range(0, 4):
		if _outside(x, y, a + k + 1, b - k - 1, maxi(r - k - 1, 0)) > 0:
			return k
	return 4
