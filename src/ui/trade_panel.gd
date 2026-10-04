class_name TradePanel
extends Control
## Il commercio con un abitante (voce 36), sopra la Bisaccia aperta come le ceste: in alto le merci dell'abitante
## (clic = compri, se hai i Lumini e il posto), sotto il prezzo; Maiusc+clic su una casella della Bisaccia vende la
## pila, «Vendi ciò che tieni» vende la pila presa con il clic. Prezzi da `ValueData`.

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
var _sell: Button
var _work: Button                       # voce 232: la bottega dell'abitante (`NpcWork`)
var sold := 0
var _portrait: TextureRect
## Voce 353: i servizi dell'abitante (`Services`), in un riquadro a sinistra del commercio.
var _svc_frame: Panel
var _svc_box: VBoxContainer
var _svc_key := ""
const PORTRAIT := 112.0                 # voce 102: il ritratto (56 px) ingrandito due volte


func setup(p: BisacciaPanel) -> void:
	panel = p
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var bag_top := Hud.HOTBAR_Y - 16 - 3 * (SlotView.SIZE + GAP) - 44
	# (voce 280) dall'alto: testata con ritratto, nome, saluto e richiesta; una fila di pulsanti; la bottega; le merci
	# con il prezzo. Il commercio prende il posto di «Creare», quindi c'è tutto lo spazio sopra la Bisaccia.
	var fy := bag_top - 16 - 352
	var y0 := fy + 260                                      # la fila delle merci
	var frame := Panel.new()
	frame.add_theme_stylebox_override("panel", UiFrames.box("forte", "normale", UiPalette.AMBRA_CHIARA))
	frame.position = Vector2(x0 - 18, fy)
	frame.size = Vector2(w + 36, 352)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(x0, fy + 20)
	_portrait.size = Vector2(PORTRAIT, PORTRAIT)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_portrait)
	_title = Label.new()
	_title.position = Vector2(x0, fy + 20)
	_title.add_theme_font_size_override("font_size", UiPalette.SOTTOTITOLO)
	_title.add_theme_color_override("font_color", UiPalette.AMBRA_CHIARA)
	add_child(_title)
	_greet = Label.new()
	_greet.position = Vector2(x0, fy + 54)
	_greet.size = Vector2(w, 40)
	_greet.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_greet.max_lines_visible = 2
	_greet.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_greet.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
	_greet.add_theme_color_override("font_color", UiPalette.TESTO)
	add_child(_greet)
	# voce 65: la richiesta personale, «Consegna» e «Dona ciò che hai in mano»
	_quest = Label.new()
	_quest.position = Vector2(x0, fy + 104)
	_quest.size = Vector2(w, 22)
	_quest.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_quest.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
	_quest.add_theme_color_override("font_color", UiPalette.LINFA)
	add_child(_quest)
	var bw := (w - 16) / 3.0
	_deliver = _act("Consegna la richiesta", Vector2(x0, fy + 148), bw)
	_deliver.pressed.connect(deliver)
	_gift = _act("Dona ciò che tieni", Vector2(x0 + bw + 8, fy + 148), bw)
	_gift.tooltip_text = "Un dono che gli piace fa crescere l'affetto molto di più. Con l'affetto: sconti e regali"
	_gift.pressed.connect(gift_held)
	_sell = _act("Vendi ciò che tieni", Vector2(x0 + 2 * (bw + 8), fy + 148), bw)
	var sell := _sell
	sell.pressed.connect(sell_held)
	sell.tooltip_text = "Vende la pila presa con il clic. Per vendere una pila della Bisaccia: Maiusc+clic sulla sua casella"
	_work = _act("", Vector2(x0, fy + 192), w)
	_work.pressed.connect(work)
	# voce 353: i servizi, nel posto libero a sinistra (dove senza commercio sta «Creare»)
	_svc_frame = Panel.new()
	_svc_frame.add_theme_stylebox_override("panel", UiFrames.box("forte", "normale", UiPalette.LINFA))
	_svc_frame.position = Vector2(16, fy)
	_svc_frame.size = Vector2(x0 - 18 - 16 - 12, 352)
	_svc_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_svc_frame)
	_svc_box = VBoxContainer.new()
	_svc_box.position = Vector2(14, 12)
	_svc_box.size = Vector2(_svc_frame.size.x - 28, 330)
	_svc_box.add_theme_constant_override("separation", 6)
	_svc_frame.add_child(_svc_box)
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


func _act(t: String, pos: Vector2, wd: float) -> Button:
	var b := Button.new()
	b.text = t
	b.position = pos
	b.size = Vector2(wd, 34)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", UiPalette.TESTO_PX - 1)
	add_child(b)
	return b


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
	if npc == "":
		return []
	var g: Array = (NpcData.NPCS[npc]["goods"] as Array).duplicate()
	if m != null and NpcStoriesData.FINAL.has(npc) and NpcBonds.story_done(m.character, npc):
		g.append(NpcStoriesData.FINAL[npc])          # voce 231: la merce in più a storia finita
	return g


func _refresh() -> void:
	if npc == "":
		return
	var nd: Dictionary = NpcData.NPCS[npc]
	_title.text = _title_text()
	_greet.text = "«%s»" % _greeting()
	if m != null and m.homes and m.homes.line(npc) != "":
		_greet.text += "   ·   " + m.homes.line(npc)          # voce 143: la sua casa
	# voce 102: con il ritratto le scritte cominciano alla sua destra
	var pt := ArtLib.tex("ritratti", npc)
	_portrait.texture = pt
	_portrait.visible = pt != null
	var dx := PORTRAIT + 12.0 if pt != null else 0.0
	var x0 := _slots[0].position.x
	var w := _slots[COLS - 1].position.x + SlotView.SIZE - x0
	for l: Label in [_title, _greet, _quest]:
		l.position.x = x0 + dx
	_greet.size.x = w - dx
	_quest.size.x = w - dx
	var bonds := m != null and nd.has("quests")
	_work.visible = m != null and NpcWork.has_shop(npc)
	if _work.visible:
		_work.text = NpcWork.label(m.world_meta, m.character, npc)
		_work.tooltip_text = NpcWork.describe(m.character, npc)
	_quest.visible = bonds
	_deliver.visible = bonds
	_gift.visible = bonds
	# i pulsanti che si vedono, in fila da sinistra, larghi uguali
	var acts: Array[Button] = []
	for b: Button in [_deliver, _gift, _sell]:
		if b.visible:
			acts.append(b)
	var bw := (w - 8.0 * 2) / 3.0
	for k in acts.size():
		acts[k].position.x = x0 + k * (bw + 8.0)
		acts[k].size.x = bw
	if bonds:
		_quest.text = "Richiesta: " + NpcBonds.quest_text(m.character, npc)
		_deliver.disabled = not NpcBonds.quest_ready(m.character, npc)
	_fill_services()
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


## I servizi dell'abitante: titolo, poi per ognuno il pulsante (nome e prezzo) e che cosa fa. Si rifà solo se cambia.
func _fill_services() -> void:
	var rows: Array = m.services.rows(npc) if m != null and m.get("services") != null else []
	_svc_frame.visible = not rows.is_empty()
	var key := "%s|%s|%d" % [npc, str(rows), lumini()]
	if key == _svc_key:
		return
	_svc_key = key
	for c in _svc_box.get_children():
		c.queue_free()
	if rows.is_empty():
		return
	var t := Label.new()
	t.text = "I servizi %s" % ItemUses._prep("di", String(NpcData.NPCS[npc]["name"]))
	t.add_theme_font_size_override("font_size", UiPalette.SOTTOTITOLO - 2)
	t.add_theme_color_override("font_color", UiPalette.LINFA)
	_svc_box.add_child(t)
	var sub := Label.new()
	sub.text = "Cose che sa fare solo lui, pagate in Lumini."
	sub.add_theme_font_size_override("font_size", 13)
	sub.add_theme_color_override("font_color", Color("#9fc8c0"))
	_svc_box.add_child(sub)
	for r in rows:
		var b := Button.new()
		var left := "" if int(r[5]) < 0 else "  ·  %d oggi" % int(r[5])
		b.text = "%s — %d Lumini%s" % [r[1], int(r[2]), left]
		b.custom_minimum_size = Vector2(0, 34)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", UiPalette.TESTO_PX - 1)
		b.disabled = String(r[4]) != ""
		b.tooltip_text = String(r[3]) if String(r[4]) == "" else "%s\n(%s)" % [r[3], r[4]]
		var id := String(r[0])
		b.pressed.connect(func() -> void:
			var msg: String = m.services.use(id)
			if msg != "":
				m.hud.toast(msg)
			_svc_key = ""
			_refresh())
		_svc_box.add_child(b)
		var d := Label.new()
		d.text = String(r[3]) if String(r[4]) == "" else "%s  [%s]" % [r[3], r[4]]
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size = Vector2(_svc_box.size.x, 0)
		d.add_theme_font_size_override("font_size", 13)
		d.add_theme_color_override("font_color", Color("#cfeee4") if String(r[4]) == "" else Color("#8a9a94"))
		_svc_box.add_child(d)


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
				var o: Dictionary = m.albero.offer_of(i)
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
	var q := NpcBonds.quest(m.character, npc)
	var rw := NpcBonds.deliver(m.character, npc)
	if rw.is_empty():
		return false
	if q.has("scene"):                                # voce 231: un capitolo della sua storia
		m.guardian.lore.show_text("%s · %s" % [NpcData.NPCS[npc]["name"], q["title"]], String(q["scene"]))
		m.objectives.bump("capitoli")
	for id in rw:
		var rest := panel.bisaccia.add(String(id), int(rw[id]))
		if rest > 0:
			m.drops.spawn(String(id), rest, m.player.position)
	m.objectives.bump("richieste")
	m.sfx.play("dono")
	m.hud.toast("%s è contento: la richiesta è fatta" % NpcData.NPCS[npc]["name"])
	_refresh()
	return true


## Voce 232: la bottega: ritira se è pronto, altrimenti lascia i materiali del primo lavoro che si può fare.
func work() -> String:
	if m == null or npc == "":
		return ""
	var got := NpcWork.collect(m.world_meta, npc)
	var msg := ""
	if not got.is_empty():
		for id in got:
			var rest := panel.bisaccia.add(String(id), int(got[id]))
			if rest > 0:
				m.drops.spawn(String(id), rest, m.player.position)
			msg = "Ritirato: %d %s" % [int(got[id]), ItemsData.get_item(String(id)).get("name", id)]
		m.objectives.bump("botteghe")
		m.sfx.play("dono")
	elif NpcWork.left(m.world_meta, npc) < 0.0:
		msg = NpcWork.start(m.world_meta, m.character, npc)
		if msg == "":
			msg = "Non hai i materiali per la bottega (vedi il suggerimento del bottone)"
	else:
		msg = "Il lavoro non è ancora pronto"
	m.hud.toast(msg)
	_refresh()
	return msg


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
