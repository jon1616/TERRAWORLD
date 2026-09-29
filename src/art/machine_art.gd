class_name MachineArt
extends RefCounted
## Roadmap 19: il disegno delle macchine della rete, dal codice, nello stile «Radici e Linfa» (corteccia, radici,
## baccelli, Linfa turchese che brilla). `draw` riconosce le macchine di `MachinesData` dal loro `look`; la parte
## luminosa va in `gm` (si accende nel buio). Chiamato da `StationArt.make`. Lavoro di puro codice.

const BARK := [Color("#3a2618"), Color("#6a4a32"), Color("#8a6040"), Color("#b08a5a")]
const LINFA := [Color("#0f4a4e"), Color("#1f8f8f"), Color("#5cc8cc"), Color("#c0ffff")]
const AMBER := [Color("#6a4a0c"), Color("#b0861c"), Color("#eec04a"), Color("#fff2a8")]
const SLATE := [Color("#26303e"), Color("#3e4a5c"), Color("#5e6e84"), Color("#8ea0b8")]
const LEAF := [Color("#12483e"), Color("#1f7a62"), Color("#3aa888"), Color("#8ef0c8")]


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	var d := MachinesData.get_machine(id)
	if d.is_empty():
		return false
	var look := String(d.get("look", "scatola"))
	match look:
		"tamburo":
			_tamburo(im, gm, w, h)
		"foglia":
			_foglia(im, gm, w, h)
		"otre":
			_otre(im, gm, w, h, 0.55)
		"lampada":
			_lampada(im, gm, w, h)
		"leva":
			_leva(im, gm, w, h)
		"pulsante":
			_pulsante(im, gm, w, h)
		"piastra":
			_piastra(im, gm, w, h)
		"porta":
			_porta(im, gm, w, h)
		_:
			_scatola(im, gm, w, h, d)
	return true


static func _rect(i: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for y in range(maxi(y0, 0), mini(y1, i.get_height())):
		for x in range(maxi(x0, 0), mini(x1, i.get_width())):
			i.set_pixel(x, y, c)


## Una base di radici che si aggrappa al pavimento (tutte le macchine stanno su una radice).
static func _roots(im: Image, w: int, h: int) -> void:
	_rect(im, 1, h - 3, w - 1, h, BARK[1])
	_rect(im, 1, h - 3, w - 1, h - 2, BARK[2])
	for x in range(2, w - 2, 5):
		Px.put(im, x, h - 1, BARK[0])
		Px.put(im, x + 2, h - 2, BARK[3])


## Il Tamburo di radice: un rullo di corteccia coricato, con le costole e l'asse di Linfa.
static func _tamburo(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var cy := h - 8
	for x in range(3, w - 3):
		for dy in range(-5, 5):
			var y := cy + dy
			var c: Color = BARK[1] if absi(dy) < 3 else BARK[0]
			if dy == -4:
				c = BARK[3]
			if (x - 3) % 5 == 0:
				c = BARK[0]
			Px.put(im, x, y, c)
	for dy in range(-5, 5):
		Px.put(im, 2, cy + dy, BARK[0])
		Px.put(im, w - 3, cy + dy, BARK[0])
	for x in range(1, w - 1):
		Px.put(im, x, cy, LINFA[1])
		if x % 3 == 0:
			Px.put(gm, x, cy, LINFA[3])


## La Foglia-lanterna: un gambo e una grande foglia turchese con le nervature che bevono la luce.
static func _foglia(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var base := Vector2(w * 0.5, h - 3)
	Px.line(im, base, Vector2(w * 0.5, h * 0.45), 2, BARK[2])
	# la foglia: un'ellisse inclinata
	var c := Vector2(w * 0.5, h * 0.36)
	for y in h:
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - c
			var q := p.rotated(-0.5)
			var v := (q.x * q.x) / (w * 0.42 * w * 0.42) + (q.y * q.y) / (h * 0.24 * h * 0.24)
			if v <= 1.0:
				Px.put(im, x, y, LEAF[1] if v > 0.7 else LEAF[2])
				if v > 0.86:
					Px.put(im, x, y, LEAF[0])
	# le nervature (luminose)
	var tip := c + Vector2(w * 0.4, 0).rotated(0.5)
	var back := c - Vector2(w * 0.4, 0).rotated(0.5)
	Px.line(im, back, tip, 1, LEAF[3])
	Px.line(gm, back, tip, 1, LINFA[3])
	for k in range(-2, 3):
		if k == 0:
			continue
		var s := c + (tip - c) * (k * 0.3)
		Px.line(im, s, s + Vector2(-2, -4) if k > 0 else s + Vector2(2, 4), 1, LEAF[3])
		Px.line(gm, s, s + Vector2(-2, -4) if k > 0 else s + Vector2(2, 4), 1, LINFA[2])


## L'Otre di Linfa: una sacca di pelle con una finestra di vetro dove si vede la Linfa.
static func _otre(im: Image, gm: Image, w: int, h: int, level: float) -> void:
	var c := Vector2(w * 0.5, h * 0.6)
	Px.disc(im, c.x, c.y, w * 0.42, BARK[0])
	Px.disc(im, c.x, c.y, w * 0.36, BARK[2])
	_rect(im, int(w * 0.38), 1, int(w * 0.62), int(h * 0.3), BARK[1])
	_rect(im, int(w * 0.34), 0, int(w * 0.66), 2, BARK[0])
	# la finestra
	var top := int(c.y - 3)
	var bot := int(c.y + 4)
	for y in range(top, bot):
		for x in range(int(c.x - 3), int(c.x + 3)):
			var full := y >= top + int((bot - top) * (1.0 - level))
			Px.put(im, x, y, LINFA[2] if full else SLATE[3])
			if full:
				Px.put(gm, x, y, LINFA[3] if y == top + int((bot - top) * (1.0 - level)) else LINFA[2])


## La Lampada a baccello: un baccello di Linfa su un gambo.
static func _lampada(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, h * 0.5), 1, BARK[2])
	var c := Vector2(w * 0.5, h * 0.35)
	Px.disc(im, c.x, c.y, 4.2, LEAF[0])
	Px.disc(im, c.x, c.y, 3.4, LINFA[2])
	Px.disc(gm, c.x, c.y, 3.0, LINFA[3])
	Px.put(im, int(c.x) - 1, int(c.y) - 2, LINFA[3])


## Una macchina senza disegno suo: una cassa di corteccia con una finestra di Linfa (si vede che è della rete).
static func _scatola(im: Image, gm: Image, w: int, h: int, _d: Dictionary) -> void:
	_rect(im, 1, 2, w - 1, h, BARK[0])
	_rect(im, 2, 3, w - 2, h - 1, BARK[2])
	for y in range(4, h - 2, 3):
		_rect(im, 2, y, w - 2, y + 1, BARK[1])
	var c := Vector2(w * 0.5, h * 0.45)
	Px.disc(im, c.x, c.y, minf(w, h) * 0.22, SLATE[0])
	Px.disc(im, c.x, c.y, minf(w, h) * 0.16, LINFA[2])
	Px.disc(gm, c.x, c.y, minf(w, h) * 0.14, LINFA[3])


## La Leva di radice: un ceppo con un ramo che si alza; la punta brilla quando è alzata.
static func _leva(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	_rect(im, 4, h - 6, w - 4, h - 3, BARK[1])
	_rect(im, 5, h - 6, w - 5, h - 5, BARK[3])
	Px.line(im, Vector2(w * 0.5, h - 6), Vector2(w - 4, 3), 2, BARK[2])
	Px.disc(im, w - 4, 3, 1.8, LINFA[2])
	Px.disc(gm, w - 4, 3, 1.6, LINFA[3])


## Il Pulsante di radice: un nodo di corteccia con una goccia di Linfa da premere.
static func _pulsante(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.disc(im, w * 0.5, h - 6, 4.5, BARK[1])
	Px.disc(im, w * 0.5, h - 7, 2.6, LINFA[1])
	Px.disc(gm, w * 0.5, h - 7, 2.4, LINFA[3])


## La Piastra di radice: una lastra bassa con le venature.
static func _piastra(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 0, h - 4, w, h, BARK[0])
	_rect(im, 1, h - 4, w - 1, h - 2, BARK[2])
	for x in range(2, w - 2, 3):
		Px.put(im, x, h - 3, BARK[3])
		Px.put(gm, x, h - 3, LINFA[3])


## La Porta di radice viva: tavole di corteccia intrecciate con una vena di Linfa nel mezzo.
static func _porta(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 1, 0, w - 1, h, BARK[0])
	_rect(im, 2, 1, w - 2, h - 1, BARK[2])
	for y in range(3, h - 1, 4):
		_rect(im, 2, y, w - 2, y + 1, BARK[1])
	for y in range(2, h - 2):
		Px.put(im, int(w * 0.5), y, LINFA[1])
		if y % 2 == 0:
			Px.put(gm, int(w * 0.5), y, LINFA[3])
	Px.put(im, w - 4, int(h * 0.55), AMBER[2])
