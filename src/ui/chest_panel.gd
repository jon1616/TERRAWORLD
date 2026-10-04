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
const MAX_COLS := 15                   # 28 set 2026: le casse più grandi (fino a 100 caselle)
const MAX_ROWS := 7


var panel: BisacciaPanel
var storage: Storage
var chest: Bisaccia
var origin := Vector2i(-1, -1)
var personal := false                  # voce 298: la Dispensa aperta con il Cuore (non si chiude allontanandosi)
var _slots: Array[SlotView] = []
var _title: Label
var _frame: Panel
var _name: LineEdit
var _craft: CheckBox
var _kind: OptionButton
var _settings: Control
var _info: Label
var _search: LineEdit                   # (3 ott 2026, richiesta dell'utente) la ricerca nella cassa e nella Dispensa
var _buttons: Array[Button] = []
## Voce 298: oltre le 105 caselle (la Dispensa) la cassa si sfoglia a pagine di `PAGE` caselle.
const PAGE := 100
var page := 0
var _per := 20                          # caselle per pagina della cassa aperta
var _pages: HBoxContainer
## Voce 352: le schede per tipo (colonna sotto i pulsanti): «Tutto» e i tipi che la cassa contiene, con quante pile.
var _cats: VBoxContainer
var cat := ""                           # "" = tutto; altrimenti una chiave di `StorageData.CATEGORIES`
var _cats_below := Vector2.ZERO         # sotto i pulsanti, se nella cornice c'è posto (`_place_cats`)


func setup(p: BisacciaPanel) -> void:
	panel = p
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_frame = Panel.new()
	_frame.add_theme_stylebox_override("panel", _box())
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_title = Label.new()
	PixelFont.apply(_title, 2)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	_info = Label.new()
	_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_info.add_theme_font_size_override("font_size", 13)
	_info.add_theme_color_override("font_color", Color("#9fc8c0"))
	_info.clip_text = true                          # (voce 351) non deve passare sotto la ricerca
	_info.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_info.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_info)
	_pages = HBoxContainer.new()
	_pages.add_theme_constant_override("separation", 4)
	add_child(_pages)
	# la ricerca: mentre si scrive restano solo gli oggetti il cui nome contiene quelle lettere (in tutte le pagine)
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca nella cassa…"
	_search.size = Vector2(190, 28)
	_search.clear_button_enabled = true
	_search.add_theme_font_size_override("font_size", 14)
	_search.text_changed.connect(func(_t: String) -> void: _refresh())
	_search.text_submitted.connect(func(_t: String) -> void: _search.release_focus())
	add_child(_search)
	# le caselle per la cassa più grande; `_layout` le mette in griglia secondo la capienza
	for i in MAX_COLS * MAX_ROWS:
		var s := SlotView.new()
		s.index = i
		s.clicked.connect(_click)
		add_child(s)
		_slots.append(s)
	# i pulsanti di comodità, in colonna a destra della cassa
	for b in [["Prendi tutto", "Tutto ciò che ci sta passa nella Bisaccia", take_all],
			["Deposita tutto", "Le 30 caselle grandi della Bisaccia nella cassa (la barra rapida resta)", _deposit_all],
			["Deposita simili", "Nella cassa solo ciò che contiene già (dalle caselle grandi della Bisaccia)", _deposit_similar],
			["Rifornisci", "Completa dalla cassa le pile che hai già (torce, dardi, pozioni…)", _restock],
			["Riordina", "Mette in ordine la cassa per tipo e per nome, unendo le pile", _sort]]:
		var btn := Button.new()
		btn.text = b[0]
		btn.tooltip_text = b[1]
		btn.focus_mode = Control.FOCUS_NONE
		btn.size = Vector2(150, 30)
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(b[2])
		add_child(btn)
		_buttons.append(btn)
	_cats = VBoxContainer.new()
	_cats.add_theme_constant_override("separation", 2)
	add_child(_cats)
	# le impostazioni, in una fascia sopra la cassa
	_settings = Panel.new()
	(_settings as Panel).add_theme_stylebox_override("panel", _box())
	_settings.size = Vector2(COLS * SlotView.SIZE + (COLS - 1) * GAP + 28, 44)
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
	_layout(20)


## La griglia secondo la capienza (28 set 2026, i gradi delle casse): 10 colonne finché bastano 7 righe, poi più
## colonne (fino a 15 × 7 = 105). Sopra la Bisaccia, mai sotto la casella Esamina a sinistra; i pulsanti a destra,
## le impostazioni in una fascia sopra.
func _layout(n: int) -> void:
	_per = n if n <= MAX_COLS * MAX_ROWS else PAGE
	n = _per
	var cols := maxi(COLS, ceili(n / float(MAX_ROWS)))
	var rows := maxi(ceili(n / float(cols)), 1)
	var w := cols * SlotView.SIZE + (cols - 1) * GAP
	# nel posto di «Creare» (in alto a sinistra), centrata con i suoi pulsanti a destra
	var x0 := maxf(CraftingPanel.RECT.position.x + (CraftingPanel.RECT.size.x - (w + 28 + 10 + 150)) / 2.0 + 14, 26.0)
	var bag_top := Hud.HOTBAR_Y - 16 - 3 * (SlotView.SIZE + GAP) - 44
	var y0 := bag_top - 14 - rows * (SlotView.SIZE + GAP)
	_frame.position = Vector2(x0 - 14, y0 - 40)
	_frame.size = Vector2(w + 28, rows * (SlotView.SIZE + GAP) + 44)
	_title.position = Vector2(x0, y0 - 34)
	_search.position = Vector2(x0 + w - _search.size.x, y0 - 36)
	_info.position = Vector2(x0 + 260, y0 - 30)
	_info.size = Vector2(maxf(w - 260 - _search.size.x - 12, 40), 20)
	for k in _slots.size():
		_slots[k].position = Vector2(x0 + (k % cols) * (SlotView.SIZE + GAP), y0 + (k / cols) * (SlotView.SIZE + GAP))
	_pages.position = Vector2(x0 + 330, y0 - 36)
	var bx := _frame.position.x + _frame.size.x + 10
	var by := _frame.position.y
	for btn in _buttons:
		btn.position = Vector2(bx, by)
		by += 34.0
	_cats_below = Vector2(bx, by + 6)
	_settings.position = Vector2(_frame.position.x, _frame.position.y - 50)


static func _box() -> StyleBox:
	return UiFrames.box("forte", "normale", Color(UiPalette.LINFA, 0.6))


## Quante pile di ogni tipo ci sono nella cassa.
func _cat_counts() -> Dictionary:
	var out := {}
	if chest == null:
		return out
	for s in chest.slots:
		if not s.is_empty():
			var c := StorageData.category_of(String(s["id"]))
			out[c] = int(out.get(c, 0)) + 1
	return out


## Le schede: «Tutto» e i tipi presenti, nell'ordine di `StorageData.CATEGORIES`. Si rifanno solo se cambiano.
var _cats_key := ""


func _fill_cats(counts: Dictionary) -> void:
	var rows := [["", "Tutto", 0]]
	var tot := 0
	for e in StorageData.CATEGORIES:
		var k := String(e[0])
		if counts.has(k):
			rows.append([k, String(StorageData.SHORT.get(k, e[1])), int(counts[k])])
			tot += int(counts[k])
	rows[0][2] = tot
	var key := "%s|%s" % [cat, str(rows)]
	if key == _cats_key:
		return
	_cats_key = key
	for c in _cats.get_children():
		c.queue_free()
	_cats.visible = rows.size() > 2                # con un tipo solo le schede non servono
	for r in rows:
		var b := Button.new()
		b.text = "%s  %d" % [r[1], int(r[2])]
		b.custom_minimum_size = Vector2(150, 22)
		b.add_theme_font_size_override("font_size", 12)
		b.focus_mode = Control.FOCUS_NONE
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.toggle_mode = true
		b.button_pressed = String(r[0]) == cat
		b.tooltip_text = "Mostra solo: %s" % StorageData.category_name(String(r[0])) if String(r[0]) != "" else "Mostra tutta la cassa"
		var k := String(r[0])
		b.pressed.connect(func() -> void:
			cat = k
			_refresh())
		_cats.add_child(b)
	_place_cats(rows.size())


## Sotto i pulsanti se ci stanno dentro l'altezza della cassa; altrimenti a sinistra della cassa (le casse piccole):
## mai sopra i pulsanti della Bisaccia.
func _place_cats(n: int) -> void:
	var need := n * 24.0
	var bottom := _frame.position.y + _frame.size.y
	if _cats_below.y + need <= bottom + 4.0 or _frame.position.x < 170.0:
		_cats.position = _cats_below
	else:
		_cats.position = Vector2(_frame.position.x - 160.0, _frame.position.y)


## Scrivere nel nome non deve muovere il Germogliato né aprire pannelli (come la ricerca di Creare).
func typing() -> bool:
	return visible and (_name.has_focus() or _search.has_focus())


func open(o: Vector2i, contents: Bisaccia, title: String, own := false) -> void:
	if chest != null and chest.changed.is_connected(_refresh):
		chest.changed.disconnect(_refresh)
	origin = o
	personal = own
	page = 0
	_search.text = ""                          # una cassa nuova si apre senza filtro
	cat = ""
	_cats_key = ""                             # (la cassa nuova può avere un'altra misura: le schede si rimettono)
	chest = contents
	_layout(contents.slots.size())
	chest.changed.connect(_refresh)
	_title.text = title
	visible = true
	if not panel.visible:
		panel.toggle()
	panel.quick_target = _from_bag
	panel.crafting.set_tall(false)             # la colonna Creare torna bassa: qui ci sono i pulsanti della cassa
	var st: Dictionary = storage.settings(o) if storage != null and not own else {}
	_settings.visible = storage != null and not own        # (la Dispensa non ha nome né «usa per creare»)
	if storage != null and not own:
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
func _from_bag(b: Bisaccia, i: int) -> void:
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
	for s in chest.slots:
		if not s.is_empty():
			used += 1
	var pages := ceili(chest.slots.size() / float(_per))
	page = clampi(page, 0, pages - 1)
	var q := _search.text.strip_edges().to_lower()
	var counts := _cat_counts()
	if cat != "" and not counts.has(cat):
		cat = ""                                # il tipo scelto non c'è più: si torna a tutto
	var filtered := q != "" or cat != ""
	var found := matches(q)
	_fill_cats(counts)
	for k in _slots.size():
		var s := _slots[k]
		if filtered:
			# la ricerca: le caselle che corrispondono, una dopo l'altra (anche dalle altre pagine)
			s.visible = k < _per and k < found.size()
			s.index = int(found[k]) if s.visible else 0
		else:
			s.index = page * _per + k
			s.visible = k < _per and s.index < chest.slots.size()
		if s.visible:
			s.set_item(chest.id_at(s.index), chest.count_at(s.index), chest.trait_at(s.index), chest.data_at(s.index))
	_show_pages(pages if not filtered else 1)
	_pages.position.x = _title.position.x + _title.get_combined_minimum_size().x + 14   # subito dopo il titolo
	# (voce 353) solo il conto: «usa per creare» e «raccoglie» si leggono già nella fascia delle impostazioni
	var tags := ["%d/%d caselle" % [used, chest.slots.size()]]
	if filtered:
		tags = ["%d trovat%s" % [found.size(), "o" if found.size() == 1 else "i"]]
	_info.text = " · ".join(tags)
	_info.tooltip_text = _info.text


## Le caselle della cassa il cui oggetto ha nel nome le lettere cercate (minuscole) e, con una scheda scelta, è di quel
## tipo; in ordine.
func matches(q: String) -> Array:
	var out := []
	if (q == "" and cat == "") or chest == null:
		return out
	for i in chest.slots.size():
		var id := chest.id_at(i)
		if id == "":
			continue
		if cat != "" and StorageData.category_of(id) != cat:
			continue
		if q == "":
			out.append(i)
			continue
		var name := String(ItemsData.get_item(id).get("name", id)).to_lower()
		if name.contains(q) or Gear.full_name(chest.slots[i]).to_lower().contains(q):
			out.append(i)
	return out


## I bottoni delle pagine (solo per le casse che ne hanno più d'una).
func _show_pages(pages: int) -> void:
	if _pages.get_child_count() == (pages if pages > 1 else 0) and pages > 1:
		for k in _pages.get_child_count():
			(_pages.get_child(k) as Button).button_pressed = k == page
		return
	for c in _pages.get_children():
		_pages.remove_child(c)
		c.queue_free()
	if pages < 2:
		return
	for k in pages:
		var b := Button.new()
		b.text = str(k + 1)
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(30, 26)
		b.add_theme_font_size_override("font_size", 13)
		UiFrames.button(b, UiPalette.LINFA, k == page)
		b.button_pressed = k == page
		b.pressed.connect(func() -> void:
			page = k
			_refresh())
		_pages.add_child(b)


func _process(_dt: float) -> void:
	if visible and not panel.visible:
		close()
