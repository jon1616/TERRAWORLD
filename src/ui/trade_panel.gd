class_name TradePanel
extends Control
## Il commercio con un abitante (voce 36), sopra la Bisaccia aperta come le ceste: in alto le merci dell'abitante
## (clic = compri, se hai i Lumini e il posto), sotto il prezzo; Maiusc+clic su una casella della Bisaccia vende la
## pila, «Vendi ciò che hai in mano» vende la pila presa con il clic. Prezzi da `ValueData`.

const COLS := 10
const GAP := 6

var panel: BisacciaPanel
var npc := ""
var _slots: Array[SlotView] = []
var _prices: Array[Label] = []
var _title: Label
var _greet: Label
var bought := 0                         # acquisti riusciti (per le prove)
var m: Node2D                           # voce 65: la scena (personaggio, Albero-Madre); la dà `Villagers`
var _quest: Label
var _deliver: Button
var _gift: Button
var sold := 0


func setup(p: BisacciaPanel) -> void:
	panel = p
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	z_index = 4                                # come la Bisaccia aperta: sopra lo sfondo scuro (28 set 2026)
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var bag_top := Hud.HOTBAR_Y - 16 - 3 * (SlotView.SIZE + GAP) - 44
	var y0 := bag_top - 40 - SlotView.SIZE - 20
	var frame := Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = CraftingPanel.BG
	sb.border_color = Color("#ffd08a")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	frame.add_theme_stylebox_override("panel", sb)
	frame.position = Vector2(x0 - 14, y0 - 124)
	frame.size = Vector2(w + 28, SlotView.SIZE + 166)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	_title = Label.new()
	_title.position = Vector2(x0, y0 - 58)
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color("#ffd08a"))
	add_child(_title)
	_greet = Label.new()
	_greet.position = Vector2(x0, y0 - 32)
	_greet.size = Vector2(w, 20)
	_greet.clip_text = true
	_greet.add_theme_font_size_override("font_size", 13)
	_greet.add_theme_color_override("font_color", Color("#cfeee4"))
	add_child(_greet)
	var sell := Button.new()
	sell.text = "Vendi ciò che hai in mano"
	sell.position = Vector2(x0 + w - 150, y0 - 116)          # (voce 65: in fila con Consegna e Dona)
	sell.size = Vector2(150, 28)
	sell.add_theme_font_size_override("font_size", 12)
	sell.pressed.connect(sell_held)
	sell.tooltip_text = "Vende la pila presa con il clic. Per vendere una pila della Bisaccia: Maiusc+clic sulla sua casella"
	add_child(sell)
	# voce 65: la richiesta personale, «Consegna» e «Dona ciò che hai in mano»
	_quest = Label.new()
	_quest.position = Vector2(x0, y0 - 84)
	_quest.size = Vector2(w, 24)
	_quest.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_quest.add_theme_font_size_override("font_size", 13)
	_quest.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_quest)
	_deliver = Button.new()
	_deliver.text = "Consegna la richiesta"
	_deliver.position = Vector2(x0 + w - 470, y0 - 116)
	_deliver.size = Vector2(150, 28)
	_deliver.add_theme_font_size_override("font_size", 12)
	_deliver.pressed.connect(deliver)
	add_child(_deliver)
	_gift = Button.new()
	_gift.text = "Dona ciò che hai in mano"
	_gift.position = Vector2(x0 + w - 312, y0 - 116)
	_gift.size = Vector2(152, 28)
	_gift.add_theme_font_size_override("font_size", 12)
	_gift.tooltip_text = "Un dono che gli piace fa crescere l'affetto molto di più. Con l'affetto: sconti e regali"
	_gift.pressed.connect(gift_held)
	add_child(_gift)
	for c in COLS:
		var s := SlotView.new()
		s.index = c
		s.position = Vector2(x0 + c * (SlotView.SIZE + GAP), y0)
		s.clicked.connect(_click)
		add_child(s)
		_slots.append(s)
		var pl := Label.new()
		pl.position = Vector2(s.position.x - 4, y0 + SlotView.SIZE + 2)
		pl.size = Vector2(SlotView.SIZE + 8, 16)
		pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pl.add_theme_font_size_override("font_size", 12)
		add_child(pl)
		_prices.append(pl)


func lumini() -> int:
	return panel.bisaccia.count("lumino")


func open(id: String) -> void:
	npc = id
	visible = true
	if not panel.visible:
		panel.toggle()
	panel.crafting.set_tall(false)             # il commercio prende il posto di «Creare»
	panel.quick_target = _sell_slot
	_refresh()


func close() -> void:
	visible = false
	npc = ""
	panel.quick_target = Callable()
	panel.crafting.set_tall(true)


func _goods() -> Array:
	return NpcData.NPCS[npc]["goods"] if npc != "" else []


func _refresh() -> void:
	if npc == "":
		return
	var nd: Dictionary = NpcData.NPCS[npc]
	_title.text = _title_text()
	_greet.text = "«%s»" % _greeting()
	var bonds := m != null and nd.has("quests")
	_quest.visible = bonds
	_deliver.visible = bonds
	_gift.visible = bonds
	if bonds:
		_quest.text = "Richiesta: " + NpcBonds.quest_text(m.character, npc)
		_deliver.disabled = not NpcBonds.quest_ready(m.character, npc)
	var goods := _goods()
	for k in COLS:
		var has := k < goods.size()
		_slots[k].visible = has
		_prices[k].visible = has
		if has:
			var id := String(goods[k][0])
			var n := int(goods[k][1])
			var price := _price(id, n)
			_slots[k].set_item(id, n)
			_slots[k].tip_extra = {"price": "buy", "cost": price}
			_prices[k].text = "%d L" % price
			_prices[k].add_theme_color_override("font_color", Color("#ffd08a") if lumini() >= price else Color("#8a6a5a"))


## Clic su una merce: la si compra.
func _click(i: int, button: int) -> void:
	if button != MOUSE_BUTTON_LEFT:
		return
	buy(i)


func buy(i: int) -> bool:
	var goods := _goods()
	if i >= goods.size():
		return false
	var id := String(goods[i][0])
	var n := int(goods[i][1])
	var price := _price(id, n)
	var b := panel.bisaccia
	if lumini() < price or b.room_for(id) < n:
		return false
	b.remove("lumino", price)
	b.add(id, n)
	bought += 1
	if m != null and NpcData.NPCS[npc].has("quests"):
		_give(NpcBonds.add(m.character, npc, NpcBonds.BUY))
	_refresh()
	return true


## Maiusc+clic su una casella della Bisaccia: la pila si vende.
func _sell_slot(i: int) -> void:
	var b := panel.bisaccia
	if b.slots[i].is_empty():
		return
	var id := b.id_at(i)
	var price := ValueData.sell_price(id, b.count_at(i))
	if price <= 0 or id == "lumino":
		return
	b.slots[i] = {}
	b.add("lumino", price)
	sold += 1
	_refresh()


func sell_held() -> void:
	var h := panel.held
	if h.is_empty() or String(h["id"]) == "lumino":
		return
	var price := ValueData.sell_price(String(h["id"]), int(h["n"]))
	if price <= 0:
		return
	panel.held = {}
	panel.bisaccia.add("lumino", price)
	panel.refresh_held()
	sold += 1
	_refresh()


func _process(_dt: float) -> void:
	if visible and not panel.visible:
		close()
	elif visible:
		_title.text = _title_text()


# ---- voce 65: affetto, doni e richieste -------------------------------------------------------------------------

func _title_text() -> String:
	var nd: Dictionary = NpcData.NPCS[npc]
	if m == null or not nd.has("quests"):
		return "%s  ·  i tuoi Lumini: %d" % [nd["name"], lumini()]
	var lv := NpcBonds.level(m.character, npc)
	return "%s  ·  affetto %s%s  ·  Lumini: %d" % [nd["name"], "♥".repeat(lv) + "♡".repeat(4 - lv),
		("  (sconto %d%%)" % roundi(lv * NpcBonds.DISCOUNT * 100.0)) if lv > 0 else "", lumini()]


## Il saluto; la Vecchia Radice dice che cosa chiede adesso l'Albero-Madre e dove cercarlo.
func _greeting() -> String:
	var nd: Dictionary = NpcData.NPCS[npc]
	if npc == "vecchia_radice" and m != null and not m.albero.done():
		var st: Dictionary = m.albero.current()
		var offers: Array = st["offers"]
		for i in offers.size():
			var p: Array = m.albero.progress(i)
			if int(p[0]) < int(p[1]):
				var o: Dictionary = offers[i]
				var what := String(o["text"]) if o.has("text") else String(ItemsData.get_item(String(o["item"]))["name"])
				return "L'Albero chiede «%s»: %s. Cerca %s." % [st["name"], what.to_lower(), o["hint"]]
		return "L'Albero ha tutto ciò che chiedeva: va' da lui e sveglialo."
	return String(nd["greet"])


func _price(id: String, n: int) -> int:
	var base := ValueData.buy_price(id, n)
	return NpcBonds.price(m.character, npc, base) if m != null and NpcData.NPCS[npc].has("quests") else base


func _give(items: Dictionary) -> void:
	for id in items:
		var rest := panel.bisaccia.add(String(id), int(items[id]))
		if rest > 0 and m != null:
			m.drops.spawn(String(id), rest, m.player.position)
	if not items.is_empty() and m != null:
		m.hud.toast("%s ti fa un regalo" % NpcData.NPCS[npc]["name"])


## Consegna la richiesta personale: gli oggetti (anche dalle casse vicine) o il traguardo; la ricompensa in Bisaccia.
func deliver() -> bool:
	if m == null or npc == "":
		return false
	var rw := NpcBonds.deliver(m.character, npc)
	if rw.is_empty():
		return false
	for id in rw:
		var rest := panel.bisaccia.add(String(id), int(rw[id]))
		if rest > 0:
			m.drops.spawn(String(id), rest, m.player.position)
	m.objectives.bump("richieste")
	m.sfx.play("dono")
	m.hud.toast("%s è contento: la richiesta è fatta" % NpcData.NPCS[npc]["name"])
	_refresh()
	return true


## Dona la pila in mano (quella presa con il clic nella Bisaccia).
func gift_held() -> int:
	var h := panel.held
	if m == null or h.is_empty() or String(h["id"]) == "lumino":
		return 0
	var v := NpcBonds.gift_value(npc, String(h["id"]), int(h["n"]))
	panel.held = {}
	panel.refresh_held()
	_give(NpcBonds.add(m.character, npc, v))
	m.hud.toast("%s apprezza il dono (+%d d'affetto)" % [NpcData.NPCS[npc]["name"], v])
	_refresh()
	return v
