class_name EncyPanel
extends Control
## L'Enciclopedia aperta (27 set 2026, richiesta dell'utente: «il punto di riferimento per il giocatore, dove può
## togliersi qualsiasi dubbio sul gioco»): a sinistra la ricerca e l'indice (capitoli per gruppo, poi i cataloghi), a
## destra la pagina con i collegamenti. «Indietro» ripercorre le pagine; «Anticipazioni» mostra anche ciò che non hai
## ancora scoperto. Le pagine le fa `EncyPages`. Si apre in gioco (tasto, pausa) e dal menu (senza personaggio).

signal closed

const TEAL := Color("#2f7a70")
const GOLD := Color("#ffd08a")

var current := "cap:inizio"
var _history: Array = []
var _index: VBoxContainer
var _index_scroll: ScrollContainer
var _search: LineEdit
var _title: Label
var _icon: TextureRect
var _text: RichTextLabel
var _spoil: CheckButton


func _init() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var bg := ColorRect.new()
	bg.color = Color(0.012, 0.03, 0.035, 0.98)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var head := Label.new()
	head.text = "Enciclopedia"
	head.position = Vector2(40, 22)
	head.add_theme_font_size_override("font_size", 30)
	head.add_theme_color_override("font_color", GOLD)
	add_child(head)
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca: una parola, un oggetto, una creatura…"
	_search.position = Vector2(40, 74)
	_search.size = Vector2(340, 38)
	_search.text_changed.connect(func(_t: String) -> void: _fill_index())
	add_child(_search)
	_index_scroll = ScrollContainer.new()
	_index_scroll.position = Vector2(40, 122)
	_index_scroll.size = Vector2(350, 700)
	_index_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_index_scroll)
	_index = VBoxContainer.new()
	_index.custom_minimum_size = Vector2(330, 0)
	_index.add_theme_constant_override("separation", 2)
	_index_scroll.add_child(_index)
	var sep := ColorRect.new()
	sep.color = Color(TEAL, 0.5)
	sep.position = Vector2(410, 30)
	sep.size = Vector2(2, 800)
	add_child(sep)
	_icon = TextureRect.new()
	_icon.position = Vector2(440, 22)
	_icon.size = Vector2(48, 48)
	_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(_icon)
	_title = Label.new()
	_title.position = Vector2(440, 26)
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.position = Vector2(440, 84)
	_text.size = Vector2(1120, 740)
	_text.add_theme_font_size_override("normal_font_size", 17)
	_text.add_theme_font_size_override("bold_font_size", 17)
	_text.add_theme_color_override("default_color", Color("#dcefe8"))
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


func _show(addr: String) -> void:
	var p := EncyPages.page(addr)
	_title.text = String(p[0])
	var tex := TipView.icon_of(String(p[2])) if String(p[2]) != "" else null
	_icon.texture = tex
	_icon.visible = tex != null
	_title.position.x = 500.0 if tex != null else 440.0
	# il grassetto del carattere del gioco deforma le lettere: le parole importanti sono chiare e calde invece
	_text.text = String(p[1]).replace("[b]", "[color=#ffe8b0]").replace("[/b]", "[/color]")
	_text.scroll_to_line(0)


## L'indice: capitoli per gruppo e cataloghi; con qualcosa nella ricerca, i risultati.
func _fill_index() -> void:
	for c in _index.get_children():
		_index.remove_child(c)
		c.queue_free()
	var q := _search.text.strip_edges()
	if q.length() >= 2:
		var res := EncyPages.search(q)
		_head("Risultati (%d)" % res.size())
		for r in res:
			_entry(String(r[0]), String(r[1]))
		if res.is_empty():
			_head("Niente: prova un'altra parola")
		return
	var group := ""
	for c in EncyPages.chapters():
		if String(c["group"]) != group:
			group = String(c["group"])
			_head(group)
		_entry("cap:" + String(c["id"]), String(c["name"]))
	_head("Cataloghi")
	for k in EncyPages.CATALOGS:
		_entry("cat:" + String(k[0]), String(k[1]))


func _head(t: String) -> void:
	var l := Label.new()
	l.text = t
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", GOLD)
	_index.add_child(l)


func _entry(addr: String, t: String) -> void:
	var b := Button.new()
	b.text = t
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color("#cfeee4"))
	b.add_theme_color_override("font_hover_color", Color("#ffb84a"))
	b.pressed.connect(func() -> void: go(addr))
	_index.add_child(b)


func _unhandled_input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		close_panel()
