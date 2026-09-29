class_name MachineArtMore
extends RefCounted
## Roadmap 19: i disegni delle macchine dalla voce 198 in poi (muoversi, luce, liquidi, giardino, fabbricare), chiamati
## da `MachineArt.draw` per i `look` che non conosce. Stesse tavolozze e stessi aiuti di `MachineArt`.


static func draw(look: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match look:
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
		"forno":
			_forno(im, gm, w, h)
		"frantoio":
			_frantoio(im, gm, w, h)
		"telaio_linfa":
			_telaio_linfa(im, gm, w, h)
		"braccio":
			_braccio(im, gm, w, h)
		"smistatore":
			_smistatore(im, gm, w, h)
		"nodo_casse":
			_nodo_casse(im, gm, w, h)
		"magazzino":
			_magazzino(im, gm, w, h)
		"trivella":
			_trivella(im, gm, w, h)
		"torretta":
			_torretta(im, gm, w, h)
		"rovo":
			_rovo(im, gm, w, h)
		"campana":
			_campana(im, gm, w, h)
		"scudo":
			_scudo(im, gm, w, h)
		_:
			return false
	return true


## L'Ascensore a bolla: una conca di corteccia con la bocca di Linfa da cui escono le bolle.
static func _ascensore(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 0, h - 6, w, h, MachineArt.BARK[0])
	MachineArt._rect(im, 1, h - 6, w - 1, h - 1, MachineArt.BARK[2])
	MachineArt._rect(im, 3, h - 7, w - 3, h - 4, MachineArt.LINFA[1])
	MachineArt._rect(gm, 4, h - 7, w - 4, h - 5, MachineArt.LINFA[3])
	for p in [Vector2(w * 0.3, h * 0.35), Vector2(w * 0.6, h * 0.2), Vector2(w * 0.75, h * 0.5)]:
		Px.disc(im, p.x, p.y, 1.4, MachineArt.LINFA[2])
		Px.disc(gm, p.x, p.y, 1.0, MachineArt.LINFA[3])


## Il Nastro vivo: una striscia di foglie intrecciate con le frecce di Linfa.
static func _nastro(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 0, h - 5, w, h, MachineArt.BARK[0])
	MachineArt._rect(im, 0, h - 5, w, h - 2, MachineArt.LEAF[1])
	for x in range(1, w, 4):
		Px.put(im, x, h - 4, MachineArt.LEAF[3])
		Px.put(im, x + 1, h - 3, MachineArt.LEAF[2])
	Px.put(im, w - 4, h - 4, MachineArt.LINFA[3])
	Px.put(gm, w - 4, h - 4, MachineArt.LINFA[3])
	Px.put(im, w - 5, h - 3, MachineArt.LINFA[2])


## La Catapulta di spore: un grosso fungo a molla, il cappello pieno di spore.
static func _catapulta(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, h * 0.5), 2, MachineArt.BARK[3])
	for y in range(int(h * 0.3), int(h * 0.55)):
		for x in w:
			var dx := (x + 0.5 - w * 0.5) / (w * 0.5)
			var top := h * 0.3 + (1.0 - (1.0 - dx * dx)) * h * 0.2
			if y >= top:
				Px.put(im, x, y, Color("#b04a3a") if (x + y) % 5 != 0 else Color("#f0e0c0"))
	Px.disc(gm, w * 0.5, h * 0.42, 1.5, Color("#ffd0a0"))


## La Porta-seme: un arco di radici attorno a un grande seme che brilla.
static func _porta_seme(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	Px.curve(im, Vector2(2, h - 3), Vector2(w * 0.5, -h * 0.3), Vector2(w - 3, h - 3), 3, MachineArt.BARK[1])
	Px.curve(im, Vector2(3, h - 3), Vector2(w * 0.5, -h * 0.2), Vector2(w - 4, h - 3), 1, MachineArt.BARK[3])
	var c := Vector2(w * 0.5, h * 0.55)
	Px.disc(im, c.x, c.y, w * 0.26, MachineArt.AMBER[1])
	Px.disc(im, c.x, c.y, w * 0.2, MachineArt.AMBER[2])
	Px.disc(gm, c.x, c.y, w * 0.16, MachineArt.AMBER[3])
	Px.line(im, c + Vector2(0, -w * 0.2), c + Vector2(0, w * 0.2), 1, MachineArt.AMBER[0])


## Il Faro di Linfa: una colonna di ardesia con in cima un grande baccello luminoso.
static func _faro(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	MachineArt._rect(im, int(w * 0.3), int(h * 0.35), int(w * 0.7), h - 3, MachineArt.SLATE[1])
	MachineArt._rect(im, int(w * 0.3), int(h * 0.35), int(w * 0.4), h - 3, MachineArt.SLATE[2])
	Px.disc(im, w * 0.5, h * 0.2, w * 0.42, MachineArt.LINFA[1])
	Px.disc(im, w * 0.5, h * 0.2, w * 0.3, MachineArt.LINFA[3])
	Px.disc(gm, w * 0.5, h * 0.2, w * 0.4, MachineArt.LINFA[3])


## La Cupola di quiete: una campana di cristallo celeste su una base di radice.
static func _cupola(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	var c := Vector2(w * 0.5, h - 4)
	for y in h - 4:
		for x in w:
			var p := Vector2(x + 0.5, y + 0.5) - c
			if p.length() <= w * 0.46 and p.y <= 0.0:
				Px.put(im, x, y, Color("#9ad8f0") if p.length() > w * 0.38 else Color("#3a6a88"))
	Px.disc(gm, c.x, c.y - h * 0.35, 2.5, Color("#d0f8ff"))


## L'Insegna di Linfa: una piccola goccia luminosa su una placca.
static func _insegna(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 2, 3, w - 2, h - 3, MachineArt.BARK[1])
	Px.disc(im, w * 0.5, h * 0.5, 3.0, MachineArt.LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.5, 2.6, Color("#ffffff"))


## La Pompa di radice (e lo Sbocco): un cilindro di legnoferro con un tubo, in giù per la pompa, in giù aperto per lo sbocco.
static func _pompa(im: Image, gm: Image, w: int, h: int, outlet: bool) -> void:
	MachineArt._rect(im, 3, 1, w - 3, h - 4, MachineArt.SLATE[1])
	MachineArt._rect(im, 4, 2, w - 4, h - 5, MachineArt.SLATE[2])
	MachineArt._rect(im, int(w * 0.4), h - 4, int(w * 0.6), h, MachineArt.SLATE[0])
	if outlet:
		MachineArt._rect(im, int(w * 0.3), h - 2, int(w * 0.7), h, MachineArt.LINFA[1])
	Px.disc(im, w * 0.5, h * 0.35, 1.8, MachineArt.LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.35, 1.5, MachineArt.LINFA[3])


## La Chiusa di radice: un blocco di legnoferro con le fasce.
static func _chiusa(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 0, 0, w, h, MachineArt.SLATE[0])
	MachineArt._rect(im, 1, 1, w - 1, h - 1, MachineArt.SLATE[2])
	for y in [4, h - 5]:
		MachineArt._rect(im, 1, y, w - 1, y + 1, MachineArt.SLATE[0])
	Px.put(im, w / 2, h / 2, MachineArt.LINFA[2])
	Px.put(gm, w / 2, h / 2, MachineArt.LINFA[3])


## L'Irrigatore: un fiore di legnoferro che spruzza gocce.
static func _irrigatore(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, h * 0.4), 1, MachineArt.SLATE[2])
	Px.disc(im, w * 0.5, h * 0.35, 3.0, MachineArt.SLATE[1])
	for a in [-0.6, 0.0, 0.6]:
		var p := Vector2(w * 0.5, h * 0.35) + Vector2(sin(a), -cos(a)) * 5.0
		Px.put(im, int(p.x), int(p.y), Color("#8ad8ff"))
		Px.put(gm, int(p.x), int(p.y), Color("#c0f0ff"))


## Il Distillatore: un alambicco d'ambra su un piede di pietra.
static func _distillatore(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 2, h - 6, w - 2, h, MachineArt.SLATE[0])
	Px.disc(im, w * 0.4, h * 0.55, w * 0.3, MachineArt.AMBER[1])
	Px.disc(im, w * 0.4, h * 0.55, w * 0.22, MachineArt.LINFA[1])
	Px.disc(gm, w * 0.4, h * 0.55, w * 0.18, MachineArt.LINFA[2])
	Px.line(im, Vector2(w * 0.4, h * 0.25), Vector2(w - 3, h * 0.45), 1, MachineArt.AMBER[2])
	MachineArt._rect(im, w - 5, int(h * 0.45), w - 2, h - 6, MachineArt.AMBER[0])


## La Serra di Linfa: una campana di vetro su un'aiuola con i germogli.
static func _serra(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, h - 5, w - 1, h, MachineArt.BARK[1])
	for x in range(3, w - 3, 4):
		Px.line(im, Vector2(x, h - 5), Vector2(x, h - 9), 1, MachineArt.LEAF[2])
	for y in range(2, h - 5):
		Px.put(im, 1, y, Color("#a8e0e0"))
		Px.put(im, w - 2, y, Color("#a8e0e0"))
	for x in range(1, w - 1):
		Px.put(im, x, 2, Color("#a8e0e0"))
	Px.disc(gm, w * 0.5, h * 0.35, 2.0, MachineArt.LINFA[3])


## La Mietitrice: una falce di legnoferro su una ruota, con la cassetta.
static func _mietitrice(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 2, 4, w - 2, h - 2, MachineArt.BARK[1])
	MachineArt._rect(im, 3, 5, w - 3, h - 3, MachineArt.BARK[2])
	Px.curve(im, Vector2(w - 3, 4), Vector2(w - 1, 0), Vector2(w - 8, 1), 1, MachineArt.SLATE[3])
	Px.disc(im, 4, h - 2, 2.0, MachineArt.SLATE[1])
	Px.put(gm, w / 2, 7, MachineArt.LINFA[3])


## La Mungitrice: un secchio di legno con un tubo di Linfa.
static func _mungitrice(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 3, int(h * 0.4), w - 3, h - 1, MachineArt.BARK[1])
	MachineArt._rect(im, 4, int(h * 0.4) + 1, w - 4, h - 2, MachineArt.BARK[3])
	MachineArt._rect(im, 4, int(h * 0.4) + 1, w - 4, int(h * 0.4) + 3, Color("#f0ece0"))
	Px.line(im, Vector2(w * 0.5, 1), Vector2(w * 0.5, h * 0.4), 1, MachineArt.LINFA[1])
	Px.put(gm, int(w * 0.5), 2, MachineArt.LINFA[3])


## La Culla calda: un nido di lana con una brace che scalda.
static func _culla(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	Px.disc(im, w * 0.5, h * 0.6, w * 0.4, Color("#e8dcc8"))
	Px.disc(im, w * 0.5, h * 0.55, w * 0.22, Color("#ff9a50"))
	Px.disc(gm, w * 0.5, h * 0.55, w * 0.18, Color("#ffc080"))


## Il Forno a Linfa: un forno di ardesia con la bocca di brace e una vena di Linfa che lo nutre.
static func _forno(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, 3, w - 1, h, MachineArt.SLATE[0])
	MachineArt._rect(im, 2, 4, w - 2, h - 1, MachineArt.SLATE[1])
	MachineArt._rect(im, int(w * 0.3), int(h * 0.5), int(w * 0.7), h - 3, Color("#401810"))
	MachineArt._rect(im, int(w * 0.34), int(h * 0.55), int(w * 0.66), h - 4, Color("#ff8a40"))
	MachineArt._rect(gm, int(w * 0.36), int(h * 0.58), int(w * 0.64), h - 5, Color("#ffc080"))
	MachineArt._rect(im, w - 5, 0, w - 2, 4, MachineArt.SLATE[0])
	Px.line(im, Vector2(2, 6), Vector2(w - 3, 6), 1, MachineArt.LINFA[1])


## Il Frantoio: due mole di pietra una sopra l'altra.
static func _frantoio(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, h - 5, w - 1, h, MachineArt.BARK[1])
	Px.disc(im, w * 0.5, h * 0.45, w * 0.36, MachineArt.SLATE[1])
	Px.disc(im, w * 0.5, h * 0.45, w * 0.28, MachineArt.SLATE[2])
	Px.disc(im, w * 0.5, h * 0.45, 2.0, MachineArt.LINFA[1])
	Px.disc(gm, w * 0.5, h * 0.45, 1.5, MachineArt.LINFA[3])
	for k in 6:
		var a := k * PI / 3.0
		Px.put(im, int(w * 0.5 + cos(a) * w * 0.2), int(h * 0.45 + sin(a) * w * 0.2), MachineArt.SLATE[0])


## Il Telaio a Linfa: un telaio con i fili di seta tesi e una spola che brilla.
static func _telaio_linfa(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, 1, 3, h, MachineArt.BARK[1])
	MachineArt._rect(im, w - 3, 1, w - 1, h, MachineArt.BARK[1])
	MachineArt._rect(im, 1, 1, w - 1, 3, MachineArt.BARK[2])
	for x in range(4, w - 3, 2):
		Px.line(im, Vector2(x, 3), Vector2(x, h - 2), 1, Color("#f0ece0"))
	Px.disc(im, w * 0.5, h * 0.65, 1.8, MachineArt.LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.65, 1.4, MachineArt.LINFA[3])


## Il Braccio di radice: una radice piegata con una pinza, sopra un piede.
static func _braccio(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 3, h - 4, w - 3, h, MachineArt.BARK[1])
	Px.line(im, Vector2(w * 0.5, h - 4), Vector2(w * 0.3, h * 0.35), 2, MachineArt.BARK[2])
	Px.line(im, Vector2(w * 0.3, h * 0.35), Vector2(w * 0.75, h * 0.2), 2, MachineArt.BARK[2])
	Px.put(im, int(w * 0.8), int(h * 0.15), MachineArt.SLATE[3])
	Px.put(im, int(w * 0.8), int(h * 0.28), MachineArt.SLATE[3])
	Px.put(gm, int(w * 0.3), int(h * 0.35), MachineArt.LINFA[3])


## Lo Smistatore: un imbuto di corteccia con le frecce di Linfa.
static func _smistatore(im: Image, gm: Image, w: int, h: int) -> void:
	for y in h - 2:
		var half := int(lerpf(w * 0.48, w * 0.18, float(y) / h))
		MachineArt._rect(im, w / 2 - half, y, w / 2 + half, y + 1, MachineArt.BARK[1] if y % 3 else MachineArt.BARK[0])
	MachineArt._rect(im, int(w * 0.35), h - 3, int(w * 0.65), h, MachineArt.SLATE[1])
	Px.put(im, int(w * 0.5), int(h * 0.4), MachineArt.LINFA[3])
	Px.put(gm, int(w * 0.5), int(h * 0.4), MachineArt.LINFA[3])


## Il Nodo delle casse: un nodo di radice con quattro vene che escono.
static func _nodo_casse(im: Image, gm: Image, w: int, h: int) -> void:
	var c := Vector2(w * 0.5, h * 0.5)
	for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
		Px.line(im, c, c + d * (w * 0.5), 1, MachineArt.BARK[2])
	Px.disc(im, c.x, c.y, 4.0, MachineArt.BARK[1])
	Px.disc(im, c.x, c.y, 2.6, MachineArt.AMBER[2])
	Px.disc(gm, c.x, c.y, 2.2, MachineArt.AMBER[3])


## Il Magazzino vivo: una grande cassa d'ambra con le fasce e una finestra di Linfa.
static func _magazzino(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, 3, w - 1, h, MachineArt.BARK[0])
	MachineArt._rect(im, 2, 4, w - 2, h - 1, MachineArt.BARK[2])
	for y in [8, int(h * 0.55), h - 6]:
		MachineArt._rect(im, 2, y, w - 2, y + 2, MachineArt.AMBER[1])
	MachineArt._rect(im, 1, 2, w - 1, 5, MachineArt.BARK[1])
	Px.disc(im, w * 0.5, h * 0.35, 3.0, MachineArt.LINFA[1])
	Px.disc(gm, w * 0.5, h * 0.35, 2.4, MachineArt.LINFA[3])


## La Trivella di radice: un castello di legnoferro con la punta a spirale che scende nel terreno.
static func _trivella(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._rect(im, 1, 1, w - 1, 4, MachineArt.SLATE[1])
	MachineArt._rect(im, 2, 4, 5, h, MachineArt.SLATE[0])
	MachineArt._rect(im, w - 5, 4, w - 2, h, MachineArt.SLATE[0])
	for y in range(5, h):
		var half := maxi(1, int((h - y) * 0.35) + 1)
		MachineArt._rect(im, w / 2 - half, y, w / 2 + half, y + 1, MachineArt.SLATE[2] if y % 2 == 0 else MachineArt.SLATE[3])
	Px.disc(im, w * 0.5, 3, 2.0, MachineArt.LINFA[1])
	Px.disc(gm, w * 0.5, 3, 1.6, MachineArt.LINFA[3])


## La Torretta di spine: un tronco di legnoferro con un arco di radice in cima.
static func _torretta(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	MachineArt._rect(im, 4, int(h * 0.35), w - 4, h - 3, MachineArt.SLATE[1])
	Px.curve(im, Vector2(1, h * 0.3), Vector2(w * 0.5, 0), Vector2(w - 2, h * 0.3), 1, MachineArt.BARK[2])
	Px.line(im, Vector2(1, h * 0.3), Vector2(w - 2, h * 0.3), 1, Color("#f0ece0"))
	Px.disc(im, w * 0.5, h * 0.45, 1.5, MachineArt.LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.45, 1.2, MachineArt.LINFA[3])


## Il Rovo vivo: un cespuglio di spine con le punte che brillano.
static func _rovo(im: Image, gm: Image, w: int, h: int) -> void:
	for k in 5:
		var a := Vector2(2 + k * 3, h - 1)
		var b := Vector2(1 + (k * 7) % w, 2 + (k * 5) % 6)
		Px.line(im, a, b, 1, MachineArt.LEAF[0] if k % 2 else MachineArt.BARK[1])
		Px.put(im, int(b.x), int(b.y), Color("#e0d0a0"))
		Px.put(gm, int(b.x), int(b.y), Color("#ffe0a0"))


## La Campana d'allarme: una campana d'ambra appesa a un arco di radice.
static func _campana(im: Image, gm: Image, w: int, h: int) -> void:
	MachineArt._roots(im, w, h)
	Px.line(im, Vector2(w * 0.5, h - 3), Vector2(w * 0.5, 3), 1, MachineArt.BARK[2])
	for y in range(4, int(h * 0.55)):
		var half := int(lerpf(2.0, w * 0.45, float(y - 4) / (h * 0.55 - 4)))
		MachineArt._rect(im, w / 2 - half, y, w / 2 + half, y + 1, MachineArt.AMBER[1] if y % 3 else MachineArt.AMBER[2])
	Px.put(gm, w / 2, int(h * 0.55), MachineArt.AMBER[3])


## Lo Scudo di corteccia: uno scudo tondo di corteccia con il bordo di legnoferro.
static func _scudo(im: Image, gm: Image, w: int, h: int) -> void:
	Px.disc(im, w * 0.5, h * 0.5, w * 0.46, MachineArt.SLATE[1])
	Px.disc(im, w * 0.5, h * 0.5, w * 0.36, MachineArt.BARK[2])
	Px.disc(im, w * 0.5, h * 0.5, 1.5, MachineArt.LINFA[2])
	Px.disc(gm, w * 0.5, h * 0.5, 1.2, MachineArt.LINFA[3])
