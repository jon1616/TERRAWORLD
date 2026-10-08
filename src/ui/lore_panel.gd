class_name LorePanel
extends Control
## Una pagina di storia (`LoreData`) al centro dello schermo: titolo, testo, e sotto «clic per chiudere». Il gioco
## non si ferma; si chiude con un clic, con E o con Esc (che in questo caso non esce dal mondo).

const W := 620.0
const PIC_W := 480.0                   # voce 104: la vignetta (240 px) ingrandita due volte
const PIC_H := 380.0                   # le vignette quasi quadrate si fermano a quest'altezza

var _title: Label
var _pic: TextureRect
var _text: Label
var _box: PanelContainer

signal page_shown(id: String)


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_box = PanelContainer.new()
	_box.add_theme_stylebox_override("panel", UiFrames.padded("forte", "normale", Color("#3aa08a"), Vector2(22, 20)))
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_box.add_child(v)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UiFonts.apply(_title, 3)                  # (Roadmap 55) il titolo in Alegreya
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	v.add_child(_title)
	_pic = TextureRect.new()
	_pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_pic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	v.add_child(_pic)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.custom_minimum_size = Vector2(W, 0)
	_text.add_theme_font_size_override("font_size", 18)
	_text.add_theme_color_override("font_color", Color("#dce8e4"))
	v.add_child(_text)
	var hint := Label.new()
	hint.text = "clic per chiudere"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	v.add_child(hint)


## Voce 231: una pagina che non sta in `LoreData` (le scene delle storie degli abitanti).
func show_text(title: String, text: String) -> void:
	_title.text = title
	_text.text = text
	_pic.visible = false
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	var vs := get_viewport_rect().size
	_box.position = (vs - _box.size) * 0.5 - Vector2(0, 60)
	_box.position.y = maxf(_box.position.y, 12.0)


func show_page(id: String) -> void:
	var pg: Dictionary = LoreData.PAGES.get(id, {})
	if pg.is_empty():
		return
	page_shown.emit(id)
	_title.text = String(pg["title"])
	_text.text = String(pg["text"])
	# voce 104: la vignetta della pagina (arte/storia/<id>.png), se c'è
	var t := ArtLib.tex("storia", id)
	_pic.visible = t != null
	if t != null:
		_pic.texture = t
		var sc := minf(PIC_W / t.get_width(), PIC_H / t.get_height())
		_pic.custom_minimum_size = (t.get_size() * sc).round()
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	var vs := get_viewport_rect().size
	_box.position = (vs - _box.size) * 0.5 - Vector2(0, 60)
	_box.position.y = maxf(_box.position.y, 12.0)


func _input(e: InputEvent) -> void:
	if not visible:
		return
	var close: bool = (e is InputEventMouseButton and e.pressed) \
			or (e is InputEventKey and e.pressed and (e.keycode == KEY_ESCAPE or Keys.pressed(e, "bisaccia")))
	if close:
		visible = false
		get_viewport().set_input_as_handled()
