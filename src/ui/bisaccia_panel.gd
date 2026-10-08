class_name BisacciaPanel
extends Control
## La Bisaccia aperta: le 30 caselle sopra la barra rapida. Un clic prende la pila (resta «in mano», segue il mouse),
## un altro clic la posa o la scambia; il clic destro prende metà pila.
## 28 set 2026 (richiesta dell'utente: Creare ed Esamina riprogettati, sfondo scuro): aperta, uno sfondo scuro copre il
## mondo e i riquadri sono opachi: in alto a sinistra «Creare» (`CraftingPanel`), a destra la colonna «Esamina»
## (`ExaminePanel`, con la scheda della ricetta scelta), in basso a sinistra la scheda del Germogliato
## (`CharacterCard`), in basso al centro l'equipaggiamento e la Bisaccia.

const COLS := 10
const ROWS := 3
const GAP := 6
## Voce 86: dove sta ogni posto dell'equipaggiamento [colonna, riga].
const EQUIP_POS := {"elmo": [0, 0], "corazza": [0, 1], "gambali": [0, 2], "stivali": [0, 3], "guanti": [1, 0],
	"mantello": [1, 1], "amuleto": [1, 2], "anello": [1, 3], "accessorio_1": [2, 0], "accessorio_2": [2, 1],
	"tasca_1": [2, 2], "tasca_2": [2, 3]}                                 # voce 296: le tasche alla cintura

var bisaccia: Bisaccia
var stations_near: Callable            # () -> stazioni a portata del giocatore, per la colonna «Creare»
var _dirty := false                    # la Bisaccia è cambiata da quando le caselle sono state disegnate
var crafting: CraftingPanel
var examine: ExaminePanel               # la colonna «Esamina» a destra
var card: CharacterCard                 # la scheda del Germogliato, in basso a sinistra
var _equip: Dictionary = {}            # posto -> SlotView
var _scorza: Label
var _sets: Label
var held := {}                        # pila «in mano» mentre la Bisaccia è aperta
## Maiusc+clic su una casella: se è aperta una cesta (`ChestPanel`), la pila ci va dentro subito.
var quick_target: Callable
## «Nelle casse vicine» (lo collega `main` a `Storage.quick_stack`): () -> {n, casse}.
var quick_stack: Callable
var mark_toggle: Callable              # (ricetta) -> bool: segna o toglie dalla lista della spesa (`Spesa`)
var mark_has: Callable                 # (ricetta) -> bool: è nella lista?
var pick_rule: Callable                # voce 297: (id) -> "" / "lascia" / "cestino" (`Backpack.rule`)
var pick_rule_next: Callable           # (id) -> il segno dopo
var _slots: Array[SlotView] = []
var _held_icon: SlotView
## Il cestino (28 set 2026, richiesta dell'utente): ciò che ci si butta resta lì finché non si butta altro (o si esce
## dal mondo), così un errore si ripara con un clic. Non si salva.
var trash := {}
var _trash_view: SlotView
var _toast: Callable = func(_t: String) -> void: pass
## Voce 295: ciò che la griglia mostra. La Bisaccia cresciuta si sfoglia a pagine di 30 caselle; le tasche (voce 296)
## e il basto (voce 299) sono altre schede. Ogni vista: {"t": scritta del bottone, "bag": Bisaccia, "from": prima
## casella, "tip": suggerimento, "icon": oggetto per l'icona}.
var _views: Array = []
var view := 0
var _tabs: Container
var _tabs_key := ""
## Roadmap 53: con gli scomparti le schede stanno in colonna a destra della griglia (una per scomparto, più la Raccolta,
## gli scomparti fissi e il basto); uno scomparto più grande di una pagina si sfoglia cliccando di nuovo la sua scheda o
## con la rotella sulla griglia. `use_item` (id) -> bool: il clic destro nella Raccolta legge o usa l'oggetto.
var page := 0
var use_item: Callable
var _where: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# lo sfondo scuro: il mondo resta dietro, appena visibile
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.015, 0.015, 0.92)   # (la fusione è lineare: 0,78 scuriva appena a metà)
	dim.position = Vector2(-400, -400)
	dim.size = Vector2(2400, 1700)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	var w := COLS * SlotView.SIZE + (COLS - 1) * GAP
	var x0 := (1600 - w) / 2.0
	var y0 := Hud.HOTBAR_Y - 16 - ROWS * (SlotView.SIZE + GAP)
	var frame := Panel.new()
	# (la stessa cornice serve anche alla colonna dell'equipaggiamento)
	frame.add_theme_stylebox_override("panel", UiFrames.box("forte"))
	frame.position = Vector2(x0 - 14, y0 - 44)
	frame.size = Vector2(w + 28, ROWS * (SlotView.SIZE + GAP) + 44 + 8 + SlotView.SIZE + 18)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	var title := Label.new()
	title.text = "Bisaccia"
	title.position = Vector2(x0, y0 - 38)
	UiFonts.set_role(title, "titolo", 26, Color("#ffb84a"))      # (Roadmap 55) il titolo in Alegreya
	add_child(title)
	# le schede: con gli scomparti (Roadmap 53) in colonna a destra della cornice; senza, accanto al titolo
	if bisaccia != null and not bisaccia.sections.is_empty():
		_tabs = VBoxContainer.new()
		_tabs.position = Vector2(frame.position.x + frame.size.x + 4, frame.position.y)
		_tabs.add_theme_constant_override("separation", 2)
	else:
		_tabs = HBoxContainer.new()
		_tabs.position = Vector2(x0 + 128, y0 - 38)
		_tabs.add_theme_constant_override("separation", 4)
	add_child(_tabs)
	# lo scomparto aperto, il suo riempimento e la pagina, accanto al titolo
	_where = Label.new()
	_where.position = Vector2(x0 + 128, y0 - 34)
	_where.add_theme_font_size_override("font_size", 16)
	_where.add_theme_color_override("font_color", Color("#e8d8b0"))
	_where.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_where.add_theme_constant_override("outline_size", 4)
	_where.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_where)
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
	# voce 86: dieci posti in tre colonne (armatura, vesti e gioielli, accessori)
	var ew := 3 * SlotView.SIZE + 2 * 12 + 24
	var ex := frame.position.x - 16 - ew + 12
	var eframe := Panel.new()
	eframe.add_theme_stylebox_override("panel", UiFrames.box("forte"))
	eframe.position = Vector2(ex - 12, frame.position.y)
	eframe.size = Vector2(ew, frame.size.y)
	eframe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(eframe)
	for k in Bisaccia.EQUIP_SLOTS.size():
		var slot: String = Bisaccia.EQUIP_SLOTS[k]
		var s := SlotView.new()
		var cr: Array = EQUIP_POS.get(slot, [0, 0])
		s.position = Vector2(ex + int(cr[0]) * (SlotView.SIZE + 12), frame.position.y + 40 + int(cr[1]) * (SlotView.SIZE + GAP))
		s.clicked.connect(func(_i: int, button: int) -> void:
			if button == MOUSE_BUTTON_LEFT:
				held = bisaccia.wear(slot, held)
				if Bisaccia.kind_of_slot(slot) == "tasca":
					view = 0                           # la scheda della tasca cambia: si torna alla Bisaccia
				_refresh())
		add_child(s)
		# vuota, la casella mostra la sagoma di ciò che ci va (voce 278: le scritte sotto uscivano dalla cornice)
		var kind := Bisaccia.kind_of_slot(slot)
		var ghost := {"accessorio": ["foglia", "Accessorio"], "tasca": ["sacca", "Tasca"]}.get(kind, [kind, slot.capitalize()]) as Array
		s.set_ghost(String(ghost[0]), String(ghost[1]))
		_equip[slot] = s
	_scorza = Label.new()
	_scorza.position = Vector2(ex - 6, frame.position.y + 10)
	_scorza.size = Vector2(ew - 12, 24)
	_scorza.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_scorza.add_theme_font_size_override("font_size", 18)
	_scorza.add_theme_color_override("font_color", Color("#ffb84a"))
	_scorza.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_scorza.add_theme_constant_override("outline_size", 5)
	_scorza.tooltip_text = "Scorza: toglie una parte di ogni ferita (10 di Scorza la dimezza, 30 ne toglie tre quarti)"
	add_child(_scorza)
	# voce 101: l'icona della Scorza accanto alla scritta
	var st := ArtLib.tex("interfaccia", "scorza")
	if st != null:
		var ic := TextureRect.new()
		ic.texture = st
		ic.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ic.position = Vector2(ex + 2, frame.position.y + 14)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(ic)
		# la scritta comincia dopo l'icona (29 set 2026: «Scorza 7 (−41% alle ferite)» finiva sotto l'icona)
		_scorza.position.x = ex + 22
		_scorza.size.x = ew - 40
		_scorza.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_scorza.add_theme_font_size_override("font_size", 16)
	# i set (voce 26): sotto gli accessori, quanti pezzi si indossano e, completo, il bonus
	_sets = Label.new()
	# (voce 296: sotto le quattro righe, dove prima stavano le tasche c'era questa scritta)
	_sets.position = Vector2(ex - 6, frame.position.y + 40 + 4 * (SlotView.SIZE + GAP) - 2)
	_sets.size = Vector2(ew - 12, 20)
	_sets.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sets.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sets.add_theme_font_size_override("font_size", 14)
	_sets.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	_sets.add_theme_constant_override("outline_size", 4)
	_sets.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_sets)
	# Riordina: in alto a destra nella cornice della Bisaccia
	var sort := Button.new()
	sort.text = "Riordina"
	sort.focus_mode = Control.FOCUS_NONE
	sort.position = Vector2(frame.position.x + frame.size.x - 90, frame.position.y + 8)
	sort.size = Vector2(76, 28)
	sort.add_theme_font_size_override("font_size", 14)
	sort.tooltip_text = "Mette in ordine lo scomparto aperto: per tipo e per nome, unendo le pile"
	sort.pressed.connect(sort_view)
	sort.tooltip_text += " (le caselle bloccate con Alt+clic restano dove sono)"
	add_child(sort)
	var qs := Button.new()
	qs.text = "Nelle casse"
	qs.focus_mode = Control.FOCUS_NONE
	qs.position = sort.position - Vector2(106, 0)
	qs.size = Vector2(100, 28)
	qs.add_theme_font_size_override("font_size", 14)
	qs.tooltip_text = "Ogni oggetto della Bisaccia (non la barra rapida) va nella cassa vicina che lo contiene già o che raccoglie il suo tipo"
	qs.pressed.connect(func() -> void:
		if quick_stack.is_valid():
			var r: Dictionary = quick_stack.call()
			_toast.call(Storage.stash_text(r)))
	add_child(qs)
	# le misure vere dei due pulsanti (la cornice ha i suoi margini): da destra, uno accanto all'altro
	sort.size.x = maxf(sort.size.x, sort.get_combined_minimum_size().x)
	sort.position.x = frame.position.x + frame.size.x - 14 - sort.size.x
	qs.size.x = maxf(qs.size.x, qs.get_combined_minimum_size().x)
	qs.position.x = sort.position.x - 6 - qs.size.x
	# il cestino: nella riga del titolo, a sinistra dei pulsanti
	_trash_view = SlotView.new()
	_trash_view.scale = Vector2(0.6, 0.6)
	_trash_view.position = Vector2(qs.position.x - 18 - SlotView.SIZE * 0.6, frame.position.y + 5)
	_trash_view.clicked.connect(func(_i: int, button: int) -> void:
		if button == MOUSE_BUTTON_LEFT:
			click_trash())
	add_child(_trash_view)
	# (voce 295: la scritta «Cestino» è diventata la sagoma della casella, per fare posto alle schede)
	_trash_view.set_ghost("cesta", "Cestino")
	_trash_view.tooltip_text = "Cestino: posa qui un oggetto per eliminarlo (clic con l'oggetto in mano, o Ctrl+clic su una casella). Finché non ci butti altro, un clic a mani vuote lo riprende."
	crafting = CraftingPanel.new()
	add_child(crafting)
	crafting.setup(bisaccia, stations_near)
	examine = ExaminePanel.new()
	add_child(examine)
	examine.setup(self, crafting)
	card = CharacterCard.new()
	add_child(card)
	card.setup(Rect2(12, frame.position.y, eframe.position.x - 24, frame.size.y), bisaccia)
	card.sheet = func() -> String: return String(examine.sheet.call()) if examine.sheet.is_valid() else ""
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
		(get_parent() as Hud).bring_panel_forward()
		_refresh()
		crafting.refresh()
		examine.refresh()
		card.refresh()
	else:
		crafting.release_search()
		(get_parent() as Hud).send_panel_back()
	if not visible:
		examine.give_back()
	if not visible and not held.is_empty():
		# richiudendo, ciò che è in mano torna nella Bisaccia
		bisaccia.add_stack(held)
		held = {}
		_refresh()


## La Bisaccia (o la tasca) che la griglia mostra adesso.
func bag() -> Bisaccia:
	if view < _views.size():
		return _views[view]["bag"]
	return bisaccia


func click_slot(i: int, button: int) -> void:
	var b := bag()
	if i >= b.slots.size():
		return
	if button == MOUSE_BUTTON_RIGHT and held.is_empty() and b == bisaccia.raccolta and not b.slots[i].is_empty() \
			and use_item.is_valid():
		use_item.call(b.id_at(i))                  # Roadmap 53: nella Raccolta il clic destro legge (tavolette, pagine)
		_refresh()
		return
	if button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_ALT) and held.is_empty() and b == bisaccia \
			and not b.slots[i].is_empty():
		# Alt+clic: blocca o sblocca la casella (Q, «Nelle casse», «Deposita», il Seme della Dispensa non la toccano)
		var on := b.toggle_lock(i)
		_toast.call("%s: %s" % [String(ItemsData.get_item(b.id_at(i)).get("name", b.id_at(i))),
			"bloccato, resta nella Bisaccia" if on else "sbloccato"])
	elif button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_CTRL) and held.is_empty() and not b.slots[i].is_empty():
		_to_trash(b.slots[i].duplicate(true))          # Ctrl+clic: la casella intera nel cestino
		b.slots[i] = {}
		b.changed.emit()
	elif button == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT) and quick_target.is_valid():
		quick_target.call(b, i)
	elif button == MOUSE_BUTTON_RIGHT and held.is_empty() and b.count_at(i) > 1:
		var half := b.count_at(i) / 2
		held = {"id": b.id_at(i), "n": half}
		b.slots[i]["n"] = b.count_at(i) - half
		b.changed.emit()
	elif button == MOUSE_BUTTON_LEFT:
		if not held.is_empty() and ((b.has_meta("accept") and not (b.get_meta("accept") as Callable).call(String(held["id"]))) \
				or (b.has_meta("accept_at") and not (b.get_meta("accept_at") as Callable).call(i, String(held["id"])))):
			_toast.call("Qui va solo ciò che è del suo tipo")   # voce 296: una tasca prende solo il suo tipo
		else:
			held = b.swap_with(i, held)
	_refresh()


## Roadmap 53: le viste degli scomparti, poi la Raccolta, gli scomparti fissi e il basto.
func _section_views() -> void:
	for s in bisaccia.sections:
		var sec := String(s[0])
		var a := int(s[1])
		var z := int(s[2])
		var used := 0
		for i in range(a, z):
			if not bisaccia.slots[i].is_empty():
				used += 1
		var inf := BagData.info(sec)
		_views.append({"t": "", "shape": inf[2], "bag": bisaccia, "from": a, "to": z, "sec": sec, "used": used,
			"ghost": String(inf[3]),
			"tip": "%s · %d caselle su %d%s" % [inf[1], used, z - a, " (clic di nuovo: pagina dopo)" if z - a > BagData.PAGE else ""]})
	var r := bisaccia.raccolta
	if r != null:
		var used2 := 0
		for st in r.slots:
			if not st.is_empty():
				used2 += 1
		_views.append({"t": "", "shape": BagData.RACCOLTA[2], "bag": r, "from": 0, "to": r.slots.size(), "sec": "raccolta",
			"used": used2, "tip": "Raccolta · %d: tavolette, pagine, cronache, ricordi, curiosità, fossili e reliquie. Non si riempie mai e resta addosso. Clic destro: leggi." % used2})
	for e in bisaccia.extra_views():
		var v: Dictionary = (e as Dictionary).duplicate()
		v["to"] = (v["bag"] as Bisaccia).slots.size()
		if String(v.get("t", "")) == "Scomparti":
			v["t"] = ""
			v["shape"] = ["freccia", "legno"]
		_views.append(v)


## Le viste della griglia: le pagine della Bisaccia, poi le tasche e il basto (`extra_views` della Bisaccia).
func _build_views() -> void:
	_views.clear()
	if not bisaccia.sections.is_empty():
		_section_views()
		_build_tabs()
		return
	var pages := ceili(float(bisaccia.slots.size() - Bisaccia.HOTBAR) / float(BackpackData.PAGE))
	for p in pages:
		_views.append({"t": str(p + 1) if pages > 1 else "Bisaccia", "bag": bisaccia, "from": Bisaccia.HOTBAR + p * BackpackData.PAGE,
			"tip": "Bisaccia, pagina %d di %d (%d caselle)" % [p + 1, pages, bisaccia.slots.size()]})
	for e in bisaccia.extra_views():
		_views.append(e)
	_build_tabs()


func _build_tabs() -> void:
	if view >= _views.size():
		view = 0
	var key := "%d|%d|%d|%s" % [view, page, _views.size(), ",".join(_views.map(func(v: Dictionary) -> String: return String(v.get("t", "")) + String(v.get("icon", "")) + str(v.get("used", ""))))]
	if key == _tabs_key:
		return
	_tabs_key = key
	for c in _tabs.get_children():
		_tabs.remove_child(c)
		c.queue_free()
	if _views.size() < 2:
		return
	for k in _views.size():
		var v: Dictionary = _views[k]
		var b := Button.new()
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(30, 28)
		b.text = String(v.get("t", ""))
		if v.has("shape"):
			# Roadmap 53: la scheda di uno scomparto (icona della sua forma) con il riempimento scritto piccolo sotto
			var sh: Array = v["shape"]
			var img0 := ItemIcons.make_ui(String(sh[0]), String(sh[1]))
			img0.resize(20, 20, Image.INTERPOLATE_LANCZOS)
			b.icon = ImageTexture.create_from_image(img0)
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.custom_minimum_size = Vector2(38, 22)
			b.text = ""                                 # (il riempimento sta accanto al titolo e nel suggerimento)
		elif String(v.get("icon", "")) != "":
			var img := ItemIcons.ui(String(v["icon"]))            # l'icona a 24 pixel: a 16 non si riconosceva
			img.resize(24, 24, Image.INTERPOLATE_LANCZOS)
			b.icon = ImageTexture.create_from_image(img)
			b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			b.custom_minimum_size = Vector2(44, 28)
		b.add_theme_font_size_override("font_size", 15)
		UiFrames.button(b, UiPalette.AMBRA, k == view)
		if not bisaccia.sections.is_empty():
			# Roadmap 53: le schede in colonna, piccole, tra la Bisaccia ed Esamina
			b.custom_minimum_size = Vector2(38, 22)
			b.expand_icon = true
			for st_name in ["normal", "hover", "pressed", "disabled", "focus", "hover_pressed"]:
				var sb := b.get_theme_stylebox(st_name)
				if sb != null:
					var sb2: StyleBox = sb.duplicate()
					sb2.content_margin_top = 2
					sb2.content_margin_bottom = 2
					sb2.content_margin_left = 6
					sb2.content_margin_right = 6
					b.add_theme_stylebox_override(st_name, sb2)
		b.button_pressed = k == view
		b.tooltip_text = String(v.get("tip", ""))
		b.pressed.connect(func() -> void:
			if view == k:
				# di nuovo la stessa scheda: la pagina dopo (uno scomparto più grande di una pagina)
				var span := int(_views[k].get("to", 0)) - int(_views[k].get("from", 0))
				page = (page + 1) % maxi(ceili(float(span) / float(BagData.PAGE)), 1)
			else:
				view = k
				page = 0
			_tabs_key = ""
			_refresh())
		_tabs.add_child(b)


## Un clic sul cestino: con una pila in mano la si butta; a mani vuote si riprende l'ultima buttata.
func click_trash() -> void:
	if not held.is_empty():
		_to_trash(held)
		held = {}
	elif not trash.is_empty():
		held = trash
		trash = {}
	_refresh()


func _to_trash(stack: Dictionary) -> void:
	trash = stack                                  # ciò che c'era prima sparisce davvero
	_toast.call("Nel cestino: %s ×%d · un clic sul cestino a mani vuote lo riprende" % [
		String(ItemsData.get_item(String(stack.get("id", ""))).get("name", stack.get("id", ""))), int(stack.get("n", 1))])


## Dopo che un altro pannello ha cambiato la pila in mano.
func refresh_held() -> void:
	_refresh()


func _refresh() -> void:
	_dirty = false
	_build_views()
	var b := bag()
	var from := int(_views[view]["from"]) if view < _views.size() else Bisaccia.HOTBAR
	var to := b.slots.size()
	if view < _views.size() and _views[view].has("to"):
		to = mini(int(_views[view]["to"]), b.slots.size())
		var span := to - from
		if page * BagData.PAGE >= span:
			page = 0
		from += page * BagData.PAGE
	_show_where(to)
	for k in _slots.size():
		var s := _slots[k]
		s.index = from + k
		s.visible = s.index < to
		if s.visible:
			s.set_item(b.id_at(s.index), b.count_at(s.index), b.trait_at(s.index), b.data_at(s.index))
			s.set_locked(b == bisaccia and b.locked(s.index))
			# gli scomparti mostrano la sagoma di ciò che ci va; le altre viste no
			var gh: Array = _views[view].get("ghosts", []) if view < _views.size() else []
			if s.index < gh.size():
				s.set_ghost(String(gh[s.index][0]), String(gh[s.index][1]))
			else:
				s.clear_ghost()
	for slot in _equip:
		var ev := _equip[slot] as SlotView
		ev.set_item(String(bisaccia.equip.get(slot, "")), 1, String(bisaccia.equip_traits.get(slot, "")),
			bisaccia.equip_data.get(slot, {}))
		ev.tip_extra = {"equipped": true}
	if _scorza:
		var done := SetsData.complete(bisaccia.equip)
		var extra_f := 0.0
		for s in done:
			extra_f += float((SetsData.all()[s]["bonus"] as Dictionary).get("defense", 0))
		for slot in bisaccia.equip:                    # voce 306: anche la Scorza del carattere e dei gioielli
			extra_f += float(ItemsData.get_item(String(bisaccia.equip[slot])).get("acc", {}).get("defense", 0.0))
		var extra := roundi(extra_f)
		var sc := bisaccia.scorza() + extra
		_scorza.text = ("Scorza %d · −%d%% ferite" % [sc, roundi(Vitals.scorza_share(sc) * 100.0)]) if sc > 0 else "Scorza 0"
		_show_sets(done)
	if _trash_view:
		_trash_view.set_item(String(trash.get("id", "")), int(trash.get("n", 0)), String(trash.get("tratto", "")),
			trash.get("dati", {}))
	_held_icon.visible = not held.is_empty()
	if not held.is_empty():
		_held_icon.set_item(held["id"], held["n"], String(held.get("tratto", "")), held.get("dati", {}))


## Roadmap 53: accanto al titolo, lo scomparto aperto, quanto è pieno e la pagina.
func _show_where(to: int) -> void:
	if _where == null:
		return
	if bisaccia.sections.is_empty() or view >= _views.size() or not _views[view].has("to"):
		_where.text = ""
		return
	var v: Dictionary = _views[view]
	var span := int(v["to"]) - int(v["from"])
	var pages := maxi(ceili(float(span) / float(BagData.PAGE)), 1)
	var sec := String(v.get("sec", ""))
	var name := BagData.name_of(sec) if sec != "" else String(v.get("tip", "")).get_slice(" ·", 0)
	_where.text = "%s · %s%s" % [name, ("%d/%d" % [int(v.get("used", 0)), span]) if sec != "raccolta" else str(int(v.get("used", 0))),
		("  · pagina %d/%d" % [page + 1, pages]) if pages > 1 else ""]


## Riordina lo scomparto aperto (o la Bisaccia intera, senza scomparti).
func sort_view() -> void:
	if bisaccia.sections.is_empty() or view >= _views.size():
		bisaccia.sort_bag()
		return
	var v: Dictionary = _views[view]
	var b: Bisaccia = v["bag"]
	if b == bisaccia:
		bisaccia._sort_range(int(v["from"]), int(v["to"]))
		bisaccia.changed.emit()
	elif b == bisaccia.raccolta:
		b.sort_bag(0)


## La rotella sulla griglia sfoglia le pagine dello scomparto aperto.
func _unhandled_input(e: InputEvent) -> void:
	if not visible or bisaccia.sections.is_empty() or not (e is InputEventMouseButton) or not e.pressed:
		return
	var mb := e as InputEventMouseButton
	if mb.button_index != MOUSE_BUTTON_WHEEL_UP and mb.button_index != MOUSE_BUTTON_WHEEL_DOWN:
		return
	if _slots.is_empty() or view >= _views.size():
		return
	var r := Rect2(_slots[0].position, _slots[_slots.size() - 1].position + Vector2(SlotView.SIZE, SlotView.SIZE) - _slots[0].position)
	if not r.has_point(get_viewport().get_mouse_position()):
		return
	var span := int(_views[view].get("to", 0)) - int(_views[view].get("from", 0))
	var pages := maxi(ceili(float(span) / float(BagData.PAGE)), 1)
	if pages > 1:
		page = posmod(page + (1 if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1), pages)
		_tabs_key = ""
		_refresh()
		get_viewport().set_input_as_handled()


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
