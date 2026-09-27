class_name BodyArt
extends RefCounted
## Le creature disegnate da una **ricetta** (voce 92): un piano del corpo e pochi parametri, nello stile «Radici e
## Linfa» (contorno scuro, tavolozza di 5 toni, occhi e segni che brillano). Così una creatura nuova dei biomi è una
## riga di dati (`BodyPlansData`) invece di un disegno scritto a mano; i disegni speciali (Guardiani, Custodi) restano a
## mano. Ogni funzione riceve la ricetta e il fotogramma (0 o 1) e restituisce [immagine, parte luminosa].
##
## Ricetta: plan (quadrupede · uccello · insetto · lumaca · anfibio · serpe · fluttuante), w, h (misura del disegno),
## pal (5 colori, dal più scuro), eye (colore dell'occhio, brilla), marks (macchie · strisce · punte · ""), mark (colore
## dei segni; brillano se `glow`), horns (corna: 0 nessuna, 1 corte, 2 ramificate), tail (coda lunga), glow (i segni
## brillano), wings (per insetto e uccello: colore delle ali).

const OUT := Color("#050c10")


static func draw(r: Dictionary, f: int) -> Array:
	var w := int(r.get("w", 20))
	var h := int(r.get("h", 16))
	var im := Px.img(w, h)
	var gm := Px.img(w, h)
	var p := Px.pal(r["pal"])
	match String(r["plan"]):
		"quadrupede":
			_quad(im, gm, r, p, f, w, h)
		"uccello":
			_bird(im, gm, r, p, f, w, h)
		"insetto":
			_bug(im, gm, r, p, f, w, h)
		"lumaca":
			_snail(im, gm, r, p, f, w, h)
		"anfibio":
			_frog(im, gm, r, p, f, w, h)
		"serpe":
			_snake(im, gm, r, p, f, w, h)
		_:
			_float(im, gm, r, p, f, w, h)
	Px.outline(im, OUT)
	return [im, gm]


## Un'ellisse piena, più chiara sopra (la luce viene dall'alto).
static func _blob(im: Image, c: Vector2, rx: float, ry: float, p: Array[Color], light := 3, dark := 2) -> void:
	for y in im.get_height():
		for x in im.get_width():
			var d := Vector2((x + 0.5 - c.x) / rx, (y + 0.5 - c.y) / ry)
			if d.length() <= 1.0:
				Px.put(im, x, y, p[light] if d.y < -0.25 else p[dark])


static func _eye(im: Image, gm: Image, r: Dictionary, x: int, y: int) -> void:
	var e := Color(String(r.get("eye", "#8ef0d8")))
	Px.put(im, x, y, e)
	Px.put(gm, x, y, e)


## I segni sul dorso: macchie, strisce o punte, dentro il rettangolo del corpo.
static func _marks(im: Image, gm: Image, r: Dictionary, p: Array[Color], box: Rect2i) -> void:
	var kind := String(r.get("marks", ""))
	if kind == "":
		return
	var c := Color(String(r.get("mark", "#f0d27a"))) if r.has("mark") else p[4]
	var glow := bool(r.get("glow", false))
	match kind:
		"macchie":
			for k in 4:
				var q := Vector2i(box.position.x + 2 + (k * 5) % maxi(box.size.x - 3, 1), box.position.y + 1 + (k % 2))
				Px.put(im, q.x, q.y, c)
				if glow:
					Px.put(gm, q.x, q.y, c)
		"strisce":
			for x in range(box.position.x + 2, box.end.x - 1, 3):
				for y in range(box.position.y, box.position.y + 3):
					Px.put(im, x, y, c)
					if glow:
						Px.put(gm, x, y, c)
		"punte":
			for x in range(box.position.x + 2, box.end.x - 1, 3):
				Px.put(im, x, box.position.y - 1, c)
				Px.put(im, x, box.position.y - 2, c.lightened(0.2))
				if glow:
					Px.put(gm, x, box.position.y - 2, c)


static func _quad(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var cy := h * 0.58
	var body_rx := w * 0.3
	var body_ry := h * 0.2
	var cx := w * 0.45
	_blob(im, Vector2(cx, cy), body_rx, body_ry, p)
	# collo, testa, muso
	var hx := cx + body_rx + 1.5
	var hy := cy - body_ry - 1.0
	Px.line(im, Vector2(cx + body_rx * 0.7, cy - 1.0), Vector2(hx, hy + 1.0), 3, p[2])
	Px.disc(im, hx + 0.5, hy, h * 0.12 + 0.8, p[3])
	Px.line(im, Vector2(hx + 1.5, hy + 0.5), Vector2(minf(hx + 4.0, w - 1.0), hy + 1.5), 1, p[2])
	_eye(im, gm, r, int(hx + 1.0), int(hy - 0.5))
	# corna
	var horns := int(r.get("horns", 0))
	if horns > 0:
		Px.line(im, Vector2(hx, hy - 1.5), Vector2(hx - 1.5, hy - 4.5), 1, p[4])
		if horns > 1:
			Px.line(im, Vector2(hx - 1.0, hy - 3.5), Vector2(hx - 3.5, hy - 5.0), 1, p[4])
			Px.line(im, Vector2(hx + 1.0, hy - 1.5), Vector2(hx + 2.5, hy - 5.0), 1, p[4])
	# coda
	var tail := 5.0 if r.get("tail", false) else 2.0
	Px.line(im, Vector2(cx - body_rx, cy - 1.0), Vector2(cx - body_rx - tail, cy - 2.0 - tail * 0.4), 1, p[3])
	# zampe che si alternano
	var s := 1.2 if f == 0 else -1.2
	var legs := [cx - body_rx * 0.6, cx - body_rx * 0.2, cx + body_rx * 0.3, cx + body_rx * 0.7]
	for i in legs.size():
		var lx: float = legs[i]
		var sw: float = s if i % 2 == 0 else -s
		Px.line(im, Vector2(lx, cy + body_ry - 1.0), Vector2(lx + sw, h - 1.0), 1, p[1])
	_marks(im, gm, r, p, Rect2i(int(cx - body_rx * 0.6), int(cy - body_ry + 1.0), int(body_rx * 1.2), 3))


static func _bird(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var c := Vector2(w * 0.45, h * 0.55)
	_blob(im, c, w * 0.24, h * 0.26, p)
	Px.disc(im, c.x + w * 0.22, c.y - h * 0.2, h * 0.15 + 0.5, p[3])
	var bx := int(c.x + w * 0.22 + h * 0.15 + 1.0)
	Px.put(im, bx, int(c.y - h * 0.18), Color("#eec04a"))
	Px.put(im, bx + 1, int(c.y - h * 0.16), Color("#c89a3a"))
	_eye(im, gm, r, int(c.x + w * 0.24), int(c.y - h * 0.24))
	var wc := Color(String(r.get("wings", ""))) if r.has("wings") else p[1]
	var up := f == 0
	Px.curve(im, Vector2(c.x - 1.0, c.y - 1.0), Vector2(c.x - w * 0.25, c.y - (h * 0.45 if up else -h * 0.1)),
		Vector2(c.x - w * 0.42, c.y - (h * 0.3 if up else -h * 0.3)), 2, wc)
	# coda a ventaglio
	Px.line(im, Vector2(c.x - w * 0.22, c.y + 1.0), Vector2(2.0, c.y + h * 0.15), 2 if r.get("tail", false) else 1, p[2])
	_marks(im, gm, r, p, Rect2i(int(c.x - w * 0.12), int(c.y - h * 0.1), int(w * 0.24), 2))


static func _bug(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var c := Vector2(w * 0.45, h * 0.6)
	_blob(im, c, w * 0.3, h * 0.22, p)
	Px.disc(im, c.x + w * 0.32, c.y - 0.5, h * 0.14 + 0.5, p[2])
	_eye(im, gm, r, int(c.x + w * 0.36), int(c.y - 1.0))
	# antenne
	Px.line(im, Vector2(c.x + w * 0.34, c.y - h * 0.12), Vector2(c.x + w * 0.45, c.y - h * 0.4), 1, p[4])
	# zampe sottili, tre per lato visibili
	var s := 1.0 if f == 0 else -1.0
	for k in 3:
		var lx := c.x - w * 0.18 + k * w * 0.18
		Px.line(im, Vector2(lx, c.y + h * 0.15), Vector2(lx + (s if k % 2 == 0 else -s), h - 1.0), 1, p[1])
	if r.has("wings"):
		var wc := Color(String(r["wings"]))
		var up := f == 0
		for k in 2:
			var root := Vector2(c.x - k * 3.0, c.y - h * 0.18)
			Px.line(im, root, root + Vector2(-w * 0.18, -(h * 0.4 if up else h * 0.2)), 2, Color(wc, 0.85))
	_marks(im, gm, r, p, Rect2i(int(c.x - w * 0.22), int(c.y - h * 0.12), int(w * 0.44), 2))


static func _snail(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var foot := h - 3.0
	var stretch := 1.0 if f == 0 else 0.0
	for x in range(1, w - 1):
		Px.put(im, x, int(foot), p[1])
		Px.put(im, x, int(foot) + 1, p[2])
	Px.line(im, Vector2(w - 5.0 + stretch, foot), Vector2(w - 3.0 + stretch, foot - 5.0), 2, p[2])
	Px.line(im, Vector2(w - 3.0 + stretch, foot - 5.0), Vector2(w - 2.0 + stretch, foot - 8.0), 1, p[3])
	_eye(im, gm, r, int(w - 2.0 + stretch), int(foot - 8.0))
	# il guscio a spirale, del colore dei segni
	var sc := Color(String(r.get("mark", "#c89a3a")))
	var shell := Vector2(w * 0.42, foot - h * 0.32)
	Px.disc(im, shell.x, shell.y, h * 0.32, sc.darkened(0.3))
	Px.disc(im, shell.x, shell.y, h * 0.2, sc)
	Px.disc(im, shell.x + 0.5, shell.y - 0.5, h * 0.08 + 0.5, sc.lightened(0.3))
	if r.get("glow", false):
		Px.put(gm, int(shell.x), int(shell.y), sc)


static func _frog(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var jump := f == 1
	var c := Vector2(w * 0.5, h * (0.5 if jump else 0.62))
	_blob(im, c, w * 0.32, h * 0.25, p)
	for side in [-1.0, 1.0]:
		var ex: float = c.x + side * w * 0.14
		Px.disc(im, ex, c.y - h * 0.24, 1.8, p[3])
		_eye(im, gm, r, int(ex), int(c.y - h * 0.26))
	Px.line(im, Vector2(c.x - w * 0.12, c.y + h * 0.05), Vector2(c.x + w * 0.12, c.y + h * 0.05), 1, p[1])
	# zampe: raccolte o tese nel salto
	for side in [-1.0, 1.0]:
		var hip: Vector2 = Vector2(c.x + side * w * 0.26, c.y + h * 0.12)
		var toe: Vector2 = Vector2(c.x + side * w * (0.46 if jump else 0.36), h - 1.0 if not jump else c.y + h * 0.4)
		Px.line(im, hip, toe, 2, p[2])
	_marks(im, gm, r, p, Rect2i(int(c.x - w * 0.2), int(c.y - h * 0.12), int(w * 0.4), 2))


static func _snake(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var ph := 0.0 if f == 0 else PI
	var prev := Vector2(1.0, h * 0.7)
	for x in range(1, w - 3):
		var y := h * 0.7 + sin(x * 0.55 + ph) * h * 0.14
		Px.line(im, prev, Vector2(x, y), 3 if x > 3 else 2, p[2] if x % 4 else p[3])
		prev = Vector2(x, y)
	Px.disc(im, w - 3.5, prev.y - 1.0, h * 0.18 + 0.6, p[3])
	_eye(im, gm, r, int(w - 3.0), int(prev.y - 2.0))
	_marks(im, gm, r, p, Rect2i(3, int(h * 0.6), w - 8, 2))


static func _float(im: Image, gm: Image, r: Dictionary, p: Array[Color], f: int, w: int, h: int) -> void:
	var bob := 1.0 if f == 0 else 0.0
	var c := Vector2(w * 0.5, h * 0.4 + bob)
	_blob(im, c, w * 0.34, h * 0.3, p)
	for k in 4:
		var tx := c.x - w * 0.24 + k * w * 0.16
		Px.line(im, Vector2(tx, c.y + h * 0.22), Vector2(tx + (1.0 if (k + f) % 2 else -1.0), h - 1.0), 1, p[1])
	_eye(im, gm, r, int(c.x + w * 0.1), int(c.y - h * 0.05))
	if r.get("glow", false):
		Px.put(gm, int(c.x), int(c.y), p[4])
	_marks(im, gm, r, p, Rect2i(int(c.x - w * 0.2), int(c.y - h * 0.2), int(w * 0.4), 2))
