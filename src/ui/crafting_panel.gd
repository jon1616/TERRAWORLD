class_name CraftingPanel
extends Control
## La colonna «Creare» accanto alla Bisaccia aperta (rifatta il 26 set 2026, richiesta dell'utente: meglio impaginata
## e con le ricette colorate per tipo).
##   in alto     il titolo con quante ricette si possono fare, e i banchi vicini (icone con il nome)
##   categorie   dieci bottoni colorati (Tutto e le nove di `CraftCatsData`), la ricerca e «Solo possibili»
##   elenco      in «Tutto» le ricette sono raggruppate per tipo, ogni gruppo con la sua intestazione colorata
##               («Armi — 3 possibili su 12»); dentro, prima quelle possibili. In cima le lavorazioni del Maglio e del
##               Telaio sull'oggetto in mano (tratti, innesti, fasce)
##   in basso    come si usa: clic crea, Maiusc+clic crea cinque volte
## È alta tutta la destra dello schermo; con una cassa aperta torna bassa accanto alla Bisaccia (`set_tall`), per
## lasciare posto ai pulsanti della cassa.
## Ogni ricetta ha la sua riga (`RecipeRow`), costruita la prima volta che serve e poi riusata: il pannello decide solo
## quali righe si vedono e in che ordine. Rifare 171 righe da capo costava 106 ms, e con la Bisaccia aperta succedeva
## in ogni fotogramma in cui si raccoglieva qualcosa.

const W := 440
const TOP_TALL := 90.0                 # dove comincia quando è alta (sotto Vita e Linfa)
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")
const MUTED := Color("#6a8a84")
## Le categorie dei bottoni: «Tutto» e quelle di `CraftCatsData` (nome, tipi). L'ultima è «Altro».
static var CATS: Array = _tabs()

var bisaccia: Bisaccia
var stations_near: Callable            # () -> Dictionary delle stazioni a portata
var luck: Callable                    # () -> float: la fortuna che alza la qualità dei pezzi fabbricati (voce 54)
var held_slot: Callable                # () -> casella dell'oggetto in mano (per rinnovarne il tratto al Maglio)
var cat := 0
var only_possible := false
var _list: VBoxContainer
var _scroll: ScrollContainer
var _frame: Panel
var _title: Label
var _count: Label
var _benches: HBoxContainer
var _search: LineEdit
var _only: CheckBox
var _hint: Label
var _cat_buttons: Array[Button] = []
var _headers: Array[Label] = []        # un'intestazione per categoria (si riusano)
var _work_header: Label
var _near_key := ""
var _t := 0.0
var _dirty := false                    # la Bisaccia è cambiata da quando l'elenco è stato fatto
var _rows := {}                        # ricetta -> la sua RecipeRow (si riusa)
var refreshes := 0                     # quante volte l'elenco è stato rifatto (per le prove)
var _warm := 0                         # fin dove sono già pronte le righe di tutte le ricette (vedi `_process`)
const WARM_PER_FRAME := 3
var _special: Array[Control] = []      # righe del Maglio e del Telaio: poche, si rifanno ogni volta
var _empty: Label                      # «Nulla da creare qui.»
var _low := Rect2()                    # posto e misura quando è bassa (accanto alla Bisaccia)

signal crafted(id: String, n: int)
signal grafted(id: String)


static func _tabs() -> Array:
	var out := [["Tutto", []]]
	for c in CraftCatsData.CATS:
		out.append([c[1], c[3]])
	return out


func setup(b: Bisaccia, near: Callable, pos: Vector2, height: float) -> void:
	bisaccia = b
	stations_near = near
	_low = Rect2(pos, Vector2(W, height))
	_frame = Panel.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.05, 0.06, 0.9)
	sb.border_color = TEAL
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(22)
	_frame.add_theme_stylebox_override("panel", sb)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_title = _label(Vector2(18, 8), 22, AMBER)
	_title.text = "Creare"
	_count = _label(Vector2(140, 13), 14, Color("#cfeee4"))
	_count.size = Vector2(W - 158, 20)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# i banchi vicini: le loro icone in fila, con il nome nel suggerimento
	var bl := _label(Vector2(18, 42), 12, MUTED)
	bl.text = "Banchi vicini:"
	_benches = HBoxContainer.new()
	_benches.position = Vector2(104, 38)
	_benches.add_theme_constant_override("separation", 4)
	add_child(_benches)
	# le categorie: due righe di cinque bottoni, ognuno con il colore della sua categoria
	var cw := (W - 28 - 4 * 5) / 5.0
	for k in CATS.size():
		var cb := Button.new()
		cb.text = {5: "Pozioni", 8: "Giardino"}.get(k, String(CATS[k][0]))
		cb.tooltip_text = String(CATS[k][0])
		cb.toggle_mode = true
		cb.focus_mode = Control.FOCUS_NONE
		cb.clip_text = true
		cb.position = Vector2(14 + (k % 5) * (cw + 5), 66 + (k / 5) * 30)
		cb.size = Vector2(cw, 26)
		cb.add_theme_font_size_override("font_size", 12)
		_style_chip(cb, AMBER if k == 0 else CraftCatsData.CATS[k - 1][2])
		cb.pressed.connect(func() -> void:
			cat = k
			refresh())
		add_child(cb)
		_cat_buttons.append(cb)
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca per nome o ingrediente…"
	_search.position = Vector2(14, 130)
	_search.size = Vector2(W - 170, 30)
	_search.add_theme_font_size_override("font_size", 14)
	_search.text_changed.connect(func(_t2: String) -> void: refresh())
	add_child(_search)
	_only = CheckBox.new()
	_only.text = "Solo possibili"
	_only.focus_mode = Control.FOCUS_NONE
	_only.position = Vector2(W - 148, 131)
	_only.add_theme_font_size_override("font_size", 13)
	_only.toggled.connect(func(on: bool) -> void:
		only_possible = on
		refresh())
	add_child(_only)
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(12, 168)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(W - 40, 0)
	_list.add_theme_constant_override("separation", 4)
	_scroll.add_child(_list)
	for c in CraftCatsData.CATS:
		var h := _header(c[2])
		_headers.append(h)
	_work_header = _header(CraftCatsData.WORK)
	_work_header.text = "Lavorazioni sull'oggetto in mano"
	_empty = Label.new()
	_empty.add_theme_color_override("font_color", MUTED)
	_empty.visible = false
	_list.add_child(_empty)
	_hint = _label(Vector2(18, 0), 12, MUTED)
	_hint.text = "Clic: crea · Maiusc+clic: crea 5 · passa sopra una ricetta per i dettagli"
	set_tall(true)
	# come la Bisaccia: a ogni cambio si segna soltanto, si rifà l'elenco una volta per fotogramma e solo se si vede
	bisaccia.changed.connect(func() -> void: _dirty = true)
	refresh()


func _label(pos: Vector2, fs: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	l.add_theme_constant_override("outline_size", 4)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


## L'intestazione di un gruppo: il nome della categoria nel suo colore, su una riga sottile dello stesso colore.
func _header(col: Color) -> Label:
	var h := Label.new()
	h.custom_minimum_size = Vector2(0, 26)
	h.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	h.add_theme_font_size_override("font_size", 14)
	h.add_theme_color_override("font_color", col)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color(col, 0.55)
	sb.border_width_bottom = 1
	sb.content_margin_left = 4
	sb.content_margin_bottom = 2
	h.add_theme_stylebox_override("normal", sb)
	h.visible = false
	_list.add_child(h)
	return h


## Alta tutta la destra dello schermo (normale) o bassa accanto alla Bisaccia (con una cassa aperta).
func set_tall(on: bool) -> void:
	if on:
		position = Vector2(_low.position.x, TOP_TALL)
		size = Vector2(W, _low.end.y - TOP_TALL)
	else:
		position = _low.position
		size = _low.size
	_frame.size = size
	_hint.position = Vector2(18, size.y - 24)
	_scroll.size = Vector2(W - 24, size.y - 168 - 30)


## Da ridisegnare (lo chiama anche `Storage` quando cambia una cassa vicina che dà gli ingredienti).
func mark_dirty() -> void:
	_dirty = true


## Quante righe si vedono nell'elenco (ricette e lavorazioni; per le prove).
func shown_rows() -> int:
	var n := 0
	for c in _list.get_children():
		if c is Button and (c as Control).visible and not c.is_queued_for_deletion():
			n += 1
	return n


## La ricerca ha il fuoco: i tasti del gioco (movimento, E, M…) non devono partire mentre si scrive.
func typing() -> bool:
	return _search != null and _search.has_focus()


func release_search() -> void:
	if _search:
		_search.release_focus()


func _style_chip(b: Button, col: Color) -> void:
	for st in ["normal", "hover", "pressed", "hover_pressed"]:
		var s := StyleBoxFlat.new()
		var on: bool = String(st).contains("pressed")
		s.bg_color = Color(0.02, 0.06, 0.07).lerp(col, 0.45 if on else (0.14 if st == "hover" else 0.06))
		s.border_color = col if on or st == "hover" else Color(col, 0.45)
		s.set_border_width_all(1)
		s.border_width_bottom = 3 if on else 1
		s.set_corner_radius_all(8)
		b.add_theme_stylebox_override(st, s)
	b.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.35))
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_color", Color.WHITE)


func _process(dt: float) -> void:
	if not is_visible_in_tree():
		# a Bisaccia chiusa si preparano le righe poco alla volta (~1 ms per riga): la prima apertura vicino a tutti i
		# banchi le costruiva tutte insieme, 200 ms di fermo
		var all := RecipesData.all()
		var made := 0
		while _warm < all.size() and made < WARM_PER_FRAME:
			var r: Dictionary = all[_warm]
			_warm += 1
			if not _rows.has(r):
				var row := _row(r)
				row.visible = false
				_rows[r] = row
				_list.add_child(row)
				made += 1
		return
	if _dirty:
		refresh()
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		var near: Dictionary = stations_near.call()
		var key := ",".join(near.keys())
		if key != _near_key:
			refresh()


## Una ricetta passa i filtri (categoria e ricerca)? La ricerca guarda il nome e gli ingredienti.
func _passes(r: Dictionary) -> bool:
	var out := String(r["out"])
	if cat > 0 and CraftCatsData.of(out) != cat - 1:
		return false
	var q := _search.text.strip_edges().to_lower() if _search else ""
	if q == "":
		return true
	if String(ItemsData.get_item(out).get("name", "")).to_lower().contains(q):
		return true
	for k in r["in"]:
		if String(ItemsData.get_item(k).get("name", "")).to_lower().contains(q):
			return true
	return false


func refresh() -> void:
	_dirty = false
	refreshes += 1
	if _list == null:
		return
	for k in _cat_buttons.size():
		_cat_buttons[k].button_pressed = k == cat
	var near: Dictionary = stations_near.call()
	var nk := ",".join(near.keys())
	if nk != _near_key or _benches.get_child_count() == 0:
		_show_benches(near)
	_near_key = nk
	for c in _special:
		c.queue_free()
	_special.clear()
	var all := Crafting.available(near)
	var recipes := all.filter(_passes)
	var have_n := Crafting.counts(bisaccia)
	var room := {}                                   # posto per ciò che nasce, uno per oggetto
	var can := {}
	for r in all:
		var out := String(r["out"])
		if not room.has(out):
			room[out] = bisaccia.room_for(out)
		var ok0 := int(room[out]) >= int(r["qty"])
		if ok0:
			for k in r["in"]:
				if int(have_n.get(k, 0)) < int(r["in"][k]):
					ok0 = false
					break
		can[r] = ok0
	# per categoria: prima le possibili, poi le altre
	var groups := []
	for c in CraftCatsData.CATS:
		groups.append([[], []])
	var possible := 0
	for r in recipes:
		var ok: bool = can[r]
		if ok:
			possible += 1
		elif only_possible:
			continue
		(groups[CraftCatsData.of(String(r["out"]))][0 if ok else 1] as Array).append(r)
	var total_ok := 0
	for r in all:
		if can[r]:
			total_ok += 1
	_count.text = "%d possibili su %d" % [total_ok, all.size()]
	_make_special(near)
	# l'ordine: le lavorazioni, poi i gruppi con la loro intestazione (in «Tutto»), poi il messaggio se è vuoto
	var order: Array[Control] = []
	_work_header.visible = not _special.is_empty()
	if not _special.is_empty():
		order.append(_work_header)
		for c in _special:
			_list.add_child(c)
			order.append(c)
	var shown := {}
	for g in groups.size():
		var ok_rows: Array = groups[g][0]
		var no_rows: Array = groups[g][1]
		var h := _headers[g]
		h.visible = cat == 0 and ok_rows.size() + no_rows.size() > 0
		if h.visible:
			h.text = "%s — %d possibili su %d" % [CraftCatsData.CATS[g][1], ok_rows.size(), ok_rows.size() + no_rows.size()] \
				if not only_possible else "%s — %d" % [CraftCatsData.CATS[g][1], ok_rows.size()]
			order.append(h)
		for k in ok_rows.size() + no_rows.size():
			var r: Dictionary = ok_rows[k] if k < ok_rows.size() else no_rows[k - ok_rows.size()]
			var row: RecipeRow = _rows.get(r)
			if row == null:
				row = _row(r)
				_rows[r] = row
				_list.add_child(row)
			row.refresh(k < ok_rows.size(), have_n)
			row.visible = true
			shown[row] = true
			order.append(row)
	if cat != 0:
		for h in _headers:
			h.visible = false
	for row in _rows.values():
		if not shown.has(row):
			row.visible = false
	for i in order.size():
		if order[i].get_index() != i:
			_list.move_child(order[i], i)
	_empty.visible = shown.is_empty() and _special.is_empty()
	if _empty.visible:
		_empty.text = "Nulla da creare qui: avvicinati a un banco." if _search.text == "" and cat == 0 and not only_possible \
			else ("Nessuna ricetta possibile con quello che hai." if only_possible else "Nessuna ricetta con questi filtri.")
	_list.move_child(_empty, _list.get_child_count() - 1)


## Le icone dei banchi vicini (con il nome nel suggerimento).
func _show_benches(near: Dictionary) -> void:
	for c in _benches.get_children():
		c.queue_free()
	if near.is_empty():
		var l := Label.new()
		l.text = "nessuno — solo ciò che si fa a mano"
		l.add_theme_font_size_override("font_size", 12)
		l.add_theme_color_override("font_color", MUTED)
		_benches.add_child(l)
		return
	for id in near:
		var sd: Dictionary = StationsData.STATIONS[id]
		var ic := TextureRect.new()
		var item := String(sd.get("item", ""))
		ic.texture = SlotView.icon(item if item != "" else id)
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(22, 22)
		ic.tooltip_text = String(sd["name"])
		_benches.add_child(ic)


## Le lavorazioni sull'oggetto in mano: al Maglio rinnovo del tratto, innesti e innesti da togliere; al Telaio le fasce.
func _make_special(near: Dictionary) -> void:
	if not held_slot.is_valid() or cat != 0:
		return
	var hs := int(held_slot.call())
	if near.has("maglio") and Bisaccia.is_gear(bisaccia.id_at(hs)):
		# (solo con un'arma o un'armatura in mano: senza, la riga era solo ingombro)
		_special.append(_reforge_row(hs))
		# innesti: una riga per ogni Essenza nella Bisaccia che va bene per l'oggetto in mano
		var seen := {}
		for s in bisaccia.slots:
			var e := String(s.get("id", ""))
			if e != "" and not seen.has(e) and String(ItemsData.get_item(e).get("kind", "")) == "essenza":
				seen[e] = true
				if TraitsData.can_graft(e, bisaccia.id_at(hs)):
					_special.append(_graft_row(hs, e))
		# voce 54: togliere un innesto
		for t in (bisaccia.slots[hs].get("dati", {}) as Dictionary).get("innesti", []):
			_special.append(_ungraft_row(hs, String(t)))
	# voce 50: al Telaio, le fasce per il manico dell'oggetto in mano
	if near.has("telaio") and String(ItemsData.get_item(bisaccia.id_at(hs)).get("form", "")) in FormsData.WRAPPABLE:
		for f in FormsData.FASCE:
			_special.append(_wrap_row(hs, f))


## La riga del Maglio: rinnova il tratto dell'oggetto in mano, per un po' di polvere di brace.
func _reforge_row(i: int) -> Button:
	var id := bisaccia.id_at(i)
	var cost := ""
	var can := id != "" and Bisaccia.is_gear(id)
	for k in TraitsData.REFORGE_COST:
		cost += "%d %s" % [TraitsData.REFORGE_COST[k], ItemsData.get_item(k)["name"]]
		can = can and Crafting.have(bisaccia, k) >= int(TraitsData.REFORGE_COST[k])
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
	var free := Gear.free_slots(bisaccia.slots[i])
	b.text = "Innesta: %s [%s] — %s" % [ItemsData.get_item(id)["name"], TraitsData.TRAITS[t]["name"],
		("posti liberi %d" % free) if free > 0 else "prende il posto del tratto"]
	b.tooltip_text = "%s: %s" % [ItemsData.get_item(essence)["name"], TraitsData.TRAITS[t]["desc"]]
	b.pressed.connect(func() -> void:
		if Crafting.graft(bisaccia, i, essence) != "":
			crafted.emit(id, 1)
			grafted.emit(id)
		refresh())
	return b


## La riga del Telaio: «Fascia di seta: Lancia di legnoferro (+8% velocità del colpo) — 3 Seta di radice».
func _wrap_row(i: int, fascia: String) -> Button:
	var fd: Dictionary = FormsData.FASCE[fascia]
	var can := Crafting.have(bisaccia, String(fd["item"])) >= int(fd["n"])
	var b := _plain_row(String(fd["item"]), can)
	b.text = "Fascia di %s: %s (%s)" % [fd["name"], ItemsData.get_item(bisaccia.id_at(i))["name"], fd["desc"]]
	b.tooltip_text = "Al Telaio di foglie: si avvolge sul manico, e prende il posto della fascia di prima.\nCosta %d %s." % [
		int(fd["n"]), ItemsData.get_item(String(fd["item"]))["name"]]
	b.pressed.connect(func() -> void:
		var id := bisaccia.id_at(i)
		if Crafting.wrap(bisaccia, i, fascia):
			crafted.emit(id, 1)
		refresh())
	return b


## La riga per togliere un innesto (voce 54): «Togli l'innesto Furia (5 Polvere di brace; l'Essenza si perde)».
func _ungraft_row(i: int, t: String) -> Button:
	var cost := ""
	var can := true
	for k in TraitsData.UNGRAFT_COST:
		cost += "%d %s" % [TraitsData.UNGRAFT_COST[k], ItemsData.get_item(k)["name"]]
		can = can and Crafting.have(bisaccia, k) >= int(TraitsData.UNGRAFT_COST[k])
	var b := _plain_row("maglio", can)
	b.text = "Togli l'innesto %s (%s; l'Essenza si perde)" % [TraitsData.TRAITS[t]["name"], cost]
	b.pressed.connect(func() -> void:
		var id := bisaccia.id_at(i)
		if Crafting.ungraft(bisaccia, i, t):
			crafted.emit(id, 1)
		refresh())
	return b


## Una riga semplice (icona e testo) nel colore delle lavorazioni.
func _plain_row(icon_id: String, can: bool) -> Button:
	var b := Button.new()
	b.icon = SlotView.icon(icon_id)
	b.expand_icon = true
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_constant_override("icon_max_width", 32)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.clip_text = true
	b.custom_minimum_size = Vector2(0, 44)
	b.add_theme_font_size_override("font_size", 14)
	RecipeRow.style(b, can, CraftCatsData.WORK)
	return b


## La riga di una ricetta: un clic fabbrica una volta, Maiusc+clic fino a cinque volte.
func _row(r: Dictionary) -> RecipeRow:
	var b := RecipeRow.new()
	b.setup(r, bisaccia)
	b.pressed.connect(func() -> void:
		var times := 5 if Input.is_key_pressed(KEY_SHIFT) else 1
		var made := 0
		for k in times:
			if not Crafting.craft(r, bisaccia, luck.call() if luck.is_valid() else 0.0):
				break
			made += 1
		if made > 0:
			crafted.emit(String(r["out"]), int(r["qty"]) * made))
	return b
