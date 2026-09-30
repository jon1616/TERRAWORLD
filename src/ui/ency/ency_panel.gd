class_name EncyPanel
extends Control
## L'Enciclopedia aperta (27 set 2026, richiesta dell'utente: «il punto di riferimento per il giocatore, dove può
## togliersi qualsiasi dubbio sul gioco»): a sinistra la ricerca e l'indice (capitoli per gruppo, poi i cataloghi), a
## destra la pagina con i collegamenti. «Indietro» ripercorre le pagine; «Anticipazioni» mostra anche ciò che non hai
## ancora scoperto. Le pagine le fa `EncyPages`. Si apre in gioco (tasto, pausa) e dal menu (senza personaggio).
## 28 set 2026 (appunto dell'utente: «lo sfondo trasparente confonde le scritte»): sfondo nero pieno (con l'1-2% di
## trasparenza il bagliore del sole passava attraverso), un colore per ogni gruppo di capitoli (intestazione, voci
## dell'indice, titolo e riga della pagina) e la voce della pagina aperta ben evidenziata nell'indice.

signal closed

const TEAL := Color("#2f7a70")
const GOLD := Color("#ffd08a")
## I colori dei gruppi, nell'ordine in cui compaiono; i cataloghi e le pagine di oggetti, creature e geni hanno il loro.
const PALETTE := [Color("#ffb84a"), Color("#6ee0c8"), Color("#ff8a78"), Color("#b890ff"), Color("#9fe070"),
	Color("#6ec8ff"), Color("#ffd24a"), Color("#ff94c8"), Color("#e0c080"), Color("#7fd0ff"), Color("#c8f07a")]
const KIND_COLOR := {"cat": Color("#f0e0a0"), "item": Color("#ffc870"), "cr": Color("#ff9a7a"), "gene": Color("#c89aff")}
const KIND_NAME := {"cat": "Cataloghi", "item": "Oggetto", "cr": "Creatura", "gene": "Gene"}

var current := "cap:inizio"
var _history: Array = []
var _index: VBoxContainer
var _index_scroll: ScrollContainer
var _search: LineEdit
var _crumb: Label
var _title: Label
var _bar: ColorRect
var _icon: TextureRect
var _text: RichTextLabel
var _spoil: CheckButton
var _entries := {}                     # indirizzo → pulsante dell'indice (per evidenziare la pagina aperta)
var _group_of := {}                    # "cap:id" → [nome del gruppo, colore]
var _styles := {}


func _init() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var bg := ColorRect.new()
	bg.color = UiPalette.FONDO
	bg.position = Vector2(-2000, -2000)          # ben oltre lo schermo, anche in una finestra più grande
	bg.size = Vector2(6000, 5000)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# la colonna dell'indice, appena più chiara, con un filo di colore
	var side := Panel.new()
	side.position = Vector2(24, 12)
	side.size = Vector2(380, 820)
	side.mouse_filter = Control.MOUSE_FILTER_IGNORE
	side.add_theme_stylebox_override("panel", UiFrames.box("riquadro"))
	add_child(side)
	var page := Panel.new()
	page.position = Vector2(420, 12)
	page.size = Vector2(1160, 820)
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page.add_theme_stylebox_override("panel", UiFrames.box("campo"))
	add_child(page)
	var head := Label.new()
	head.text = "Enciclopedia"
	head.position = Vector2(40, 22)
	head.add_theme_font_size_override("font_size", 30)
	head.add_theme_color_override("font_color", GOLD)
	add_child(head)
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca: una parola, un oggetto, una creatura…"
	_search.position = Vector2(40, 74)
	_search.size = Vector2(348, 38)
	_search.text_changed.connect(func(_t: String) -> void: _fill_index())
	add_child(_search)
	_index_scroll = ScrollContainer.new()
	_index_scroll.position = Vector2(40, 122)
	_index_scroll.size = Vector2(356, 700)
	_index_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_index_scroll)
	_index = VBoxContainer.new()
	_index.custom_minimum_size = Vector2(334, 0)
	_index.add_theme_constant_override("separation", 1)
	_index_scroll.add_child(_index)
	_crumb = Label.new()
	_crumb.position = Vector2(444, 18)
	_crumb.add_theme_font_size_override("font_size", 14)
	add_child(_crumb)
	_icon = TextureRect.new()
	_icon.position = Vector2(444, 38)
	_icon.size = Vector2(44, 44)
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(_icon)
	_title = Label.new()
	_title.position = Vector2(444, 38)
	PixelFont.apply(_title, 3)                  # (voce 272) il titolo nel carattere di pixel
	_title.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	_title.add_theme_constant_override("outline_size", 4)
	add_child(_title)
	_bar = ColorRect.new()
	_bar.position = Vector2(444, 84)
	_bar.size = Vector2(1112, 3)
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bar)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.position = Vector2(444, 100)
	_text.size = Vector2(1116, 720)
	_text.add_theme_font_size_override("normal_font_size", 17)
	_text.add_theme_font_size_override("bold_font_size", 17)
	_text.add_theme_color_override("default_color", Color("#e8f4f0"))
	_text.meta_underlined = true
	_text.meta_clicked.connect(func(meta: Variant) -> void: go(String(meta)))
	add_child(_text)
	var back := _button("← Indietro", Vector2(440, 842), Vector2(160, 40))
	back.pressed.connect(_back)
	var home := _button("Inizio", Vector2(612, 842), Vector2(120, 40))
	home.pressed.connect(func() -> void: go("cap:inizio"))
	_spoil = CheckButton.new()
	_spoil.text = "Anticipazioni: mostra anche ciò che non hai scoperto"
	_spoil.position = Vector2(760, 842)
	_spoil.focus_mode = Control.FOCUS_NONE
	_spoil.toggled.connect(func(on: bool) -> void:
		EncyPages.show_all = on
		_fill_index()
		_show(current))
	add_child(_spoil)
	var close := _button("Chiudi (Esc)", Vector2(1400, 842), Vector2(160, 40))
	close.pressed.connect(close_panel)


func _button(t: String, pos: Vector2, sz: Vector2) -> Button:
	var b := Button.new()
	b.text = t
	b.position = pos
	b.size = sz
	b.focus_mode = Control.FOCUS_NONE
	RecipeRow.style(b, true, TEAL)
	add_child(b)
	return b


func open(addr := "") -> void:
	visible = true
	_spoil.button_pressed = EncyPages.show_all
	_fill_index()
	go(addr if addr != "" else current, addr == "")


func close_panel() -> void:
	visible = false
	_search.release_focus()
	closed.emit()


## Va a una pagina (e la ricorda per «Indietro»).
func go(addr: String, no_history := false) -> void:
	if not no_history and addr != current:
		_history.append(current)
		if _history.size() > 60:
			_history.pop_front()
	current = addr
	_show(addr)


func _back() -> void:
	if not _history.is_empty():
		current = String(_history.pop_back())
		_show(current)


## Il gruppo di una pagina e il suo colore: [nome, colore].
func _group(addr: String) -> Array:
	if _group_of.is_empty():
		_build_groups()
	if _group_of.has(addr):
		return _group_of[addr]
	var kind := addr.get_slice(":", 0)
	return [String(KIND_NAME.get(kind, "")), KIND_COLOR.get(kind, Color("#8ef0d8"))]


func _build_groups() -> void:
	var names := []
	for c in EncyPages.chapters():
		var g := String(c["group"])
		if not g in names:
			names.append(g)
		_group_of["cap:" + String(c["id"])] = [g, PALETTE[names.find(g) % PALETTE.size()]]


func _show(addr: String) -> void:
	var p := EncyPages.page(addr)
	var gr := _group(addr)
	var col: Color = gr[1]
	_crumb.text = String(gr[0]).to_upper() if String(gr[0]) != "" else ""
	_crumb.add_theme_color_override("font_color", col.darkened(0.1))
	_title.text = String(p[0])
	_title.add_theme_color_override("font_color", col.lightened(0.15))
	_bar.color = col
	var tex := TipView.icon_of(String(p[2])) if String(p[2]) != "" else null
	_icon.texture = tex
	_icon.visible = tex != null
	_title.position.x = 500.0 if tex != null else 444.0
	# il grassetto del carattere del gioco deforma le lettere: le parole importanti sono chiare e calde invece
	_text.text = String(p[1]).replace("[b]", "[color=#ffe8b0]").replace("[/b]", "[/color]")
	_text.scroll_to_line(0)
	_highlight()


## La voce della pagina aperta nell'indice: fondo e filo del colore del gruppo, testo acceso, freccia davanti.
func _highlight() -> void:
	for a in _entries:
		var b: Button = _entries[a]
		if not is_instance_valid(b):
			continue
		var on := String(a) == current
		var col: Color = _group(String(a))[1]
		var label := String(b.get_meta("label"))
		b.text = ("▸ " + label) if on else ("   " + label)
		b.add_theme_color_override("font_color", Color.WHITE if on else col.lerp(Color("#dcefe8"), 0.45))
		b.add_theme_color_override("font_hover_color", Color.WHITE if on else col.lightened(0.2))
		for st in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(st, _entry_style(col, on, st))
		if on and visible:
			_index_scroll.ensure_control_visible.call_deferred(b)


func _entry_style(col: Color, on: bool, st: String) -> StyleBoxFlat:
	var key := "%s:%s:%s" % [col.to_html(false), on, st]
	if not _styles.has(key):
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(col, 0.32) if on else (Color(col, 0.12) if st == "hover" else Color(0, 0, 0, 0))
		sb.border_color = col
		sb.border_width_left = 4 if on else (2 if st == "hover" else 0)
		sb.set_corner_radius_all(4)
		sb.content_margin_left = 6
		sb.content_margin_top = 2
		sb.content_margin_bottom = 2
		_styles[key] = sb
	return _styles[key]


## L'indice: capitoli per gruppo e cataloghi; con qualcosa nella ricerca, i risultati.
func _fill_index() -> void:
	for c in _index.get_children():
		_index.remove_child(c)
		c.queue_free()
	_entries.clear()
	var q := _search.text.strip_edges()
	if q.length() >= 2:
		var res := EncyPages.search(q)
		_head("Risultati (%d)" % res.size(), GOLD)
		for r in res:
			_entry(String(r[0]), String(r[1]))
		if res.is_empty():
			_head("Niente: prova un'altra parola", Color("#8a9a96"))
		_highlight()
		return
	var group := ""
	for c in EncyPages.chapters():
		var addr := "cap:" + String(c["id"])
		if String(c["group"]) != group:
			group = String(c["group"])
			_head(group, _group(addr)[1])
		_entry(addr, String(c["name"]))
	_head("Cataloghi", KIND_COLOR["cat"])
	for k in EncyPages.CATALOGS:
		_entry("cat:" + String(k[0]), String(k[1]))
	_highlight()


func _head(t: String, col: Color) -> void:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var dot := ColorRect.new()
	dot.color = col
	dot.custom_minimum_size = Vector2(4, 16)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(dot)
	var l := Label.new()
	l.text = t.to_upper()
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", col)
	box.add_child(l)
	if _index.get_child_count() > 0:
		var gap := Control.new()
		gap.custom_minimum_size = Vector2(0, 6)
		_index.add_child(gap)
	_index.add_child(box)


func _entry(addr: String, t: String) -> void:
	var b := Button.new()
	b.set_meta("label", t)
	b.text = "   " + t
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 15)
	b.pressed.connect(func() -> void: go(addr))
	_index.add_child(b)
	_entries[addr] = b


func _unhandled_input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		close_panel()
