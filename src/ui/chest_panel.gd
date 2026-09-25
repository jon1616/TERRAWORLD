class_name ChestPanel
extends Control
## Il contenuto di una cesta o di uno scrigno, sopra la Bisaccia aperta (voce 10). Stesse regole della Bisaccia: un clic
## prende o posa la pila «in mano» (condivisa con `BisacciaPanel.held`), il clic destro prende metà pila;
## Maiusc+clic sposta subito la pila dall'altra parte; «Prendi tutto» svuota nella Bisaccia ciò che ci sta.
## Si chiude chiudendo la Bisaccia o allontanandosi.

const COLS := 10
const GAP := 6

var panel: BisacciaPanel
var chest: Bisaccia
var origin := Vector2i(-1, -1)
var _slots: Array[SlotView] = []
var _title: Label
var _frame: Panel


func setup(p: BisacciaPanel) -> void:
	panel = p
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var rows := 2
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var bag_top := Hud.HOTBAR_Y - 16 - 3 * (SlotView.SIZE + GAP) - 44
	var y0 := bag_top - 14 - rows * (SlotView.SIZE + GAP)
	_frame = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.06, 0.06, 0.86)
	sb.border_color = Color("#6ff0d8")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	_frame.add_theme_stylebox_override("panel", sb)
	_frame.position = Vector2(x0 - 14, y0 - 40)
	_frame.size = Vector2(w + 28, rows * (SlotView.SIZE + GAP) + 44)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_title = Label.new()
	_title.position = Vector2(x0, y0 - 34)
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	var take := Button.new()
	take.text = "Prendi tutto"
	take.position = Vector2(x0 + w - 130, y0 - 38)
	take.size = Vector2(130, 30)
	take.pressed.connect(take_all)
	add_child(take)
	for r in rows:
		for c in COLS:
			var s := SlotView.new()
			s.index = r * COLS + c
			s.position = Vector2(x0 + c * (SlotView.SIZE + GAP), y0 + r * (SlotView.SIZE + GAP))
			s.clicked.connect(_click)
			add_child(s)
			_slots.append(s)


func open(o: Vector2i, contents: Bisaccia, title: String) -> void:
	if chest != null and chest.changed.is_connected(_refresh):
		chest.changed.disconnect(_refresh)
	origin = o
	chest = contents
	chest.changed.connect(_refresh)
	_title.text = title
	visible = true
	if not panel.visible:
		panel.toggle()
	panel.quick_target = _from_bag
	_refresh()


func close() -> void:
	visible = false
	panel.quick_target = Callable()
	if chest != null and chest.changed.is_connected(_refresh):
		chest.changed.disconnect(_refresh)
	chest = null


func take_all() -> void:
	if chest == null:
		return
	for i in chest.slots.size():
		if chest.slots[i].is_empty():
			continue
		var rest := panel.bisaccia.add(chest.id_at(i), chest.count_at(i))
		chest.slots[i] = {} if rest <= 0 else {"id": chest.id_at(i), "n": rest}
	chest.changed.emit()


## Maiusc+clic su una casella della Bisaccia mentre la cesta è aperta: la pila passa nella cesta.
func _from_bag(i: int) -> void:
	var b := panel.bisaccia
	if b.slots[i].is_empty():
		return
	var rest := chest.add(b.id_at(i), b.count_at(i))
	b.slots[i] = {} if rest <= 0 else {"id": b.id_at(i), "n": rest}
	b.changed.emit()


func _click(i: int, button: int) -> void:
	if chest == null:
		return
	if button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
		if not chest.slots[i].is_empty():
			var rest := panel.bisaccia.add(chest.id_at(i), chest.count_at(i))
			chest.slots[i] = {} if rest <= 0 else {"id": chest.id_at(i), "n": rest}
			chest.changed.emit()
	elif button == MOUSE_BUTTON_RIGHT and panel.held.is_empty() and chest.count_at(i) > 1:
		var half := chest.count_at(i) / 2
		panel.held = {"id": chest.id_at(i), "n": half}
		chest.slots[i]["n"] = chest.count_at(i) - half
		chest.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		panel.held = chest.swap_with(i, panel.held)
	panel.refresh_held()


func _refresh() -> void:
	if chest == null:
		return
	for s in _slots:
		s.visible = s.index < chest.slots.size()
		if s.visible:
			s.set_item(chest.id_at(s.index), chest.count_at(s.index))


func _process(_dt: float) -> void:
	if visible and not panel.visible:
		close()
