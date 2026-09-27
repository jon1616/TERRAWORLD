class_name TipView
extends PanelContainer
## Il disegno di una `TipCard`: riquadro scuro con il bordo del colore della scheda e un filo acceso a sinistra, nome
## grande con l'icona in una cornicetta, valori in colonna, righe sottili tra le parti, comandi in fondo.
## Si rifà da capo a ogni scheda nuova (poche decine di nodi, meno di un millisecondo).

const ICON := 36.0
const MIN_W := 120.0

static var _icons := {}

var _box: VBoxContainer
var _style: StyleBoxFlat


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.015, 0.04, 0.05, 0.96)
	_style.set_border_width_all(1)
	_style.border_width_left = 4
	_style.set_corner_radius_all(8)
	_style.content_margin_left = 14
	_style.content_margin_right = 12
	_style.content_margin_top = 9
	_style.content_margin_bottom = 9
	_style.shadow_color = Color(0, 0, 0, 0.45)
	_style.shadow_size = 6
	_style.shadow_offset = Vector2(2, 3)
	add_theme_stylebox_override("panel", _style)
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 4)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)


static func icon_of(v: Variant) -> Texture2D:
	if v is Texture2D:
		return v
	if v is Image:
		return ImageTexture.create_from_image(v)
	var id := String(v) if v != null else ""
	if id == "" or ItemsData.get_item(id).is_empty():
		return null
	if not _icons.has(id):
		_icons[id] = ImageTexture.create_from_image(ItemIcons.of(id))
	return _icons[id]


func show_card(c: TipCard) -> void:
	for ch in _box.get_children():
		_box.remove_child(ch)
		ch.queue_free()
	_style.border_color = c.accent.darkened(0.25)
	var w := c.width
	for b in c.blocks:
		match String(b["t"]):
			"title":
				_box.add_child(_title(String(b["text"]), c.accent, b.get("icon")))
			"sub":
				_box.add_child(_label(String(b["text"]), 13, b["color"]))
			"stats":
				_box.add_child(_stats(b["rows"]))
			"text":
				_box.add_child(_rich(String(b["text"]), w))
			"bar":
				_box.add_child(_bar(String(b["text"]), float(b["frac"]), b["color"], w))
			"sep":
				var r := ColorRect.new()
				r.color = Color(c.accent, 0.22)
				r.custom_minimum_size = Vector2(0, 1)
				r.mouse_filter = Control.MOUSE_FILTER_IGNORE
				_box.add_child(r)
			"hint":
				var h := _rich("[color=#%s]%s[/color]" % [TipCard.DIM.to_html(false), b["text"]], w, 12)
				_box.add_child(h)
	custom_minimum_size = Vector2(0, 0)
	reset_size()


func _label(s: String, fs: int, col: Color) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _title(s: String, col: Color, icon: Variant) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := icon_of(icon)
	if tex != null:
		var frame := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(col, 0.10)
		sb.border_color = Color(col, 0.45)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.set_content_margin_all(2)
		frame.add_theme_stylebox_override("panel", sb)
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var t := TextureRect.new()
		t.texture = tex
		t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.custom_minimum_size = Vector2(ICON, ICON)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(t)
		row.add_child(frame)
	var l := _label(s, 18, col)
	l.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03))
	l.add_theme_constant_override("outline_size", 3)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	row.add_child(l)
	return row


func _rich(bb: String, w: float, fs := 14) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.add_theme_font_size_override("normal_font_size", fs)
	r.add_theme_color_override("default_color", TipCard.TEXT)
	if w > 0.0:
		r.custom_minimum_size = Vector2(w, 0)
		r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.text = bb
	if w <= 0.0:
		r.custom_minimum_size = Vector2(measure(bb, fs) + 6.0, 0)
	return r


static var _strip: RegEx
static var _img: RegEx


## Quanto è largo un testo con i colori (BBCode), con il carattere del gioco: la misura del nodo arriva solo dopo che
## è stato disegnato, troppo tardi per stringere il riquadro.
static func measure(bb: String, fs: int) -> float:
	if _strip == null:
		_strip = RegEx.create_from_string("\\[[^\\]]*\\]")
		_img = RegEx.create_from_string("\\[img[^\\]]*\\][^\\[]*\\[/img\\]")
	# voce 101: un'icona ([img]...[/img]) vale circa due lettere larghe
	var plain := _strip.sub(_img.sub(bb, "WW", true), "", true)
	var font := ThemeDB.fallback_font
	var w := 0.0
	for ln in plain.split("\n"):
		w = maxf(w, font.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
	return w


## Valori in due colonne per riga: nome spento a sinistra, valore chiaro a destra (due coppie per riga se sono tante).
func _stats(rows: Array) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 4 if rows.size() > 3 else 2
	g.add_theme_constant_override("h_separation", 12)
	g.add_theme_constant_override("v_separation", 1)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for r in rows:
		g.add_child(_label(String(r[0]), 13, TipCard.SOFT))
		var v := RichTextLabel.new()
		v.bbcode_enabled = true
		v.fit_content = true
		v.scroll_active = false
		v.autowrap_mode = TextServer.AUTOWRAP_OFF
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_font_size_override("normal_font_size", 14)
		var col: Color = r[2] if r.size() > 2 else TipCard.TEXT
		v.text = "[color=#%s]%s[/color]" % [col.to_html(false), r[1]]
		v.custom_minimum_size = Vector2(measure(String(r[1]), 14) + 6.0, 0)
		g.add_child(v)
	return g


func _bar(label: String, frac: float, col: Color, w: float) -> Control:
	var c := Control.new()
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bw := maxf(w, 220.0)
	c.custom_minimum_size = Vector2(bw, 18)
	var bg := ColorRect.new()
	bg.color = Color(col.darkened(0.7), 0.9)
	bg.size = Vector2(bw, 16)
	bg.position = Vector2(0, 1)
	c.add_child(bg)
	var fg := ColorRect.new()
	fg.color = col
	fg.size = Vector2(bw * frac, 16)
	fg.position = Vector2(0, 1)
	c.add_child(fg)
	var l := _label(label, 12, Color("#f4fffa"))
	l.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03))
	l.add_theme_constant_override("outline_size", 4)
	l.position = Vector2(6, -1)
	c.add_child(l)
	return c
