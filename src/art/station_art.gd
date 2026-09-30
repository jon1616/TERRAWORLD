class_name StationArt
extends RefCounted
## Le stazioni di fabbricazione disegnate dal codice, nello stile «Radici e Linfa», con la loro parte luminosa:
##   (ceppo, maglio e banco dell'Innestatrice: in `CompactArt`)
##   baccello_ardente  baccello di pietra ardesia con la bocca di brace accesa e crepe che brillano
##   cuore_mondo       il Cuore del mondo malato: un nodo grigio di radici con il cuore spento
##   cuore_vivo        lo stesso Cuore guarito: radici vive e un cuore di Linfa che brilla
##   portale           un arco di radici con un vortice di Linfa dentro
## Restituisce {img, glow} della misura della stazione (16 px per tessera).

const S := 16
const OUT := Color("#050c10")


static func make(id: String) -> Dictionary:
	var size: Array = StationsData.STATIONS[id]["size"]
	var w: int = size[0] * S
	var h: int = size[1] * S
	var drawn := StationTemplates.make(id, w, h)     # voce 106: il disegno di Nano Banana, se c'è
	if not drawn.is_empty():
		return drawn
	var im := Px.img(w, h)
	var gm := Px.img(w, h)
	if id.begins_with("albero_madre_"):              # voce 62: l'Albero-Madre, in cinque fasi (la sesta, d'oro: Roadmap 28)
		var ph := int(id.get_slice("_", 2))
		MotherTreeArt.draw(mini(ph, 4), im, gm, w, h)
		if ph >= 5:
			_gold(im, w, h)
		return {"img": im, "glow": gm}
	if id == "albero_antico":                        # Roadmap 28: l'Albero Antico, dorato
		MotherTreeArt.draw(4, im, gm, w, h)
		_gold(im, w, h)
		return {"img": im, "glow": gm}
	var lost := LostGardensData.tree_of(id)
	if String(lost[0]) != "":                        # Roadmap 21: un Albero perduto, malato o guarito, nel suo colore
		MotherTreeArt.draw(4 if bool(lost[1]) else 0, im, gm, w, h)
		var col: Color = LostGardensData.GARDENS[String(lost[0])]["color"]
		for y in h:
			for x in w:
				var p := im.get_pixel(x, y)
				if p.a > 0.0:
					im.set_pixel(x, y, Color(p.r, p.g, p.b, p.a).lerp(col * Color(p.v, p.v, p.v), 0.35 if bool(lost[1]) else 0.2))
		return {"img": im, "glow": gm}
	if SeminatoriArt.draw(id, im, gm, w, h):       # Roadmap 9: stele, meccanismi e luoghi dei Seminatori
		Px.outline(im, OUT)
		return {"img": im, "glow": gm}
	if FountainArt.draw(id, im, gm, w, h):         # voce 119: le fonti dei liquidi
		Px.outline(im, OUT)
		return {"img": im, "glow": gm}
	if MachineArt.draw(id, im, gm, w, h):          # Roadmap 19: le macchine della rete
		Px.outline(im, OUT)
		return {"img": im, "glow": gm}
	if CompactArt.draw(id, im, gm, w, h):          # banchi e mobili rimpiccioliti
		Px.outline(im, OUT)
		return {"img": im, "glow": gm}
	match id:
		"baccello_ardente":
			_baccello(im, gm, w, h)
		"cuore_mondo":
			_cuore(im, gm, w, h, false)
		"cuore_vivo":
			_cuore(im, gm, w, h, true)
		"cuore_meraviglia":
			_meraviglia(im, gm, w, h)
		"tenda_campo":
			_tenda(im, gm, w, h)
		"vetrina":
			_vetrina(im, gm, w, h)
		"dispensa":
			CompactArt._cassa(im, gm, w, h, "cristallo")          # voce 298: una cassa con la vena accesa
		"giacimento":
			_giacimento(im, gm, w, h)
		"portale":
			_portale(im, gm, w, h)
		"fagotto":
			_fagotto(im, gm, w, h)
		"aiuola":
			_aiuola(im, gm, w, h)
		"pianta_seme":
			_pianta_seme(im, gm, w, h)
		_:
			WorkshopArt.draw(id, im, gm, w, h)
	Px.outline(im, OUT)
	return {"img": im, "glow": gm}


static func _baccello(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var brace := Px.pal(TileDefs.P_BRACE)
	var cx := w / 2.0
	# il baccello: un'ellisse appoggiata, un po' appuntita in alto
	for y in h:
		for x in w:
			var dy := (y + 0.5 - (h - 1.0)) / (h - 2.0)
			var dx := (x + 0.5 - cx) / (w * 0.47 * (1.0 - maxf(-dy - 0.55, 0.0) * 1.2))
			if dx * dx + dy * dy <= 1.0 and y < h:
				var t := 0.6 - dx * 0.3 + dy * 0.2
				var c := st[clampi(int(t * 5.0), 0, 4)]
				if absi(x - int(cx)) == int(abs(dy) * 6.0) + 6:
					c = st[0]
				Px.put(im, x, y, c)
	# la bocca di brace
	for y in range(h - 14, h - 2):
		for x in range(int(cx - 7), int(cx + 7)):
			var d := Vector2((x + 0.5 - cx) / 6.5, (y + 0.5 - (h - 7.0)) / 6.0)
			if d.length() <= 1.0:
				var c := brace[3] if d.length() < 0.4 else (brace[2] if d.length() < 0.75 else brace[1])
				Px.put(im, x, y, c)
				Px.put(gm, x, y, c)
	# crepe che brillano
	for crack in [[Vector2(cx - 10.0, 10.0), Vector2(cx - 6.0, 16.0)], [Vector2(cx + 9.0, 8.0), Vector2(cx + 12.0, 15.0)]]:
		Px.line(im, crack[0], crack[1], 1, brace[2])
		Px.line(gm, crack[0], crack[1], 1, brace[2])


## Il Cuore del mondo: un groviglio di radici attorno a un cuore. Malato è grigio e spento; vivo brilla di Linfa.
static func _cuore(im: Image, gm: Image, w: int, h: int, alive: bool) -> void:
	var root := Px.pal(TileDefs.P_RADICE if alive else TileDefs.P_NODO)
	var core := Px.pal(TileDefs.P_CRYSTAL) if alive else Px.pal(["#2a2a26", "#4a4840", "#6a6656", "#8a8470", "#a8a08a"])
	var cx := w / 2.0
	var cy := h / 2.0 + 2.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	# il cuore: due lobi e una punta
	for y in h:
		for x in w:
			var u := (x + 0.5 - cx) / 11.0
			var v := (y + 0.5 - cy) / 10.0
			var a := u * u + pow(-v - sqrt(absf(u)) * 0.8, 2.0)
			if a <= 1.0:
				var c := core[clampi(int((0.8 - u * 0.3 + v * 0.3) * 4.0), 0, 4)]
				Px.put(im, x, y, c)
				if alive or a < 0.25:
					Px.put(gm, x, y, c if alive else core[3])
	# le radici che lo avvolgono e scendono a terra
	for k in 7:
		var a0 := rng.randf_range(0.0, TAU)
		var from := Vector2(cx, cy) + Vector2(cos(a0), sin(a0)) * 9.0
		var to := Vector2(rng.randf_range(2.0, w - 2.0), h - 1.0) if k < 4 else Vector2(cx, cy) + Vector2(cos(a0 + 2.2), sin(a0 + 2.2)) * 11.0
		var mid := (from + to) * 0.5 + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6))
		Px.curve(im, from, mid, to, 2, root[1])
		Px.curve(im, from, mid, to, 1, root[3])


## Portale di radici: due radici che si piegano ad arco, dentro un vortice di Linfa che gira.
static func _portale(im: Image, gm: Image, w: int, h: int) -> void:
	var root := Px.pal(TileDefs.P_RADICE)
	var lin := Px.pal(TileDefs.P_CRYSTAL)
	var cx := w / 2.0
	var cy := h * 0.45
	for y in h:
		for x in w:
			var d := Vector2((x + 0.5 - cx) / (w * 0.36), (y + 0.5 - cy) / (h * 0.36))
			var r := d.length()
			if r <= 1.0:
				var ang := atan2(d.y, d.x) + r * 5.0
				var t := 0.5 + 0.5 * sin(ang * 3.0)
				var c := lin[clampi(int((1.0 - r) * 3.0 + t * 1.5), 0, 4)]
				Px.put(im, x, y, c)
				Px.put(gm, x, y, c)
	for side in [-1.0, 1.0]:
		var base := Vector2(cx + side * (w * 0.42), h - 1.0)
		var top := Vector2(cx + side * 3.0, 1.0)
		var mid := Vector2(cx + side * (w * 0.55), h * 0.3)
		Px.curve(im, base, mid, top, 3, root[1])
		Px.curve(im, base, mid, top, 1, root[3])
	for x in range(2, w - 2):
		Px.put(im, x, h - 1, root[0])


## Aiuola del Giardino (voce 45): un letto di terra scura cerchiato di radici, con tre germogli e rune di Linfa accese
## sul bordo. Sopra resta vuota: lì crescerà il portale.
## Voce 237: il cuore di una meraviglia, un fiore di cristallo iridato su un piedistallo di pietra.
static func _meraviglia(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var iri := [Color("#5a3a8a"), Color("#3aa0c8"), Color("#8ef0d8"), Color("#f0c050"), Color("#ffe0f0")]
	var cx := w / 2.0
	for y in range(h - 7, h):                               # il piedistallo
		for x in range(int(cx - 7 + (h - y) * 0.4), int(cx + 7 - (h - y) * 0.4)):
			Px.put(im, x, y, st[clampi(2 + (1 if x < cx else 0) - (1 if y == h - 1 else 0), 0, 4)])
	for k in 5:                                             # cinque petali di cristallo
		var a := -PI / 2.0 + (k - 2) * 0.55
		var tip := Vector2(cx, h - 9.0) + Vector2(cos(a), sin(a)) * 14.0
		for s in 12:
			var p := Vector2(cx, h - 9.0).lerp(tip, s / 11.0)
			var r := 2.6 * sin(PI * s / 11.0) + 0.6
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					if Vector2(dx, dy).length() <= r:
						var c: Color = iri[(k + s / 4) % 5]
						Px.put(im, int(p.x) + dx, int(p.y) + dy, c)
						Px.put(gm, int(p.x) + dx, int(p.y) + dy, c)
	for dy in range(-2, 3):                                 # il centro che brilla
		for dx in range(-2, 3):
			if absi(dx) + absi(dy) <= 2:
				Px.put(im, int(cx) + dx, h - 10 + dy, Color("#ffffff"))
				Px.put(gm, int(cx) + dx, h - 10 + dy, Color("#ffffff"))


## Voce 239: la Tenda da campo, un telo di foglie su due pali, con una lanterna accesa davanti.
static func _tenda(im: Image, gm: Image, w: int, h: int) -> void:
	var leaf := Px.pal(TileDefs.P_GRASS)
	var wood := Px.pal(TileDefs.P_ASSI)
	var cx := w / 2.0
	for y in range(3, h):
		var half := (y - 2.0) / (h - 2.0) * (w * 0.46)
		for x in range(int(cx - half), int(cx + half) + 1):
			var edge := absf(x + 0.5 - cx) > half - 1.5
			var c: Color = leaf[1] if edge else leaf[clampi(2 + (1 if x < cx else 0) - (1 if (x + y) % 5 == 0 else 0), 0, 4)]
			Px.put(im, x, y, c)
	for y in range(h - 9, h):                               # l'entrata, scura
		for x in range(int(cx - 2 - (y - h + 9) * 0.35), int(cx + 3 + (y - h + 9) * 0.35)):
			Px.put(im, x, y, wood[0])
	for y in range(1, 5):                                   # la punta del palo
		Px.put(im, int(cx), y, wood[2])
	for y in range(h - 6, h - 2):                           # la lanterna accesa
		for x in range(int(cx + 9), int(cx + 12)):
			Px.put(im, x, y, Color("#ffd070"))
			Px.put(gm, x, y, Color("#ffd070"))


## Voce 253: la vetrina del Museo, una teca di vetro chiaro su un piedistallo di pietra dei Seminatori.
static func _vetrina(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	for y in range(h - 9, h):                               # il piedistallo
		for x in range(2, w - 2):
			Px.put(im, x, y, st[2 if x > 3 and x < w - 4 else 1] if y > h - 8 else st[3])
	for y in range(2, h - 9):                               # la teca
		for x in range(1, w - 1):
			var edge := x == 1 or x == w - 2 or y == 2
			Px.put(im, x, y, Color(0.75, 0.95, 1.0, 0.95) if edge else Color(0.55, 0.8, 0.9, 0.35))
	for y in range(4, h - 11):                              # un riflesso
		Px.put(im, 4, y, Color(0.95, 1.0, 1.0, 0.7))
		Px.put(gm, 4, y, Color(0.5, 0.7, 0.8))


## Voce 254: un giacimento fossile, un sasso chiaro con un osso che spunta.
static func _giacimento(im: Image, _gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_PALLIDITE)
	for y in range(h - 9, h):
		for x in range(1, w - 1):
			var d := Vector2((x + 0.5 - w / 2.0) / (w * 0.45), (y + 0.5 - h) / 9.0).length()
			if d <= 1.0:
				Px.put(im, x, y, st[clampi(3 - int(d * 3.0), 0, 4)])
	var bone := Color("#f0e6d0")
	for x in range(4, w - 4):
		Px.put(im, x, h - 6, bone)
	for p in [Vector2i(3, h - 7), Vector2i(3, h - 5), Vector2i(w - 4, h - 7), Vector2i(w - 4, h - 5)]:
		Px.put(im, p.x, p.y, bone)


## Roadmap 28: un Albero dorato (l'Albero Antico, l'Albero-Madre dopo il finale).
static func _gold(im: Image, w: int, h: int) -> void:
	for y in h:
		for x in w:
			var p := im.get_pixel(x, y)
			if p.a > 0.0:
				im.set_pixel(x, y, Color(p.r, p.g, p.b, p.a).lerp(Color("#ffd870") * Color(p.v, p.v, p.v), 0.4))


static func _aiuola(im: Image, gm: Image, w: int, h: int) -> void:
	var soil := Px.pal(TileDefs.P_DIRT)
	var root := Px.pal(TileDefs.P_RADICE)
	var sprout := Px.pal(TileDefs.P_GRASS)
	var lin := Px.pal(TileDefs.P_CRYSTAL)
	var top := h - 11
	for y in range(top, h):
		for x in range(2, w - 2):
			var edge := y == top or x < 4 or x > w - 5
			var c := root[2] if edge else (soil[2] if (x * 3 + y) % 5 else soil[3])
			if y == h - 1:
				c = root[1]
			Px.put(im, x, y, c)
	for x in range(3, w - 3, 6):                   # le rune del bordo
		Px.put(im, x, top + 1, lin[3])
		Px.put(gm, x, top + 1, lin[3])
	for k in 3:                                    # tre germogli che aspettano il Seme
		var sx := 12 + k * 12
		for y in range(top - 5 + (k % 2), top):
			Px.put(im, sx, y, sprout[2])
		Px.put(im, sx - 1, top - 5 + (k % 2), sprout[3])
		Px.put(im, sx + 1, top - 6 + (k % 2), sprout[4])
		Px.put(gm, sx + 1, top - 6 + (k % 2), sprout[4])


## Pianta-seme (voce 46): uno stelo ricurvo con due foglie e in cima un baccello d'ambra che brilla.
static func _pianta_seme(im: Image, gm: Image, w: int, h: int) -> void:
	var leaf := Px.pal(TileDefs.P_GRASS)
	var pod := Px.pal(TileDefs.P_AMBRA)
	Px.curve(im, Vector2(w / 2.0, h - 1), Vector2(w / 2.0 + 4, h * 0.55), Vector2(w / 2.0 - 1, 10), 1, leaf[2])
	Px.disc(im, 4.5, h * 0.6, 2.4, leaf[3])
	Px.disc(im, w - 5.0, h * 0.72, 2.4, leaf[2])
	Px.disc(im, w / 2.0 - 1, 7.0, 4.2, pod[1])
	Px.disc(im, w / 2.0 - 1, 6.5, 3.0, pod[2])
	Px.disc(im, w / 2.0 - 2, 5.5, 1.4, pod[3])
	Px.disc(gm, w / 2.0 - 1, 7.0, 4.2, pod[2])
	Px.disc(gm, w / 2.0 - 2, 5.5, 1.6, pod[3])


## Cesta di radici: intreccio di legno di lanterna, coperchio con una foglia.
## Fagotto del Germogliato: un fagotto di foglie legato con una radice, con un filo di luce d'ambra (si ritrova al buio).
static func _fagotto(im: Image, gm: Image, w: int, h: int) -> void:
	var leaf := Px.pal(TileDefs.P_GRASS)
	for y in range(5, h):
		for x in range(2, w - 2):
			var d := Vector2((x + 0.5 - w / 2.0) / 6.0, (y + 0.5 - 11.0) / 5.5)
			if d.length() <= 1.0:
				Px.put(im, x, y, leaf[3] if d.y < 0.0 else leaf[2])
	Px.line(im, Vector2(3.0, 10.0), Vector2(13.0, 10.0), 1, Color(TileDefs.P_ROOT[2]))
	Px.line(im, Vector2(8.0, 4.0), Vector2(8.0, 7.0), 1, Color(TileDefs.P_ROOT[2]))
	Px.put(im, 8, 3, Color("#ffb040"))
	Px.put(gm, 8, 3, Color("#ffb040"))
	Px.put(gm, 8, 10, Color("#ffb040"))
