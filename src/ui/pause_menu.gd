class_name PauseMenu
extends Control
## Il menu di pausa (27 set 2026): Esc in gioco, quando non c'è un pannello da chiudere. Il mondo si ferma; da qui si
## riprende, si aprono le Opzioni e l'Enciclopedia, si salva, si torna al menu o si esce dal gioco.
## Prima Esc salvava e tornava subito al menu: ora lo fa il bottone «Salva e torna al menu».

var m: Node2D
var options: OptionsPanel
var _box: VBoxContainer


func setup(main: Node2D, opts: OptionsPanel) -> void:
	m = main
	options = opts
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.02, 0.03, 0.9)
	bg.size = size
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# (voce 283) il menu sta su un riquadro forte, il titolo nel carattere di pixel
	UiScreen.box(self, Rect2(610, 176, 380, 474), true)
	var t := Label.new()
	t.text = "Pausa"
	UiFonts.apply(t, 4, UiPalette.AMBRA_CHIARA, true)
	t.position = Vector2(0, 196)
	t.size = Vector2(1600, UiFonts.size(4))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(t)
	_box = VBoxContainer.new()
	_box.position = Vector2(650, 270)
	_box.custom_minimum_size = Vector2(300, 0)
	_box.add_theme_constant_override("separation", 12)
	add_child(_box)
	_add("Riprendi", close_menu)
	_add("Opzioni", func() -> void:
		visible = false
		options.open())
	_add("Enciclopedia", func() -> void:
		visible = false
		if m.get("encyclopedia") != null:
			m.encyclopedia.open())
	_add("Salva ora", func() -> void:
		m.save_game()
		m.hud.toast("Salvato"))
	_add("Salva e torna al menu", func() -> void:
		get_tree().paused = false
		m.save_game()
		get_tree().change_scene_to_file(m.MENU_SCENE))
	_add("Salva ed esci dal gioco", func() -> void:
		m.save_game()
		get_tree().quit())
	options.closed.connect(func() -> void:
		if m.game_options.menu_wanted:
			visible = true)


func _add(text: String, f: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 50)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 21)
	RecipeRow.style(b, true, Color("#2f7a70"))
	b.pressed.connect(f)
	_box.add_child(b)


func open_menu() -> void:
	m.game_options.menu_wanted = true
	visible = true


func close_menu() -> void:
	m.game_options.menu_wanted = false
	visible = false


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		close_menu()
		get_viewport().set_input_as_handled()
