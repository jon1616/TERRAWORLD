class_name UiTheme
extends RefCounted
## Il tema unico del gioco (voce 270, guida `ARTE.md`): si scrive nel tema predefinito del motore, così vale per ogni
## finestra e ogni pannello, anche per le finestrelle a sé (i suggerimenti di Godot, i menu a tendina). I pannelli
## che si stilano da sé con uno StyleBox proprio restano come sono finché non passano di qui (voci 278-283).
## Lo chiama `GameTheme.apply` all'avvio (`Session._ready`).


static func apply() -> void:
	var t := ThemeDB.get_default_theme()
	var P := UiPalette
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
	t.set_font_size("font_size", "TooltipLabel", 15)


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


## La casella di spunta: un quadratino di radice, con la foglia di Linfa quando è scelta (pixel doppi).
static func _check(on: bool) -> Texture2D:
	var n := 9
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in n:
		for x in n:
			var edge := x == 0 or y == 0 or x == n - 1 or y == n - 1
			var corner := (x == 0 or x == n - 1) and (y == 0 or y == n - 1)
			if corner:
				continue
			img.set_pixel(x, y, UiPalette.BORDO_CHIARO if edge else Color("#081211"))
	if on:
		for p in [Vector2i(2, 4), Vector2i(3, 5), Vector2i(4, 6), Vector2i(5, 5), Vector2i(6, 4), Vector2i(6, 3), Vector2i(7, 2)]:
			img.set_pixel(p.x, p.y, UiPalette.LINFA)
		for p in [Vector2i(2, 5), Vector2i(3, 6), Vector2i(5, 4), Vector2i(6, 2)]:
			img.set_pixel(p.x, p.y, UiPalette.FOGLIA)
	img.resize(n * 2, n * 2, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)


## La freccia dei menu a tendina.
static func _arrow() -> Texture2D:
	var img := Image.create(7, 4, false, Image.FORMAT_RGBA8)
	for y in 4:
		for x in range(y, 7 - y):
			img.set_pixel(x, y, UiPalette.LINFA)
	img.resize(14, 8, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)


## Il pomello dei cursori: un seme d'ambra.
static func _knob(hot: bool) -> Texture2D:
	var n := 7
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var c := UiPalette.AMBRA_CHIARA if hot else UiPalette.AMBRA
	for y in n:
		for x in n:
			var d := Vector2(x - 3, y - 3).length()
			if d <= 3.2:
				img.set_pixel(x, y, Color("#2a1428") if d > 2.4 else (c.lightened(0.35) if x < 3 and y < 3 else c))
	img.resize(n * 2, n * 2, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(img)
