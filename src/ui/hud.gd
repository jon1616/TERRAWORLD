class_name Hud
extends CanvasLayer
## Barra rapida (le prime 10 caselle della Bisaccia, in basso al centro), nome dell'oggetto in mano, messaggi brevi,
## aiuto sui comandi, e la Bisaccia aperta (tasto E o Tab). Stile «Radici e Linfa».

signal selected(item: Dictionary)

const AMBER := Color("#ffb84a")
const HOTBAR_Y := 900 - SlotView.SIZE - 18

var bisaccia: Bisaccia                 # da impostare prima di aggiungere il nodo alla scena
var stations_near: Callable            # idem: () -> stazioni a portata (per la colonna «Creare»)
var sel := 0
var panel: BisacciaPanel
var map: Control                       # la mappa (MapPanel): aperta, il mouse serve a lei
var overlays: Array[Control] = []      # altri pannelli a schermo intero (Erbario): aperti, il mouse serve a loro
var _slots: Array[SlotView] = []
var _strip: Panel                      # (voce 274) il riquadro sotto la barra rapida, a Bisaccia chiusa
var _name: Label
var _info: Label
var _help_hint: Label
var help := true                      # l'aiuto dei tasti in alto a sinistra (F1); spento per chi gioca da un po'
var _toast: Label
var _toast_box: PanelContainer         # la cartolina dell'avviso (voce 276): fondo proprio, scorre dall'alto
var _toast_tw: Tween
var _toast_mode := -1
var _toast_at := Vector2.ZERO
var _toast_slide := 0.0
var _fx_seen := {}                     # pannello -> si vedeva al fotogramma prima (per `UiFx.appear`)


func _ready() -> void:
	layer = 10
	UiTheme.smooth_layer(self)               # (Roadmap 55) l'interfaccia morbida, il mondo resta a pixel
	# la Bisaccia per prima: la sua cornice sta sotto la barra rapida, che resta in primo piano
	panel = BisacciaPanel.new()
	panel.bisaccia = bisaccia
	panel.stations_near = stations_near
	panel.visible = false
	add_child(panel)
	panel.crafting.held_slot = func() -> int: return sel
	selected.connect(func(_it: Dictionary) -> void:
		if panel.visible:
			panel.crafting.refresh())
	var n := Bisaccia.HOTBAR
	var x0 := (1600 - (n * SlotView.SIZE + (n - 1) * 6)) / 2.0
	# (voce 274) la barra rapida sta su un suo riquadro: si legge sopra ogni sfondo, cielo o grotta
	_strip = Panel.new()
	_strip.add_theme_stylebox_override("panel", UiFrames.box("riquadro"))
	_strip.position = Vector2(x0 - 10, HOTBAR_Y - 10)
	_strip.size = Vector2(n * SlotView.SIZE + (n - 1) * 6 + 20, SlotView.SIZE + 20)
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_strip.modulate.a = 0.92
	add_child(_strip)
	for k in n:
		var s := SlotView.new()
		s.index = k
		s.position = Vector2(x0 + k * (SlotView.SIZE + 6), HOTBAR_Y)
		s.clicked.connect(_on_slot_clicked)
		add_child(s)
		var num := Label.new()
		num.text = str((k + 1) % 10)
		num.position = Vector2(6, 2)
		num.mouse_filter = Control.MOUSE_FILTER_IGNORE
		UiFonts.apply(num, 1, Color("#9fd8c8"), true)
		s.add_child(num)
		s.pivot_offset = Vector2(SlotView.SIZE, SlotView.SIZE) * 0.5
		_slots.append(s)
	_name = Label.new()
	_name.position = Vector2(0, HOTBAR_Y - 12 - UiFonts.size(2))
	_name.size = Vector2(1600, UiFonts.size(2))
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiFonts.apply(_name, 2, AMBER, true)
	add_child(_name)
	_info = _label(self, Vector2(16, 6), 13)
	_info.add_theme_constant_override("line_spacing", -2)
	_info.add_theme_color_override("font_color", Color("#9fc8c0"))
	_info.visible = help
	_help_hint = _label(self, Vector2(16, 6), 12)
	_help_hint.text = "%s aiuto" % Keys.label("aiuto")
	_help_hint.add_theme_color_override("font_color", Color("#6a8a84"))
	_help_hint.visible = not help
	_info.text = Keys.help_text()           # con i tasti scelti nelle Opzioni
	# gli avvisi al centro, sotto la scritta degli strati: possono essere lunghi (obiettivi, Erbario)
	# (voce 276) una cartolina con il suo fondo: sopra i pannelli resta leggibile e non si mescola con le loro scritte
	_toast_box = PanelContainer.new()
	_toast_box.add_theme_stylebox_override("panel", UiFrames.padded("suggerimento", "normale", Color(UiPalette.AMBRA, 0.5), Vector2(18, 8)))
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.visible = false
	_toast_box.z_index = 6                     # gli avvisi restano leggibili anche con la Bisaccia aperta
	_toast_box.set_meta("fluttua", true)       # `LayoutCheck`: una cartolina sopra tutto, non una scritta sovrapposta
	add_child(_toast_box)
	_toast = Label.new()
	_toast.add_theme_font_size_override("font_size", UiPalette.GRANDE)
	_toast.add_theme_color_override("font_color", UiPalette.TESTO)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_box.add_child(_toast)
	bisaccia.changed.connect(_refresh)
	_refresh()
	select(0)


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#fff4dc"))
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	l.add_theme_constant_override("outline_size", 6)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


## Messaggio breve in alto al centro che svanisce da solo.
func toast(text: String) -> void:
	_toast.text = text
	_toast_mode = -1                           # da misurare e posare (in `_place_toast`)
	_place_toast()
	_toast_box.visible = true
	if _toast_tw != null:
		_toast_tw.kill()
	# entra in 0,18 s scendendo di 6 px, resta, esce in 0,30 (ARTE.md §6)
	_toast_box.modulate.a = 0.0
	_toast_slide = -6.0
	_toast_tw = create_tween()
	_toast_tw.tween_property(_toast_box, "modulate:a", 1.0, 0.18)
	_toast_tw.parallel().tween_property(self, "_toast_slide", 0.0, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_toast_tw.tween_interval(float(Settings.v("avvisi")))
	_toast_tw.tween_property(_toast_box, "modulate:a", 0.0, 0.30)
	_toast_tw.tween_callback(func() -> void: _toast_box.visible = false)


## Dove sta l'avviso: 0 = al centro, sotto la scritta degli strati; 1 = con la Bisaccia aperta lo schermo è tutto
## occupato, in fondo alla colonna di Esamina, dove di solito non c'è nulla (voce 276: al centro copriva le impostazioni
## della cassa); 2 = con un pannello a schermo intero (Semenzaio, Erbario…), in basso al centro sopra il piede.
## Si ricontrolla a ogni fotogramma: un pannello aperto mentre l'avviso è in vista lo sposta.
func _place_toast() -> void:
	var mode := 0
	if panel != null and panel.visible:
		mode = 1
	else:
		for o in overlays:
			if (o as Control).visible:
				mode = 2
		if map != null and map.visible:
			mode = 2
	if mode != _toast_mode:
		_toast_mode = mode
		var max_w := 900.0 if mode == 0 else (360.0 if mode == 1 else 560.0)
		var f := _toast.get_theme_font("font")
		var wide := f.get_string_size(_toast.text, HORIZONTAL_ALIGNMENT_LEFT, -1, UiPalette.GRANDE).x > max_w
		_toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if wide else TextServer.AUTOWRAP_OFF
		_toast.custom_minimum_size = Vector2(max_w if wide else 0.0, 0)
		_toast_box.size = Vector2.ZERO
		_toast_box.size = _toast_box.get_combined_minimum_size()
		_toast_at = Vector2(roundf((1600.0 - _toast_box.size.x) * 0.5), 236.0)
		if mode == 1:
			var col := panel.examine.get_global_rect()
			_toast_at = Vector2(roundf(col.position.x + (col.size.x - _toast_box.size.x) * 0.5), col.end.y - 20.0 - _toast_box.size.y)
		elif mode == 2:
			# (Roadmap 55) sulla fascia del piede, al centro: in alto a destra copriva i numeri chiave, sopra il piede i
			# bottoni del pannello; qui copre al più i promemoria dei tasti, per pochi secondi
			_toast_at = Vector2(roundf((1600.0 - _toast_box.size.x) * 0.5), 896.0 - _toast_box.size.y)
	if mode == 1:
		# il testo che va a capo cresce un fotogramma dopo la misura: l'avviso resta appoggiato al fondo della colonna
		var bottom := panel.examine.get_global_rect().end.y - 20.0
		_toast_at.y = bottom - _toast_box.size.y
	_toast_box.position = _toast_at + Vector2(0, _toast_slide)


## L'oggetto in mano: {"id", "name", "use", "tex"} (id vuoto = mani nude).
func current() -> Dictionary:
	var id := bisaccia.id_at(sel)
	if id == "":
		return {"id": "", "name": "", "use": "", "tex": null, "tratto": ""}
	var tr := bisaccia.trait_at(sel)
	var dati: Dictionary = bisaccia.slots[sel].get("dati", {})
	return {"id": id, "name": Gear.full_name({"id": id, "tratto": tr, "dati": dati}), "use": ItemsData.use_of(id),
		"tex": SlotView.world_icon(id), "tratto": tr, "dati": dati}     # l'attrezzo in mano: pixel art del mondo


func select(k: int) -> void:
	var was := sel
	sel = posmod(k, Bisaccia.HOTBAR)
	for i in _slots.size():
		_slots[i].set_selected(i == sel)
	if was != sel and UiFx.on():
		# (voce 274) la casella scelta si solleva un attimo
		var s := _slots[sel]
		s.scale = Vector2(1.1, 1.1)
		s.create_tween().tween_property(s, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_update_name()
	selected.emit(current())


## Un pannello a schermo intero aperto (Semenzaio, Erbario, Albero-Madre, mappa…) sta in cima all'HUD, sopra ogni
## scritta: aggiunto prima di altre (la riga dell'Albero-Madre) restava sotto di loro e le scritte gli passavano sopra
## (28 set 2026, segnalato dall'utente con il Semenzaio).
func _process(_dt: float) -> void:
	_strip.visible = not panel.visible
	if _toast_box.visible:
		_place_toast()
	_fx_watch()
	var last := get_child(get_child_count() - 1)
	for o in overlays:
		if o.visible:
			if o != last:
				move_child(o, -1)
			return
	if map != null and map.visible and map != last:
		move_child(map, -1)


## (voce 273) un pannello che si apre compare con la sua breve dissolvenza (`UiFx.appear`), qualunque sia chi lo apre.
func _fx_watch() -> void:
	var list: Array = overlays.duplicate()
	list.append(panel)
	list.append(map)
	for c in list:
		if c == null:
			continue
		var v := (c as Control).visible
		if v and not bool(_fx_seen.get(c, false)):
			UiFx.appear(c)
		_fx_seen[c] = v


func is_open() -> bool:
	if panel.visible or (map != null and map.visible):
		return true
	for o in overlays:
		if o.visible:
			return true
	return false


func _refresh() -> void:
	for i in _slots.size():
		_slots[i].set_item(bisaccia.id_at(i), bisaccia.count_at(i), bisaccia.trait_at(i), bisaccia.data_at(i))
	_update_name()
	selected.emit(current())


## La Bisaccia aperta (con cassa o commercio) in cima all'ordine dei nodi, sopra le scritte dell'HUD, e la barra rapida
## e gli avvisi sopra di lei. (28 set 2026: con il solo `z_index` il pannello si **disegnava** sopra gli obiettivi, ma i
## clic seguono l'ordine dei nodi e la lista degli obiettivi, sotto il pannello, si prendeva i clic sulle ricette.)
func bring_panel_forward() -> void:
	# le scritte dell'HUD con un suggerimento (orologio, obiettivi, Albero, effetti) sentono il mouse: sotto la Bisaccia
	# aperta rubavano i clic alle prime ricette di Creare (28 set 2026). Finché è aperta non lo sentono più.
	# Le caselle della barra rapida no: hanno anche loro un suggerimento, ma servono per spostare gli oggetti.
	for c in get_children():
		if c is Control and c != panel and not c is SlotView and c.has_meta("tip") \
				and c.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			c.set_meta("filtro", c.mouse_filter)
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	move_child(panel, -1)
	for c in get_children():
		if c is ChestPanel or c is TradePanel:
			move_child(c, -1)
	for s in _slots:
		move_child(s, -1)
	move_child(_toast_box, -1)


## Chiusa la Bisaccia, lei e la barra rapida tornano in fondo all'ordine: i pannelli a schermo intero (Semenzaio,
## Erbario, mappa…) devono coprire la barra.
func send_panel_back() -> void:
	for c in get_children():
		if c is Control and c.has_meta("filtro"):
			c.mouse_filter = int(c.get_meta("filtro"))
			c.remove_meta("filtro")
	move_child(panel, 0)
	move_child(_strip, 1)
	for k in _slots.size():
		move_child(_slots[k], k + 2)


func _update_name() -> void:
	var t: String = current()["name"]
	if t != _name.text:
		_name.text = t
		UiFx.flash(_name, Color(1, 1, 1, 0.0))   # (voce 274) il nome nuovo compare in dissolvenza


func _on_slot_clicked(i: int, button: int) -> void:
	if panel.visible:
		panel.click_slot(i, button)
	elif button == MOUSE_BUTTON_LEFT:
		select(i)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode >= KEY_0 and e.keycode <= KEY_9:
			select((e.keycode - KEY_0 + 9) % 10)
		elif Keys.pressed(e, "aiuto"):
			help = not help
			_info.text = Keys.help_text()
			_info.visible = help
			_help_hint.visible = not help
		elif Keys.pressed(e, "bisaccia"):
			panel.toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and panel.visible:
			panel.toggle()
			get_viewport().set_input_as_handled()
	elif e is InputEventMouseButton and e.pressed and not panel.visible:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			select(sel - 1)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select(sel + 1)
