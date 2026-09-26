class_name GameOptions
extends Node
## Le Opzioni durante la partita (27 set 2026): la pausa (menu di pausa, Bisaccia aperta se «Pausa mentre crei»,
## pannelli grandi, finestra non in primo piano), l'ingrandimento della visuale, la minimappa, il contatore dei
## fotogrammi. Monta il menu di pausa e la schermata delle Opzioni nell'interfaccia.
## In pausa si ferma tutto il mondo (`get_tree().paused`): l'interfaccia, i suggerimenti, i suoni e la musica restano
## vivi (`PROCESS_MODE_ALWAYS`), così si può creare, leggere, spostare oggetti.

var m: Node2D
var menu: PauseMenu
var options: OptionsPanel
var menu_wanted := false               # il menu di pausa (o le Opzioni aperte da lì)
var _focus := true
var _fps: Label
var _last := {}


func setup(main: Node2D) -> void:
	m = main
	process_mode = Node.PROCESS_MODE_ALWAYS
	m.hud.process_mode = Node.PROCESS_MODE_ALWAYS
	if m.sfx != null:
		m.sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	options = OptionsPanel.new()
	m.hud.add_child(options)
	menu = PauseMenu.new()
	m.hud.add_child(menu)
	menu.setup(m, options)
	m.hud.overlays.append(menu)
	m.hud.overlays.append(options)
	_fps = Label.new()
	_fps.position = Vector2(16, 876)
	_fps.add_theme_font_size_override("font_size", 12)
	_fps.add_theme_color_override("font_color", Color("#8aa8a2"))
	_fps.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.hud.add_child(_fps)
	if m.minimap != null:
		m.minimap.shown = bool(Settings.v("minimappa"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_focus = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_focus = true


func _process(_dt: float) -> void:
	if not m.built:
		return
	get_tree().paused = want_pause()
	var z := float(Settings.v("zoom"))
	if m.cam != null and absf(m.cam.zoom.x - z) > 0.001:
		m.cam.zoom = Vector2(z, z)
	_fps.visible = bool(Settings.v("contatore_fps"))
	if _fps.visible:
		_fps.text = "%d fps" % Engine.get_frames_per_second()
	_changed("minimappa", func(val: Variant) -> void:
		if m.minimap != null:
			m.minimap.shown = bool(val))


## Una volta per cambio dell'opzione (la minimappa si mostra e si nasconde anche con il suo tasto).
func _changed(id: String, f: Callable) -> void:
	var val: Variant = Settings.v(id)
	if _last.has(id) and _last[id] != val:
		f.call(val)
	_last[id] = val


func want_pause() -> bool:
	if menu_wanted or options.visible or m.get("encyclopedia") != null and m.encyclopedia.panel.visible:
		return true
	if bool(Settings.v("pausa_fuoco")) and not _focus:
		return true
	if bool(Settings.v("pausa_bisaccia")) and m.hud.panel.visible:
		return true
	if bool(Settings.v("pausa_pannelli")):
		if m.hud.map != null and m.hud.map.visible:
			return true
		for o in m.hud.overlays:
			if o.visible:
				return true
	return false


func open_menu() -> void:
	menu.open_menu()


func _exit_tree() -> void:
	get_tree().paused = false
