class_name UiTheme
extends RefCounted
## Il tema unico del gioco (voce 270, guida `ARTE.md`): si scrive nel tema predefinito del motore, così vale per ogni
## finestra e ogni pannello, anche per le finestrelle a sé (i suggerimenti di Godot, i menu a tendina). I pannelli
## che si stilano da sé con uno StyleBox proprio restano come sono finché non passano di qui (voci 278-283).
## Lo chiama `GameTheme.apply` all'avvio (`Session._ready`).


static func apply() -> void:
	var t := ThemeDB.get_default_theme()
	var P := UiPalette
	# (Roadmap 55) i caratteri: Alegreya Sans per tutto il testo, il grassetto e il corsivo della stessa famiglia
	t.default_font = UiFonts.get_font("testo")
	t.default_font_size = P.TESTO_PX
	t.set_font("bold_font", "RichTextLabel", UiFonts.get_font("forte"))
	t.set_font("italics_font", "RichTextLabel", UiFonts.get_font("corsivo"))
	t.set_font("bold_italics_font", "RichTextLabel", UiFonts.get_font("forte"))
	t.set_font("mono_font", "RichTextLabel", UiFonts.get_font("numeri"))
	t.set_constant("line_separation", "RichTextLabel", 2)
	t.set_constant("line_spacing", "Label", 1)
	# riquadri
	t.set_stylebox("panel", "Panel", UiFrames.box("riquadro"))
	t.set_stylebox("panel", "PanelContainer", UiFrames.box("riquadro"))
	# testo
	t.set_color("font_color", "Label", P.TESTO)
	t.set_color("default_color", "RichTextLabel", P.TESTO)
	t.set_color("font_selected_color", "RichTextLabel", P.FONDO)
	t.set_color("selection_color", "RichTextLabel", Color(P.LINFA, 0.4))
	# pulsanti (anche quelli a scelta e a spunta)
	for ty in ["Button", "OptionButton", "MenuButton"]:
		t.set_stylebox("normal", ty, UiFrames.box("pulsante"))
		t.set_stylebox("hover", ty, UiFrames.box("pulsante", "sopra"))
		t.set_stylebox("pressed", ty, UiFrames.box("pulsante", "premuto"))
		t.set_stylebox("hover_pressed", ty, UiFrames.box("pulsante", "premuto"))
		t.set_stylebox("disabled", ty, UiFrames.box("pulsante", "spento"))
		t.set_stylebox("focus", ty, StyleBoxEmpty.new())
		t.set_color("font_color", ty, P.TESTO)
		t.set_color("font_hover_color", ty, P.AMBRA_CHIARA)
		t.set_color("font_pressed_color", ty, P.AMBRA)
		t.set_color("font_hover_pressed_color", ty, P.AMBRA)
		t.set_color("font_focus_color", ty, P.TESTO)
		t.set_color("font_disabled_color", ty, P.TESTO_MUTO)
	t.set_icon("arrow", "OptionButton", _arrow())
	t.set_constant("arrow_margin", "OptionButton", 8)
	for ty in ["CheckBox", "CheckButton"]:
		for st in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
			t.set_stylebox(st, ty, StyleBoxEmpty.new())
		t.set_color("font_color", ty, P.TESTO)
		t.set_color("font_hover_color", ty, P.AMBRA_CHIARA)
		t.set_color("font_pressed_color", ty, P.TESTO)
		t.set_color("font_hover_pressed_color", ty, P.AMBRA_CHIARA)
		t.set_color("font_disabled_color", ty, P.TESTO_MUTO)
		t.set_constant("h_separation", ty, 8)
	t.set_icon("checked", "CheckBox", _check(true))
	t.set_icon("unchecked", "CheckBox", _check(false))
	t.set_icon("checked_disabled", "CheckBox", _check(true))
	t.set_icon("unchecked_disabled", "CheckBox", _check(false))
	for k in ["checked", "checked_disabled"]:
		t.set_icon(k, "CheckButton", _switch(true))
	for k in ["unchecked", "unchecked_disabled"]:
		t.set_icon(k, "CheckButton", _switch(false))
	# campi di testo
	t.set_stylebox("normal", "LineEdit", UiFrames.box("campo"))
	t.set_stylebox("focus", "LineEdit", UiFrames.box("campo", "scelto"))
	t.set_stylebox("read_only", "LineEdit", UiFrames.box("campo"))
	t.set_color("font_color", "LineEdit", P.TESTO)
	t.set_color("font_placeholder_color", "LineEdit", P.TESTO_MUTO)
	t.set_color("caret_color", "LineEdit", P.LINFA)
	t.set_color("selection_color", "LineEdit", Color(P.LINFA, 0.35))
	# menu a tendina
	t.set_stylebox("panel", "PopupMenu", UiFrames.box("suggerimento"))
	t.set_stylebox("hover", "PopupMenu", _flat(Color(P.BORDO, 0.45), 4))
	t.set_color("font_color", "PopupMenu", P.TESTO)
	t.set_color("font_hover_color", "PopupMenu", P.AMBRA_CHIARA)
	t.set_color("font_disabled_color", "PopupMenu", P.TESTO_MUTO)
	t.set_constant("v_separation", "PopupMenu", 6)
	# barre di scorrimento: sottili, il cursore del colore della Linfa
	for ty in ["VScrollBar", "HScrollBar"]:
		t.set_stylebox("scroll", ty, _flat(Color(0, 0, 0, 0.35), 4, 5))
		t.set_stylebox("scroll_focus", ty, _flat(Color(0, 0, 0, 0.35), 4, 5))
		t.set_stylebox("grabber", ty, _flat(Color(P.BORDO, 0.9), 4, 5))
		t.set_stylebox("grabber_highlight", ty, _flat(P.BORDO_CHIARO, 4, 5))
		t.set_stylebox("grabber_pressed", ty, _flat(P.LINFA, 4, 5))
	# cursori (opzioni)
	t.set_stylebox("slider", "HSlider", _flat(Color(0, 0, 0, 0.45), 3, 0, 4))
	t.set_stylebox("grabber_area", "HSlider", _flat(Color(P.BORDO, 0.9), 3, 0, 4))
	t.set_stylebox("grabber_area_highlight", "HSlider", _flat(P.BORDO_CHIARO, 3, 0, 4))
	t.set_icon("grabber", "HSlider", _knob(false))
	t.set_icon("grabber_highlight", "HSlider", _knob(true))
	# schede
	for ty in ["TabBar", "TabContainer"]:
		t.set_stylebox("tab_selected", ty, UiFrames.box("pulsante", "scelto"))
		t.set_stylebox("tab_unselected", ty, UiFrames.box("pulsante"))
		t.set_stylebox("tab_hovered", ty, UiFrames.box("pulsante", "sopra"))
		t.set_stylebox("tab_disabled", ty, UiFrames.box("pulsante", "spento"))
		t.set_color("font_selected_color", ty, P.AMBRA)
		t.set_color("font_unselected_color", ty, P.TESTO_SPENTO)
		t.set_color("font_hovered_color", ty, P.AMBRA_CHIARA)
	t.set_stylebox("panel", "TabContainer", UiFrames.box("riquadro"))
	# barre di avanzamento
	t.set_stylebox("background", "ProgressBar", _flat(Color(0, 0, 0, 0.45), 3, 0, 1, Color(P.BORDO, 0.6)))
	t.set_stylebox("fill", "ProgressBar", _flat(P.BORDO_CHIARO, 3))
	t.set_color("font_color", "ProgressBar", P.TESTO)
	# suggerimenti di Godot (i `tooltip_text` che restano)
	t.set_stylebox("panel", "TooltipPanel", UiFrames.box("suggerimento"))
	t.set_color("font_color", "TooltipLabel", P.TESTO)
	t.set_color("font_outline_color", "TooltipLabel", Color(0.01, 0.03, 0.04))
	t.set_constant("outline_size", "TooltipLabel", 0)
	t.set_font_size("font_size", "TooltipLabel", P.TESTO_PX)


## (Roadmap 55) Uno strato dell'interfaccia (l'HUD, i suggerimenti) disegna i suoi controlli con il filtro morbido:
## testo, cornici e icone dipinte restano lisci quando la finestra ingrandisce i 1600×900 del gioco (il progetto usa il
## filtro a pixel netti, giusto per il mondo). Vale per i figli di adesso e per quelli che arrivano dopo; chi vuole i
## pixel netti (un disegno a pixel ingrandito di numeri interi) lo chiede da sé.
static func smooth_layer(layer: CanvasLayer) -> void:
	for ch in layer.get_children():
		_smooth(ch)
	layer.child_entered_tree.connect(_smooth)


static func _smooth(n: Node) -> void:
	var ci := n as CanvasItem
	if ci != null and ci.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE:
		ci.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_soft_outline(n)
	for ch in n.get_children():
		_soft_outline(ch)


## (Roadmap 55) Le scritte sopra il mondo avevano un contorno scuro spesso (5-8 px), pensato per il carattere a pixel:
## con Alegreya le lettere sembravano macchiate. Diventa sottile e semitrasparente, con un'ombra morbida sotto.
static func _soft_outline(n: Node) -> void:
	if not (n is Label or n is RichTextLabel):
		return
	var c := n as Control
	if not c.has_theme_constant_override("outline_size"):
		return
	var o := c.get_theme_constant("outline_size")
	if o <= 0:
		return
	c.add_theme_constant_override("outline_size", mini(o, 4))
	var oc := c.get_theme_color("font_outline_color") if n is Label else c.get_theme_color("font_outline_color", "RichTextLabel")
	c.add_theme_color_override("font_outline_color", Color(oc, minf(oc.a, 0.8)))
	c.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	c.add_theme_constant_override("shadow_offset_x", 0)
	c.add_theme_constant_override("shadow_offset_y", 2)
	c.add_theme_constant_override("shadow_outline_size", 5)


## Un riquadro piatto semplice (barre sottili, evidenziazioni): angoli `r`, larghezza minima `w`, altezza minima `h`.
static func _flat(c: Color, r := 4, w := 0, h := 0, border := Color(0, 0, 0, 0)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = c
	sb.set_corner_radius_all(r)
	if w > 0:
		sb.content_margin_left = w * 0.5
		sb.content_margin_right = w * 0.5
	if h > 0:
		sb.content_margin_top = h * 0.5
		sb.content_margin_bottom = h * 0.5
	if border.a > 0.0:
		sb.border_color = border
		sb.set_border_width_all(1)
	return sb


## (Roadmap 55) Le piccole icone dei controlli, disegnate morbide: ogni pixel prende la parte di forma che copre
## (distanza dal bordo), così restano lisce anche ingrandite. Misure in pixel dello schermo.
static func _shape(w: int, h: int, paint: Callable) -> Texture2D:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			var c: Color = paint.call(Vector2(x + 0.5, y + 0.5))
			if c.a > 0.0:
				img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)


## Quanto un punto è dentro una forma che ha distanza `d` dal bordo (negativa dentro): un pixel di sfumatura.
static func _cov(d: float) -> float:
	return clampf(0.5 - d, 0.0, 1.0)


static func _rbox(p: Vector2, c: Vector2, half: Vector2, r: float) -> float:
	var q := (p - c).abs() - half + Vector2(r, r)
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length() + minf(maxf(q.x, q.y), 0.0) - r


static func _over(base: Color, top: Color) -> Color:
	var a := top.a + base.a * (1.0 - top.a)
	if a <= 0.0:
		return Color(0, 0, 0, 0)
	return Color((top.r * top.a + base.r * base.a * (1.0 - top.a)) / a, (top.g * top.a + base.g * base.a * (1.0 - top.a)) / a,
		(top.b * top.a + base.b * base.a * (1.0 - top.a)) / a, a)


## La casella di spunta: un quadratino dagli angoli morbidi, con il segno di Linfa quando è scelta.
static func _check(on: bool) -> Texture2D:
	return _shape(20, 20, func(p: Vector2) -> Color:
		var d := _rbox(p, Vector2(10, 10), Vector2(8.5, 8.5), 4.0)
		var c := Color(UiPalette.BORDO_CHIARO, 0.85 * _cov(d))
		c = _over(c, Color("#0a1314", _cov(d + 1.4)))
		if on:
			c = _over(c, Color(Color("#173a35"), _cov(d + 1.4)))
			var a := Vector2(5.5, 10.5)
			var b := Vector2(8.6, 13.6)
			var e := Vector2(14.8, 6.4)
			var dist := minf(Geometry2D.get_closest_point_to_segment(p, a, b).distance_to(p),
				Geometry2D.get_closest_point_to_segment(p, b, e).distance_to(p))
			c = _over(c, Color(UiPalette.LINFA, _cov(dist - 1.3)))
		return c)


## L'interruttore (CheckButton): una scanalatura tonda, il seme d'ambra scivola a destra e la Linfa si accende.
static func _switch(on: bool) -> Texture2D:
	return _shape(36, 20, func(p: Vector2) -> Color:
		var d := _rbox(p, Vector2(18, 10), Vector2(16.5, 8.5), 8.5)
		var c := Color(UiPalette.BORDO_CHIARO if on else UiPalette.BORDO, _cov(d))
		c = _over(c, Color(Color("#1d4a43") if on else Color("#0a1314"), _cov(d + 1.2)))
		var kc := Vector2(26.5 if on else 9.5, 10)
		var kd := p.distance_to(kc) - 6.0
		c = _over(c, Color(UiPalette.AMBRA if on else UiPalette.TESTO_MUTO, _cov(kd)))
		c = _over(c, Color(1, 1, 1, 0.25 * _cov(p.distance_to(kc + Vector2(-2, -2)) - 2.2)))
		return c)


## La freccia dei menu a tendina.
static func _arrow() -> Texture2D:
	return _shape(14, 9, func(p: Vector2) -> Color:
		var d := minf(Geometry2D.get_closest_point_to_segment(p, Vector2(2.5, 2.5), Vector2(7, 6.5)).distance_to(p),
			Geometry2D.get_closest_point_to_segment(p, Vector2(7, 6.5), Vector2(11.5, 2.5)).distance_to(p))
		return Color(UiPalette.LINFA, _cov(d - 1.1)))


## Il pomello dei cursori: un seme d'ambra con la sua luce.
static func _knob(hot: bool) -> Texture2D:
	return _shape(18, 18, func(p: Vector2) -> Color:
		var d := p.distance_to(Vector2(9, 9)) - 7.0
		var c := Color(Color("#1a0f08"), _cov(d))
		c = _over(c, Color(UiPalette.AMBRA_CHIARA if hot else UiPalette.AMBRA, _cov(d + 1.3)))
		c = _over(c, Color(1, 1, 1, 0.3 * _cov(p.distance_to(Vector2(7, 7)) - 2.5)))
		return c)
