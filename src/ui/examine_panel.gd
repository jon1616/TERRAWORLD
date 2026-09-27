class_name ExaminePanel
extends Control
## «Esamina», la colonna a destra della Bisaccia aperta (riprogettata il 28 set 2026 insieme a «Creare», richiesta
## dell'utente: impaginazione chiara, sfondo scuro). Mostra una cosa alla volta, l'ultima scelta:
##   una ricetta scelta in Creare  in cima la scheda per crearla: l'oggetto grande, il banco (vicino o no), gli
##                                 ingredienti uno per riga con «ne hai / ne servono», la quantità (−, +, Max) e il
##                                 pulsante «Crea»; sotto tutto ciò che si sa dell'oggetto (`ItemInfo`)
##   un oggetto posato nella casella  (clic con una pila in mano, come in una casella qualunque) la sua scheda; se si
##                                 può fabbricare, «Vai alla ricetta»
## Chiudendo la Bisaccia l'oggetto posato torna nella Bisaccia.

const RECT := Rect2(1168, 92, 420, 798)
const AMBER := Color("#ffb84a")
const GOLD := Color("#ffd08a")
const MUTED := Color("#6a8a84")
const TEXT := Color("#dcefe8")
const OK := Color("#7ee8a0")
const BAD := Color("#ff7a6a")

var panel: BisacciaPanel
var crafting: CraftingPanel
var held := {}                         # l'oggetto posato nella casella
var recipe := {}                       # la ricetta scelta in Creare
var qty := 1
var sheet: Callable                    # () -> la scheda del Germogliato (la mostra `CharacterCard`)
var _slot: SlotView
var _hint: Label
var _card: VBoxContainer               # la scheda per creare
var _big: TextureRect
var _name: Label
var _where: Label
var _ings: VBoxContainer
var _qty_label: Label
var _max_label: Label
var _make: Button
var _goto: Button
var _text: RichTextLabel
var _dirty := false
var _mode_recipe := false              # la scheda mostra la ricetta scelta (non l'oggetto posato)


func setup(p: BisacciaPanel, c: CraftingPanel) -> void:
	panel = p
	crafting = c
	position = RECT.position
	size = RECT.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var frame := Panel.new()
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", CraftingPanel.panel_box(Color("#2f7a70")))
	add_child(frame)
	var title := _label(self, Vector2(18, 10), 22, AMBER)
	title.text = "Esamina"
	_slot = SlotView.new()
	_slot.position = Vector2(size.x - 18 - SlotView.SIZE, 10)
	_slot.clicked.connect(_click)
	_slot.tooltip_text = "Posa qui un oggetto per esaminarlo"
	add_child(_slot)
	_hint = _label(self, Vector2(18, 42), 12, MUTED)
	_hint.text = "posa qui un oggetto →"
	_hint.size = Vector2(size.x - 100, 20)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# la scheda per creare
	_card = VBoxContainer.new()
	_card.position = Vector2(16, 76)
	_card.size = Vector2(size.x - 32, 0)
	_card.add_theme_constant_override("separation", 6)
	add_child(_card)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	_card.add_child(head)
	var box := Panel.new()
	box.custom_minimum_size = Vector2(64, 64)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#0f1c1a")
	sb.border_color = Color("#2f7a70")
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	box.add_theme_stylebox_override("panel", sb)
	head.add_child(box)
	_big = TextureRect.new()
	_big.position = Vector2(8, 8)
	_big.size = Vector2(48, 48)
	_big.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_big.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	box.add_child(_big)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.add_theme_constant_override("separation", 2)
	head.add_child(names)
	_name = Label.new()
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_name.add_theme_font_size_override("font_size", 20)
	names.add_child(_name)
	_where = Label.new()
	_where.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_where.add_theme_font_size_override("font_size", 13)
	names.add_child(_where)
	var need := Label.new()
	need.text = "Serve"
	need.add_theme_font_size_override("font_size", 14)
	need.add_theme_color_override("font_color", GOLD)
	_card.add_child(need)
	_ings = VBoxContainer.new()
	_ings.add_theme_constant_override("separation", 3)
	_card.add_child(_ings)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_card.add_child(row)
	row.add_child(_small("−", func() -> void: _set_qty(qty - 1)))
	_qty_label = Label.new()
	_qty_label.custom_minimum_size = Vector2(46, 0)
	_qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_qty_label.add_theme_font_size_override("font_size", 18)
	row.add_child(_qty_label)
	row.add_child(_small("+", func() -> void: _set_qty(qty + 1)))
	row.add_child(_small("Max", func() -> void: _set_qty(maxi(crafting.times_possible(recipe), 1))))
	_make = Button.new()
	_make.text = "Crea"
	_make.focus_mode = Control.FOCUS_NONE
	_make.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_make.custom_minimum_size = Vector2(0, 40)
	_make.add_theme_font_size_override("font_size", 18)
	_make_style(_make)
	_make.pressed.connect(func() -> void:
		if not recipe.is_empty():
			crafting.craft_times(recipe, qty)
			_set_qty(qty))
	row.add_child(_make)
	_max_label = Label.new()
	_max_label.add_theme_font_size_override("font_size", 13)
	_card.add_child(_max_label)
	var line := ColorRect.new()
	line.color = Color("#2f7a70", 0.6)
	line.custom_minimum_size = Vector2(0, 1)
	_card.add_child(line)
	_goto = Button.new()
	_goto.text = "Vai alla ricetta"
	_goto.focus_mode = Control.FOCUS_NONE
	_goto.position = Vector2(16, 76)
	_goto.size = Vector2(180, 32)
	RecipeRow.style(_goto, true, Color("#2f7a70"))
	_goto.pressed.connect(func() -> void:
		var rs := RecipesData.making(String(held.get("id", "")))
		if not rs.is_empty():
			crafting.pick(rs[0]))
	add_child(_goto)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.scroll_active = true
	_text.add_theme_font_size_override("normal_font_size", 15)
	_text.add_theme_color_override("default_color", TEXT)
	_text.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_text)
	crafting.picked.connect(show_recipe)
	crafting.refreshed.connect(func() -> void: _dirty = true)
	panel.bisaccia.changed.connect(func() -> void: _dirty = true)
	refresh()


func _label(parent: Control, pos: Vector2, fs: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _small(t: String, f: Callable) -> Button:
	var b := Button.new()
	b.text = t
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(40 if t.length() < 3 else 52, 40)
	b.add_theme_font_size_override("font_size", 16)
	RecipeRow.style(b, true, Color("#2f7a70"))
	b.pressed.connect(f)
	return b


static func _make_style(b: Button) -> void:
	for st in ["normal", "hover", "pressed", "disabled"]:
		var s := StyleBoxFlat.new()
		var off: bool = st == "disabled"
		s.bg_color = Color("#3a2a10") if off else (Color("#b8741e") if st == "hover" else Color("#9a5e14"))
		s.border_color = Color("#5a4a30") if off else AMBER
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		b.add_theme_stylebox_override(st, s)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_disabled_color", Color("#8a7a60"))


func _click(_i: int, button: int) -> void:
	if button != MOUSE_BUTTON_LEFT:
		return
	var out := held
	held = panel.held
	panel.held = out
	panel.refresh_held()
	if not held.is_empty():
		_mode_recipe = false                     # posando un oggetto la scheda passa all'oggetto
	refresh()


## La ricetta scelta in Creare (l'oggetto posato resta nella casella, ma la scheda passa alla ricetta).
func show_recipe(r: Dictionary) -> void:
	if r != recipe:
		qty = 1
	recipe = r
	_mode_recipe = true
	refresh()


## Mostra un oggetto senza toglierlo dalla Bisaccia (prove). `dati`: quelli propri della casella.
func show_item(id: String, tratto := "", dati := {}) -> void:
	_text.text = ItemInfo.bbcode(id, tratto, dati)


func _set_qty(n: int) -> void:
	qty = clampi(n, 1, 999)
	_fill_recipe()


func refresh() -> void:
	_dirty = false
	_slot.set_item(String(held.get("id", "")), int(held.get("n", 0)), String(held.get("tratto", "")), held.get("dati", {}))
	_hint.visible = held.is_empty()
	var rec := _mode_recipe and not recipe.is_empty()
	_card.visible = rec
	_goto.visible = false
	if rec:
		_fill_recipe()
		return
	_text.position = Vector2(16, 76)
	_text.size = Vector2(size.x - 32, size.y - 92)
	if held.is_empty():
		_text.text = "[color=#6a8a84]Scegli una ricetta in [color=#ffb84a]Creare[/color]: qui compare che cosa serve e il pulsante per crearla.\n\nOppure posa un oggetto nella casella in alto a destra: saprai a cosa serve, in quali ricette si usa e come si ottiene.[/color]"
		return
	if not held.has("dati"):
		var fresh := Genome.fresh_for_item(String(held["id"]))   # un Seme salvato prima dei genomi
		if not fresh.is_empty():
			held["dati"] = fresh
	var makes := not RecipesData.making(String(held["id"])).is_empty()
	_goto.visible = makes
	if makes:
		_text.position = Vector2(16, 116)
		_text.size = Vector2(size.x - 32, size.y - 132)
	show_item(String(held["id"]), String(held.get("tratto", "")), held.get("dati", {}))


## La scheda per creare: i numeri secondo la Bisaccia e le casse vicine di adesso.
func _fill_recipe() -> void:
	var r := recipe
	var out := String(r["out"])
	var it := ItemsData.get_item(out)
	var col := CraftCatsData.color_of(out)
	_big.texture = SlotView.icon(out)
	_name.text = "%s%s" % [it.get("name", out), ("  ×%d" % int(r["qty"])) if int(r["qty"]) > 1 else ""]
	_name.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.25))
	var st := String(r["station"])
	var near := crafting.station_ok(r)
	_where.text = "%s · %s" % [CraftCatsData.CATS[CraftCatsData.of(out)][1],
		"si fa a mano, ovunque" if st == "" else ("%s: vicino ✓" % StationsData.STATIONS[st]["name"] if near
			else "serve il %s: non è vicino" % StationsData.STATIONS[st]["name"])]
	_where.add_theme_color_override("font_color", TEXT if near else BAD)
	for c in _ings.get_children():
		_ings.remove_child(c)                    # tolte subito: la misura della scheda non deve contarle
		c.queue_free()
	for k in r["in"]:
		var need := int(r["in"][k]) * qty
		var have := Crafting.have(panel.bisaccia, String(k))
		var there := Crafting.in_pool(String(k))
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation", 8)
		var ic := TextureRect.new()
		ic.texture = SlotView.icon(String(k))
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(28, 28)
		line.add_child(ic)
		var nm := Label.new()
		nm.text = String(ItemsData.get_item(String(k)).get("name", k)) + ("  (%d nelle casse)" % there if there > 0 else "")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.clip_text = true
		nm.add_theme_font_size_override("font_size", 15)
		nm.add_theme_color_override("font_color", TEXT)
		line.add_child(nm)
		var cnt := Label.new()
		cnt.text = "%s / %d" % [SlotView.short_count(have), need]
		cnt.add_theme_font_size_override("font_size", 15)
		cnt.add_theme_color_override("font_color", OK if have >= need else BAD)
		line.add_child(cnt)
		_ings.add_child(line)
	var can_n := crafting.times_possible(r)
	_qty_label.text = str(qty)
	_make.disabled = can_n < qty
	_make.text = "Crea" if qty == 1 else "Crea ×%d" % qty
	_max_label.text = ("Puoi farne fino a %d." % can_n) if can_n > 0 else ("Mancano ingredienti." if near else "Avvicinati al banco.")
	_max_label.add_theme_color_override("font_color", OK if can_n >= qty else MUTED)
	# sotto, la scheda dell'oggetto
	var top := 76.0 + _card.get_combined_minimum_size().y + 8.0
	_text.position = Vector2(16, top)
	_text.size = Vector2(size.x - 32, size.y - top - 12)
	show_item(out)
	# il nome c'è già, grande, in cima alla scheda: la descrizione comincia dalla riga dopo
	var cut := _text.text.find("\n")
	if cut >= 0:
		_text.text = _text.text.substr(cut + 1)


func _process(_dt: float) -> void:
	if _dirty and is_visible_in_tree():
		refresh()


## La Bisaccia si chiude: l'oggetto esaminato torna dentro.
func give_back() -> void:
	if not held.is_empty():
		panel.bisaccia.add_stack(held)
		held = {}
	refresh()
