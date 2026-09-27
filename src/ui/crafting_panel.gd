class_name CraftingPanel
extends Control
## «Creare», con la Bisaccia aperta (riprogettato il 28 set 2026, richiesta dell'utente: «impaginazione nettamente
## migliore, con sfondo scuro, pratica, intuitiva e chiara»). Un riquadro scuro in alto a sinistra, sopra la Bisaccia:
##   in alto       titolo, quante ricette si possono fare, i banchi vicini (icona e nome)
##   a sinistra    le categorie in colonna, ognuna con il suo colore e «possibili / tutte»; in fondo le Lavorazioni
##                 del Maglio e del Telaio sull'oggetto in mano (se ce ne sono)
##   al centro     la ricerca (nome o ingrediente), «Solo possibili», «Anche i banchi lontani»; sotto la griglia delle
##                 ricette (`RecipeTile`), per categoria, prima quelle possibili
## Un clic sceglie la ricetta: la sua scheda (ingredienti, banco, quantità, «Crea») compare in Esamina, a destra.
## Doppio clic crea una volta, Maiusc+clic cinque. Con una cassa aperta il riquadro lascia il posto alla cassa.
## Le caselle si fanno una volta (poche per fotogramma a Bisaccia chiusa) e si riusano: il pannello decide solo quali si
## vedono e in che ordine (rifare centinaia di nodi a ogni raccolta costava 100 ms, 26 set 2026).

signal crafted(id: String, n: int)
signal grafted(id: String)
signal picked(r: Dictionary)           # la ricetta scelta (la mostra Esamina)
signal refreshed                       # l'elenco è stato rifatto (banchi vicini, conteggi)

const RECT := Rect2(12, 12, 1144, 556)
const SIDE_W := 196.0
const COLS := 14
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")
const MUTED := Color("#6a8a84")
const TEXT := Color("#dcefe8")
const BG := Color("#0a1211")
const WORK_CAT := 10                   # l'indice della categoria «Lavorazioni»
const WARM_PER_FRAME := 4
## Le categorie: «Tutto», quelle di `CraftCatsData`, «Lavorazioni».
static var CATS: Array = _tabs()

var bisaccia: Bisaccia
var stations_near: Callable            # () -> Dictionary delle stazioni a portata
var luck: Callable                     # () -> float: la fortuna alza la qualità dei pezzi fabbricati (voce 54)
var held_slot: Callable                # () -> casella dell'oggetto in mano (lavorazioni del Maglio e del Telaio)
var cat := 0
var only_possible := false
var all_benches := false               # mostra anche le ricette dei banchi lontani (per sapere cosa serve e dove)
var selected := {}
var refreshes := 0
var _search: LineEdit
var _only: CheckBox
var _all: CheckBox
var _count: Label
var _benches: HBoxContainer
var _cat_buttons: Array[Button] = []
var _scroll: ScrollContainer
var _content: VBoxContainer
var _sections: Array = []              # per categoria: [intestazione, griglia]
var _work_head: Label
var _work_box: VBoxContainer
var _empty: Label
var _tiles := {}                       # ricetta -> RecipeTile (si riusa)
var _dirty := false
var _near_key := ""
var _t := 0.0
var _warm := 0
var _can := {}                         # ricetta -> si può fare (dall'ultimo refresh)
var _near := {}


static func _tabs() -> Array:
	var out := [["Tutto", AMBER]]
	for c in CraftCatsData.CATS:
		out.append([c[1], c[2]])
	out.append(["Lavorazioni", CraftCatsData.WORK])
	return out


func setup(b: Bisaccia, near: Callable) -> void:
	bisaccia = b
	stations_near = near
	position = RECT.position
	size = RECT.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	var frame := Panel.new()
	frame.size = size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", panel_box(TEAL))
	add_child(frame)
	var title := _label(Vector2(20, 10), 24, AMBER)
	title.text = "Creare"
	_count = _label(Vector2(size.x - 330, 18), 14, TEXT)
	_count.size = Vector2(310, 20)
	_count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bl := _label(Vector2(SIDE_W + 16, 17), 13, MUTED)
	bl.text = "Banchi vicini:"
	_benches = HBoxContainer.new()
	_benches.position = Vector2(SIDE_W + 108, 10)
	_benches.add_theme_constant_override("separation", 8)
	add_child(_benches)
	# le categorie, in colonna
	var y := 56.0
	for k in CATS.size():
		var cb := Button.new()
		cb.toggle_mode = true
		cb.focus_mode = Control.FOCUS_NONE
		cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		cb.position = Vector2(12, y + (10.0 if k == WORK_CAT else 0.0))
		cb.size = Vector2(SIDE_W - 16, 38)
		cb.clip_text = true
		cb.add_theme_font_size_override("font_size", 14)
		_side_style(cb, CATS[k][1])
		cb.pressed.connect(func() -> void:
			cat = k
			_scroll.scroll_vertical = 0
			refresh())
		add_child(cb)
		_cat_buttons.append(cb)
		y += 42.0
	var sep := ColorRect.new()
	sep.color = Color(TEAL, 0.5)
	sep.position = Vector2(SIDE_W, 50)
	sep.size = Vector2(1, size.y - 62)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)
	# ricerca e filtri
	_search = LineEdit.new()
	_search.placeholder_text = "Cerca per nome o ingrediente…"
	_search.position = Vector2(SIDE_W + 16, 52)
	_search.size = Vector2(380, 34)
	_search.add_theme_font_size_override("font_size", 15)
	_search.clear_button_enabled = true
	_search.text_changed.connect(func(_t2: String) -> void: refresh())
	add_child(_search)
	_only = _check("Solo possibili", Vector2(SIDE_W + 412, 54), func(on: bool) -> void:
		only_possible = on
		refresh())
	_all = _check("Anche i banchi lontani", Vector2(SIDE_W + 560, 54), func(on: bool) -> void:
		all_benches = on
		refresh())
	_all.tooltip_text = "Mostra anche le ricette dei banchi che non hai vicino: per sapere che cosa serve e dove farle"
	# la griglia, per categoria
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(SIDE_W + 14, 96)
	_scroll.size = Vector2(size.x - SIDE_W - 24, size.y - 96 - 34)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_content = VBoxContainer.new()
	_content.custom_minimum_size = Vector2(_scroll.size.x - 16, 0)
	_content.add_theme_constant_override("separation", 6)
	_scroll.add_child(_content)
	_work_head = _head(CraftCatsData.WORK)
	_work_head.text = "Lavorazioni sull'oggetto in mano"
	_work_box = VBoxContainer.new()
	_work_box.add_theme_constant_override("separation", 4)
	_content.add_child(_work_box)
	for c in CraftCatsData.CATS:
		var h := _head(c[2])
		var g := GridContainer.new()
		g.columns = COLS
		g.add_theme_constant_override("h_separation", 5)
		g.add_theme_constant_override("v_separation", 5)
		_content.add_child(g)
		_sections.append([h, g])
	_empty = Label.new()
	_empty.add_theme_color_override("font_color", MUTED)
	_empty.add_theme_font_size_override("font_size", 15)
	_empty.visible = false
	_content.add_child(_empty)
	var hint := _label(Vector2(SIDE_W + 18, size.y - 28), 13, MUTED)
	hint.text = "Clic: scegli (la scheda è in Esamina, a destra) · doppio clic: crea · Maiusc+clic: crea 5 · passa sopra per i dettagli"
	bisaccia.changed.connect(func() -> void: _dirty = true)


## La cornice scura dei riquadri della Bisaccia aperta (Creare, Esamina, la scheda del Germogliato).
static func panel_box(border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = BG
	sb.border_color = border
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(14)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 6
	return sb


func _label(pos: Vector2, fs: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func _check(t: String, pos: Vector2, f: Callable) -> CheckBox:
	var c := CheckBox.new()
	c.text = t
	c.focus_mode = Control.FOCUS_NONE
	c.position = pos
	c.add_theme_font_size_override("font_size", 14)
	c.toggled.connect(f)
	add_child(c)
	return c


## L'intestazione di una categoria nella griglia: il nome nel suo colore, su una riga sottile dello stesso colore.
func _head(col: Color) -> Label:
	var h := Label.new()
	h.custom_minimum_size = Vector2(0, 28)
	h.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	h.add_theme_font_size_override("font_size", 15)
	h.add_theme_color_override("font_color", col)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color(col, 0.55)
	sb.border_width_bottom = 1
	sb.content_margin_left = 4
	sb.content_margin_bottom = 3
	h.add_theme_stylebox_override("normal", sb)
	h.visible = false
	_content.add_child(h)
	return h


## Il bottone di una categoria: striscia del colore a sinistra, fondo acceso quando è scelta.
func _side_style(b: Button, col: Color) -> void:
	for st in ["normal", "hover", "pressed", "hover_pressed"]:
		var s := StyleBoxFlat.new()
		var on: bool = String(st).contains("pressed")
		s.bg_color = BG.lerp(col, 0.34 if on else (0.12 if st == "hover" else 0.04))
		s.border_color = col
		s.border_width_left = 5
		s.set_corner_radius_all(6)
		s.content_margin_left = 14
		b.add_theme_stylebox_override(st, s)
	b.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.3))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)


## Con una cassa aperta il riquadro lascia il posto alla cassa (il nome viene dalla colonna alta di prima).
func set_tall(on: bool) -> void:
	visible = on


func mark_dirty() -> void:
	_dirty = true


func typing() -> bool:
	return _search != null and _search.has_focus()


func release_search() -> void:
	if _search:
		_search.release_focus()


## Quante ricette (e lavorazioni) si vedono (per le prove).
func shown_rows() -> int:
	var n := 0
	for t in _tiles.values():
		if (t as Control).visible:
			n += 1
	for c in _work_box.get_children():
		if (c as Control).visible and not c.is_queued_for_deletion():
			n += 1
	return n


## Le caselle ricetta che si vedono, nell'ordine della griglia (per le prove).
func shown_tiles() -> Array[RecipeTile]:
	var out: Array[RecipeTile] = []
	for s in _sections:
		for t in (s[1] as GridContainer).get_children():
			if (t as Control).visible:
				out.append(t as RecipeTile)
	return out


func _process(dt: float) -> void:
	if not is_visible_in_tree():
		# a Bisaccia chiusa si preparano le caselle poco alla volta: la prima apertura non deve costruirle tutte insieme
		var all := RecipesData.all()
		var made := 0
		while _warm < all.size() and made < WARM_PER_FRAME:
			var r: Dictionary = all[_warm]
			_warm += 1
			if not _tiles.has(r):
				_tile(r).visible = false
				made += 1
		return
	if _dirty:
		refresh()
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		var near: Dictionary = stations_near.call()
		if ",".join(near.keys()) != _near_key:
			refresh()


func _tile(r: Dictionary) -> RecipeTile:
	var t := RecipeTile.new()
	t.setup(r, bisaccia)
	t.chosen.connect(func(tile: RecipeTile) -> void: pick(tile.r))
	t.quick.connect(func(tile: RecipeTile, times: int) -> void:
		pick(tile.r)
		craft_times(tile.r, times))
	(_sections[CraftCatsData.of(String(r["out"]))][1] as GridContainer).add_child(t)
	_tiles[r] = t
	return t


## Una ricetta passa la ricerca? Guarda il nome e gli ingredienti.
func _passes(r: Dictionary) -> bool:
	var q := _search.text.strip_edges().to_lower() if _search else ""
	if q == "":
		return true
	if String(ItemsData.get_item(String(r["out"])).get("name", "")).to_lower().contains(q):
		return true
	for k in r["in"]:
		if String(ItemsData.get_item(k).get("name", "")).to_lower().contains(q):
			return true
	return false


func refresh() -> void:
	_dirty = false
	refreshes += 1
	if _content == null:
		return
	_near = stations_near.call()
	var nk := ",".join(_near.keys())
	if nk != _near_key or _benches.get_child_count() == 0:
		_show_benches(_near)
	_near_key = nk
	var here := Crafting.available(_near)
	var here_set := {}
	for r in here:
		here_set[r] = true
	var pool: Array = Crafting.available(StationsData.STATIONS) if all_benches else here
	var have_n := Crafting.counts(bisaccia)
	var room := {}
	_can.clear()
	for r in pool:
		var out := String(r["out"])
		if not room.has(out):
			room[out] = bisaccia.room_for(out)
		var ok := here_set.has(r) and int(room[out]) >= int(r["qty"])
		if ok:
			for k in r["in"]:
				if int(have_n.get(k, 0)) < int(r["in"][k]):
					ok = false
					break
		_can[r] = ok
	# per categoria (dopo la ricerca): prima le possibili, poi le altre
	var groups := []
	var totals := []
	for c in CraftCatsData.CATS:
		groups.append([[], []])
		totals.append([0, 0])
	var possible := 0
	for r in pool:
		var ok: bool = _can[r]
		if ok:
			possible += 1
		if not _passes(r):
			continue
		var g := CraftCatsData.of(String(r["out"]))
		totals[g][1] += 1
		if ok:
			totals[g][0] += 1
		elif only_possible:
			continue
		(groups[g][0 if ok else 1] as Array).append(r)
	_count.text = "%d possibili su %d%s" % [possible, here.size(), "  ·  %d in tutto" % pool.size() if all_benches else ""]
	# la colonna delle categorie
	var work: Array[Button] = []
	if held_slot.is_valid():
		work = CraftWork.rows(self, int(held_slot.call()), _near)
	for k in _cat_buttons.size():
		var b := _cat_buttons[k]
		b.button_pressed = k == cat
		if k == 0:
			b.text = "Tutto   %d" % possible
		elif k == WORK_CAT:
			b.text = "Lavorazioni   %d" % work.size()
			b.visible = not work.is_empty() or cat == WORK_CAT
		else:
			b.text = "%s   %d/%d" % [CATS[k][0], totals[k - 1][0], totals[k - 1][1]]
	# le lavorazioni (in «Tutto» e nella loro categoria)
	for c in _work_box.get_children():
		c.queue_free()
	var show_work := cat == 0 or cat == WORK_CAT
	for w in work:
		_work_box.add_child(w)
	_work_head.visible = show_work and not work.is_empty()
	_work_box.visible = show_work
	# la griglia
	var shown := {}
	for g in groups.size():
		var head: Label = _sections[g][0]
		var grid: GridContainer = _sections[g][1]
		var on := cat == 0 or cat == g + 1
		var ok_rows: Array = groups[g][0]
		var no_rows: Array = groups[g][1]
		var n := ok_rows.size() + no_rows.size()
		head.visible = on and n > 0
		grid.visible = on and n > 0
		if not head.visible:
			continue
		head.text = "%s — %d possibili su %d" % [CraftCatsData.CATS[g][1], ok_rows.size(), totals[g][1]]
		var i := 0
		for r in ok_rows + no_rows:
			var t: RecipeTile = _tiles.get(r)
			if t == null:
				t = _tile(r)
			t.refresh(_can[r], have_n)
			t.set_picked(r == selected)
			t.visible = true
			shown[t] = true
			if t.get_index() != i:
				grid.move_child(t, i)
			i += 1
	for t in _tiles.values():
		if not shown.has(t):
			t.visible = false
	_empty.visible = shown.is_empty() and not (_work_box.visible and not work.is_empty())
	if _empty.visible:
		_empty.text = "Nessuna ricetta possibile con quello che hai." if only_possible else (
			"Nessuna ricetta con questa ricerca." if _search.text.strip_edges() != "" else
			"Nulla da creare qui: avvicinati a un banco, o spunta «Anche i banchi lontani».")
	_content.move_child(_empty, _content.get_child_count() - 1)
	refreshed.emit()                             # la scheda in Esamina segue i numeri nuovi (senza cambiare ciò che mostra)


## I banchi vicini: icona e nome breve.
func _show_benches(near: Dictionary) -> void:
	for c in _benches.get_children():
		c.queue_free()
	if near.is_empty():
		var l := Label.new()
		l.text = "nessuno — solo ciò che si fa a mano"
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", MUTED)
		_benches.add_child(l)
		return
	for id in near:
		var sd: Dictionary = StationsData.STATIONS[id]
		var box := HBoxContainer.new()
		box.add_theme_constant_override("separation", 3)
		box.tooltip_text = String(sd["name"])
		var ic := TextureRect.new()
		var item := String(sd.get("item", ""))
		ic.texture = SlotView.icon(item if item != "" else id)
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(24, 24)
		box.add_child(ic)
		var l := Label.new()
		l.text = CraftCatsData.short_station(String(id))
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", TEXT)
		box.add_child(l)
		_benches.add_child(box)


## Sceglie una ricetta: si evidenzia e la sua scheda compare in Esamina.
func pick(r: Dictionary) -> void:
	if not selected.is_empty() and _tiles.has(selected):
		(_tiles[selected] as RecipeTile).set_picked(false)
	selected = r
	if _tiles.has(r):
		(_tiles[r] as RecipeTile).set_picked(true)
	picked.emit(r)


## Il banco della ricetta è vicino (o si fa a mano)?
func station_ok(r: Dictionary) -> bool:
	var st := String(r["station"])
	return st == "" or (stations_near.call() as Dictionary).has(st)


## Quante volte si può fare adesso (0 se manca il banco, gli ingredienti o il posto).
func times_possible(r: Dictionary) -> int:
	if not station_ok(r):
		return 0
	var n := 1 << 30
	for k in r["in"]:
		n = mini(n, Crafting.have(bisaccia, String(k)) / int(r["in"][k]))
	if Bisaccia.is_gear(String(r["out"])):
		var free := 0
		for s in bisaccia.slots:
			if s.is_empty():
				free += 1
		n = mini(n, free)
	else:
		n = mini(n, bisaccia.room_for(String(r["out"])) / maxi(int(r["qty"]), 1))
	return maxi(n, 0)


## Crea `times` volte (finché si può). Restituisce quante volte l'ha fatto.
func craft_times(r: Dictionary, times: int) -> int:
	if not station_ok(r):
		return 0
	var made := 0
	for k in times:
		if not Crafting.craft(r, bisaccia, luck.call() if luck.is_valid() else 0.0):
			break
		made += 1
	if made > 0:
		crafted.emit(String(r["out"]), int(r["qty"]) * made)
	return made
