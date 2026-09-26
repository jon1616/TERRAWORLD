class_name ChestPanel
extends Control
## Il contenuto di una cesta o di uno scrigno, sopra la Bisaccia aperta (voce 10). Stesse regole della Bisaccia: un clic
## prende o posa la pila «in mano» (condivisa con `BisacciaPanel.held`), il clic destro prende metà pila;
## Maiusc+clic sposta subito la pila dall'altra parte. Si chiude chiudendo la Bisaccia o allontanandosi.
## 26 set 2026 (richiesta dell'utente): a destra i pulsanti di comodità (Prendi tutto, Deposita tutto, Deposita
## simili, Rifornisci, Riordina), sopra le impostazioni della cassa (nome, «usa per creare», che cosa raccoglie da
## «Nelle casse vicine»). Le regole stanno in `Storage`.

const COLS := 10
const GAP := 6

var panel: BisacciaPanel
var storage: Storage
var chest: Bisaccia
var origin := Vector2i(-1, -1)
var _slots: Array[SlotView] = []
var _title: Label
var _frame: Panel
var _name: LineEdit
var _craft: CheckBox
var _kind: OptionButton
var _settings: Control
var _info: Label


func setup(p: BisacciaPanel) -> void:
	panel = p
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var rows := 2
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var bag_top := Hud.HOTBAR_Y - 16 - 3 * (SlotView.SIZE + GAP) - 44
	var y0 := bag_top - 14 - rows * (SlotView.SIZE + GAP)
	_frame = Panel.new()
	_frame.add_theme_stylebox_override("panel", _box())
	_frame.position = Vector2(x0 - 14, y0 - 40)
	_frame.size = Vector2(w + 28, rows * (SlotView.SIZE + GAP) + 44)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_title = Label.new()
	_title.position = Vector2(x0, y0 - 34)
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	_info = Label.new()
	_info.position = Vector2(x0 + 260, y0 - 30)
	_info.size = Vector2(w - 260, 20)
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_info.add_theme_font_size_override("font_size", 13)
	_info.add_theme_color_override("font_color", Color("#9fc8c0"))
	add_child(_info)
	for r in rows:
		for c in COLS:
			var s := SlotView.new()
			s.index = r * COLS + c
			s.position = Vector2(x0 + c * (SlotView.SIZE + GAP), y0 + r * (SlotView.SIZE + GAP))
			s.clicked.connect(_click)
			add_child(s)
			_slots.append(s)
	# i pulsanti di comodità, in colonna a destra della cassa
	var bx := _frame.position.x + _frame.size.x + 10
	var by := _frame.position.y
	for b in [["Prendi tutto", "Tutto ciò che ci sta passa nella Bisaccia", take_all],
			["Deposita tutto", "Le 30 caselle grandi della Bisaccia nella cassa (la barra rapida resta)", _deposit_all],
			["Deposita simili", "Nella cassa solo ciò che contiene già (dalle caselle grandi della Bisaccia)", _deposit_similar],
			["Rifornisci", "Completa dalla cassa le pile che hai già (torce, dardi, pozioni…)", _restock],
			["Riordina", "Mette in ordine la cassa per tipo e per nome, unendo le pile", _sort]]:
		var btn := Button.new()
		btn.text = b[0]
		btn.tooltip_text = b[1]
		btn.focus_mode = Control.FOCUS_NONE
		btn.position = Vector2(bx, by)
		btn.size = Vector2(150, 30)
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(b[2])
		add_child(btn)
		by += 34.0
	# le impostazioni, in una fascia sopra la cassa
	_settings = Panel.new()
	(_settings as Panel).add_theme_stylebox_override("panel", _box())
	_settings.position = Vector2(_frame.position.x, _frame.position.y - 50)
	_settings.size = Vector2(_frame.size.x, 44)
	add_child(_settings)
	_name = LineEdit.new()
	_name.position = Vector2(12, 7)
	_name.size = Vector2(190, 30)
	_name.max_length = 20
	_name.placeholder_text = "Nome della cassa"
	_name.text_submitted.connect(func(t: String) -> void:
		_set_opt("nome", t.strip_edges())
		_name.release_focus())
	_name.focus_exited.connect(func() -> void: _set_opt("nome", _name.text.strip_edges()))
	_settings.add_child(_name)
	_craft = CheckBox.new()
	_craft.text = "Usa per creare"
	_craft.tooltip_text = "Se è vicina, la creazione prende gli ingredienti anche da questa cassa"
	_craft.position = Vector2(212, 7)
	_craft.size = Vector2(150, 30)
	_craft.focus_mode = Control.FOCUS_NONE
	_craft.toggled.connect(func(on: bool) -> void: _set_opt("creare", on))
	_settings.add_child(_craft)
	var lab := Label.new()
	lab.text = "Raccoglie:"
	lab.position = Vector2(372, 11)
	lab.add_theme_font_size_override("font_size", 14)
	_settings.add_child(lab)
	_kind = OptionButton.new()
	_kind.position = Vector2(452, 7)
	_kind.size = Vector2(_settings.size.x - 464, 30)
	_kind.fit_to_longest_item = false
	_kind.clip_text = true
	_kind.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_kind.focus_mode = Control.FOCUS_NONE
	_kind.tooltip_text = "Che cosa ci mette «Nelle casse vicine» (dalla Bisaccia), oltre a ciò che contiene già"
	for e in StorageData.CATEGORIES:
		_kind.add_item(String(e[1]))
	_kind.item_selected.connect(func(i: int) -> void: _set_opt("tipo", String(StorageData.CATEGORIES[i][0])))
	_settings.add_child(_kind)


static func _box() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.06, 0.06, 0.86)
	sb.border_color = Color("#6ff0d8")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	return sb


## Scrivere nel nome non deve muovere il Germogliato né aprire pannelli (come la ricerca di Creare).
func typing() -> bool:
	return visible and _name.has_focus()


func open(o: Vector2i, contents: Bisaccia, title: String) -> void:
	if chest != null and chest.changed.is_connected(_refresh):
		chest.changed.disconnect(_refresh)
	origin = o
	chest = contents
	chest.changed.connect(_refresh)
	_title.text = title
	visible = true
	if not panel.visible:
		panel.toggle()
	panel.quick_target = _from_bag
	panel.crafting.set_tall(false)             # la colonna Creare torna bassa: qui ci sono i pulsanti della cassa
	var st: Dictionary = storage.settings(o) if storage != null else {}
	_settings.visible = storage != null
	if storage != null:
		_name.text = String(st["nome"])
		_craft.set_pressed_no_signal(bool(st["creare"]))
		var ks: Array = StorageData.CATEGORIES.map(func(e: Array) -> String: return String(e[0]))
		_kind.select(maxi(ks.find(String(st["tipo"])), 0))
		if String(st["nome"]) != "":
			_title.text = "%s — %s" % [st["nome"], title]
	_refresh()


func close() -> void:
	if visible and storage != null and _name.has_focus():
		_set_opt("nome", _name.text.strip_edges())
		_name.release_focus()
	visible = false
	panel.quick_target = Callable()
	panel.crafting.set_tall(true)
	if chest != null and chest.changed.is_connected(_refresh):
		chest.changed.disconnect(_refresh)
	chest = null


func _set_opt(k: String, v: Variant) -> void:
	if storage != null and chest != null:
		storage.set_setting(origin, k, v)
		_refresh()


func take_all() -> void:
	if chest == null:
		return
	for i in chest.slots.size():
		Storage.move_slot(chest, i, panel.bisaccia)
	panel.bisaccia.changed.emit()
	chest.changed.emit()


func _deposit_all() -> void:
	if chest != null and storage != null:
		storage.deposit_all(chest)


func _deposit_similar() -> void:
	if chest != null and storage != null:
		storage.deposit_similar(chest)


func _restock() -> void:
	if chest != null and storage != null:
		storage.restock(chest)
		chest.changed.emit()


func _sort() -> void:
	if chest != null:
		chest.sort_bag(0)


## Maiusc+clic su una casella della Bisaccia mentre la cesta è aperta: la pila passa nella cesta.
func _from_bag(i: int) -> void:
	var b := panel.bisaccia
	if b.slots[i].is_empty():
		return
	Storage.move_slot(b, i, chest)
	b.changed.emit()
	chest.changed.emit()


func _click(i: int, button: int) -> void:
	if chest == null:
		return
	if button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
		if not chest.slots[i].is_empty():
			Storage.move_slot(chest, i, panel.bisaccia)
			panel.bisaccia.changed.emit()
			chest.changed.emit()
	elif button == MOUSE_BUTTON_RIGHT and panel.held.is_empty() and chest.count_at(i) > 1:
		var half := chest.count_at(i) / 2
		panel.held = {"id": chest.id_at(i), "n": half}
		chest.slots[i]["n"] = chest.count_at(i) - half
		chest.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		panel.held = chest.swap_with(i, panel.held)
	panel.refresh_held()


func _refresh() -> void:
	if chest == null:
		return
	var used := 0
	for s in _slots:
		s.visible = s.index < chest.slots.size()
		if s.visible:
			s.set_item(chest.id_at(s.index), chest.count_at(s.index), chest.trait_at(s.index), chest.data_at(s.index))
			if chest.id_at(s.index) != "":
				used += 1
	var tags := ["%d/%d caselle" % [used, chest.slots.size()]]
	if storage != null:
		var st := storage.settings(origin)
		if st["creare"]:
			tags.append("dà gli ingredienti alla creazione")
		if String(st["tipo"]) != "":
			tags.append("raccoglie: " + StorageData.category_name(String(st["tipo"])).to_lower())
	_info.text = " · ".join(tags)


func _process(_dt: float) -> void:
	if visible and not panel.visible:
		close()
