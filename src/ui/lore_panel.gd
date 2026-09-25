class_name LorePanel
extends Control
## Una pagina di storia (`LoreData`) al centro dello schermo: titolo, testo, e sotto «clic per chiudere». Il gioco
## non si ferma; si chiude con un clic, con E o con Esc (che in questo caso non esce dal mondo).

const W := 620.0

var _title: Label
var _text: Label
var _box: PanelContainer

signal page_shown(id: String)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_box = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.07, 0.09, 0.92)
	sb.border_color = Color("#3aa08a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(22)
	_box.add_theme_stylebox_override("panel", sb)
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_box.add_child(v)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 26)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	v.add_child(_title)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(W, 0)
	_text.add_theme_font_size_override("font_size", 16)
	_text.add_theme_color_override("font_color", Color("#dce8e4"))
	v.add_child(_text)
	var hint := Label.new()
	hint.text = "clic per chiudere"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	v.add_child(hint)


func show_page(id: String) -> void:
	var pg: Dictionary = LoreData.PAGES.get(id, {})
	if pg.is_empty():
		return
	page_shown.emit(id)
	_title.text = String(pg["title"])
	_text.text = String(pg["text"])
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	var vs := get_viewport_rect().size
	_box.position = (vs - _box.size) * 0.5 - Vector2(0, 60)


func _input(e: InputEvent) -> void:
	if not visible:
		return
	var close: bool = (e is InputEventMouseButton and e.pressed) \
			or (e is InputEventKey and e.pressed and e.keycode in [KEY_E, KEY_ESCAPE])
	if close:
		visible = false
		get_viewport().set_input_as_handled()
