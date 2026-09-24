class_name Hud
extends CanvasLayer
## Barra rapida (le prime 10 caselle della Bisaccia, in basso al centro), nome dell'oggetto in mano, messaggi brevi,
## aiuto sui comandi, e la Bisaccia aperta (tasto E o Tab). Stile «Radici e Linfa».

signal selected(item: Dictionary)

const AMBER := Color("#ffb84a")
const HOTBAR_Y := 900 - SlotView.SIZE - 18

var bisaccia: Bisaccia                 # da impostare prima di aggiungere il nodo alla scena
var sel := 0
var panel: BisacciaPanel
var _slots: Array[SlotView] = []
var _name: Label
var _info: Label
var _toast: Label


func _ready() -> void:
	layer = 10
	# la Bisaccia per prima: la sua cornice sta sotto la barra rapida, che resta in primo piano
	panel = BisacciaPanel.new()
	panel.bisaccia = bisaccia
	panel.visible = false
	add_child(panel)
	var n := Bisaccia.HOTBAR
	var x0 := (1600 - (n * SlotView.SIZE + (n - 1) * 6)) / 2.0
	for k in n:
		var s := SlotView.new()
		s.index = k
		s.position = Vector2(x0 + k * (SlotView.SIZE + 6), HOTBAR_Y)
		s.clicked.connect(_on_slot_clicked)
		add_child(s)
		var num := _label(s, Vector2(7, 1), 12)
		num.add_theme_color_override("font_color", Color("#9fd8c8"))
		num.text = str((k + 1) % 10)
		_slots.append(s)
	_name = _label(self, Vector2(0, HOTBAR_Y - 32), 20)
	_name.size = Vector2(1600, 28)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_color_override("font_color", AMBER)
	_info = _label(self, Vector2(16, 10), 14)
	_info.add_theme_color_override("font_color", Color("#9fc8c0"))
	_info.text = "A/D muovi · Spazio salta · clic sinistro usa (scava, abbatti, piazza) · clic destro torcia · 1-0 / rotella oggetti · E Bisaccia · Esc salva ed esce\nTutto ciò che vedi è generato dal codice: nessuna immagine esterna."
	_toast = _label(self, Vector2(1200, 12), 18)
	_toast.size = Vector2(380, 30)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_toast.modulate.a = 0.0
	bisaccia.changed.connect(_refresh)
	_refresh()
	select(0)


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#fff4dc"))
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


## Messaggio breve in alto a destra che svanisce da solo.
func toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	create_tween().tween_property(_toast, "modulate:a", 0.0, 1.2).set_delay(1.5)


## L'oggetto in mano: {"id", "name", "use", "tex"} (id vuoto = mani nude).
func current() -> Dictionary:
	var id := bisaccia.id_at(sel)
	if id == "":
		return {"id": "", "name": "", "use": "", "tex": null}
	return {"id": id, "name": ItemsData.get_item(id)["name"], "use": ItemsData.use_of(id), "tex": SlotView.icon(id)}


func select(k: int) -> void:
	sel = posmod(k, Bisaccia.HOTBAR)
	for i in _slots.size():
		_slots[i].set_selected(i == sel)
	_update_name()
	selected.emit(current())


func is_open() -> bool:
	return panel.visible


func _refresh() -> void:
	for i in _slots.size():
		_slots[i].set_item(bisaccia.id_at(i), bisaccia.count_at(i))
	_update_name()
	selected.emit(current())


func _update_name() -> void:
	_name.text = current()["name"]


func _on_slot_clicked(i: int, button: int) -> void:
	if panel.visible:
		panel.click_slot(i, button)
	elif button == MOUSE_BUTTON_LEFT:
		select(i)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode >= KEY_0 and e.keycode <= KEY_9:
			select((e.keycode - KEY_0 + 9) % 10)
		elif e.keycode == KEY_E or e.keycode == KEY_TAB:
			panel.toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and panel.visible:
			panel.toggle()
			get_viewport().set_input_as_handled()
	elif e is InputEventMouseButton and e.pressed and not panel.visible:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			select(sel - 1)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select(sel + 1)
