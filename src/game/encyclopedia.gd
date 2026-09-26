class_name Encyclopedia
extends Node
## L'Enciclopedia in partita (27 set 2026): monta `EncyPanel` nell'interfaccia, la apre con il suo tasto (H) e dal
## bottone «?» in basso a sinistra; le pagine conoscono il personaggio (ciò che ha scoperto).

var m: Node2D
var panel: EncyPanel
var _btn: Button


func setup(main: Node2D) -> void:
	m = main
	process_mode = Node.PROCESS_MODE_ALWAYS
	EncyPages.ch = m.character
	_btn = Button.new()
	_btn.text = "?"
	_btn.position = Vector2(16, 840)
	_btn.size = Vector2(40, 40)
	_btn.focus_mode = Control.FOCUS_NONE
	_btn.add_theme_font_size_override("font_size", 20)
	RecipeRow.style(_btn, true, Color("#2f7a70"))
	Tips.attach(_btn, func() -> Variant: return TipCard.simple("Enciclopedia (%s): tutto sul gioco, con la ricerca" % Keys.label("enciclopedia")))
	_btn.pressed.connect(func() -> void: open())
	m.hud.add_child(_btn)
	panel = EncyPanel.new()                  # dopo il bottone: aperta lo copre
	m.hud.add_child(panel)
	m.hud.overlays.append(panel)


func open(addr := "") -> void:
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	panel.open(addr)


func _process(_dt: float) -> void:
	_btn.visible = not m.hud.is_open()          # sopra la mappa e i pannelli coprirebbe le loro scritte


func _unhandled_input(e: InputEvent) -> void:
	if Keys.pressed(e, "enciclopedia"):
		if panel.visible:
			panel.close_panel()
		elif not m.hud.is_open() or m.hud.panel.visible:
			open()
		get_viewport().set_input_as_handled()
