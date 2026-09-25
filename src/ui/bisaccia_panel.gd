class_name BisacciaPanel
extends Control
## La Bisaccia aperta: le 30 caselle sopra la barra rapida. Un clic prende la pila (resta «in mano», segue il mouse),
## un altro clic la posa o la scambia; il clic destro prende metà pila. A destra la colonna «Creare» (`CraftingPanel`).

const COLS := 10
const ROWS := 3
const GAP := 6

var bisaccia: Bisaccia
var stations_near: Callable            # () -> stazioni a portata del giocatore, per la colonna «Creare»
var crafting: CraftingPanel
var _equip: Dictionary = {}            # posto -> SlotView
var _scorza: Label
var held := {}                        # pila «in mano» mentre la Bisaccia è aperta
## Maiusc+clic su una casella: se è aperta una cesta (`ChestPanel`), la pila ci va dentro subito.
var quick_target: Callable
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
	# (la stessa cornice serve anche alla colonna dell'equipaggiamento)
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
	# equipaggiamento: una colonna a sinistra, con il nome dei posti e la Scorza totale
	# due colonne: armatura (elmo, corazza, gambali) e accessori
	var ex := frame.position.x - 16 - 2 * SlotView.SIZE - 40
	var eframe := Panel.new()
	eframe.add_theme_stylebox_override("panel", sb)
	eframe.position = Vector2(ex - 12, frame.position.y)
	eframe.size = Vector2(2 * SlotView.SIZE + 64, frame.size.y)
	eframe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(eframe)
	for k in Bisaccia.EQUIP_SLOTS.size():
		var slot: String = Bisaccia.EQUIP_SLOTS[k]
		var s := SlotView.new()
		var col := 0 if k < 3 else 1
		var row := k if k < 3 else k - 3
		s.position = Vector2(ex + 12 + col * (SlotView.SIZE + 16), frame.position.y + 40 + row * (SlotView.SIZE + 22))
		s.clicked.connect(func(_i: int, button: int) -> void:
			if button == MOUSE_BUTTON_LEFT:
				held = bisaccia.wear(slot, held)
				_refresh())
		add_child(s)
		var tag := Label.new()
		tag.text = "Accessorio" if Bisaccia.kind_of_slot(slot) == "accessorio" else slot.capitalize()
		tag.position = s.position + Vector2(-6, SlotView.SIZE - 2)
		tag.size = Vector2(SlotView.SIZE + 12, 18)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 12)
		tag.add_theme_color_override("font_color", Color("#9fc8c0"))
		add_child(tag)
		_equip[slot] = s
	_scorza = Label.new()
	_scorza.position = Vector2(ex - 6, frame.position.y + 8)
	_scorza.size = Vector2(2 * SlotView.SIZE + 52, 24)
	_scorza.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scorza.add_theme_font_size_override("font_size", 16)
	_scorza.add_theme_color_override("font_color", Color("#ffb84a"))
	_scorza.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_scorza.add_theme_constant_override("outline_size", 5)
	_scorza.tooltip_text = "Scorza: toglie metà del suo valore a ogni ferita"
	add_child(_scorza)
	crafting = CraftingPanel.new()
	add_child(crafting)
	crafting.setup(bisaccia, stations_near, Vector2(frame.position.x + frame.size.x + 16, frame.position.y), frame.size.y)
	_held_icon = SlotView.new()
	_held_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_icon.modulate = Color(1, 1, 1, 0.9)
	_held_icon.visible = false
	add_child(_held_icon)
	bisaccia.changed.connect(_refresh)
	_refresh()


func toggle() -> void:
	visible = not visible
	if visible:
		crafting.refresh()
	if not visible and not held.is_empty():
		# richiudendo, ciò che è in mano torna nella Bisaccia
		bisaccia.add(held["id"], held["n"])
		held = {}
		_refresh()


func click_slot(i: int, button: int) -> void:
	if button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT) and quick_target.is_valid():
		quick_target.call(i)
	elif button == MOUSE_BUTTON_RIGHT and held.is_empty() and bisaccia.count_at(i) > 1:
		var half := bisaccia.count_at(i) / 2
		held = {"id": bisaccia.id_at(i), "n": half}
		bisaccia.slots[i]["n"] = bisaccia.count_at(i) - half
		bisaccia.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		held = bisaccia.swap_with(i, held)
	_refresh()


## Dopo che un altro pannello ha cambiato la pila in mano.
func refresh_held() -> void:
	_refresh()


func _refresh() -> void:
	for s in _slots:
		s.set_item(bisaccia.id_at(s.index), bisaccia.count_at(s.index))
	for slot in _equip:
		(_equip[slot] as SlotView).set_item(String(bisaccia.equip.get(slot, "")), 1)
	if _scorza:
		_scorza.text = "Scorza %d" % bisaccia.scorza()
	_held_icon.visible = not held.is_empty()
	if not held.is_empty():
		_held_icon.set_item(held["id"], held["n"])


func _process(_dt: float) -> void:
	if _held_icon.visible:
		_held_icon.position = get_viewport().get_mouse_position() + Vector2(8, 8)
