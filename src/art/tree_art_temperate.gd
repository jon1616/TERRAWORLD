class_name TreeArtTemperate
extends RefCounted
## Gli alberi delle terre temperate (voce 92), nello stesso stile di `TreeArt` (che li chiama per nome):
##   ombrello    Prati di vento: tronco sottile piegato dal vento, chioma piatta e argentata che pende da una parte
##   sequoia     Selve di corteccia rossa: tronco rosso e grosso, chioma a palchi di foglie di rame
##   cappellone  Colline dei cappelli: gambo tozzo, cappello largo bruno-arancio a pois, lamelle che brillano
##   mangrovia   Torbiere di Linfa: radici ad arco sopra la torba, tronco storto, chioma scura con gocce di Linfa

const OUT := Color("#05090c")


static func draw(species: String, im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> bool:
	match species:
		"ombrello":
			_ombrello(im, gm, w, h, rng)
		"sequoia":
			_sequoia(im, gm, w, h, rng)
		"cappellone":
			_cappellone(im, gm, w, h, rng)
		"mangrovia":
			_mangrovia(im, gm, w, h, rng)
		_:
			return false
	return true


## Un'ellisse di foglie: più chiara in alto, con un po' di rumore.
static func _leaves(im: Image, q: Vector2, rx: float, ry: float, leaf: Array[Color], rng: RandomNumberGenerator) -> void:
	for y in range(int(q.y - ry), int(q.y + ry) + 1):
		for x in range(int(q.x - rx), int(q.x + rx) + 1):
			var dx := (x + 0.5 - q.x) / rx
			var dy := (y + 0.5 - q.y) / ry
			if dx * dx + dy * dy <= 1.0:
				var t := 0.6 - dy * 0.45 + rng.randf_range(-0.12, 0.12)
				Px.put(im, x, y, leaf[clampi(int(t * 5.0), 0, 4)])


static func _ombrello(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#1a1a16", "#34342a", "#4e4e40", "#6e6c58"])
	var leaf := Px.pal(["#1e3a34", "#2e5a50", "#4a8878", "#7ab8a4", "#c8ece0"])
	var sc := h / 124.0
	var lean := -1.0 if rng.randf() < 0.5 else 1.0
	var cx := w / 2.0
	var crown_y := int(h * rng.randf_range(0.16, 0.24)) + 4
	# il tronco piegato: una curva sottile dalla base alla chioma, spostata dal vento
	var top := Vector2(cx + lean * w * 0.18, crown_y + 4)
	Px.curve(im, Vector2(cx, h - 1), Vector2(cx - lean * w * 0.05, h * 0.55), top, int(1 + sc * 1.6), bark[2])
	Px.curve(im, Vector2(cx + 1, h - 1), Vector2(cx - lean * w * 0.05 + 1, h * 0.55), top + Vector2(1, 0), 1, bark[1])
	# la chioma piatta che il vento spinge: ellissi larghe, sfrangiate dalla parte del vento
	for k in 4:
		var q := top + Vector2(lean * rng.randf_range(0.0, 0.25) * w, rng.randf_range(-3.0, 3.0) * sc)
		_leaves(im, q, rng.randf_range(0.3, 0.45) * w, rng.randf_range(3.0, 5.0) * sc + 2.0, leaf, rng)
	# fili di foglie che pendono sottovento
	for k in int(5 + 5 * sc):
		var x0 := top.x + rng.randf_range(-0.3, 0.45) * w * lean
		var ln := rng.randf_range(4.0, 12.0) * sc
		Px.line(im, Vector2(x0, top.y + 3), Vector2(x0 + lean * 2.0, top.y + 3 + ln), 1, leaf[3])
	Px.outline(im, OUT)
	for k in int(2 + 3 * sc):
		var q := top + Vector2(rng.randf_range(-0.3, 0.3) * w, rng.randf_range(-2.0, 4.0))
		Px.put(gm, int(q.x), int(q.y), leaf[4])


static func _sequoia(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#3a0e08", "#6a1e12", "#9a3420", "#c85a36"])
	var leaf := Px.pal(["#3a1a08", "#6a3010", "#a0521a", "#d8802a", "#ffc070"])
	var sc := h / 124.0
	var cx := w / 2.0
	var xs := TreeArt._trunk(im, w, h, int(h * 0.12), bark, rng, 2.2 + 3.0 * sc)
	# i palchi di rame: dall'alto (piccoli) al basso (larghi), staccati tra loro come nelle sequoie
	var tiers := clampi(int(2 + 3 * sc), 2, 6)
	for i in tiers:
		var y := int(h * 0.1 + i * (h * 0.55) / tiers)
		var x := float(xs[clampi(y, 0, h - 1)]) if y < h and xs[clampi(y, 0, h - 1)] != 0.0 else cx
		var rx := w * (0.18 + 0.22 * float(i + 1) / tiers)
		_leaves(im, Vector2(x, y), rx, rng.randf_range(3.5, 5.5) * sc + 2.0, leaf, rng)
	# le scanalature del tronco
	for y in range(int(h * 0.6), h - 2, 3):
		var x2 := float(xs[y]) if xs[y] != 0.0 else cx
		Px.put(im, int(x2), y, bark[0])
	Px.outline(im, OUT)
	for k in int(2 + 4 * sc):
		var q := Vector2(cx + rng.randf_range(-0.35, 0.35) * w, rng.randf_range(h * 0.1, h * 0.6))
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.put(im, int(q.x), int(q.y), leaf[4])
			Px.put(gm, int(q.x), int(q.y), leaf[4])


static func _cappellone(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var stem := Px.pal(["#4a3a2a", "#7a6450", "#a88e74", "#d8c4a4"])
	var cap := Px.pal(["#4a1e0a", "#7a3412", "#b0561e", "#e0823a", "#ffc080"])
	var gill := Color("#ffd8a0")
	var sc := h / 124.0
	var cx := w / 2.0
	var cap_y := int(h * rng.randf_range(0.28, 0.4))
	var sw := 2.5 + 3.5 * sc
	# il gambo tozzo, un poco più largo alla base
	for y in range(cap_y, h):
		var t := float(y - cap_y) / float(maxi(h - cap_y, 1))
		var hw := sw * (0.8 + t * 0.5)
		for x in range(int(cx - hw), int(cx + hw) + 1):
			var k := (x - (cx - hw)) / (2.0 * hw)
			Px.put(im, x, y, stem[3] if k < 0.3 else (stem[2] if k < 0.75 else stem[1]))
	# il cappello: mezza ellisse larga, con i pois chiari
	var rx := w * 0.48
	var ry := (cap_y - 2) * 0.9 + 3.0
	for y in range(maxi(int(cap_y - ry), 0), cap_y + 2):
		for x in w:
			var dx := (x + 0.5 - cx) / rx
			var dy := (y + 0.5 - cap_y) / ry
			if dx * dx + dy * dy <= 1.0 and dy <= 0.12:
				var t := 0.75 + dy * 0.6 + rng.randf_range(-0.08, 0.08)
				Px.put(im, x, y, cap[clampi(int(t * 5.0), 0, 4)])
	for k in int(4 + 5 * sc):
		var q := Vector2(cx + rng.randf_range(-0.7, 0.7) * rx, cap_y - rng.randf_range(0.2, 0.8) * ry)
		if im.get_pixel(int(q.x), int(q.y)).a > 0.5:
			Px.disc(im, q.x, q.y, 1.0 + sc * 0.6, Color("#f4e4c8"))
	Px.outline(im, OUT)
	# le lamelle sotto il cappello, che brillano appena
	for x in range(int(cx - rx * 0.85), int(cx + rx * 0.85), 2):
		Px.put(im, x, cap_y + 1, gill)
		Px.put(gm, x, cap_y + 1, Color(gill, 0.6))


static func _mangrovia(im: Image, gm: Image, w: int, h: int, rng: RandomNumberGenerator) -> void:
	var bark := Px.pal(["#141a12", "#26301e", "#3a4a2c", "#566a3e"])
	var leaf := Px.pal(["#0a2018", "#123628", "#1e5240", "#2e7a5e", "#5ab890"])
	var linfa := Color("#5cf0d8")
	var sc := h / 124.0
	var cx := w / 2.0
	var root_top := int(h * 0.7)
	# le radici ad arco sopra la torba
	for k in 5:
		var fx := cx + (k - 2) * w * 0.14 + rng.randf_range(-2, 2)
		Px.curve(im, Vector2(cx + rng.randf_range(-2, 2), root_top), Vector2((cx + fx) * 0.5, root_top - 4.0 * sc),
			Vector2(fx, h - 1), int(1 + sc), bark[2])
	# il tronco storto
	var top := Vector2(cx + rng.randf_range(-0.12, 0.12) * w, h * 0.3)
	Px.curve(im, Vector2(cx, root_top), Vector2(cx + rng.randf_range(-6, 6) * sc, h * 0.5), top, int(2 + 2 * sc), bark[2])
	# la chioma: tre ellissi scure un po' spioventi
	for k in 3:
		var q := top + Vector2((k - 1) * w * 0.2, rng.randf_range(-4.0, 2.0) * sc)
		_leaves(im, q, rng.randf_range(0.2, 0.3) * w, rng.randf_range(5.0, 8.0) * sc + 2.0, leaf, rng)
	Px.outline(im, OUT)
	# gocce di Linfa che pendono dalla chioma e brillano
	for k in int(3 + 4 * sc):
		var q := top + Vector2(rng.randf_range(-0.4, 0.4) * w, rng.randf_range(4.0, 10.0) * sc)
		Px.put(im, int(q.x), int(q.y), linfa)
		Px.put(gm, int(q.x), int(q.y), linfa)
