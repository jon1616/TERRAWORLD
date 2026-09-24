class_name CraftingPanel
extends Control
## La colonna «Creare» accanto alla Bisaccia aperta: le ricette usabili con le stazioni vicine. Chiare quelle per cui
## bastano i materiali (in cima), attenuate le altre; passando sopra si vede cosa serve. Un clic fabbrica una volta.

const W := 440
const ROW := 44
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")

var bisaccia: Bisaccia
var stations_near: Callable            # () -> Dictionary delle stazioni a portata
var _list: VBoxContainer
var _title: Label
var _near_key := ""
var _t := 0.0

signal crafted(id: String, n: int)


func setup(b: Bisaccia, near: Callable, pos: Vector2, height: float) -> void:
	bisaccia = b
	stations_near = near
	position = pos
	size = Vector2(W, height)
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.05, 0.06, 0.82)
	sb.border_color = TEAL
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(22)
	frame.add_theme_stylebox_override("panel", sb)
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	_title = Label.new()
	_title.position = Vector2(16, 6)
	_title.add_theme_font_size_override("font_size", 22)
	_title.add_theme_color_override("font_color", AMBER)
	_title.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_title.add_theme_constant_override("outline_size", 6)
	add_child(_title)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 44)
	scroll.size = Vector2(W - 24, height - 56)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(W - 40, 0)
	_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_list)
	bisaccia.changed.connect(refresh)
	refresh()


func _process(dt: float) -> void:
	if not is_visible_in_tree():
		return
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		var near: Dictionary = stations_near.call()
		var key := ",".join(near.keys())
		if key != _near_key:
			refresh()


func refresh() -> void:
	if _list == null:
		return
	var near: Dictionary = stations_near.call()
	_near_key = ",".join(near.keys())
	var names := []
	for id in near:
		names.append(StationsData.STATIONS[id]["name"])
	_title.text = "Creare" + ("" if names.is_empty() else "  ·  " + ", ".join(names))
	for c in _list.get_children():
		c.queue_free()
	var recipes := Crafting.available(near)
	var ok := recipes.filter(func(r: Dictionary) -> bool: return Crafting.can_craft(r, bisaccia))
	var no := recipes.filter(func(r: Dictionary) -> bool: return not Crafting.can_craft(r, bisaccia))
	for r in ok + no:
		_list.add_child(_row(r, Crafting.can_craft(r, bisaccia)))
	if recipes.is_empty():
		var l := Label.new()
		l.text = "Nulla da creare qui."
		_list.add_child(l)


func _row(r: Dictionary, can: bool) -> Button:
	var b := Button.new()
	var out: String = r["out"]
	var n := int(r["qty"])
	b.text = "%s%s" % [ItemsData.get_item(out)["name"], (" ×%d" % n) if n > 1 else ""]
	b.icon = SlotView.icon(out)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 32)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, ROW)
	b.tooltip_text = Crafting.describe(r, bisaccia)
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", Color("#eafff6") if can else Color("#6f8a86"))
	b.add_theme_color_override("font_hover_color", AMBER if can else Color("#8fa8a4"))
	b.modulate = Color(1, 1, 1, 1) if can else Color(1, 1, 1, 0.6)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.14, 0.16, 0.9) if st != "hover" else Color(0.08, 0.22, 0.24, 0.95)
		sb.border_color = AMBER if st == "hover" and can else TEAL
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(14)
		sb.content_margin_left = 10
		b.add_theme_stylebox_override(st, sb)
	b.pressed.connect(func() -> void:
		if Crafting.craft(r, bisaccia):
			crafted.emit(out, n))
	return b
