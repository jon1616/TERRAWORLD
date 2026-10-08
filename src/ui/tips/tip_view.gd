class_name TipView
extends PanelContainer
## Il disegno di una `TipCard` (voce 277; rifatto nella Roadmap 55 «Il volto chiaro»). Gli stessi pezzi dei pannelli:
##   intestazione  l'icona in una casella, il nome in Alegreya del colore della scheda, e sotto la riga «che cos'è»
##                 divisa in etichette tonde (il tipo nel colore della scheda, il resto neutro)
##   valori        in colonna, il nome spento e il valore chiaro (due coppie per riga se sono tante)
##   testo         Alegreya Sans, con i colori della scheda
##   barra         morbida, con la sua etichetta sopra
##   righe         sottili, che sfumano ai lati
##   comandi       in fondo, come tasti disegnati («Clic destro» → il tasto e cosa fa)
## Nessun testo più largo di `MAX_W`: va a capo. Si rifà da capo a ogni scheda nuova (poche decine di nodi).

const ICON := 40.0
const MIN_W := 120.0
const MAX_W := 430.0
const FS := 15

static var _icons := {}

var _box: VBoxContainer


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 6)
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
	UiKit.clear(_box)
	add_theme_stylebox_override("panel", UiFrames.padded("suggerimento", "normale", Color(c.accent, 0.75), Vector2(15, 12)))
	var w := c.width
	var i := 0
	while i < c.blocks.size():
		var b: Dictionary = c.blocks[i]
		match String(b["t"]):
			"title":
				var sub := ""
				if i + 1 < c.blocks.size() and String(c.blocks[i + 1]["t"]) == "sub":
					sub = String(c.blocks[i + 1]["text"])
					i += 1
				_box.add_child(_title(String(b["text"]), c.accent, b.get("icon"), sub))
				var band := UiRule.new()
				band.color = Color(c.accent, 0.55)
				_box.add_child(band)
			"sub":
				_box.add_child(_chips(String(b["text"]), c.accent))
			"stats":
				_box.add_child(_stats(b["rows"]))
			"text":
				var tx := String(b["text"])
				var hd := _heading(tx)
				if not hd.is_empty():
					# un testo dei moduli che comincia con il suo titolo («[font_size=N][color=#c]Nome…»): il titolo come
					# quello delle schede, il resto sotto
					var hc: Color = hd[1] if hd[1] is Color else c.accent
					_box.add_child(_title(String(hd[0]), hc, null, ""))
					var band := UiRule.new()
					band.color = Color(hc, 0.55)
					_box.add_child(band)
					tx = String(hd[2])
				if tx.strip_edges() != "":
					_box.add_child(_rich(tx.strip_edges(), w))
			"bar":
				_box.add_child(_bar(String(b["text"]), float(b["frac"]), b["color"], w))
			"sep":
				var r := UiRule.new()
				r.fade_both = true
				r.color = Color(c.accent, 0.3)
				_box.add_child(r)
			"hint":
				_box.add_child(_hint(String(b["text"])))
		i += 1
	custom_minimum_size = Vector2(0, 0)
	reset_size()


func _label(s: String, fs: int, col: Color, role := "chiaro") -> Label:
	return UiKit.label(s, fs, col, role)


## Il nome con l'icona; sotto, la riga «che cos'è» in etichette.
func _title(s: String, col: Color, icon: Variant, sub: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := icon_of(icon)
	if tex != null:
		var frame := PanelContainer.new()
		frame.add_theme_stylebox_override("panel", UiFrames.padded("casella", "normale", Color(col, 0.6), Vector2(4, 4)))
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.add_child(UiKit.icon_rect(tex, ICON))
		row.add_child(frame)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var room := MAX_W - (ICON + 22.0 if tex != null else 0.0)
	var l := UiKit.label(s, 20, col.lerp(UiPalette.TESTO, 0.2), "nome")
	# un nome lunghissimo va a capo invece di allargare la scheda oltre `MAX_W`
	if UiFonts.get_font("nome").get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, 20).x > room:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(room, 0)
	vb.add_child(l)
	if sub != "":
		vb.add_child(_chips(sub, col, room))
	row.add_child(vb)
	return row


## «Spada · rarità Rara · grado 2» → tre etichette: la prima del colore della scheda.
func _chips(s: String, col: Color, room := MAX_W) -> Control:
	var parts := s.split(" · ", false)
	if parts.size() <= 1 and s.length() > 34:
		return _rich("[color=#%s]%s[/color]" % [UiPalette.TESTO_SPENTO.to_html(false), s], room, 14)
	var fl := HFlowContainer.new()
	fl.add_theme_constant_override("h_separation", 6)
	fl.add_theme_constant_override("v_separation", 4)
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fl.custom_minimum_size = Vector2(minf(room, _chips_w(parts)), 0)
	for k in parts.size():
		fl.add_child(UiKit.chip(_plain(String(parts[k])), Color(col, 0.9) if k == 0 else Color(0, 0, 0, 0), null, 13))
	return fl


func _chips_w(parts: Array) -> float:
	var f := UiFonts.get_font("forte")
	var w := 0.0
	for p in parts:
		w += f.get_string_size(_plain(String(p)), HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 24.0
	return w


func _rich(bb: String, w: float, fs := FS) -> RichTextLabel:
	var r := UiKit.rich(bb, 0.0, fs)
	r.add_theme_color_override("default_color", UiPalette.TESTO)
	if w > 0.0:
		r.custom_minimum_size = Vector2(minf(w, MAX_W), 0)
		r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		var mw := measure(bb, fs) + 8.0
		if mw > MAX_W:
			mw = MAX_W
			r.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		else:
			r.autowrap_mode = TextServer.AUTOWRAP_OFF
		r.custom_minimum_size = Vector2(mw, 0)
	return r


static var _strip: RegEx
static var _img: RegEx
static var _head: RegEx


## [nome, colore o null, il resto] se il testo comincia con un titolo a misura grande; altrimenti [].
static func _heading(tx: String) -> Array:
	if _head == null:
		_head = RegEx.create_from_string("^\\[font_size=\\d+\\](?:\\[color=#?([0-9a-fA-F]{6,8})\\])?(.*?)(?:\\[/color\\])?\\[/font_size\\]\\s*\\n?")
	var mh := _head.search(tx)
	if mh == null:
		return []
	return [_plain(mh.get_string(2)), Color("#" + mh.get_string(1)) if mh.get_string(1) != "" else null, tx.substr(mh.get_end())]


static func _plain(s: String) -> String:
	if _strip == null:
		_strip = RegEx.create_from_string("\\[[^\\]]*\\]")
		_img = RegEx.create_from_string("\\[img[^\\]]*\\][^\\[]*\\[/img\\]")
	return _strip.sub(s, "", true)


## Quanto è largo un testo con i colori (BBCode), con il carattere del gioco: la misura del nodo arriva solo dopo che
## è stato disegnato, troppo tardi per stringere il riquadro.
static func measure(bb: String, fs: int) -> float:
	_plain("")
	# voce 101: un'icona ([img]...[/img]) vale circa due lettere larghe
	var plain := _strip.sub(_img.sub(bb, "WW", true), "", true)
	var font := UiFonts.get_font("chiaro")
	var bold := UiFonts.get_font("forte")
	var w := 0.0
	for ln in plain.split("\n"):
		w = maxf(w, maxf(font.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x,
			bold.get_string_size(ln, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x * 0.97))
	return w


## Valori in colonna: nome spento a sinistra, valore chiaro a destra (due coppie per riga se sono tante).
func _stats(rows: Array) -> GridContainer:
	var g := GridContainer.new()
	g.columns = 4 if rows.size() > 3 else 2
	g.add_theme_constant_override("h_separation", 14)
	g.add_theme_constant_override("v_separation", 2)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for r in rows:
		g.add_child(_label(String(r[0]), 14, UiPalette.TESTO_MUTO))
		var v := UiKit.rich("", 0.0, 16)
		v.add_theme_font_override("normal_font", UiFonts.get_font("forte"))
		v.autowrap_mode = TextServer.AUTOWRAP_OFF
		var col: Color = r[2] if r.size() > 2 else UiPalette.TESTO
		v.text = "[color=#%s]%s[/color]" % [col.to_html(false), r[1]]
		v.custom_minimum_size = Vector2(measure(String(r[1]), 16) + 8.0, 0)
		g.add_child(v)
	return g


## Una barra morbida con la sua etichetta sopra.
func _bar(label: String, frac: float, col: Color, w: float) -> Control:
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(_label(label, 14, UiPalette.TESTO, "forte"))
	vb.add_child(UiKit.bar(frac, col, maxf(w, 240.0), 8.0))
	return vb


## I comandi: «Clic destro: apri · Maiusc: confronta» → un tasto disegnato e che cosa fa, per ognuno.
func _hint(s: String) -> Control:
	var fl := HFlowContainer.new()
	fl.add_theme_constant_override("h_separation", 14)
	fl.add_theme_constant_override("v_separation", 5)
	fl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var parts := _plain(s).split(" · ", false)
	var total := 0.0
	for p in parts:
		var t := String(p).strip_edges()
		var k := t.find(": ")
		if k > 0 and k <= 24:
			var key := t.substr(0, k)
			var what := t.substr(k + 2)
			fl.add_child(UiKit.hint(key.substr(0, 1).to_upper() + key.substr(1), what))
			total += measure(t, 14) + 40.0
		else:
			fl.add_child(_label(t, 14, UiPalette.TESTO_MUTO, "corsivo"))
			total += measure(t, 14) + 14.0
	fl.custom_minimum_size = Vector2(minf(total, MAX_W), 0)
	return fl
