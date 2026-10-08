class_name UiFrames
extends RefCounted
## Le cornici dell'interfaccia (voci 270-271; rifatte nella Roadmap 55 «Il volto chiaro»). Prima erano immagini a pixel
## doppi stirate dal motore (l'utente: «poco eleganti, molto pixellose»); ora sono disegnate a vettori (`UiStyle`):
## inchiostro verde-notte, un bordo sottile, angoli morbidi, un'ombra che le stacca dal fondo, il filo di Linfa (o
## d'ambra) che sfuma sul bordo alto. Nitide a ogni grandezza dello schermo.
##
## `box(tipo, stato, accento)`:
##   riquadro     i pannelli e i riquadri
##   forte        i pannelli principali (ombra più ampia, filo d'ambra con la gemma)
##   suggerimento le schede che seguono il mouse
##   sezione      un riquadro dentro un pannello (le parti di una scheda, il prossimo passo): senza ombra
##   casella      le caselle degli oggetti (stati: normale, sopra, scelto)
##   pulsante     i pulsanti (stati: normale, sopra, premuto, spento, scelto)
##   icona        un pulsante con solo l'icona (margini stretti)
##   principale   il pulsante che conta (Crea, Conferma): ambra; stati come pulsante
##   campo        i campi di testo (stato "scelto" quando si scrive)
##   chip         le etichette tonde (tipo, rarità, numeri chiave, i tasti)
## L'accento (facoltativo) tinge bordo e fondo; il suo alfa è la forza della tinta (1 = piena). `padded` dà la stessa
## cornice con margini interni diversi.

static var _cache := {}


static func box(kind: String, state := "normale", accent := Color(0, 0, 0, 0)) -> StyleBox:
	var key := "%s|%s|%s" % [kind, state, accent.to_html()]
	if _cache.has(key):
		return _cache[key]
	var sb := _make(kind, state, accent)
	_cache[key] = sb
	return sb


## La stessa cornice con i margini interni `pad` (orizzontale, verticale).
static func padded(kind: String, state: String, accent: Color, pad: Vector2) -> StyleBox:
	var key := "%s|%s|%s|%s" % [kind, state, accent.to_html(), pad]
	if not _cache.has(key):
		var sb := _make(kind, state, accent)
		sb.content_margin_left = pad.x
		sb.content_margin_right = pad.x
		sb.content_margin_top = pad.y
		sb.content_margin_bottom = pad.y
		_cache[key] = sb
	return _cache[key]


## Gli stili di un pulsante (normale, sopra, premuto, spento; il fuoco non si disegna) con un accento: `scelto` = il
## pulsante resta acceso (una categoria scelta, una scheda aperta).
static func button(b: Button, accent := Color(0, 0, 0, 0), chosen := false, kind := "pulsante") -> void:
	var base := "scelto" if chosen else "normale"
	b.add_theme_stylebox_override("normal", box(kind, base, accent))
	b.add_theme_stylebox_override("hover", box(kind, "scelto" if chosen else "sopra", accent))
	b.add_theme_stylebox_override("pressed", box(kind, "premuto", accent))
	b.add_theme_stylebox_override("hover_pressed", box(kind, "premuto", accent))
	b.add_theme_stylebox_override("disabled", box(kind, "spento", accent))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


static func _tint(c: Color, accent: Color, k: float) -> Color:
	if accent.a <= 0.0:
		return c
	return Color(c.lerp(Color(accent, 1.0), k * accent.a), c.a)


static func _make(kind: String, state: String, accent: Color) -> StyleBox:
	var P := UiPalette
	var st := UiStyle.new()
	var pad := Vector2(18, 16)
	match kind:
		"forte":
			st.setup(_tint(P.PANNELLO, accent, 0.08), _tint(Color(P.BORDO_CHIARO, 0.55), accent, 0.5), 12, 22)
			st.thread = Color(P.AMBRA, 0.75) if accent.a <= 0.0 else Color(accent, 0.85)
			st.gem = true
			st.sheen = 0.035
			pad = Vector2(20, 18)
		"suggerimento":
			st.setup(_tint(Color("#0e1819", 0.98), accent, 0.07), _tint(Color(P.BORDO_CHIARO, 0.5), accent, 0.6), 10, 16)
			st.thread = Color(P.LINFA, 0.5) if accent.a <= 0.0 else Color(accent, 0.9)
			st.sheen = 0.03
			pad = Vector2(14, 11)
		"sezione":
			st.setup(_tint(Color(P.PANNELLO_ALTO, 0.85), accent, 0.10), _tint(Color(P.BORDO, 0.7), accent, 0.55), 8, 0)
			if accent.a > 0.0:
				st.thread = Color(accent, 0.7)
			pad = Vector2(14, 12)
		"chip":
			var f := Color(P.PANNELLO_VIVO, 0.9)
			var b := Color(P.BORDO_CHIARO, 0.45)
			if accent.a > 0.0:
				f = Color(Color(accent, 1.0).darkened(0.72), 0.95)
				b = Color(accent, 0.75)
			st.setup(f, b, 999, 0)
			pad = Vector2(9, 2)
		"casella":
			var f := Color("#0c1617")
			var b := Color(P.BORDO, 0.85)
			match state:
				"sopra":
					f = P.PANNELLO_VIVO
					b = P.BORDO_CHIARO
				"scelto":
					f = P.PANNELLO_VIVO
					b = P.AMBRA
			st.setup(_tint(f, accent, 0.16), _tint(b, accent, 0.55) if state == "normale" else b, 7, 0)
			if state == "scelto":
				st.set_glow(Color(P.AMBRA, 0.35))
			pad = Vector2.ZERO
		"principale":
			var f := Color("#3d2b13")
			var b := P.AMBRA
			match state:
				"sopra", "scelto":
					f = Color("#57401b")
					b = P.AMBRA_CHIARA
				"premuto":
					f = Color("#2a1d0c")
				"spento":
					f = Color("#2a2218", 0.6)
					b = Color("#5a4a30")
			st.setup(f, b, 8, 0)
			if state != "premuto" and state != "spento":
				st.thread = Color(P.AMBRA_CHIARA, 0.55)
			pad = Vector2(18, 7)
		"pulsante", "icona":
			var f := P.PANNELLO_ALTO
			var b := Color(P.BORDO_CHIARO, 0.55)
			match state:
				"sopra":
					f = P.PANNELLO_VIVO
					b = P.BORDO_CHIARO
				"premuto":
					f = P.PANNELLO.darkened(0.2)
					b = P.AMBRA
				"spento":
					f = Color(P.PANNELLO_ALTO, 0.5)
					b = Color(P.BORDO, 0.4)
				"scelto":
					f = P.PANNELLO_VIVO
					b = P.AMBRA
			st.setup(_tint(f, accent, 0.12), _tint(b, accent, 0.55), 8, 0)
			if state == "scelto":
				st.thread = Color(P.AMBRA, 0.8) if accent.a <= 0.0 else Color(accent, 0.9)
			st.sheen = 0.03 if state != "premuto" else 0.0
			pad = Vector2(14, 6) if kind == "pulsante" else Vector2(4, 4)
		"campo":
			st.setup(Color("#0a1314"), Color(P.BORDO_CHIARO, 0.45) if state != "scelto" else P.LINFA, 8, 0)
			pad = Vector2(12, 7)
		_:
			# riquadro
			st.setup(_tint(P.PANNELLO, accent, 0.10), _tint(Color(P.BORDO, 0.95), accent, 0.55), 10, 14)
			st.thread = Color(P.LINFA, 0.32) if accent.a <= 0.0 else Color(accent, 0.75)
			st.sheen = 0.03
	st.content_margin_left = pad.x
	st.content_margin_right = pad.x
	st.content_margin_top = pad.y
	st.content_margin_bottom = pad.y
	if (kind == "pulsante" or kind == "principale" or kind == "icona") and state == "premuto":
		st.content_margin_top = pad.y + 1
		st.content_margin_bottom = pad.y - 1
	return st
