class_name CraftingPanel
extends Control
## La colonna «Creare» accanto alla Bisaccia aperta: le ricette usabili con le stazioni vicine. Chiare quelle per cui
## bastano i materiali (in cima), attenuate le altre. Ogni riga mostra l'oggetto e, sotto, gli ingredienti con le
## loro icone (rossi quelli che mancano). In alto le **categorie** e una **ricerca** per nome (voce 29: con le stazioni
## nuove le ricette sono più di cento). Un clic fabbrica una volta.

const W := 440
const ROW := 56
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")
## Categorie: nome visibile e tipi di oggetto (`kind` in `ItemsData`) che ci stanno; "" = tutto.
const CATS := [
	["Tutto", []],
	["Armi", ["spada", "arco", "bastone", "munizione", "piccone", "ascia"]],
	["Armature", ["elmo", "corazza", "gambali"]],
	["Accessori", ["accessorio"]],
	["Pozioni", ["consumabile", "cura", "purifica"]],
	["Materiali", ["materiale", "blocco"]],
	["Banchi", ["stazione", "piattaforma", "torcia"]],
	["Altro", []],
]

var bisaccia: Bisaccia
var stations_near: Callable            # () -> Dictionary delle stazioni a portata
var held_slot: Callable                # () -> casella dell'oggetto in mano (per rinnovarne il tratto al Maglio)
var cat := 0
var _list: VBoxContainer
var _title: Label
var _search: LineEdit
var _cat_buttons: Array[Button] = []
var _near_key := ""
var _t := 0.0

signal crafted(id: String, n: int)
signal grafted(id: String)


func setup(b: Bisaccia, near: Callable, pos: Vector2, height: float) -> void:
	bisaccia = b
	stations_near = near
	position = pos
	size = Vector2(W, height)
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.05, 0.06, 0.82)
	sb.border_color = TEAL
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(22)
	frame.add_theme_stylebox_override("panel", sb)
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	_title = Label.new()
	_title.position = Vector2(16, 6)
	_title.size = Vector2(W - 32, 30)
	_title.clip_text = true
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", AMBER)
	_title.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_title.add_theme_constant_override("outline_size", 6)
	add_child(_title)
	# le categorie, in due righe di piccoli bottoni, e la ricerca
	for k in CATS.size():
		var cb := Button.new()
		cb.text = String(CATS[k][0])
		cb.toggle_mode = true
		cb.focus_mode = Control.FOCUS_NONE
		cb.position = Vector2(14 + (k % 4) * 104, 38 + (k / 4) * 26)
		cb.size = Vector2(100, 24)
		cb.add_theme_font_size_override("font_size", 12)
		_style_chip(cb)
		cb.pressed.connect(func() -> void:
			cat = k
			refresh())
		add_child(cb)
		_cat_buttons.append(cb)
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca per nome…"
	_search.position = Vector2(14, 92)
	_search.size = Vector2(W - 28, 28)
	_search.add_theme_font_size_override("font_size", 14)
	_search.text_changed.connect(func(_t2: String) -> void: refresh())
	add_child(_search)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 126)
	scroll.size = Vector2(W - 24, height - 138)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(W - 40, 0)
	_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_list)
	bisaccia.changed.connect(refresh)
	refresh()


## La ricerca ha il fuoco: i tasti del gioco (movimento, E, M…) non devono partire mentre si scrive.
func typing() -> bool:
	return _search != null and _search.has_focus()


func release_search() -> void:
	if _search:
		_search.release_focus()


func _style_chip(b: Button) -> void:
	for st in ["normal", "hover", "pressed", "hover_pressed"]:
		var s := StyleBoxFlat.new()
		var on: bool = String(st).contains("pressed")
		s.bg_color = Color(0.1, 0.3, 0.3, 0.95) if on else Color(0.03, 0.1, 0.12, 0.9)
		s.border_color = AMBER if on else TEAL
		s.set_border_width_all(1)
		s.set_corner_radius_all(10)
		b.add_theme_stylebox_override(st, s)
	b.add_theme_color_override("font_pressed_color", AMBER)
	b.add_theme_color_override("font_hover_pressed_color", AMBER)


func _process(dt: float) -> void:
	if not is_visible_in_tree():
		return
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		var near: Dictionary = stations_near.call()
		var key := ",".join(near.keys())
		if key != _near_key:
			refresh()


## Una ricetta passa i filtri (categoria e ricerca)?
func _passes(r: Dictionary) -> bool:
	var it := ItemsData.get_item(String(r["out"]))
	var kind := String(it.get("kind", ""))
	var kinds: Array = CATS[cat][1]
	if cat == CATS.size() - 1:
		for c in CATS:
			if kind in c[1]:
				return false
	elif not kinds.is_empty() and not kind in kinds:
		return false
	var q := _search.text.strip_edges().to_lower() if _search else ""
	return q == "" or String(it.get("name", "")).to_lower().contains(q)


func refresh() -> void:
	if _list == null:
		return
	for k in _cat_buttons.size():
		_cat_buttons[k].button_pressed = k == cat
	var near: Dictionary = stations_near.call()
	_near_key = ",".join(near.keys())
	for c in _list.get_children():
		c.queue_free()
	var recipes := Crafting.available(near).filter(_passes)
	var ok := recipes.filter(func(r: Dictionary) -> bool: return Crafting.can_craft(r, bisaccia))
	var no := recipes.filter(func(r: Dictionary) -> bool: return not Crafting.can_craft(r, bisaccia))
	var names := []
	for id in near:
		names.append(StationsData.STATIONS[id]["name"])
	_title.text = "Creare · %d possibili · %d banchi vicini" % [ok.size(), names.size()]
	_title.tooltip_text = "Stazioni vicine: %s" % (", ".join(names) if not names.is_empty() else "nessuna (solo ciò che si fa a mano)")
	if near.has("maglio") and held_slot.is_valid() and cat == 0:
		var hs := int(held_slot.call())
		_list.add_child(_reforge_row(hs))
		# innesti: una riga per ogni Essenza nella Bisaccia che va bene per l'oggetto in mano
		var seen := {}
		for s in bisaccia.slots:
			var e := String(s.get("id", ""))
			if e != "" and not seen.has(e) and String(ItemsData.get_item(e).get("kind", "")) == "essenza":
				seen[e] = true
				if TraitsData.can_graft(e, bisaccia.id_at(hs)):
					_list.add_child(_graft_row(hs, e))
	for r in ok + no:
		_list.add_child(_row(r, Crafting.can_craft(r, bisaccia)))
	if recipes.is_empty():
		var l := Label.new()
		l.text = "Nulla da creare qui." if _search.text == "" and cat == 0 else "Nessuna ricetta con questi filtri."
		l.add_theme_color_override("font_color", Color("#6a8a84"))
		_list.add_child(l)


## La riga del Maglio: rinnova il tratto dell'oggetto in mano, per un po' di polvere di brace.
func _reforge_row(i: int) -> Button:
	var id := bisaccia.id_at(i)
	var cost := ""
	var can := id != "" and Bisaccia.is_gear(id)
	for k in TraitsData.REFORGE_COST:
		cost += "%d %s" % [TraitsData.REFORGE_COST[k], ItemsData.get_item(k)["name"]]
		can = can and bisaccia.count(k) >= int(TraitsData.REFORGE_COST[k])
	var b := _plain_row(id if id != "" else "maglio", can)
	b.text = "Rinnova il tratto: %s" % (TraitsData.full_name(id, bisaccia.trait_at(i)) if Bisaccia.is_gear(id) else "(prendi in mano un'arma o un'armatura)")
	b.tooltip_text = "Al Maglio dei Seminatori: un tratto nuovo, sempre diverso dal vecchio.\nCosta %s." % cost
	b.pressed.connect(func() -> void:
		var t := Crafting.reforge(bisaccia, i)
		if t != "":
			crafted.emit(id, 1)
		refresh())
	return b


## La riga dell'innesto: «Innesta Essenza di furia → Spada di legnoferro [Furia]».
func _graft_row(i: int, essence: String) -> Button:
	var id := bisaccia.id_at(i)
	var t := String(ItemsData.get_item(essence)["graft"])
	var b := _plain_row(essence, true)
	b.text = "Innesta: %s [%s]" % [ItemsData.get_item(id)["name"], TraitsData.TRAITS[t]["name"]]
	b.tooltip_text = "%s: %s" % [ItemsData.get_item(essence)["name"], TraitsData.TRAITS[t]["desc"]]
	b.pressed.connect(func() -> void:
		if Crafting.graft(bisaccia, i, essence) != "":
			crafted.emit(id, 1)
			grafted.emit(id)
		refresh())
	return b


## Una riga semplice (icona e testo) con lo stile della colonna.
func _plain_row(icon_id: String, can: bool) -> Button:
	var b := Button.new()
	b.icon = SlotView.icon(icon_id)
	b.expand_icon = true
	b.add_theme_constant_override("icon_max_width", 32)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(0, 44)
	b.add_theme_font_size_override("font_size", 15)
	_style_row(b, can)
	return b


func _style_row(b: Button, can: bool) -> void:
	b.add_theme_color_override("font_color", Color("#eafff6") if can else Color("#6f8a86"))
	b.add_theme_color_override("font_hover_color", AMBER if can else Color("#8fa8a4"))
	b.modulate = Color(1, 1, 1, 1) if can else Color(1, 1, 1, 0.62)
	for st in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.14, 0.16, 0.9) if st != "hover" else Color(0.08, 0.22, 0.24, 0.95)
		sb.border_color = AMBER if st == "hover" and can else TEAL
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(14)
		sb.content_margin_left = 10
		b.add_theme_stylebox_override(st, sb)


## Una ricetta: l'icona grande, il nome con la quantità e, sotto, gli ingredienti (icona e quanti, rossi se mancano).
func _row(r: Dictionary, can: bool) -> Button:
	var b := Button.new()
	var out: String = r["out"]
	var n := int(r["qty"])
	b.custom_minimum_size = Vector2(0, ROW)
	b.tooltip_text = Crafting.describe(r, bisaccia)
	_style_row(b, can)
	var ic := TextureRect.new()
	ic.texture = SlotView.icon(out)
	ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.position = Vector2(10, 10)
	ic.size = Vector2(36, 36)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ic)
	var lbl := Label.new()
	lbl.text = "%s%s" % [ItemsData.get_item(out)["name"], (" ×%d" % n) if n > 1 else ""]
	lbl.position = Vector2(54, 3)
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color("#eafff6") if can else Color("#8aa6a2"))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(lbl)
	var x := 54.0
	for k in r["in"]:
		var need := int(r["in"][k])
		var enough := bisaccia.count(k) >= need
		var small := TextureRect.new()
		small.texture = SlotView.icon(String(k))
		small.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		small.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		small.position = Vector2(x, 30)
		small.size = Vector2(20, 20)
		small.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(small)
		var cnt := Label.new()
		cnt.text = str(need)
		cnt.position = Vector2(x + 21, 30)
		cnt.add_theme_font_size_override("font_size", 13)
		cnt.add_theme_color_override("font_color", Color("#cfeee4") if enough else Color("#ff7a6a"))
		cnt.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(cnt)
		x += 30.0 + 8.0 * str(need).length()
	b.pressed.connect(func() -> void:
		if Crafting.craft(r, bisaccia):
			crafted.emit(out, n))
	return b
