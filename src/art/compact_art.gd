class_name CompactArt
extends RefCounted
## I banchi da lavoro e i mobili rimpiccioliti (26 set 2026, appunto dell'utente: «troppo grandi»). Prima erano alti
## due tessere, quasi quanto il Germogliato (36 px): un banco ora arriva alla vita, un tavolo al fianco, una sedia al
## ginocchio. Disegnati apposta per la misura nuova (rimpicciolire i disegni vecchi cancellava i dettagli):
##   ceppo 2×1          ceppo d'albero-lanterna con gli anelli in cima, radici, un germoglio e il coltellino
##   maglio 2×1         incudine di legnoferro con le rune e il maglio appoggiato
##   mola 2×1           ruota d'ardesia su un cavalletto basso, con la gemma al piede
##   alambicco 2×1      ampolla di Linfa sul treppiede con la brace, il collo che piega nell'ampolla piccola
##   paiolo 2×1         pentola d'ardesia su tre pietre, brace sotto e vapore
##   banco_innesti 3×1  piano di legnoferro, campana di Linfa, due Semi e il coltello da innesto
##   tavolo 3×1, sedia 1×1
##   cesta, scrigno, reliquiario 2×1 (le casse: prima 2×2)
## Il Baccello ardente (2×2), il Telaio (2×2) e l'Incubatrice (2×1) usano i disegni di prima, che seguono la misura.
## Restituisce false per gli altri: li disegna `StationArt`.


static func draw(id: String, im: Image, gm: Image, w: int, h: int) -> bool:
	match id:
		"ceppo":
			_ceppo(im, w, h)
		"maglio":
			_maglio(im, gm, w, h)
		"mola":
			_mola(im, gm, w, h)
		"paiolo":
			_paiolo(im, gm, w, h)
		"alambicco":
			_alambicco(im, gm, w, h)
		"banco_innesti":
			_banco_innesti(im, gm, w, h)
		"tavolo":
			_tavolo(im, gm, w, h)
		"sedia":
			_sedia(im, w, h)
		"bacheca":
			_bacheca(im, gm, w, h)
		"cesta":
			_cesta(im, w, h)
		"scrigno":
			_scrigno(im, gm, w, h)
		"scrigno_parola":
			_scrigno(im, gm, w, h)
			_word_seal(im, gm, w)
		"reliquiario":
			_reliquiario(im, gm, w, h)
		"arena":
			_arena(im, gm, w, h)
		"stella_eterna":
			_stella(im, gm, w, h)
		"esca", "esca_legnoferro", "esca_ambra", "tramoggia", "tramoggia_ambra", "radice_ancora", "nastro_dx", "nastro_sx":
			FarmArt.draw(id, im, gm, w, h)
		_ when TrapsData.is_trap(id):
			_trap(im, gm, w, h, TrapsData.info(id))
		_ when ZonesData.is_totem(id):
			_totem(im, gm, w, h, ZonesData.info(id))
		"pozza_linfa":
			_pozza(im, gm, w, h)                          # Roadmap 45, voce 396
		_ when StationsData.STATIONS.get(id, {}).has("brew"):
			_fonte(im, gm, w, h, Color(String(StationsData.STATIONS[id]["brew"])))   # voce 398: le fonti
		_:
			if not ChestsData.mimic_of(id).is_empty():
				id = String(ChestsData.mimic_of(id)["chest"])   # voce 393: il mimo ha l'aspetto della cassa del bioma
			if not ChestsData.is_chest(id):
				return false
			if ChestsData.is_found(id):
				_scrigno(im, gm, w, h)
				_trim(im, gm, w, h, String(ChestsData.info(id)["mat"]))
				if ChestsData.info(id).has("key"):
					_lock(im, gm, w, h)                       # voce 392: la cassa sigillata
			else:
				_cassa(im, gm, w, h, String(ChestsData.info(id)["mat"]))
	return true


static func _wood() -> Array[Color]:
	return Px.pal(["#241624", "#362234", "#4c3246", "#644652", "#7a5a6a"])


static func _ceppo(im: Image, w: int, h: int) -> void:
	var bark := Px.pal(["#140c14", "#241624", "#362234", "#4c3246", "#62405a"])
	var ring := Px.pal(["#6a4a3a", "#9a7258", "#c49a74", "#e2c09a"])
	var cx := w / 2.0
	for y in range(4, h):
		var hw := 10.0 + (y - 4) * 0.25
		for x in range(int(cx - hw), int(cx + hw)):
			var k := (x - (cx - hw)) / (2.0 * hw)
			var c := bark[3] if k < 0.3 else (bark[2] if k < 0.75 else bark[1])
			if (x * 5 + y) % 7 == 0:
				c = bark[4]
			Px.put(im, x, y, c)
	for side in [-1.0, 1.0]:
		Px.line(im, Vector2(cx + side * 9.0, h - 3.0), Vector2(cx + side * 14.0, h - 1.0), 1, bark[2])
	for y in range(1, 7):
		for x in range(int(cx - 11), int(cx + 11)):
			var d := Vector2((x + 0.5 - cx) / 11.0, (y + 0.5 - 3.8) / 2.7)
			if d.length() <= 1.0:
				Px.put(im, x, y, ring[3 - clampi(int(d.length() * 4.0), 0, 3)] if int(d.length() * 6.0) % 2 == 0 else ring[1])
	for q in [Vector2i(int(cx) + 8, 1), Vector2i(int(cx) + 9, 0), Vector2i(int(cx) + 7, 0)]:
		Px.put(im, q.x, q.y, Color("#3aa08a"))
	Px.line(im, Vector2(cx - 5.0, 3.0), Vector2(cx - 3.0, 0.0), 1, Color("#dce6f2"))


static func _maglio(im: Image, gm: Image, w: int, h: int) -> void:
	var fe := Px.pal(TileDefs.P_LEGNOFERRO)
	var bark := _wood()
	var cx := w / 2.0
	for y in range(5, h):
		var hw := 12.0 if y < 8 else (6.0 if y < h - 4 else 9.0)
		for x in range(int(cx - hw), int(cx + hw)):
			Px.put(im, x, y, fe[3] if y == 5 else (fe[2] if x < cx else fe[1]))
	var rune := Color("#5cc8cc")
	for q in [Vector2i(int(cx) - 3, 9), Vector2i(int(cx) - 2, 10), Vector2i(int(cx) + 1, 9), Vector2i(int(cx) + 2, 10)]:
		Px.put(im, q.x, q.y, rune)
		Px.put(gm, q.x, q.y, rune)
	Px.line(im, Vector2(cx - 10.0, 4.0), Vector2(cx + 5.0, 1.0), 1, bark[3])
	for y in range(0, 4):
		for x in range(int(cx + 4), int(cx + 10)):
			Px.put(im, x, y, fe[3] if y == 0 else fe[2])


static func _mola(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var bark := _wood()
	var c := Vector2(w / 2.0, 7.0)
	Px.line(im, Vector2(5.0, h - 1.0), Vector2(c.x - 3.0, c.y + 2.0), 1, bark[2])
	Px.line(im, Vector2(w - 6.0, h - 1.0), Vector2(c.x + 3.0, c.y + 2.0), 1, bark[2])
	Px.line(im, Vector2(6.0, h - 3.0), Vector2(w - 7.0, h - 3.0), 1, bark[3])
	for y in h:
		for x in w:
			var d := Vector2(x + 0.5, y + 0.5) - c
			if d.length() <= 6.5:
				var col := st[3] if d.length() > 5.3 else (st[2] if int(d.angle() * 3.0 / PI + 6.0) % 2 == 0 else st[1])
				Px.put(im, x, y, col)
	Px.disc(im, c.x, c.y, 1.3, bark[4])
	Px.line(im, c, c + Vector2(5.0, -5.0), 1, bark[1])
	Px.disc(im, w - 4.0, h - 2.0, 1.6, Color("#c8283c"))
	Px.put(im, w - 5, h - 3, Color("#ffd0d4"))
	Px.put(gm, w - 5, h - 3, Color("#ff6a78"))


static func _paiolo(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_STONE)
	var brace := Px.pal(TileDefs.P_BRACE)
	for x in [7, w / 2, w - 8]:
		Px.disc(im, x, h - 1.5, 1.8, st[1])
	for q in [Vector2i(w / 2 - 3, h - 3), Vector2i(w / 2 + 2, h - 3), Vector2i(w / 2, h - 2)]:
		Px.put(im, q.x, q.y, brace[3])
		Px.put(gm, q.x, q.y, brace[3])
	for y in range(4, h - 3):
		var hw := 10.0 - absf(y - 8.0) * 0.45
		for x in w:
			if absf(x + 0.5 - w / 2.0) <= hw:
				Px.put(im, x, y, st[3] if y < 5 else (st[2] if x < w / 2 else st[1]))
	for x in range(7, w - 7):
		Px.put(im, x, 4, Color("#a8704a"))
	for k in 3:
		Px.put(im, 11 + k * 5, 2 - k % 2, Color(0.85, 0.9, 0.9, 0.5))
		Px.put(im, 12 + k * 5, 1 - k % 2 + 1, Color(0.85, 0.9, 0.9, 0.35))


static func _banco_innesti(im: Image, gm: Image, w: int, h: int) -> void:
	var iron := Px.pal(TileDefs.P_LEGNOFERRO)
	var glass := Px.pal(TileDefs.P_VETRO)
	var lin := Px.pal(TileDefs.P_CRYSTAL)
	var amber := Px.pal(TileDefs.P_AMBRA)
	for x in range(2, w - 2):
		Px.put(im, x, 8, iron[2])
		Px.put(im, x, 9, iron[1])
	for y in range(10, h):
		for x in [4, 5, w - 6, w - 5]:
			Px.put(im, x, y, iron[1])
	Px.disc(im, 11.0, 4.0, 3.8, glass[1])
	Px.disc(im, 11.0, 4.0, 3.0, lin[2])
	Px.disc(gm, 11.0, 4.0, 3.0, lin[3])
	Px.put(im, 10, 3, lin[4])
	for k in 2:
		Px.disc(im, 24.0 + k * 5, 6.0, 1.6, amber[1 + k])
		Px.put(gm, 24 + k * 5, 6, amber[3])
	Px.line(im, Vector2(34, 7), Vector2(39, 4), 1, iron[3])


static func _tavolo(im: Image, gm: Image, w: int, h: int) -> void:
	var wd := _wood()
	for x in range(1, w - 1):
		Px.put(im, x, 4, wd[4])
		Px.put(im, x, 5, wd[3])
		Px.put(im, x, 6, wd[2])
	for lx in [4, w - 5]:
		Px.line(im, Vector2(lx, 7.0), Vector2(lx + (1 if lx < w / 2 else -1), h - 1.0), 2, wd[2])
	Px.put(im, w / 2, 3, Color("#ffb040"))
	Px.put(gm, w / 2, 3, Color("#ffb040"))


static func _sedia(im: Image, w: int, h: int) -> void:
	var wd := _wood()
	Px.line(im, Vector2(4.0, 2.0), Vector2(4.0, h - 1.0), 2, wd[3])
	for x in range(4, w - 3):
		Px.put(im, x, 8, wd[4])
		Px.put(im, x, 9, wd[2])
	Px.line(im, Vector2(w - 5.0, 10.0), Vector2(w - 5.0, h - 1.0), 1, wd[2])
	Px.put(im, 5, 3, Color("#3aa08a"))


static func _alambicco(im: Image, gm: Image, w: int, h: int) -> void:
	var bark := _wood()
	var glass := Color(0.72, 0.95, 0.98, 0.55)
	var linfa := Px.pal(TileDefs.P_CRYSTAL)
	for lx in [5.0, 17.0]:
		Px.line(im, Vector2(lx, h - 1.0), Vector2(11.0, h - 5.0), 1, bark[2])
	Px.put(im, 10, h - 2, Color("#ffb040"))
	Px.put(gm, 10, h - 2, Color("#ffb040"))
	for y in h:
		for x in w:
			var d := Vector2((x + 0.5 - 11.0) / 5.0, (y + 0.5 - 7.5) / 4.5)
			if d.length() <= 1.0:
				var c := glass
				if y > 7:
					c = linfa[3] if d.x < -0.2 else linfa[2]
					Px.put(gm, x, y, c)
				Px.put(im, x, y, c)
	Px.line(im, Vector2(11.0, 3.0), Vector2(11.0, 0.0), 1, glass)
	Px.curve(im, Vector2(11.0, 0.0), Vector2(19.0, 0.0), Vector2(23.0, 7.0), 1, glass)
	Px.disc(im, 24.0, 10.0, 3.0, glass)
	Px.disc(im, 24.0, 11.0, 1.8, linfa[3])
	Px.disc(gm, 24.0, 11.0, 1.8, linfa[3])
	Px.put(im, 9, 5, Color.WHITE)


## Cesta di radici intrecciate, con il bordo e un germoglio.
static func _cesta(im: Image, w: int, h: int) -> void:
	var wood := Px.pal(["#3a2430", "#5a3a48", "#7a5462", "#9a7080"])
	for y in range(5, h):
		for x in range(3, w - 3):
			Px.put(im, x, y, wood[2] if (x + y / 2) % 4 < 2 else wood[1])
	for x in range(2, w - 2):
		Px.put(im, x, 3, wood[3])
		Px.put(im, x, 4, wood[2])
	Px.put(im, w / 2, 2, Color(TileDefs.P_GRASS[3]))
	Px.put(im, w / 2 + 1, 1, Color(TileDefs.P_GRASS[4]))


## Scrigno dei Seminatori: pietra lavorata, coperchio a cupola, runa di Linfa accesa.
static func _scrigno(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	for y in range(2, h):
		for x in range(3, w - 3):
			var c := st[3] if y < 7 else st[2]
			if y == 7 or x == 3 or x == w - 4:
				c = st[1]
			Px.put(im, x, y, c)
	for x in range(5, w - 5):
		Px.put(im, x, 1, st[4])
	var rune := Color("#6ff0d8")
	for q in [Vector2i(w / 2, 9), Vector2i(w / 2, 10), Vector2i(w / 2, 11), Vector2i(w / 2 - 1, 10), Vector2i(w / 2 + 1, 10),
			Vector2i(w / 2 - 2, 4), Vector2i(w / 2 + 2, 4)]:
		Px.put(im, q.x, q.y, rune)
		Px.put(gm, q.x, q.y, rune)


## Reliquiario: un piccolo scrigno a forma di seme, coperchio d'ambra e runa accesa.
static func _reliquiario(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	var amb := Px.pal(TileDefs.P_AMBRA)
	for y in range(6, h):
		for x in range(5, w - 5):
			Px.put(im, x, y, st[2] if x < w / 2 else st[1])
	for y in range(1, 7):
		var hw := 4.0 + (y - 1) * 1.3
		for x in w:
			if absf(x + 0.5 - w / 2.0) <= hw:
				Px.put(im, x, y, amb[2] if y > 2 else amb[3])
	Px.line(im, Vector2(5.0, 6.0), Vector2(w - 6.0, 6.0), 1, amb[1])
	for q in [Vector2i(w / 2 - 1, 10), Vector2i(w / 2, 9), Vector2i(w / 2 + 1, 10), Vector2i(w / 2, 11)]:
		Px.put(im, q.x, q.y, Color("#6ff0d8"))
		Px.put(gm, q.x, q.y, Color("#6ff0d8"))
	Px.put(gm, w / 2, 2, amb[3])


## Voce 67, la Bacheca dei Giardinieri: una tavola su due pali, con i fogli appesi e una puntina di Linfa accesa.
static func _bacheca(im: Image, gm: Image, w: int, h: int) -> void:
	var wd := _wood()
	for px in [4, w - 5]:
		Px.line(im, Vector2(px, 4), Vector2(px, h - 1), 2, wd[2])
	for y in range(3, 20):
		for x in range(3, w - 3):
			Px.put(im, x, y, wd[3] if (x + y * 2) % 7 else wd[2])
	for q in [Vector2i(8, 6), Vector2i(20, 7), Vector2i(32, 5)]:
		for y in range(q.y, q.y + 9):
			for x in range(q.x, q.x + 8):
				Px.put(im, x, y, Color("#e8dcc0") if (y - q.y) % 3 else Color("#b8a888"))
		Px.put(im, q.x + 3, q.y, Color("#6ff0d8"))
		Px.put(gm, q.x + 3, q.y, Color("#6ff0d8"))


## I gradi delle casse (28 set 2026): assi scure con le fasce e gli angoli del metallo, il coperchio bordato, la
## serratura; dai metalli del fine gioco una vena accesa sul coperchio.
static func _cassa(im: Image, gm: Image, w: int, h: int, mat: String) -> void:
	var wood := _wood()
	var met := ItemIcons.pal(mat)
	for y in range(3, h):
		for x in range(3, w - 3):
			Px.put(im, x, y, wood[2] if (y / 3) % 2 == 0 else wood[1])
	for x in range(2, w - 2):
		Px.put(im, x, 2, met[3])
		Px.put(im, x, 3, met[2])
		Px.put(im, x, 8, met[2])
	for y in range(2, h):
		for x in [3, 4, w - 5, w - 4]:
			Px.put(im, x, y, met[2] if x in [3, w - 4] else met[1])
	for q in [Vector2i(w / 2 - 1, 6), Vector2i(w / 2, 6), Vector2i(w / 2 - 1, 7), Vector2i(w / 2, 7)]:
		Px.put(im, q.x, q.y, met[met.size() - 1])
	if mat in ["cristallo", "vuotite", "brillaluce", "ambra"]:
		var glow := met[met.size() - 1]
		for x in range(6, w - 6, 3):
			Px.put(im, x, 2, glow)
			Px.put(gm, x, 2, glow)
		Px.put(gm, w / 2 - 1, 6, glow)
		Px.put(gm, w / 2, 6, glow)


## Gli scrigni trovati più grandi: bordi e runa del loro colore sopra lo Scrigno dei Seminatori.
static func _trim(im: Image, gm: Image, w: int, h: int, mat: String) -> void:
	var met := ItemIcons.pal(mat)
	for x in range(3, w - 3):
		Px.put(im, x, 2, met[3])
		Px.put(im, x, h - 1, met[2])
	for y in range(2, h):
		Px.put(im, 3, y, met[2])
		Px.put(im, w - 4, y, met[2])
	var rune := met[met.size() - 1]
	for q in [Vector2i(w / 2 - 3, 10), Vector2i(w / 2 + 3, 10), Vector2i(w / 2 - 3, 11), Vector2i(w / 2 + 3, 11)]:
		Px.put(im, q.x, q.y, rune)
		Px.put(gm, q.x, q.y, rune)


## Voce 84, il Cerchio dei Seminatori (3×1): una fila bassa di pietre lavorate con le rune accese, al centro un disco
## d'ambra dove il Guardiano si risveglia.
static func _arena(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	var amb := Px.pal(TileDefs.P_AMBRA)
	for x in range(1, w - 1):
		for y in range(h - 5, h):
			Px.put(im, x, y, st[2] if y > h - 4 else st[3])
	for px in [3, w / 2 - 1, w - 5]:
		for y in range(h - 11, h - 5):
			Px.put(im, px, y, st[3])
			Px.put(im, px + 1, y, st[2])
		Px.put(im, px, h - 12, Color("#6ff0d8"))
		Px.put(gm, px, h - 12, Color("#6ff0d8"))
	for x in range(w / 2 - 6, w / 2 + 6):
		Px.put(im, x, h - 5, amb[3])
		Px.put(gm, x, h - 5, amb[2])


## Voce 87, i totem di zona (1×2): un palo di legno fasciato del metallo del grado, in cima il segno del tipo nel suo
## colore (acceso), e per gli stendardi un drappo; gli antichi in pietra dei Seminatori.
static func _totem(im: Image, gm: Image, w: int, h: int, d: Dictionary) -> void:
	var td: Dictionary = ZonesData.TYPES[d["type"]]
	var col := Color(String(td["color"]))
	var old := not d.has("tier")
	var pole := Px.pal(TileDefs.P_SEM) if old else _wood()
	var met := ItemIcons.pal(["radicite", "legnoferro", "ambra"][clampi(int(d.get("tier", 1)) - 1, 0, 2)] if not old else "brillaluce")
	var cx := w / 2
	for y in range(8, h):
		Px.put(im, cx - 1, y, pole[2])
		Px.put(im, cx, y, pole[3])
	for y in [12, 20, h - 3]:
		Px.put(im, cx - 1, y, met[3])
		Px.put(im, cx, y, met[3])
	match String(td["icon"]):
		"velo":
			for y in range(4, 16):
				for x in range(cx + 1, mini(cx + 7, w)):
					Px.put(im, x, y, col.darkened(0.35) if (x + y) % 5 else col)
			Px.put(gm, cx + 3, 9, col)
		"altare":
			for y in range(h - 6, h):
				for x in range(1, w - 1):
					Px.put(im, x, y, pole[2] if y > h - 3 else pole[3])
		_:
			pass
	for q in [Vector2i(cx - 1, 5), Vector2i(cx, 5), Vector2i(cx - 1, 6), Vector2i(cx, 6), Vector2i(cx - 2, 6), Vector2i(cx + 1, 6),
			Vector2i(cx - 1, 7), Vector2i(cx, 7), Vector2i(cx - 1, 4), Vector2i(cx, 4)]:
		Px.put(im, q.x, q.y, col)
		Px.put(gm, q.x, q.y, col)


## Voce 88, le trappole (1×1): una base bassa del metallo del grado e sopra il segno del tipo (punte, lama, runa accesa,
## blocco della pressa, bocchetta dei getti, intreccio della rete) nel suo colore.
static func _trap(im: Image, gm: Image, w: int, h: int, d: Dictionary) -> void:
	var type := String(d["type"])
	var col := Color(String(TrapsData.TYPES[type]["color"]))
	var met := ItemIcons.pal(["radicite", "legnoferro", "ambra"][clampi(int(d.get("tier", 1)) - 1, 0, 2)])
	for x in range(1, w - 1):
		Px.put(im, x, h - 1, met[2])
		Px.put(im, x, h - 2, met[3])
	match type:
		"spuntoni":
			for x0 in [2, 6, 10]:
				for k in 6:
					Px.put(im, x0 + 1, h - 3 - k, col.darkened(0.1 * k))
					if k < 3:
						Px.put(im, x0, h - 3 - k, col.darkened(0.4))
						Px.put(im, x0 + 2, h - 3 - k, col.darkened(0.4))
		"lama":
			var c0 := Vector2(w / 2.0, h - 9)
			for a in 24:
				var ang := a * TAU / 24.0
				for r in range(2, 7):
					if a % 6 < 3:
						Px.put(im, int(c0.x + cos(ang) * r), int(c0.y + sin(ang) * r), col if r > 4 else col.darkened(0.3))
			Px.put(im, int(c0.x), int(c0.y), met[1])
		"pressa":
			for y in range(0, h - 3):
				for x in range(1, w - 1):
					Px.put(im, x, y, col.darkened(0.2 + 0.25 * float(x % 4 == 0 or y % 5 == 0)))
			for x in range(1, w - 1):
				Px.put(im, x, h - 3, met[1])
		"getto_brace", "getto_acqua":
			for y in range(h - 9, h - 2):
				for x in range(3, w - 3):
					Px.put(im, x, y, met[3] if y > h - 5 else met[2])
			for y in range(h - 8, h - 5):
				Px.put(im, 1, y, col)
				Px.put(im, w - 2, y, col)
				Px.put(gm, 1, y, col)
				Px.put(gm, w - 2, y, col)
		"rete":
			for y in range(h - 8, h - 2):
				for x in range(1, w - 1):
					if (x + y) % 3 == 0 or (x - y + 30) % 3 == 0:
						Px.put(im, x, y, col.darkened(0.2))
		_:
			# le rune: una pietra piatta con il segno acceso
			for y in range(h - 5, h - 2):
				for x in range(2, w - 2):
					Px.put(im, x, y, Px.pal(TileDefs.P_SEM)[2])
			for q in [Vector2i(w / 2, h - 4), Vector2i(w / 2 - 2, h - 4), Vector2i(w / 2 + 2, h - 4), Vector2i(w / 2, h - 5),
					Vector2i(w / 2 - 1, h - 3), Vector2i(w / 2 + 1, h - 3)]:
				Px.put(im, q.x, q.y, col)
				Px.put(gm, q.x, q.y, col)



## Voce 97, la stella caduta che non si spegne: una stella a cinque punte, tutta accesa.
static func _stella(im: Image, gm: Image, w: int, h: int) -> void:
	var c := Vector2(w / 2.0, h / 2.0 + 1.0)
	for a in 5:
		var ang := -PI / 2.0 + a * TAU / 5.0
		Px.line(im, c, c + Vector2(cos(ang), sin(ang)) * 6.0, 1, Color("#fff0a0"))
		Px.line(gm, c, c + Vector2(cos(ang), sin(ang)) * 6.0, 1, Color("#fff0a0"))
	Px.disc(im, c.x, c.y, 2.5, Color("#ffffff"))
	Px.disc(gm, c.x, c.y, 2.5, Color("#ffffff"))


## Roadmap 17: il sigillo a parola sul coperchio dello scrigno: una fila di glifi d'ambra accesi.
static func _word_seal(im: Image, gm: Image, w: int) -> void:
	var gold := Color("#ffc860")
	for x in range(5, w - 5):
		if x % 3 != 1:
			Px.put(im, x, 5, gold)
			Px.put(gm, x, 5, Color(0.8, 0.55, 0.2))
		if x % 3 == 0:
			Px.put(im, x, 4, gold)
			Px.put(gm, x, 4, Color(0.6, 0.4, 0.15))


## Voce 392: il sigillo della cassa sigillata (una serratura d'ambra al centro, che brilla).
static func _lock(im: Image, gm: Image, w: int, h: int) -> void:
	var amb := Px.pal(TileDefs.P_AMBRA)
	var cx := w / 2
	for y in range(h / 2 - 2, h / 2 + 4):
		for x in range(cx - 2, cx + 2):
			Px.put(im, x, y, amb[2] if y < h / 2 + 1 else amb[1])
	Px.put(im, cx - 1, h / 2, Color("#1a0e14"))
	Px.put(im, cx - 1, h / 2 + 1, Color("#1a0e14"))
	Px.put(gm, cx - 2, h / 2 - 2, amb[3])
	Px.put(gm, cx + 1, h / 2 - 2, amb[3])


## Voce 396: la Pozza di Linfa antica (3×1): un bacino di pietra dei Seminatori pieno di Linfa che brilla.
static func _pozza(im: Image, gm: Image, w: int, h: int) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	for x in range(1, w - 1):
		for y in range(h - 7, h):
			var rim := x <= 2 or x >= w - 3 or y >= h - 2
			if rim:
				Px.put(im, x, y, st[3] if y == h - 7 else st[2])
	for x in range(3, w - 3):
		for y in range(h - 6, h - 2):
			var c := Color("#2ec8b0") if y == h - 6 else Color("#14806e")
			Px.put(im, x, y, c)
			Px.put(gm, x, y, Color("#5cf0d8") if y == h - 6 else Color("#1a8a78"))
	for x in [6, 14, 25, 37]:
		if x < w - 3:
			Px.put(im, x, h - 7, Color("#c8fff0"))
			Px.put(gm, x, h - 7, Color("#c8fff0"))


## Voce 398: una fonte (1×2): un piedistallo di pietra dei Seminatori con una coppa piena di pozione che brilla.
static func _fonte(im: Image, gm: Image, w: int, h: int, col: Color) -> void:
	var st := Px.pal(TileDefs.P_SEM)
	var cx := w / 2
	for y in range(h - 14, h):
		for x in range(cx - 2, cx + 2):
			Px.put(im, x, y, st[2] if x < cx else st[1])
	for x in range(cx - 4, cx + 4):
		Px.put(im, x, h - 1, st[3])
		Px.put(im, x, h - 15, st[3])
	for y in range(h - 20, h - 15):
		var hw := 6 - (h - 15 - y) / 2
		for x in range(cx - hw, cx + hw):
			Px.put(im, x, y, st[3] if y == h - 20 or absi(x - cx) >= hw - 1 else col)
			if absi(x - cx) < hw - 1 and y > h - 20:
				Px.put(gm, x, y, col)
	Px.put(im, cx - 2, h - 19, Color.WHITE)

