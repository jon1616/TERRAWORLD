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
var _name: Label
var _info: Label
var _help_hint: Label
var help := true                      # l'aiuto dei tasti in alto a sinistra (F1); spento per chi gioca da un po'
var _toast: Label


func _ready() -> void:
	layer = 10
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
	for k in n:
		var s := SlotView.new()
		s.index = k
		s.position = Vector2(x0 + k * (SlotView.SIZE + 6), HOTBAR_Y)
		s.clicked.connect(_on_slot_clicked)
		add_child(s)
		var num := _label(s, Vector2(7, 1), 12)
		num.add_theme_color_override("font_color", Color("#9fd8c8"))
		num.text = str((k + 1) % 10)
		_slots.append(s)
	_name = _label(self, Vector2(0, HOTBAR_Y - 32), 20)
	_name.size = Vector2(1600, 28)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_color_override("font_color", AMBER)
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
	_toast = _label(self, Vector2(0, 236), 18)
	_toast.size = Vector2(1600, 30)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.modulate.a = 0.0
	_toast.z_index = 6                         # gli avvisi restano leggibili anche con la Bisaccia aperta
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
	_toast.modulate.a = 1.0
	create_tween().tween_property(_toast, "modulate:a", 0.0, 1.2).set_delay(float(Settings.v("avvisi")))


## L'oggetto in mano: {"id", "name", "use", "tex"} (id vuoto = mani nude).
func current() -> Dictionary:
	var id := bisaccia.id_at(sel)
	if id == "":
		return {"id": "", "name": "", "use": "", "tex": null, "tratto": ""}
	var tr := bisaccia.trait_at(sel)
	var dati: Dictionary = bisaccia.slots[sel].get("dati", {})
	return {"id": id, "name": Gear.full_name({"id": id, "tratto": tr, "dati": dati}), "use": ItemsData.use_of(id),
		"tex": SlotView.icon(id), "tratto": tr, "dati": dati}


func select(k: int) -> void:
	sel = posmod(k, Bisaccia.HOTBAR)
	for i in _slots.size():
		_slots[i].set_selected(i == sel)
	_update_name()
	selected.emit(current())


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
	move_child(panel, -1)
	for c in get_children():
		if c is ChestPanel or c is TradePanel:
			move_child(c, -1)
	for s in _slots:
		move_child(s, -1)
	move_child(_toast, -1)


## Chiusa la Bisaccia, lei e la barra rapida tornano in fondo all'ordine: i pannelli a schermo intero (Semenzaio,
## Erbario, mappa…) devono coprire la barra.
func send_panel_back() -> void:
	move_child(panel, 0)
	for k in _slots.size():
		move_child(_slots[k], k + 1)


func _update_name() -> void:
	_name.text = current()["name"]


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
