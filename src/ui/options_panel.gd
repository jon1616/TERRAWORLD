class_name OptionsPanel
extends Control
## La schermata delle Opzioni (27 set 2026, richiesta dell'utente: «ampia e completa, che copra tutti gli aspetti del
## gioco»): a sinistra le sezioni (`OptionsData.SECTIONS`), a destra una riga per opzione con il nome, che cosa fa e
## il comando (cursore, interruttore, scelta). La sezione Comandi cambia i tasti: clic su un tasto, poi il tasto nuovo
## (Esc annulla; un tasto già usato da un altro comando passa a questo). Si apre dal menu e dalla pausa in gioco.
## Ogni cambio si salva subito (`Settings.set_v`).

signal closed

const TEAL := Color("#2f7a70")
const GOLD := Color("#ffd08a")
const TEXT := Color("#e4f6ee")
const DIM := Color("#8aa8a2")

var section := "audio"
var _tabs := {}
var _rows: VBoxContainer
var _scroll: ScrollContainer
var _capture: Array = []               # [azione, posto] mentre si aspetta il tasto nuovo
var _note: Label


func _init() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS
	size = Vector2(1600, 900)
	var bg := ColorRect.new()
	bg.color = UiPalette.FONDO                 # opaco: la fusione è lineare, al 97% il mondo si vedeva ancora
	var glow := UiBackdrop.new()               # (Roadmap 55) la luce morbida dei pannelli
	glow.size = Vector2(1600, 900)
	bg.add_child(glow)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var title := Label.new()
	title.text = "Opzioni"
	title.position = Vector2(120, 36)
	UiFonts.apply(title, 3)                  # (Roadmap 55) il titolo in Alegreya
	title.add_theme_color_override("font_color", GOLD)
	add_child(title)
	var y := 110.0
	for s in OptionsData.SECTIONS:
		var b := Button.new()
		b.text = String(s[1])
		b.position = Vector2(120, y)
		b.size = Vector2(220, 46)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 20)
		var sid := String(s[0])
		b.pressed.connect(func() -> void: show_section(sid))
		add_child(b)
		_tabs[sid] = b
		y += 54.0
	_scroll = ScrollContainer.new()
	UiScreen.box(self, Rect2(362, 94, 1136, 706))        # (voce 283) le righe in un riquadro
	_scroll.position = Vector2(380, 110)
	_scroll.size = Vector2(1100, 674)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_rows = VBoxContainer.new()
	_rows.custom_minimum_size = Vector2(1080, 0)
	_rows.add_theme_constant_override("separation", 10)
	_scroll.add_child(_rows)
	_note = Label.new()
	_note.position = Vector2(380, 812)
	_note.add_theme_color_override("font_color", DIM)
	add_child(_note)
	var reset := _button("Valori di partenza", Vector2(120, 820), Vector2(220, 44))
	reset.tooltip_text = "Rimette come all'inizio le opzioni di questa sezione (o tutti i tasti, nella sezione Comandi)"
	reset.pressed.connect(_reset_section)
	var close := _button("Chiudi (Esc)", Vector2(1300, 820), Vector2(180, 44))
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


func open() -> void:
	Settings.load_once()
	visible = true
	show_section(section)


func close_panel() -> void:
	_capture = []
	visible = false
	closed.emit()


func show_section(sid: String) -> void:
	section = sid
	_capture = []
	_note.text = ""
	for k in _tabs:
		RecipeRow.style(_tabs[k], true, Color("#ffb84a") if k == sid else TEAL)
	for c in _rows.get_children():
		_rows.remove_child(c)
		c.queue_free()
	if sid == "comandi":
		_keys_rows()
		return
	for o in OptionsData.OPTIONS:
		if String(o["sec"]) == sid:
			_rows.add_child(_row(o))
	_scroll.scroll_vertical = 0


## Una riga: nome e spiegazione a sinistra, il comando a destra.
func _row(o: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 30)
	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(600, 0)
	left.add_theme_constant_override("separation", 2)
	var n := Label.new()
	n.text = String(o["name"])
	n.add_theme_font_size_override("font_size", 21)
	n.add_theme_color_override("font_color", TEXT)
	left.add_child(n)
	var d := Label.new()
	d.text = String(o.get("desc", ""))
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(600, 0)
	d.add_theme_font_size_override("font_size", 16)
	d.add_theme_color_override("font_color", DIM)
	left.add_child(d)
	row.add_child(left)
	row.add_child(_control(o))
	return row


func _control(o: Dictionary) -> Control:
	var id := String(o["id"])
	var cur: Variant = Settings.v(id)
	match String(o["type"]):
		"bool":
			var cb := CheckButton.new()
			cb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			cb.button_pressed = bool(cur)
			cb.text = "Sì" if bool(cur) else "No"
			cb.focus_mode = Control.FOCUS_NONE
			cb.add_theme_font_size_override("font_size", 19)
			cb.toggled.connect(func(on: bool) -> void:
				cb.text = "Sì" if on else "No"
				Settings.set_v(id, on))
			return cb
		"choice":
			var ob := OptionButton.new()
			ob.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			ob.custom_minimum_size = Vector2(380, 40)
			ob.focus_mode = Control.FOCUS_NONE
			ob.add_theme_font_size_override("font_size", 18)
			var ch: Array = o["choices"]
			for i in ch.size():
				ob.add_item(String(ch[i][1]), i)
				if _same(ch[i][0], cur):
					ob.select(i)
			ob.item_selected.connect(func(i: int) -> void: Settings.set_v(id, ch[i][0]))
			return ob
		_:
			var box := HBoxContainer.new()
			box.add_theme_constant_override("separation", 12)
			box.size_flags_vertical = Control.SIZE_SHRINK_CENTER   # (voce 283) cursore e valore sulla stessa riga
			var sl := HSlider.new()
			sl.min_value = float(o["min"])
			sl.max_value = float(o["max"])
			sl.step = float(o["step"])
			sl.value = float(cur)
			sl.custom_minimum_size = Vector2(300, 36)
			sl.focus_mode = Control.FOCUS_NONE
			var lab := Label.new()
			lab.custom_minimum_size = Vector2(80, 0)
			lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lab.size_flags_vertical = Control.SIZE_FILL
			lab.add_theme_font_size_override("font_size", 19)
			lab.add_theme_color_override("font_color", GOLD)
			lab.text = _fmt(o, float(cur))
			sl.value_changed.connect(func(val: float) -> void:
				lab.text = _fmt(o, val)
				Settings.set_v(id, val))
			box.add_child(sl)
			box.add_child(lab)
			return box


static func _same(a: Variant, b: Variant) -> bool:
	if typeof(a) in [TYPE_INT, TYPE_FLOAT] and typeof(b) in [TYPE_INT, TYPE_FLOAT]:
		return absf(float(a) - float(b)) < 0.0001
	return str(a) == str(b)


static func _fmt(o: Dictionary, val: float) -> String:
	match String(o.get("fmt", "")):
		"pct":
			return "%d%%" % roundi(val * 100.0)
		"s":
			return ("%.2f s" % val).replace(".", ",")
		"tessere":
			return "%d tessere" % roundi(val)
	return str(val)


## I comandi: per ogni azione due tasti; clic su uno e poi il tasto nuovo.
func _keys_rows() -> void:
	var group := ""
	for a in KeysData.ACTIONS:
		if String(a[3]) != group:
			group = String(a[3])
			var h := Label.new()
			h.text = group
			h.add_theme_font_size_override("font_size", 22)
			h.add_theme_color_override("font_color", GOLD)
			_rows.add_child(h)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		var n := Label.new()
		n.text = String(a[1])
		n.custom_minimum_size = Vector2(560, 0)
		n.add_theme_font_size_override("font_size", 19)
		n.add_theme_color_override("font_color", TEXT)
		row.add_child(n)
		var ks: Array = Settings.keys_of(String(a[0]))
		for slot in 2:
			var b := Button.new()
			b.custom_minimum_size = Vector2(200, 38)
			b.focus_mode = Control.FOCUS_NONE
			b.text = Keys.key_name(int(ks[slot])) if slot < ks.size() else "—"
			RecipeRow.style(b, true, TEAL)
			var act := String(a[0])
			var sl := slot
			b.pressed.connect(func() -> void:
				_capture = [act, sl]
				b.text = "Premi un tasto…"
				_note.text = "Premi il tasto nuovo per «%s» (Esc annulla, Cancella toglie questo tasto)" % a[1])
			row.add_child(b)
		_rows.add_child(row)
	var fixed := Label.new()
	fixed.text = "Fissi: Esc (pausa, chiude i pannelli), 1-0 e rotella (barra rapida), clic sinistro (usa), clic destro (tocca)."
	fixed.add_theme_color_override("font_color", DIM)
	_rows.add_child(fixed)


func _input(e: InputEvent) -> void:
	if not visible:
		return
	if e is InputEventKey and e.pressed and not e.echo:
		if not _capture.is_empty():
			get_viewport().set_input_as_handled()
			var k := (e as InputEventKey).keycode
			var msg := ""
			if k != KEY_ESCAPE:
				msg = _assign(String(_capture[0]), int(_capture[1]), k)
			_capture = []
			show_section("comandi")
			_note.text = msg
			return
		if (e as InputEventKey).keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			close_panel()


## Il tasto nuovo per un'azione; se lo usava un'altra azione, lo perde quella. Cancella toglie il tasto.
func _assign(act: String, slot: int, k: int) -> String:
	var ks: Array = Settings.keys_of(act).duplicate()
	if k == KEY_BACKSPACE:
		if slot < ks.size() and ks.size() > 1:
			ks.remove_at(slot)
		Settings.set_keys(act, ks)
		return ""
	if k in [KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]:
		return "I numeri servono alla barra rapida: scegli un altro tasto"
	var msg := ""
	for a in KeysData.ACTIONS:
		var other := String(a[0])
		if other != act and k in Settings.keys_of(other):
			var oks: Array = Settings.keys_of(other).duplicate()
			oks.erase(k)
			Settings.set_keys(other, oks)
			msg = "%s non è più il tasto di «%s»" % [Keys.key_name(k), a[1]]
	if slot < ks.size():
		ks[slot] = k
	else:
		ks.append(k)
	Settings.set_keys(act, ks)
	return msg


func _reset_section() -> void:
	if section == "comandi":
		Settings.reset_keys()
	else:
		for o in OptionsData.OPTIONS:
			if String(o["sec"]) == section:
				Settings.set_v(String(o["id"]), o["def"])
	show_section(section)
