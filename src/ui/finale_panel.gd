class_name FinalePanel
extends Control
## Il pannello del finale (Roadmap 28, voce 264): a schermo intero, una pagina alla volta (clic, Spazio o Invio per
## andare avanti, Esc per chiudere): il racconto dell'Albero Antico, l'epilogo con i numeri della partita, i titoli di
## coda. Le pagine gliele dà `Finale`.

var pages: Array = []                  # [[titolo, testo], …]
var index := 0
var _title: Label
var _text: RichTextLabel
var _foot: Label


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.02)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = Label.new()
	_title.position = Vector2(200, 150)
	_title.size = Vector2(1200, 60)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	PixelFont.apply(_title, 4)                  # (voce 272) il titolo nel carattere di pixel
	_title.add_theme_color_override("font_color", Color("#ffd870"))
	add_child(_title)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.position = Vector2(300, 250)
	_text.size = Vector2(1000, 500)
	_text.add_theme_font_size_override("normal_font_size", 22)
	_text.add_theme_font_size_override("bold_font_size", 22)
	add_child(_text)
	_foot = Label.new()
	_foot.position = Vector2(200, 820)
	_foot.size = Vector2(1200, 30)
	_foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_foot.add_theme_color_override("font_color", Color("#8a9a84"))
	add_child(_foot)


func show_pages(p: Array) -> void:
	pages = p
	index = 0
	visible = true
	get_parent().move_child(self, -1)
	_show()


func _show() -> void:
	var pg: Array = pages[index]
	_title.text = String(pg[0])
	_text.text = "[center]%s[/center]" % String(pg[1])
	_foot.text = "%d / %d · clic o Spazio per andare avanti · Esc per chiudere" % [index + 1, pages.size()]


func next() -> void:
	index += 1
	if index >= pages.size():
		close()
	else:
		_show()


func close() -> void:
	visible = false


func _gui_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		next()
		accept_event()


func _unhandled_input(e: InputEvent) -> void:
	if not visible or not (e is InputEventKey and e.pressed and not e.echo):
		return
	if e.keycode == KEY_ESCAPE:
		close()
	elif e.keycode == KEY_SPACE or e.keycode == KEY_ENTER:
		next()
	get_viewport().set_input_as_handled()
