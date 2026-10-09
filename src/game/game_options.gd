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
## 9 ott 2026 (l'utente: «le creature si muovono e fanno sparire la scheda prima che riesca a leggerla»): il tasto
## «osserva» ferma il mondo senza aprire nulla; le schede del mondo restano vive e si interroga tutto con il mouse.
var observing := false
var _focus := true
var _fps: Label
var _why: Label                        # 2 ott 2026: perché il gioco è fermo, quando nessun pannello lo dice
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
	_why = Label.new()
	_why.position = Vector2(0, 150)
	_why.size = Vector2(1600, 30)
	_why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_why.add_theme_font_size_override("font_size", UiPalette.GRANDE)
	_why.add_theme_color_override("font_color", UiPalette.AMBRA_CHIARA)
	_why.add_theme_color_override("font_outline_color", UiPalette.FONDO)
	_why.add_theme_constant_override("outline_size", 6)
	_why.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_why.visible = false
	m.hud.add_child(_why)
	_why.add_to_group(HudScrim.GROUP)
	_fps = Label.new()
	_fps.position = Vector2(16, 876)
	_fps.add_theme_font_size_override("font_size", 14)
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
	# 2 ott 2026 (l'utente: «a volte, uscendo da un pannello con Esc, il gioco si blocca: il Germogliato non si muove, si
	# può solo aprire la Bisaccia»): il primo piano si legge anche dalla finestra a ogni fotogramma. Contava solo sugli
	# avvisi del sistema, e se il «tornato in primo piano» non arrivava il gioco restava in pausa per sempre, in silenzio.
	if not _focus and get_window().has_focus():
		_focus = true
	var fo := get_viewport().gui_get_focus_owner()
	if fo != null and not fo.is_visible_in_tree():
		fo.release_focus()                    # un campo nascosto non tiene il cursore (né i tasti del Germogliato)
	get_tree().paused = want_pause()
	_show_why()
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


## Una scritta con il perché, quando il gioco è fermo. Sta sotto i pannelli (che vanno in cima all'HUD): si vede solo
## se il gioco è fermo e nulla lo mostra, cioè proprio quando sembrerebbe bloccato.
func _show_why() -> void:
	var t := ""
	if observing and not m.hud.is_open() and not menu.visible and not options.visible:
		t = "In osservazione: passa il mouse sulle cose · %s o Esc per riprendere" % Keys.label("osserva")
	elif get_tree().paused and not menu.visible and not options.visible:      # (il menu di pausa si spiega da sé)
		t = "In pausa: %s · Esc per riprendere" % ", ".join(pause_reasons())
	if t != _why.text:
		_why.text = t
	_why.visible = t != ""
	if _why.visible and _why.get_index() != 0:
		m.hud.move_child(_why, 0)               # sotto tutto il resto dell'HUD


## I motivi della pausa di adesso, in parole.
func pause_reasons() -> Array:
	var out := []
	if observing:
		out.append("osservazione")
	if menu_wanted:
		out.append("menu di pausa")
	if options.visible:
		out.append("Opzioni")
	if m.get("encyclopedia") != null and m.encyclopedia.panel.visible:
		out.append("Enciclopedia")
	if bool(Settings.v("pausa_fuoco")) and not _focus:
		out.append("la finestra non è in primo piano (un clic sul gioco)")
	if bool(Settings.v("pausa_bisaccia")) and m.hud.panel.visible:
		out.append("Bisaccia aperta")
	if bool(Settings.v("pausa_pannelli")):
		if m.hud.map != null and m.hud.map.visible:
			out.append("mappa")
		for o in m.hud.overlays:
			if o.visible:
				out.append("pannello %s" % String(o.get_script().get_global_name()))
	return out


## 2 ott 2026, trovato dal giro intero (il blocco segnalato dall'utente): con il cursore in un campo di testo (il nome
## nella Mandria, la ricerca di Creare) Esc lo prendeva il campo, il pannello restava aperto e il gioco in pausa, e il
## Germogliato non camminava perché «si scriveva». Ora Esc toglie prima il cursore dal campo e prosegue: lo stesso Esc
## chiude anche il pannello.
func _input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		var fo := get_viewport().gui_get_focus_owner()
		if fo is LineEdit or fo is TextEdit:
			fo.release_focus()


## Esc senza nulla di aperto: se il gioco è fermo senza un motivo che si veda, riparte (qui e non in `main`, che in
## pausa non riceve i tasti).
func _unhandled_input(e: InputEvent) -> void:
	if m == null or not m.built:
		return
	if Keys.pressed(e, "osserva") and (observing or not m.hud.is_open() and not menu.visible):
		observing = not observing
		get_viewport().set_input_as_handled()
		return
	if observing and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE \
			and not m.hud.is_open() and not menu.visible and not options.visible:
		observing = false
		get_viewport().set_input_as_handled()
		return
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE and m != null and m.built and unstick():
		get_viewport().set_input_as_handled()


## Esc senza nulla di aperto che lo prenda: se il gioco è fermo senza un motivo che si veda, riparte.
func unstick() -> bool:
	if not get_tree().paused or m.hud.is_open() or menu.visible or options.visible:
		return false
	_focus = true
	menu_wanted = false
	observing = false
	if m.get("encyclopedia") != null and m.encyclopedia.panel.visible:
		return false
	get_tree().paused = want_pause()
	return not get_tree().paused


func want_pause() -> bool:
	if observing:
		return true
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
