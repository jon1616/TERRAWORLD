class_name CraftingPanel
extends Control
## «Creare», con la Bisaccia aperta (riprogettato il 28 set 2026, richiesta dell'utente: «impaginazione nettamente
## migliore, con sfondo scuro, pratica, intuitiva e chiara»). Un riquadro scuro in alto a sinistra, sopra la Bisaccia:
##   in alto       titolo, quante ricette si possono fare, i banchi vicini (icona e nome)
##   a sinistra    le categorie in colonna, sotto i titoli dei quattro gruppi, ognuna con il suo colore e quante se
##                 ne possono fare; in fondo le Lavorazioni del Maglio e del Telaio sull'oggetto in mano (se ce ne sono)
##   al centro     la ricerca (nome o ingrediente), «Solo possibili», «Anche i banchi lontani»; i bottoni delle
##                 sottocategorie della categoria scelta (30 set 2026); sotto la griglia delle ricette (`RecipeTile`),
##                 una sezione per sottocategoria, prima quelle possibili
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
## L'indice della categoria «Lavorazioni»: dopo «Tutto» e quelle di `CraftCatsData` (si conta: una categoria nuova
## spostava il numero scritto a mano, Roadmap 19).
static var WORK_CAT: int = CraftCatsData.CATS.size() + 1
const WARM_PER_FRAME := 4
## Le categorie: «Tutto», quelle di `CraftCatsData`, «Lavorazioni».
static var CATS: Array = _tabs()

var bisaccia: Bisaccia
var stations_near: Callable            # () -> Dictionary delle stazioni a portata
var luck: Callable                     # () -> float: la fortuna alza la qualità dei pezzi fabbricati (voce 54)
var held_slot: Callable                # () -> casella dell'oggetto in mano (lavorazioni del Maglio e del Telaio)
var language: Language                 # Roadmap 17: le parole certe (le incisioni del Maglio); la collega `main`
var cat := 0
var sub := ""                          # la sottocategoria scelta ("" = tutte)
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
var _sections: Array = []              # per sottocategoria: [intestazione, griglia, categoria, nome]
var _sec_index := {}                   # "categoria|sottocategoria" -> indice in `_sections`
var _chips: Control                    # i bottoni delle sottocategorie
var _chips_key := ""
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
	var out := [["Tutto", AMBER, -1]]
	for c in CraftCatsData.CATS:
		out.append([c[1], c[2], c[3]])
	out.append(["Lavorazioni", CraftCatsData.WORK, -1])
	return out


func setup(b: Bisaccia, near: Callable) -> void:
	bisaccia = b
	stations_near = near
	position = RECT.position
	size = RECT.size
	mouse_filter = Control.MOUSE_FILTER_STOP
	CraftLayout.build(self)                  # i bottoni, le categorie, la ricerca e la griglia: `CraftLayout`


## La cornice scura dei riquadri della Bisaccia aperta (Creare, Esamina, la scheda del Germogliato).
static func panel_box(border: Color) -> StyleBox:
	return UiFrames.box("forte", "normale", Color(0, 0, 0, 0) if border == UiPalette.BORDO else border)


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
	(_sections[_section_of(r)][1] as GridContainer).add_child(t)
	_tiles[r] = t
	return t


func _section_of(r: Dictionary) -> int:
	return int(_sec_index["%d|%s" % [CraftCatsData.of(String(r["out"])), CraftCatsData.sub_of(r)]])


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
		var ok := here_set.has(r)
		if ok:
			for k in r["in"]:
				if int(have_n.get(k, 0)) < int(r["in"][k]):
					ok = false
					break
		if ok:
			# il posto nella Bisaccia solo per le ricette che si possono fare (è il conto più caro)
			var out := String(r["out"])
			if not room.has(out):
				room[out] = bisaccia.room_for(out)
			ok = int(room[out]) >= int(r["qty"])
		_can[r] = ok
	# per sottocategoria (dopo la ricerca): prima le possibili, poi le altre
	var groups := []
	var totals := []                              # per categoria: [possibili, tutte]
	var sec_n := []                               # per sottocategoria: [possibili, tutte]
	for c in CraftCatsData.CATS:
		totals.append([0, 0])
	for s in _sections:
		groups.append([[], []])
		sec_n.append([0, 0])
	var possible := 0
	for r in pool:
		var ok: bool = _can[r]
		if ok:
			possible += 1
		if not _passes(r):
			continue
		var g := CraftCatsData.of(String(r["out"]))
		var si := _section_of(r)
		totals[g][1] += 1
		sec_n[si][1] += 1
		if ok:
			totals[g][0] += 1
			sec_n[si][0] += 1
		elif only_possible:
			continue
		(groups[si][0 if ok else 1] as Array).append(r)
	_show_chips(sec_n)
	_count.text = "%d possibili su %d%s" % [possible, here.size(), "  ·  %d in tutto" % pool.size() if all_benches else ""]
	# la colonna delle categorie
	var work: Array[Button] = []
	if held_slot.is_valid():
		work = CraftWork.rows(self, int(held_slot.call()), _near)
	for k in _cat_buttons.size():
		var b := _cat_buttons[k]
		b.button_pressed = k == cat
		# il nome a sinistra, a destra quante ricette si possono fare adesso (voce 279: «nome  0/40» non ci stava)
		var n := possible if k == 0 else (work.size() if k == WORK_CAT else int(totals[k - 1][0]))
		b.text = "Tutto" if k == 0 else ("Lavorazioni" if k == WORK_CAT else String(CATS[k][0]))
		var badge := b.get_node("n") as Label
		badge.text = str(n)
		badge.add_theme_color_override("font_color", UiPalette.BUONO if n > 0 else UiPalette.TESTO_MUTO)
		if k == WORK_CAT:
			b.visible = not work.is_empty() or cat == WORK_CAT
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
		var k: int = _sections[g][2]
		var on: bool = (cat == 0 or cat == k + 1) and (sub == "" or sub == String(_sections[g][3]))
		var ok_rows: Array = groups[g][0]
		var no_rows: Array = groups[g][1]
		var n := ok_rows.size() + no_rows.size()
		head.visible = on and n > 0
		grid.visible = on and n > 0
		if not head.visible:
			continue
		# in «Tutto» anche il nome della categoria; se la sottocategoria è la categoria stessa, una volta sola
		var title := String(_sections[g][3])
		if cat == 0 and title != String(CraftCatsData.CATS[k][1]):
			title = "%s · %s" % [CraftCatsData.CATS[k][1], title]
		head.text = "%s — %d %s su %d" % [title, ok_rows.size(), "possibile" if ok_rows.size() == 1 else "possibili",
			int(sec_n[g][1])]
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


## I bottoni delle sottocategorie della categoria scelta (solo se sono almeno due), e la griglia subito sotto.
func _show_chips(sec_n: Array) -> void:
	var list := []
	if cat > 0 and cat != WORK_CAT:
		for g in _sections.size():
			if int(_sections[g][2]) == cat - 1 and int(sec_n[g][0 if only_possible else 1]) > 0:
				list.append([String(_sections[g][3]), int(sec_n[g][0])])
	var names := list.map(func(e: Array) -> String: return String(e[0]))
	if sub != "" and not sub in names:
		sub = ""                                 # (la ricerca o i filtri l'hanno svuotata)
	var key := "%d|%s|%s" % [cat, sub, str(list)]
	if key == _chips_key:
		return
	_chips_key = key
	var h := CraftLayout.chips(self, list, CATS[cat][1] if cat > 0 and cat < CATS.size() else AMBER)
	var top := 96.0 if h <= 0.0 else _chips.position.y + h + 4.0
	_scroll.position.y = top
	_scroll.size.y = size.y - top - 34.0


## I banchi vicini: solo le icone, il nome passandoci sopra (3 ott 2026, l'utente: con tanti banchi i nomi uscivano dal
## pannello e coprivano «possibili su…»). Se non entrano tutte prima di quella scritta, l'ultima casella è «+N» e il suo
## suggerimento elenca gli altri.
const BENCH_ICON := 26
const BENCH_GAP := 5

func _show_benches(near: Dictionary) -> void:
	for c in _benches.get_children():
		c.queue_free()
	_benches.add_theme_constant_override("separation", BENCH_GAP)
	if near.is_empty():
		var l := Label.new()
		l.text = "nessuno — solo ciò che si fa a mano"
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", MUTED)
		_benches.add_child(l)
		return
	# quante icone entrano tra «Banchi vicini:» e la scritta del conteggio (a destra)
	var room := _count.position.x - 12.0 - _benches.position.x
	var fit := maxi(int((room + BENCH_GAP) / float(BENCH_ICON + BENCH_GAP)), 1)
	var ids: Array = near.keys()
	var shown := ids.size() if ids.size() <= fit else fit - 1
	for i in shown:
		var id := String(ids[i])
		var sd: Dictionary = StationsData.STATIONS[id]
		var ic := TextureRect.new()
		var item := String(sd.get("item", ""))
		ic.texture = SlotView.icon(item if item != "" else id)
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(BENCH_ICON, BENCH_ICON)
		ic.mouse_filter = Control.MOUSE_FILTER_STOP
		ic.tooltip_text = String(sd["name"])
		_benches.add_child(ic)
	if shown < ids.size():
		var more := Label.new()
		more.text = "+%d" % (ids.size() - shown)
		more.custom_minimum_size = Vector2(BENCH_ICON, BENCH_ICON)
		more.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		more.add_theme_font_size_override("font_size", 13)
		more.add_theme_color_override("font_color", TEXT)
		more.mouse_filter = Control.MOUSE_FILTER_STOP
		var rest := PackedStringArray()
		for i in range(shown, ids.size()):
			rest.append(String(StationsData.STATIONS[String(ids[i])]["name"]))
		more.tooltip_text = "Anche: " + ", ".join(rest)
		_benches.add_child(more)


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
