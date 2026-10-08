class_name UiFonts
extends RefCounted
## I caratteri dell'interfaccia (Roadmap 55 «Il volto chiaro», 8 ott 2026; l'utente: «poco eleganti, molto pixellose…
## togli tutti i caratteri a pixel»). Due famiglie sorelle, disegnate insieme da Huerta Tipográfica (licenza OFL, i file
## in `arte/caratteri/`):
##   Alegreya       calligrafica, con le grazie e il tratto della penna: titoli, nomi, intestazioni («titolo», «nome»),
##                  e le pagine da leggere: stele, storia, finale («libro», e il corsivo «racconto»)
##   Alegreya Sans  la sua compagna senza grazie, calda e chiara: tutto il testo («testo», «chiaro», «forte», «corsivo»)
## Le cifre sono sempre allineate («lnum»: niente numeri che scendono sotto la riga) e, nei numeri che cambiano
## (Vita, quantità), della stessa larghezza («tnum»: non ballano).
## I simboli che i caratteri non hanno (★ ✦ ⚔ frecce…) li prende il carattere del motore (`fallbacks`).
##
## `apply(l, k, col, shadow)` è il posto unico per i titoli: k = 1 numeri piccoli, 2 sottotitolo, 3 titolo, 4 grande.

const DIR := "res://arte/caratteri/"

## Le misure dei ruoli di `apply` (k → px).
const SIZES := {1: 15, 2: 21, 3: 32, 4: 44}

static var _f := {}


## Un carattere per ruolo: testo, chiaro, forte, corsivo, numeri, titolo, nome, racconto.
static func get_font(role := "testo") -> Font:
	if _f.has(role):
		return _f[role]
	var f: Font
	match role:
		"chiaro":
			f = _sans("AlegreyaSans-Regular.ttf")
		"forte":
			f = _sans("AlegreyaSans-Bold.ttf")
		"corsivo":
			f = _sans("AlegreyaSans-Italic.ttf")
		"numeri":
			f = _sans("AlegreyaSans-Bold.ttf", true)
		"titolo":
			f = _serif("Alegreya.ttf", 700)
		"nome":
			f = _serif("Alegreya.ttf", 600)
		"racconto":
			f = _serif("Alegreya-Italic.ttf", 450)
		"libro":
			f = _serif("Alegreya.ttf", 430)
		_:
			f = _sans("AlegreyaSans-Medium.ttf")
	_f[role] = f
	return f


static func _base(file: String) -> FontFile:
	var ff: FontFile = load(DIR + file)
	ff.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	ff.hinting = TextServer.HINTING_LIGHT
	ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	ff.generate_mipmaps = false
	ff.fallbacks = [ThemeDB.fallback_font] if ThemeDB.fallback_font != null else []
	return ff


static func _tag(s: String) -> int:
	return TextServerManager.get_primary_interface().name_to_tag(s)


static func _sans(file: String, tabular := false) -> Font:
	var v := FontVariation.new()
	v.base_font = _base(file)
	var feats := {_tag("lnum"): 1}
	if tabular:
		feats[_tag("tnum")] = 1
	v.opentype_features = feats
	return v


static func _serif(file: String, weight: int) -> Font:
	var v := FontVariation.new()
	v.base_font = _base(file)
	v.variation_opentype = {_tag("wght"): weight}
	v.opentype_features = {_tag("lnum"): 1}
	return v


## Il carattere dei titoli (al posto del carattere di pixel di prima).
static func font() -> Font:
	return get_font("titolo")


static func size(k: int) -> int:
	return int(SIZES.get(clampi(k, 1, 4), 32))


## Mette un ruolo su un'etichetta: k = 1 numeri piccoli (forti, larghezza fissa), 2 sottotitolo, 3 titolo, 4 grande;
## colore e, per il testo sopra il mondo, un'ombra morbida e un contorno scuro che lo staccano da ogni sfondo.
static func apply(l: Control, k: int, col := Color(0, 0, 0, 0), shadow := false) -> void:
	l.add_theme_font_override("font", get_font("numeri") if k <= 1 else get_font("titolo"))
	l.add_theme_font_size_override("font_size", size(k))
	if col.a > 0.0:
		l.add_theme_color_override("font_color", col)
	if shadow:
		on_world(l, k <= 1)


## Il testo scritto sopra il mondo (avvisi, nomi, numeri): contorno scuro sottile e un'ombra morbida.
static func on_world(l: Control, small := false) -> void:
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.05, 0.85))
	l.add_theme_constant_override("outline_size", 4 if small else 5)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 2)
	l.add_theme_constant_override("shadow_outline_size", 6)


## Il testo di un ruolo a una misura (per chi disegna da sé con `draw_string`).
static func set_role(l: Control, role: String, px: int, col := Color(0, 0, 0, 0)) -> void:
	l.add_theme_font_override("font", get_font(role))
	l.add_theme_font_size_override("font_size", px)
	if col.a > 0.0:
		l.add_theme_color_override("font_color", col)
