class_name UiScreen
extends RefCounted
## Lo scheletro dei pannelli a schermo intero (voce 281, guida `ARTE.md` §3): Erbario, mandria, Semenzaio, Albero…
## Tutti con le stesse zone, così nessuno inventa le sue misure e nulla esce dallo schermo:
##   titolo      in alto a sinistra (48, 22), 28 px ambra; il sottotitolo sotto (48, 62), 14 px
##   contenuto   da y 90 a y 830, in riquadri (`box`)
##   piede       la riga dei tasti (48, 852), 13 px, muta

const TOP := 90.0
const BOTTOM := 830.0
const SIDE := 36.0


## Lo sfondo che copre il mondo.
static func backdrop(parent: Control) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = UiPalette.FONDO
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg


static func title(parent: Control, text := "") -> Label:
	var l := Label.new()
	l.position = Vector2(48, 22)
	l.text = text
	UiFonts.apply(l, 3)                  # (Roadmap 55) il titolo in Alegreya
	l.add_theme_color_override("font_color", UiPalette.AMBRA)
	parent.add_child(l)
	return l


static func subtitle(parent: Control, text := "") -> Label:
	var l := Label.new()
	l.position = Vector2(48, 62)
	l.text = text
	l.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
	l.add_theme_color_override("font_color", UiPalette.TESTO_SPENTO)
	parent.add_child(l)
	return l


## Un riquadro (cornice del tema) che non prende il mouse.
static func box(parent: Control, r: Rect2, strong := false) -> Panel:
	var p := Panel.new()
	p.position = r.position
	p.size = r.size
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if strong:
		p.add_theme_stylebox_override("panel", UiFrames.box("forte"))
	parent.add_child(p)
	return p


static func hint(parent: Control, text: String) -> Label:
	var l := Label.new()
	l.position = Vector2(48, 852)
	l.size = Vector2(1504, 24)
	l.text = text
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.add_theme_font_size_override("font_size", UiPalette.NOTA + 1)
	l.add_theme_color_override("font_color", UiPalette.TESTO_MUTO)
	parent.add_child(l)
	return l
