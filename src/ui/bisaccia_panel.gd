class_name BisacciaPanel
extends Control
## La Bisaccia aperta: le 30 caselle sopra la barra rapida. Un clic prende la pila (resta «in mano», segue il mouse),
## un altro clic la posa o la scambia; il clic destro prende metà pila. A destra la colonna «Creare» (`CraftingPanel`).

const COLS := 10
const ROWS := 3
const GAP := 6

var bisaccia: Bisaccia
var stations_near: Callable            # () -> stazioni a portata del giocatore, per la colonna «Creare»
var _dirty := false                    # la Bisaccia è cambiata da quando le caselle sono state disegnate
var crafting: CraftingPanel
var examine: ExaminePanel               # la casella «Esamina» in alto a sinistra
var _equip: Dictionary = {}            # posto -> SlotView
var _scorza: Label
var _sets: Label
var held := {}                        # pila «in mano» mentre la Bisaccia è aperta
## Maiusc+clic su una casella: se è aperta una cesta (`ChestPanel`), la pila ci va dentro subito.
var quick_target: Callable
var _slots: Array[SlotView] = []
var _held_icon: SlotView


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var y0 := Hud.HOTBAR_Y - 16 - ROWS * (SlotView.SIZE + GAP)
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	# (la stessa cornice serve anche alla colonna dell'equipaggiamento)
	sb.bg_color = Color(0.01, 0.05, 0.06, 0.82)
	sb.border_color = Color("#2f7a70")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(22)
	frame.add_theme_stylebox_override("panel", sb)
	frame.position = Vector2(x0 - 14, y0 - 44)
	frame.size = Vector2(w + 28, ROWS * (SlotView.SIZE + GAP) + 44 + 8 + SlotView.SIZE + 18)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	var title := Label.new()
	title.text = "Bisaccia"
	title.position = Vector2(x0, y0 - 38)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#ffb84a"))
	title.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	title.add_theme_constant_override("outline_size", 6)
	add_child(title)
	for r in ROWS:
		for c in COLS:
			var s := SlotView.new()
			s.index = Bisaccia.HOTBAR + r * COLS + c
			s.position = Vector2(x0 + c * (SlotView.SIZE + GAP), y0 + r * (SlotView.SIZE + GAP))
			s.clicked.connect(click_slot)
			add_child(s)
			_slots.append(s)
	# equipaggiamento: una colonna a sinistra, con il nome dei posti e la Scorza totale
	# due colonne: armatura (elmo, corazza, gambali) e accessori
	var ex := frame.position.x - 16 - 2 * SlotView.SIZE - 40
	var eframe := Panel.new()
	eframe.add_theme_stylebox_override("panel", sb)
	eframe.position = Vector2(ex - 12, frame.position.y)
	eframe.size = Vector2(2 * SlotView.SIZE + 64, frame.size.y)
	eframe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(eframe)
	for k in Bisaccia.EQUIP_SLOTS.size():
		var slot: String = Bisaccia.EQUIP_SLOTS[k]
		var s := SlotView.new()
		var col := 0 if k < 3 else 1
		var row := k if k < 3 else k - 3
		s.position = Vector2(ex + 12 + col * (SlotView.SIZE + 16), frame.position.y + 40 + row * (SlotView.SIZE + 22))
		s.clicked.connect(func(_i: int, button: int) -> void:
			if button == MOUSE_BUTTON_LEFT:
				held = bisaccia.wear(slot, held)
				_refresh())
		add_child(s)
		var tag := Label.new()
		tag.text = "Accessorio" if Bisaccia.kind_of_slot(slot) == "accessorio" else slot.capitalize()
		tag.position = s.position + Vector2(-6, SlotView.SIZE - 2)
		tag.size = Vector2(SlotView.SIZE + 12, 18)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 12)
		tag.add_theme_color_override("font_color", Color("#9fc8c0"))
		add_child(tag)
		_equip[slot] = s
	_scorza = Label.new()
	_scorza.position = Vector2(ex - 6, frame.position.y + 8)
	_scorza.size = Vector2(2 * SlotView.SIZE + 52, 24)
	_scorza.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scorza.add_theme_font_size_override("font_size", 16)
	_scorza.add_theme_color_override("font_color", Color("#ffb84a"))
	_scorza.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_scorza.add_theme_constant_override("outline_size", 5)
	_scorza.tooltip_text = "Scorza: toglie metà del suo valore a ogni ferita"
	add_child(_scorza)
	# i set (voce 26): sotto gli accessori, quanti pezzi si indossano e, completo, il bonus
	_sets = Label.new()
	_sets.position = Vector2(ex + 12 + SlotView.SIZE + 4, frame.position.y + 40 + 2 * (SlotView.SIZE + 22) - 4)
	_sets.size = Vector2(SlotView.SIZE + 40, SlotView.SIZE + 26)
	_sets.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sets.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sets.add_theme_font_size_override("font_size", 11)
	_sets.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_sets.add_theme_constant_override("outline_size", 4)
	_sets.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_sets)
	# Riordina: in alto a destra nella cornice della Bisaccia
	var sort := Button.new()
	sort.text = "Riordina"
	sort.focus_mode = Control.FOCUS_NONE
	sort.position = Vector2(frame.position.x + frame.size.x - 112, frame.position.y + 8)
	sort.size = Vector2(98, 28)
	sort.add_theme_font_size_override("font_size", 13)
	sort.tooltip_text = "Mette in ordine la Bisaccia (non la barra rapida): per tipo e per nome, unendo le pile"
	sort.pressed.connect(func() -> void: bisaccia.sort_bag())
	add_child(sort)
	crafting = CraftingPanel.new()
	add_child(crafting)
	crafting.setup(bisaccia, stations_near, Vector2(frame.position.x + frame.size.x + 16, frame.position.y), frame.size.y)
	examine = ExaminePanel.new()
	add_child(examine)
	examine.setup(self, Vector2(20, frame.position.y - 16 - ExaminePanel.H))
	_held_icon = SlotView.new()
	_held_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_held_icon.modulate = Color(1, 1, 1, 0.9)
	_held_icon.visible = false
	add_child(_held_icon)
	# ogni oggetto raccolto cambia la Bisaccia: ridisegnare subito 40 caselle a ogni cambio (anche a pannello chiuso)
	# faceva un fotogramma da 60 ms quando se ne raccoglievano molti insieme. Si segna e si ridisegna in `_process`,
	# una volta per fotogramma e solo a pannello aperto.
	bisaccia.changed.connect(func() -> void: _dirty = true)
	_refresh()


func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()
		crafting.refresh()
		examine.refresh()
	else:
		crafting.release_search()
	if not visible:
		examine.give_back()
	if not visible and not held.is_empty():
		# richiudendo, ciò che è in mano torna nella Bisaccia
		bisaccia.add_stack(held)
		held = {}
		_refresh()


func click_slot(i: int, button: int) -> void:
	if button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT) and quick_target.is_valid():
		quick_target.call(i)
	elif button == MOUSE_BUTTON_RIGHT and held.is_empty() and bisaccia.count_at(i) > 1:
		var half := bisaccia.count_at(i) / 2
		held = {"id": bisaccia.id_at(i), "n": half}
		bisaccia.slots[i]["n"] = bisaccia.count_at(i) - half
		bisaccia.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		held = bisaccia.swap_with(i, held)
	_refresh()


## Dopo che un altro pannello ha cambiato la pila in mano.
func refresh_held() -> void:
	_refresh()


func _refresh() -> void:
	_dirty = false
	for s in _slots:
		s.set_item(bisaccia.id_at(s.index), bisaccia.count_at(s.index), bisaccia.trait_at(s.index))
	for slot in _equip:
		(_equip[slot] as SlotView).set_item(String(bisaccia.equip.get(slot, "")), 1, String(bisaccia.equip_traits.get(slot, "")))
	if _scorza:
		var done := SetsData.complete(bisaccia.equip)
		var extra := 0
		for s in done:
			extra += int((SetsData.all()[s]["bonus"] as Dictionary).get("defense", 0))
		_scorza.text = "Scorza %d" % (bisaccia.scorza() + extra)
		_show_sets(done)
	_held_icon.visible = not held.is_empty()
	if not held.is_empty():
		_held_icon.set_item(held["id"], held["n"], String(held.get("tratto", "")))


## Il set più avanti tra quelli di cui si indossa qualcosa: nome e pezzi (dorato se completo); il bonus nel
## suggerimento.
func _show_sets(done: Array) -> void:
	var best := ""
	var best_n := 0
	for s in SetsData.all():
		var n := SetsData.worn(s, bisaccia.equip)
		if n > best_n or (s in done and not best in done):
			best = s
			best_n = n
	if best == "" or best_n < 1:
		_sets.text = ""
		_sets.tooltip_text = ""
		return
	var sd: Dictionary = SetsData.all()[best]
	var tot := (sd["pieces"] as Array).size()
	_sets.text = "Set %s · %d/%d" % [sd["name"], best_n, tot]
	_sets.add_theme_color_override("font_color", Color("#ffd08a") if best in done else Color("#6a8a84"))
	var tip := ""
	for s in done:
		tip += "%s (completo): %s\n" % [SetsData.all()[s]["name"], SetsData.all()[s]["desc"]]
	if not best in done:
		tip += "%s: %d pezzi su %d. Completo: %s" % [sd["name"], best_n, tot, sd["desc"]]
	_sets.tooltip_text = tip.strip_edges()


func _process(_dt: float) -> void:
	if _dirty and visible:
		_refresh()
	if _held_icon.visible:
		_held_icon.position = get_viewport().get_mouse_position() + Vector2(8, 8)
