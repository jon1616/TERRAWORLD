class_name BisacciaPanel
extends Control
## La Bisaccia aperta: le 30 caselle sopra la barra rapida. Un clic prende la pila (resta «in mano», segue il mouse),
## un altro clic la posa o la scambia; il clic destro prende metà pila. La fabbricazione arriva con la voce 4c.

const COLS := 10
const ROWS := 3
const GAP := 6

var bisaccia: Bisaccia
var held := {}                        # pila «in mano» mentre la Bisaccia è aperta
var _slots: Array[SlotView] = []
var _held_icon: SlotView


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var y0 := Hud.HOTBAR_Y - 16 - ROWS * (SlotView.SIZE + GAP)
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.05, 0.06, 0.82)
	sb.border_color = Color("#2f7a70")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(22)
	frame.add_theme_stylebox_override("panel", sb)
	frame.position = Vector2(x0 - 14, y0 - 44)
	frame.size = Vector2(w + 28, ROWS * (SlotView.SIZE + GAP) + 44 + 8 + SlotView.SIZE + 18)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	var title := Label.new()
	title.text = "Bisaccia"
	title.position = Vector2(x0, y0 - 38)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#ffb84a"))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	title.add_theme_constant_override("outline_size", 6)
	add_child(title)
	for r in ROWS:
		for c in COLS:
			var s := SlotView.new()
			s.index = Bisaccia.HOTBAR + r * COLS + c
			s.position = Vector2(x0 + c * (SlotView.SIZE + GAP), y0 + r * (SlotView.SIZE + GAP))
			s.clicked.connect(click_slot)
			add_child(s)
			_slots.append(s)
	_held_icon = SlotView.new()
	_held_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_icon.modulate = Color(1, 1, 1, 0.9)
	_held_icon.visible = false
	add_child(_held_icon)
	bisaccia.changed.connect(_refresh)
	_refresh()


func toggle() -> void:
	visible = not visible
	if not visible and not held.is_empty():
		# richiudendo, ciò che è in mano torna nella Bisaccia
		bisaccia.add(held["id"], held["n"])
		held = {}
		_refresh()


func click_slot(i: int, button: int) -> void:
	if button == MOUSE_BUTTON_RIGHT and held.is_empty() and bisaccia.count_at(i) > 1:
		var half := bisaccia.count_at(i) / 2
		held = {"id": bisaccia.id_at(i), "n": half}
		bisaccia.slots[i]["n"] = bisaccia.count_at(i) - half
		bisaccia.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		held = bisaccia.swap_with(i, held)
	_refresh()


func _refresh() -> void:
	for s in _slots:
		s.set_item(bisaccia.id_at(s.index), bisaccia.count_at(s.index))
	_held_icon.visible = not held.is_empty()
	if not held.is_empty():
		_held_icon.set_item(held["id"], held["n"])


func _process(_dt: float) -> void:
	if _held_icon.visible:
		_held_icon.position = get_viewport().get_mouse_position() + Vector2(8, 8)
