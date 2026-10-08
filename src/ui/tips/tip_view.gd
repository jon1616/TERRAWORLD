class_name TipView
extends PanelContainer
## Il disegno di una `TipCard` (voce 277): la cornice «suggerimento» del tema tinta del colore della scheda, il nome nel
## carattere di pixel con l'icona in una casella, una fascia del colore (tipo o rarità) che sfuma sotto il nome, valori
## in colonna, righe sottili tra le parti, comandi in fondo. Nessun testo più largo di `MAX_W`: va a capo.
## Si rifà da capo a ogni scheda nuova (poche decine di nodi, meno di un millisecondo).

const ICON := 36.0
const MIN_W := 120.0
const MAX_W := 440.0

static var _icons := {}

var _box: VBoxContainer
static var _bands := {}


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		_icons[id] = ImageTexture.create_from_image(ItemIcons.ui(id))
	return _icons[id]


func show_card(c: TipCard) -> void:
	for ch in _box.get_children():
		_box.remove_child(ch)
		ch.queue_free()
	add_theme_stylebox_override("panel", UiFrames.padded("suggerimento", "normale", Color(c.accent, 0.7), Vector2(14, 10)))
	var w := c.width
	for b in c.blocks:
		match String(b["t"]):
			"title":
				_box.add_child(_title(String(b["text"]), c.accent, b.get("icon")))
				_box.add_child(_band(c.accent))
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
		frame.add_theme_stylebox_override("panel", UiFrames.padded("casella", "normale", col, Vector2(4, 4)))
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var t := TextureRect.new()
		t.texture = tex
		t.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR     # le icone dipinte (8 ott 2026)
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		t.custom_minimum_size = Vector2(ICON, ICON)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.add_child(t)
		row.add_child(frame)
	var l := Label.new()
	l.text = s
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	PixelFont.apply(l, 2, col, true)
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# un nome lunghissimo va a capo invece di allargare la scheda oltre `MAX_W`
	var room := MAX_W - (ICON + 18.0 if tex != null else 0.0)
	if PixelFont.font().get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, PixelFont.size(2)).x > room:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(room, 0)
	row.add_child(l)
	return row


## La fascia del colore della scheda sotto il nome: piena a sinistra, sfuma verso destra.
func _band(col: Color) -> Control:
	var key := col.to_html()
	if not _bands.has(key):
		var g := Gradient.new()
		g.set_color(0, Color(col, 0.75))
		g.set_color(1, Color(col, 0.0))
		var gt := GradientTexture2D.new()
		gt.gradient = g
		gt.width = 128
		gt.height = 1
		_bands[key] = gt
	var t := TextureRect.new()
	t.texture = _bands[key]
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.custom_minimum_size = Vector2(0, 2)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


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
		var mw := measure(bb, fs) + 6.0
		if mw > MAX_W:
			mw = MAX_W
			r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r.custom_minimum_size = Vector2(mw, 0)
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
