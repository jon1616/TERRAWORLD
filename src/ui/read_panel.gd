class_name ReadPanel
extends Control
## Un riquadro da leggere al centro dello schermo (voce 68): le stele dei Seminatori, e più avanti gli indizi delle
## catene e le scritte dei luoghi. Titolo, testo con i colori; si chiude con un clic, Esc o il tasto della Bisaccia.

var _title: Label
var _text: RichTextLabel
var _box: PanelContainer


func _init() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.01, 0.02, 0.72)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	_box = PanelContainer.new()
	_box.add_theme_stylebox_override("panel", UiFrames.padded("forte", "normale", Color("#6ff0b8"), Vector2(24, 22)))
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_box.add_child(v)
	_title = Label.new()
	UiFonts.apply(_title, 3)                  # (Roadmap 55) il titolo in Alegreya
	_title.add_theme_color_override("font_color", Color("#ffd08a"))
	v.add_child(_title)
	var rule := UiRule.new()
	rule.color = Color("#6ff0b8", 0.5)
	v.add_child(rule)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.custom_minimum_size = Vector2(760, 0)
	UiKit.book(_text, 21)                     # (Roadmap 55) si legge come una pagina
	_text.add_theme_color_override("default_color", Color("#dcefe8"))
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_text)
	var hint := UiKit.hint("Clic", "chiudi")
	hint.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(hint)


func show_text(title: String, bb: String) -> void:
	_title.text = title
	_text.text = bb
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	_box.reset_size()
	_box.position = (size - _box.size) / 2.0


func _input(e: InputEvent) -> void:
	if not visible:
		return
	var close: bool = (e is InputEventMouseButton and e.pressed) \
			or (e is InputEventKey and e.pressed and not e.echo and (e.keycode == KEY_ESCAPE or Keys.pressed(e, "bisaccia")))
	if close:
		visible = false
		get_viewport().set_input_as_handled()
