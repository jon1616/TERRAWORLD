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
		"cisterna":
			_cisterna(im, gm, w, h)
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
		"mulino":
			_mulino(im, gm, w, h)
		"ruota":
			_ruota(im, gm, w, h)
		"brace":
			_brace(im, gm, w, h)
		"pozzo":
			_pozzo(im, gm, w, h)
		"cuore_cristallo":
			_cuore_cristallo(im, gm, w, h)
		"ruota_mandria":
			_ruota_mandria(im, gm, w, h)
		"parafulmine":
			_parafulmine(im, gm, w, h)
		"radice_madre":
			_radice_madre(im, gm, w, h)
		"ascensore":
			_ascensore(im, gm, w, h)
		"nastro":
			_nastro(im, gm, w, h)
		"catapulta":
			_catapulta(im, gm, w, h)
		"porta_seme":
			_porta_seme(im, gm, w, h)
		"faro":
			_faro(im, gm, w, h)
		"cupola":
			_cupola(im, gm, w, h)
		"insegna":
			_insegna(im, gm, w, h)
		"pompa", "sbocco":
			_pompa(im, gm, w, h, look == "sbocco")
		"chiusa":
			_chiusa(im, gm, w, h)
		"irrigatore":
			_irrigatore(im, gm, w, h)
		"distillatore":
			_distillatore(im, gm, w, h)
		"serra":
			_serra(im, gm, w, h)
		"mietitrice":
			_mietitrice(im, gm, w, h)
		"mungitrice":
			_mungitrice(im, gm, w, h)
		"culla":
			_culla(im, gm, w, h)
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


## Il Mulino di semi: un fusto di radice e quattro pale di pappo bianco attorno a un mozzo di Linfa.
static func _mulino(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var hub := Vector2(w * 0.5, h * 0.32)
	Px.line(im, Vector2(w * 0.5, h - 3), hub, 2, BARK[2])
	for k in 4:
		var a := k * PI * 0.5 + 0.4
		var tip := hub + Vector2(cos(a), sin(a)) * (w * 0.46)
		Px.line(im, hub, tip, 1, BARK[3])
		for t in [0.45, 0.7, 0.95]:
			var p := hub.lerp(tip, t)
			Px.disc(im, p.x, p.y, 1.6, Color("#f0ece0"))
	Px.disc(im, hub.x, hub.y, 2.4, BARK[1])
	Px.disc(im, hub.x, hub.y, 1.4, LINFA[2])
	Px.disc(gm, hub.x, hub.y, 1.3, LINFA[3])


## La Ruota d'acqua: una ruota di legnoferro a pale con l'asse di Linfa.
static func _ruota(im: Image, gm: Image, w: int, h: int) -> void:
	var c := Vector2(w * 0.5, h * 0.5)
	var r := minf(w, h) * 0.46
	Px.disc(im, c.x, c.y, r, SLATE[0])
	Px.disc(im, c.x, c.y, r - 2.0, Color(0, 0, 0, 0))
	for y in h:
		for x in w:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(c)
			if d <= r and d >= r - 2.0:
				Px.put(im, x, y, SLATE[1])
	for k in 8:
		var a := k * PI / 4.0
		var p := c + Vector2(cos(a), sin(a)) * r
		Px.line(im, c, p, 1, SLATE[2])
		Px.disc(im, p.x, p.y, 1.6, BARK[2])
	Px.disc(im, c.x, c.y, 2.2, LINFA[1])
	Px.disc(gm, c.x, c.y, 1.6, LINFA[3])


## Il Baccello di brace: un baccello scuro di ardesia con la bocca di brace che brilla.
static func _brace(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var c := Vector2(w * 0.5, h * 0.52)
	Px.disc(im, c.x, c.y, w * 0.44, SLATE[0])
	Px.disc(im, c.x, c.y, w * 0.38, SLATE[1])
	Px.disc(im, c.x, c.y + 3, w * 0.2, Color("#401810"))
	Px.disc(im, c.x, c.y + 3, w * 0.15, Color("#ff7a30"))
	Px.disc(gm, c.x, c.y + 3, w * 0.14, Color("#ffb060"))
	Px.line(im, Vector2(c.x, 1), Vector2(c.x, c.y - w * 0.3), 2, BARK[1])


## Il Pozzo di Linfa: un anello di pietra e una vasca di Linfa luminosa con un tubo di radice che scende.
static func _pozzo(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 1, int(h * 0.4), w - 1, h, SLATE[0])
	_rect(im, 3, int(h * 0.4) + 2, w - 3, h - 2, LINFA[1])
	_rect(gm, 4, int(h * 0.4) + 3, w - 4, h - 3, LINFA[2])
	for x in range(1, w - 1, 3):
		Px.put(im, x, int(h * 0.4), SLATE[2])
	Px.line(im, Vector2(w * 0.5, 1), Vector2(w * 0.5, h - 2), 2, BARK[2])
	Px.disc(im, w * 0.5, 3, 2.4, BARK[1])


## Il Cuore di cristallo: un cristallo di Linfa stretto in una radice.
static func _cuore_cristallo(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var c := Vector2(w * 0.5, h * 0.45)
	for y in h:
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - c
			if absf(p.x) / (w * 0.3) + absf(p.y) / (h * 0.4) <= 1.0:
				Px.put(im, x, y, LINFA[2] if p.x < 0 else LINFA[1])
				if absf(p.x) / (w * 0.3) + absf(p.y) / (h * 0.4) <= 0.6:
					Px.put(gm, x, y, LINFA[3])
	Px.line(im, Vector2(3, h - 4), c + Vector2(-3, 4), 2, BARK[1])
	Px.line(im, Vector2(w - 4, h - 4), c + Vector2(3, 4), 2, BARK[1])


## La Ruota della mandria: una grande ruota di corteccia dove corre una creatura, su due piedi di radice.
static func _ruota_mandria(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var c := Vector2(w * 0.5, h * 0.5)
	var r := h * 0.47
	for y in h:
		for x in w:
			var d := Vector2(x + 0.5, y + 0.5).distance_to(c)
			if d <= r and d >= r - 2.5:
				Px.put(im, x, y, BARK[2] if d > r - 1.2 else BARK[1])
	for k in 6:
		var a := k * PI / 3.0
		Px.line(im, c, c + Vector2(cos(a), sin(a)) * (r - 1.0), 1, BARK[0])
	Px.disc(im, c.x, c.y, 2.0, LINFA[1])
	Px.disc(gm, c.x, c.y, 1.5, LINFA[3])


## Il Parafulmine di radice: un'asta alta di legnoferro con la punta di folgorite.
static func _parafulmine(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, 4), 2, SLATE[2])
	for y in range(8, h - 4, 6):
		Px.put(im, int(w * 0.5) - 1, y, SLATE[0])
		Px.put(im, int(w * 0.5) + 1, y + 2, LINFA[1])
	Px.disc(im, w * 0.5, 3, 2.4, Color("#d8e8ff"))
	Px.disc(gm, w * 0.5, 3, 2.0, Color("#f0f8ff"))


## La Radice-madre: un groviglio di radici grosse con i nodi di Linfa che pulsano.
static func _radice_madre(im: Image, gm: Image, w: int, h: int) -> void:
	for k in 5:
		var a := Vector2(2 + k * (w - 4) / 4.0, h - 1)
		var b := Vector2(w * 0.5 + (k - 2) * 2.0, 3)
		Px.curve(im, a, Vector2(w * 0.5 + (2 - k) * 4.0, h * 0.5), b, 2, BARK[1] if k % 2 == 0 else BARK[2])
	for p in [Vector2(w * 0.3, h * 0.35), Vector2(w * 0.65, h * 0.55), Vector2(w * 0.5, h * 0.2)]:
		Px.disc(im, p.x, p.y, 1.8, LINFA[2])
		Px.disc(gm, p.x, p.y, 1.6, LINFA[3])


## La Cisterna viva: una vasca di corteccia cerchiata di legnoferro con una grande finestra dove sale la Linfa.
static func _cisterna(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 1, 2, w - 1, h, BARK[0])
	_rect(im, 2, 3, w - 2, h - 1, BARK[2])
	for y in [5, h - 6]:
		_rect(im, 1, y, w - 1, y + 2, SLATE[1])
	_rect(im, 6, 9, w - 6, h - 9, SLATE[0])
	_rect(im, 7, int(h * 0.45), w - 7, h - 10, LINFA[1])
	_rect(gm, 8, int(h * 0.45) + 1, w - 8, h - 11, LINFA[2])
	_rect(im, int(w * 0.3), 0, int(w * 0.7), 3, BARK[1])


## L'Ascensore a bolla: una conca di corteccia con la bocca di Linfa da cui escono le bolle.
static func _ascensore(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 0, h - 6, w, h, BARK[0])
	_rect(im, 1, h - 6, w - 1, h - 1, BARK[2])
	_rect(im, 3, h - 7, w - 3, h - 4, LINFA[1])
	_rect(gm, 4, h - 7, w - 4, h - 5, LINFA[3])
	for p in [Vector2(w * 0.3, h * 0.35), Vector2(w * 0.6, h * 0.2), Vector2(w * 0.75, h * 0.5)]:
		Px.disc(im, p.x, p.y, 1.4, LINFA[2])
		Px.disc(gm, p.x, p.y, 1.0, LINFA[3])


## Il Nastro vivo: una striscia di foglie intrecciate con le frecce di Linfa.
static func _nastro(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 0, h - 5, w, h, BARK[0])
	_rect(im, 0, h - 5, w, h - 2, LEAF[1])
	for x in range(1, w, 4):
		Px.put(im, x, h - 4, LEAF[3])
		Px.put(im, x + 1, h - 3, LEAF[2])
	Px.put(im, w - 4, h - 4, LINFA[3])
	Px.put(gm, w - 4, h - 4, LINFA[3])
	Px.put(im, w - 5, h - 3, LINFA[2])


## La Catapulta di spore: un grosso fungo a molla, il cappello pieno di spore.
static func _catapulta(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, h * 0.5), 2, BARK[3])
	for y in range(int(h * 0.3), int(h * 0.55)):
		for x in w:
			var dx := (x + 0.5 - w * 0.5) / (w * 0.5)
			var top := h * 0.3 + (1.0 - (1.0 - dx * dx)) * h * 0.2
			if y >= top:
				Px.put(im, x, y, Color("#b04a3a") if (x + y) % 5 != 0 else Color("#f0e0c0"))
	Px.disc(gm, w * 0.5, h * 0.42, 1.5, Color("#ffd0a0"))


## La Porta-seme: un arco di radici attorno a un grande seme che brilla.
static func _porta_seme(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.curve(im, Vector2(2, h - 3), Vector2(w * 0.5, -h * 0.3), Vector2(w - 3, h - 3), 3, BARK[1])
	Px.curve(im, Vector2(3, h - 3), Vector2(w * 0.5, -h * 0.2), Vector2(w - 4, h - 3), 1, BARK[3])
	var c := Vector2(w * 0.5, h * 0.55)
	Px.disc(im, c.x, c.y, w * 0.26, AMBER[1])
	Px.disc(im, c.x, c.y, w * 0.2, AMBER[2])
	Px.disc(gm, c.x, c.y, w * 0.16, AMBER[3])
	Px.line(im, c + Vector2(0, -w * 0.2), c + Vector2(0, w * 0.2), 1, AMBER[0])


## Il Faro di Linfa: una colonna di ardesia con in cima un grande baccello luminoso.
static func _faro(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	_rect(im, int(w * 0.3), int(h * 0.35), int(w * 0.7), h - 3, SLATE[1])
	_rect(im, int(w * 0.3), int(h * 0.35), int(w * 0.4), h - 3, SLATE[2])
	Px.disc(im, w * 0.5, h * 0.2, w * 0.42, LINFA[1])
	Px.disc(im, w * 0.5, h * 0.2, w * 0.3, LINFA[3])
	Px.disc(gm, w * 0.5, h * 0.2, w * 0.4, LINFA[3])


## La Cupola di quiete: una campana di cristallo celeste su una base di radice.
static func _cupola(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	var c := Vector2(w * 0.5, h - 4)
	for y in h - 4:
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - c
			if p.length() <= w * 0.46 and p.y <= 0.0:
				Px.put(im, x, y, Color("#9ad8f0") if p.length() > w * 0.38 else Color("#3a6a88"))
	Px.disc(gm, c.x, c.y - h * 0.35, 2.5, Color("#d0f8ff"))


## L'Insegna di Linfa: una piccola goccia luminosa su una placca.
static func _insegna(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 2, 3, w - 2, h - 3, BARK[1])
	Px.disc(im, w * 0.5, h * 0.5, 3.0, LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.5, 2.6, Color("#ffffff"))


## La Pompa di radice (e lo Sbocco): un cilindro di legnoferro con un tubo, in giù per la pompa, in giù aperto per lo sbocco.
static func _pompa(im: Image, gm: Image, w: int, h: int, outlet: bool) -> void:
	_rect(im, 3, 1, w - 3, h - 4, SLATE[1])
	_rect(im, 4, 2, w - 4, h - 5, SLATE[2])
	_rect(im, int(w * 0.4), h - 4, int(w * 0.6), h, SLATE[0])
	if outlet:
		_rect(im, int(w * 0.3), h - 2, int(w * 0.7), h, LINFA[1])
	Px.disc(im, w * 0.5, h * 0.35, 1.8, LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.35, 1.5, LINFA[3])


## La Chiusa di radice: un blocco di legnoferro con le fasce.
static func _chiusa(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 0, 0, w, h, SLATE[0])
	_rect(im, 1, 1, w - 1, h - 1, SLATE[2])
	for y in [4, h - 5]:
		_rect(im, 1, y, w - 1, y + 1, SLATE[0])
	Px.put(im, w / 2, h / 2, LINFA[2])
	Px.put(gm, w / 2, h / 2, LINFA[3])


## L'Irrigatore: un fiore di legnoferro che spruzza gocce.
static func _irrigatore(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, h * 0.4), 1, SLATE[2])
	Px.disc(im, w * 0.5, h * 0.35, 3.0, SLATE[1])
	for a in [-0.6, 0.0, 0.6]:
		var p := Vector2(w * 0.5, h * 0.35) + Vector2(sin(a), -cos(a)) * 5.0
		Px.put(im, int(p.x), int(p.y), Color("#8ad8ff"))
		Px.put(gm, int(p.x), int(p.y), Color("#c0f0ff"))


## Il Distillatore: un alambicco d'ambra su un piede di pietra.
static func _distillatore(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 2, h - 6, w - 2, h, SLATE[0])
	Px.disc(im, w * 0.4, h * 0.55, w * 0.3, AMBER[1])
	Px.disc(im, w * 0.4, h * 0.55, w * 0.22, LINFA[1])
	Px.disc(gm, w * 0.4, h * 0.55, w * 0.18, LINFA[2])
	Px.line(im, Vector2(w * 0.4, h * 0.25), Vector2(w - 3, h * 0.45), 1, AMBER[2])
	_rect(im, w - 5, int(h * 0.45), w - 2, h - 6, AMBER[0])


## La Serra di Linfa: una campana di vetro su un'aiuola con i germogli.
static func _serra(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 1, h - 5, w - 1, h, BARK[1])
	for x in range(3, w - 3, 4):
		Px.line(im, Vector2(x, h - 5), Vector2(x, h - 9), 1, LEAF[2])
	for y in range(2, h - 5):
		Px.put(im, 1, y, Color("#a8e0e0"))
		Px.put(im, w - 2, y, Color("#a8e0e0"))
	for x in range(1, w - 1):
		Px.put(im, x, 2, Color("#a8e0e0"))
	Px.disc(gm, w * 0.5, h * 0.35, 2.0, LINFA[3])


## La Mietitrice: una falce di legnoferro su una ruota, con la cassetta.
static func _mietitrice(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 2, 4, w - 2, h - 2, BARK[1])
	_rect(im, 3, 5, w - 3, h - 3, BARK[2])
	Px.curve(im, Vector2(w - 3, 4), Vector2(w - 1, 0), Vector2(w - 8, 1), 1, SLATE[3])
	Px.disc(im, 4, h - 2, 2.0, SLATE[1])
	Px.put(gm, w / 2, 7, LINFA[3])


## La Mungitrice: un secchio di legno con un tubo di Linfa.
static func _mungitrice(im: Image, gm: Image, w: int, h: int) -> void:
	_rect(im, 3, int(h * 0.4), w - 3, h - 1, BARK[1])
	_rect(im, 4, int(h * 0.4) + 1, w - 4, h - 2, BARK[3])
	_rect(im, 4, int(h * 0.4) + 1, w - 4, int(h * 0.4) + 3, Color("#f0ece0"))
	Px.line(im, Vector2(w * 0.5, 1), Vector2(w * 0.5, h * 0.4), 1, LINFA[1])
	Px.put(gm, int(w * 0.5), 2, LINFA[3])


## La Culla calda: un nido di lana con una brace che scalda.
static func _culla(im: Image, gm: Image, w: int, h: int) -> void:
	_roots(im, w, h)
	Px.disc(im, w * 0.5, h * 0.6, w * 0.4, Color("#e8dcc8"))
	Px.disc(im, w * 0.5, h * 0.55, w * 0.22, Color("#ff9a50"))
	Px.disc(gm, w * 0.5, h * 0.55, w * 0.18, Color("#ffc080"))
