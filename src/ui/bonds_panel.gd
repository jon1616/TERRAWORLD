class_name BondsPanel
extends UiPage
## I compagni (Roadmap 32, voce 316; tasto «compagni», Y; anche un clic sulla barra del compagno): la Sacca dei
## legami e la scheda di battaglia di ogni creatura. A sinistra i cinque posti della sacca e sotto la riserva (le altre
## creature della mandria); a destra la creatura scelta: livello ed esperienza, Vita, danno, difesa e velocità (con i
## Frutti), lo stile (le mosse della sua specie) e le mosse imparate con gli istinti, il ciondolo e i tratti,
## l'affiatamento con i suoi cinque gradi, l'atteggiamento, il dono. I comandi: in campo, richiama, nella sacca o al
## Giardino, l'atteggiamento, dimenticare una mossa (l'istinto torna nella Bisaccia), togliere il ciondolo.
## Nome, recinti, coppie e fiere restano nella Mandria (G).
## Roadmap 55 «Il volto chiaro»: sullo scheletro comune (`UiPage`); la scheda a destra impaginata da `UiDetail`.

const ROW := 86.0
const BOND := Color("#ffb070")

var LIST := Rect2()
var CARD := Rect2()
var sel := -1                           # uid della scheda scelta
var _rows: Control
var _reserve: VBoxContainer
var _body: UiDetail
var _body_scroll: ScrollContainer
var _pic: TextureRect
var _actions: HBoxContainer
var _stances: HBoxContainer
var _moves: HBoxContainer
var _sub: Label
var book := false                       # voce 317: il Libro dei legami al posto della scheda
var _book_btn: Button
var _grid: Control
var _book_head: Label
var _card_nodes: Array = []
const CELL := 52.0


func setup(main: Node2D, bag: BondBag) -> void:
	m = main
	key_action = "compagni"
	visible = false
	build_page("I compagni", "", ArtLib.tex("interfaccia", "pannello_mandria") if ArtLib.has("interfaccia", "pannello_mandria") else null, BOND)
	_sub = page_sub
	set_hints([[Keys.label("compagni"), "apri e chiudi"], [Keys.label("compagno"), "evoca o richiama"], [Keys.label("cambia_compagno"), "cambia"],
		["Clic", "sul compagno in campo: dagli un oggetto"], [Keys.label("mandria"), "nome, recinti, coppie"]])
	var br := body_rect()
	body.visible = false                     # (qui le parti stanno direttamente nel pannello)
	LIST = Rect2(br.position, Vector2(560, br.size.y))
	CARD = Rect2(br.position + Vector2(600, 0), Vector2(br.size.x - 600, br.size.y))
	var lb := Panel.new()
	lb.add_theme_stylebox_override("panel", UiFrames.box("sezione"))
	lb.position = LIST.position
	lb.size = LIST.size
	lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(lb)
	var lt := UiKit.caps("Nella Sacca dei legami", BOND)
	lt.position = Vector2(LIST.position.x + 18, LIST.position.y + 16)
	add_child(lt)
	_rows = Control.new()
	_rows.position = LIST.position + Vector2(18, 42)
	_rows.size = Vector2(LIST.size.x - 36, ROW * HerdData.FOLLOW_MAX)
	_rows.mouse_filter = Control.MOUSE_FILTER_STOP
	_rows.draw.connect(_draw_rows)
	_rows.gui_input.connect(_on_rows)
	add_child(_rows)
	var rt := UiKit.caps("Nel Giardino, nei recinti, di guardia", BOND)
	rt.position = Vector2(LIST.position.x + 18, _rows.position.y + _rows.size.y + 12)
	add_child(rt)
	var sc := ScrollContainer.new()
	sc.position = Vector2(LIST.position.x + 18, rt.position.y + 30)
	sc.size = Vector2(LIST.size.x - 36, LIST.end.y - rt.position.y - 44)
	add_child(sc)
	_reserve = VBoxContainer.new()
	_reserve.custom_minimum_size = Vector2(sc.size.x - 14, 0)
	_reserve.add_theme_constant_override("separation", 4)
	sc.add_child(_reserve)
	_pic = TextureRect.new()                 # (resta per chi lo cerca: il ritratto ora sta nel medaglione della scheda)
	_pic.visible = false
	add_child(_pic)
	_actions = _row(CARD.position + Vector2(0, 0))
	_body_scroll = ScrollContainer.new()
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body_scroll.position = CARD.position + Vector2(0, 52)
	_body_scroll.size = Vector2(CARD.size.x, CARD.size.y - 52 - 104)
	add_child(_body_scroll)
	var bpad := MarginContainer.new()
	bpad.add_theme_constant_override("margin_right", 22)
	bpad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.add_child(bpad)
	_body = UiDetail.new()
	bpad.add_child(_body)
	var sl := UiKit.caps("Atteggiamento")
	sl.position = CARD.position + Vector2(0, CARD.size.y - 92)
	add_child(sl)
	_stances = _row(CARD.position + Vector2(150, CARD.size.y - 100))
	var ml := UiKit.caps("Mosse imparate")
	ml.position = CARD.position + Vector2(0, CARD.size.y - 40)
	add_child(ml)
	_moves = _row(CARD.position + Vector2(150, CARD.size.y - 48))
	_card_nodes = [_actions, _body_scroll, _stances, _moves, sl, ml]
	# voce 317: il Libro dei legami
	_book_btn = Button.new()
	_book_btn.focus_mode = Control.FOCUS_NONE
	_book_btn.position = Vector2(CARD.end.x - 280, CARD.position.y)
	_book_btn.custom_minimum_size = Vector2(260, 36)
	_book_btn.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
	_book_btn.pressed.connect(func() -> void:
		book = not book
		mark_dirty())
	add_child(_book_btn)
	_book_head = _label("", CARD.position + Vector2(0, 4), UiPalette.AMBRA_CHIARA, UiPalette.GRANDE)
	_book_head.size = Vector2(CARD.size.x - 310, 52)
	_book_head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_grid = Control.new()
	_grid.position = CARD.position + Vector2(0, 66)
	_grid.size = Vector2(CARD.size.x, CARD.size.y - 70)
	_grid.mouse_filter = Control.MOUSE_FILTER_STOP
	_grid.draw.connect(_draw_book)
	add_child(_grid)
	Tips.attach(_grid, _book_tip)
	bag.changed.connect(func() -> void: mark_dirty())       # (in `setup` di `BondBag`: `m.bonds` non c'è ancora)
	m.herd.changed.connect(func() -> void: mark_dirty())


func _label(t: String, at: Vector2, col: Color, fs: int) -> Label:
	var l := Label.new()
	l.text = t
	l.position = at
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l


func _row(at: Vector2) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.position = at
	h.add_theme_constant_override("separation", 8)
	add_child(h)
	return h


func on_open() -> void:
	if sel < 0 or m.herd.rec_of(sel).is_empty():
		var f: Dictionary = m.bonds.field()
		var bag: Array = m.bonds.bag()
		sel = int(f["uid"]) if not f.is_empty() else (int(bag[0]["uid"]) if not bag.is_empty() else -1)


func can_open() -> bool:
	return not m.hud.is_open()


func refresh() -> void:
	_refresh()


func _on_rows(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var i := int(e.position.y / ROW)
		var bag: Array = m.bonds.bag()
		if i >= 0 and i < bag.size():
			sel = int(bag[i]["uid"])
			mark_dirty()
			_rows.accept_event()


func _draw_rows() -> void:
	var f: Font = UiFonts.get_font("forte")
	var fc: Font = UiFonts.get_font("chiaro")
	var fs := 18
	var fs1 := 14
	var bag: Array = m.bonds.bag()
	for i in HerdData.FOLLOW_MAX:
		var r := Rect2(0, i * ROW, _rows.size.x, ROW - 8)
		if i >= bag.size():
			_rows.draw_style_box(UiFrames.box("casella"), r)
			_rows.draw_string(f, r.position + Vector2(16, 44), "posto libero", HORIZONTAL_ALIGNMENT_LEFT, -1, fs1, UiPalette.TESTO_MUTO)
			continue
		var rec: Dictionary = bag[i]
		var on := bool(rec.get("campo", false))
		var ko := bool(rec.get("ko", false))
		var accent := UiPalette.AMBRA if int(rec["uid"]) == sel else Color(0, 0, 0, 0)
		_rows.draw_style_box(UiFrames.box("casella", "scelto" if int(rec["uid"]) == sel else "normale", accent), r)
		var pr := Rect2(r.position + Vector2(8, 8), Vector2(ROW - 24, ROW - 24))
		_pic_in(BondBar.portrait(rec), pr, 0.4 if ko else 1.0)
		var x := pr.end.x + 12
		_rows.draw_string(f, Vector2(x, r.position.y + 26), String(rec["nome"]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs, UiPalette.TESTO)
		var st := "KO · guarisce nel Giardino" if ko else ("in campo" if on else "pronto")
		var col := UiPalette.PERICOLO if ko else (UiPalette.AMBRA if on else UiPalette.BUONO)
		_rows.draw_string(f, Vector2(r.end.x - 12 - f.get_string_size(st, HORIZONTAL_ALIGNMENT_LEFT, -1, fs1).x, r.position.y + 24), st,
			HORIZONTAL_ALIGNMENT_LEFT, -1, fs1, col)
		var info := "%s · liv. %d · affiatamento %d" % [_species(rec), int(rec["lvl"]), BondsData.bond_grade(rec)]
		_rows.draw_string(fc, Vector2(x, r.position.y + 46), info, HORIZONTAL_ALIGNMENT_LEFT, r.end.x - x - 12, fs1, UiPalette.TESTO_SPENTO)
		var hp := _hp(rec)
		var bw := r.end.x - x - 12
		var tr := StyleBoxFlat.new()
		tr.bg_color = Color(0, 0, 0, 0.45)
		tr.set_corner_radius_all(4)
		tr.anti_aliasing = true
		_rows.draw_style_box(tr, Rect2(x, r.position.y + 56, bw, 8))
		if hp > 0.0:
			var fl := StyleBoxFlat.new()
			fl.bg_color = VitalsView.hp_color(hp)
			fl.set_corner_radius_all(4)
			fl.anti_aliasing = true
			_rows.draw_style_box(fl, Rect2(x, r.position.y + 56, maxf(bw * hp, 8.0), 8))


func _pic_in(tex: Texture2D, r: Rect2, alpha: float) -> void:
	var ts := tex.get_size()
	var k := floorf(minf(r.size.x / ts.x, r.size.y / ts.y))
	if k < 1.0:
		k = minf(r.size.x / ts.x, r.size.y / ts.y)
	var sz := ts * k
	_rows.draw_texture_rect(tex, Rect2(r.position + (r.size - sz) * 0.5, sz), false, Color(1, 1, 1, alpha))


func _hp(rec: Dictionary) -> float:
	var c: Creature = m.herd.beasts.get(int(rec["uid"]))
	if c != null and is_instance_valid(c):
		return clampf(float(c.hp) / float(maxi(c.hp_max, 1)), 0.0, 1.0)
	return 0.0 if bool(rec.get("ko", false)) else clampf(float(rec.get("vita", 1.0)), 0.0, 1.0)


static func _species(rec: Dictionary) -> String:
	return String(CreaturesData.get_data(String(rec["specie"])).get("name", rec["specie"]))


func _refresh() -> void:
	var bag: Array = m.bonds.bag()
	_sub.text = "Cinque con te, uno in campo: combatte con lo stile della sua specie, cresce con le battaglie e con ciò che trovi. Nella sacca %d su %d." % [
		bag.size(), HerdData.FOLLOW_MAX]
	_rows.queue_redraw()
	for c in _reserve.get_children():
		_reserve.remove_child(c)
		c.queue_free()
	var others: Array = m.herd.records().filter(func(r: Dictionary) -> bool: return String(r["stato"]) != "segue")
	if others.is_empty():
		var l := Label.new()
		l.text = "Nessuna: le creature che leghi quando la sacca è piena vanno a riposare nel Giardino."
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(_reserve.custom_minimum_size.x, 0)
		l.add_theme_color_override("font_color", UiPalette.TESTO_MUTO)
		_reserve.add_child(l)
	for r in others:
		var b := Button.new()
		b.text = "%s · %s · liv. %d · %s" % [r["nome"], _species(r), int(r["lvl"]), HerdInfo.STATES.get(String(r["stato"]), r["stato"])]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.icon = BondBar.portrait(r)
		b.expand_icon = false
		b.add_theme_constant_override("icon_max_width", 28)
		b.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		b.custom_minimum_size = Vector2(_reserve.custom_minimum_size.x, 36)
		UiFrames.button(b, UiPalette.AMBRA, int(r["uid"]) == sel)
		var uid := int(r["uid"])
		b.pressed.connect(func() -> void:
			sel = uid
			mark_dirty())
		_reserve.add_child(b)
	var bc: Array = m.bonds.book_count()
	_book_btn.text = ("Torna alla scheda" if book else "Libro dei legami %d/%d" % [bc[0], bc[1]])
	UiFrames.button(_book_btn, UiPalette.AMBRA, book)
	for n in _card_nodes:
		(n as CanvasItem).visible = not book
	_grid.visible = book
	_book_head.visible = book
	if book:
		_book_head.text = book_head()
		_grid.queue_redraw()
		return
	var rec: Dictionary = m.herd.rec_of(sel)
	_card(rec)


func _clear(box: HBoxContainer) -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


func _button(box: HBoxContainer, t: String, tip: String, act: Callable, chosen := false, disabled := false) -> Button:
	var b := Button.new()
	b.text = t
	b.focus_mode = Control.FOCUS_NONE
	b.disabled = disabled
	b.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
	UiFrames.button(b, UiPalette.AMBRA, chosen)
	if tip != "":
		Tips.attach(b, func() -> Variant: return TipCard.simple(tip))
	b.pressed.connect(func() -> void:
		act.call()
		mark_dirty())
	box.add_child(b)
	return b


## La scheda di battaglia della creatura scelta.
func _card(rec: Dictionary) -> void:
	_clear(_actions)
	_clear(_stances)
	_clear(_moves)
	_body.reset(BOND, _body_scroll.size.x - 40.0)
	if rec.is_empty():
		_body.empty(null, "La Sacca dei legami è vuota", "Lega una creatura (ogni creatura tranne i boss):",
			[["laccio_intrecciato", "Il Laccio su una creatura stremata."], ["gelatina", "Il cibo che le piace."],
			["vasetto", "Un uovo nell'Incubatrice."]])
		_body.note("Alcune vogliono il loro momento: le creature del Vuoto al buio, gli spiriti di notte, quelle di pietra il Sigillo del legame.")
		return
	var in_bag := String(rec["stato"]) == "segue"
	var on := bool(rec.get("campo", false))
	var ko := bool(rec.get("ko", false))
	var bb: BondBag = m.bonds
	if in_bag:
		if on:
			_button(_actions, "Richiama", "Torna nella sacca (la sua Vita resta com'è)", bb.recall)
		else:
			_button(_actions, "In campo", "Combatte accanto a te" if not ko else "È KO: guarisce solo nel Giardino",
				func() -> void:
					var why: String = bb.summon(rec)
					if why != "":
						m.hud.toast(why), false, ko)
		_button(_actions, "Al Giardino", "Lascia la sacca e va a riposare nel Giardino (fa posto a un'altra)",
			func() -> void: m.herd.set_state(rec, "riposo"))
	else:
		var full: bool = bb.bag().size() >= HerdData.FOLLOW_MAX
		_button(_actions, "Nella sacca", "La Sacca dei legami è piena" if full else "Viene con te nella Sacca dei legami",
			func() -> void:
				var why: String = m.herd.set_state(rec, "segue")
				if why != "":
					m.hud.toast(why), false, full)
	var cur := String(rec.get("indole", "protettivo"))
	for s in BondsData.STANCE_ORDER:
		var sd: Array = BondsData.STANCES[s]
		var key := String(s)
		_button(_stances, String(sd[0]), String(sd[1]), func() -> void: bb.set_stance(rec, key), key == cur)
	var known: Array = rec.get("istinti", [])
	var slots := BondsData.slots_at(int(rec["lvl"]))
	for b in known:
		var bid := String(b)
		_button(_moves, "Dimentica: %s" % _move_name(bid), "La mossa si dimentica e l'istinto torna nella Bisaccia",
			func() -> void: forget(rec, bid))
	if known.is_empty():
		var l := Label.new()
		l.text = "nessuna (posti: %d)" % slots
		l.add_theme_color_override("font_color", UiPalette.TESTO_MUTO)
		_moves.add_child(l)
	if String(rec.get("ciondolo", "")) != "":
		_button(_moves, "Togli il ciondolo", "Il ciondolo torna nella Bisaccia", func() -> void: take_charm(rec))
	_body.bbcode(sheet(rec), BondBar.portrait(rec))


## Il testo della scheda (BBCode).
func sheet(rec: Dictionary) -> String:
	var sp := String(rec["specie"])
	var st := Herd.stats_of(rec)
	var lvl := int(rec["lvl"])
	var pt := FamiliesData.parts(sp)
	var fam := Herd.family_of(rec)
	var t := "[font_size=24][color=#ffd08a]%s[/color][/font_size]  [color=#9fc8c0]%s[/color]\n" % [rec["nome"], _species(rec)]
	var tags := []
	var nat := BondsData.nature_of(sp)
	if nat != "":
		tags.append(String(BondsData.NATURE_TEXT[nat]).get_slice(":", 0))
	if String(pt[2]) != "":
		tags.append("elemento %s" % String(ElementsData.ELEMENTS[String(pt[2])]["name"]).to_lower())
	var an: Dictionary = rec.get("antico", {})
	if String(an.get("r", "")) != "":
		tags.append(String(AncientData.RARITIES[String(an["r"])]["label"]).to_lower())
	if not tags.is_empty():
		t += "[color=#6a8a84]%s[/color]\n" % " · ".join(tags)
	var need := HerdData.xp_for(lvl)
	t += "\n[b]Livello %d[/b]%s\n" % [lvl, "" if lvl >= HerdData.LVL_MAX else "  [color=#8ef0d8]esperienza %d / %d[/color]" % [int(rec["xp"]), need]]
	var fr: Dictionary = rec.get("frutti", {})
	t += "Vita [b]%d[/b] · danno [b]%d[/b] · difesa [b]%d[/b] · velocità [b]%d[/b]\n" % [st["hp"], st["damage"], st["defense"], roundi(float(st["speed"]))]
	var fl := []
	for id in BondsData.FRUITS:
		var k := String(BondsData.FRUITS[id][0])
		fl.append("%s %d/%d" % [String(BondsData.FRUITS[id][1]).to_lower(), int(fr.get(k, 0)), BondsData.FRUIT_MAX])
	t += "[color=#6a8a84]Frutti: %s[/color]\n" % ", ".join(fl)
	var style := []
	for b in BondsData.style_of(sp):
		style.append(_move_name(String(b)))
	t += "\n[b]Stile[/b]: %s\n" % ", ".join(style)
	var known: Array = rec.get("istinti", [])
	var slots := BondsData.slots_at(lvl)
	var nx := ""
	for l in BondsData.SLOT_LVLS:
		if lvl < int(l) and nx == "":
			nx = " (il prossimo al livello %d)" % int(l)
	t += "[b]Mosse imparate[/b] %d su %d posti%s%s\n" % [known.size(), slots, nx,
		(": " + ", ".join(known.map(func(b: String) -> String: return _move_name(b)))) if not known.is_empty() else ""]
	var cd := String(rec.get("ciondolo", ""))
	t += "[b]Ciondolo[/b]: %s\n" % ("%s (%s)" % [BondsData.CIONDOLI[cd][0], BondsData.CIONDOLI[cd][2]] if cd != "" else "nessuno")
	var trs := []
	for tr in an.get("t", []):
		trs.append("%s (%s)" % [AncientData.TRAITS[tr]["name"], AncientData.TRAITS[tr]["desc"]])
	if not trs.is_empty():
		t += "[b]Tratti[/b]: %s\n" % ", ".join(trs)
	var aid: Array = BondsData.aid_of(fam)
	t += "[b]Il suo dono[/b] (solo in campo): %s\n" % aid[1]
	var g := BondsData.bond_grade(rec)
	var p := float(rec.get("legame", 0.0))
	var nxt := "" if g >= BondsData.BOND_GRADES.size() else " — %d punti su %d per il grado %d" % [int(p), int(BondsData.BOND_GRADES[g]), g + 1]
	t += "\n[b]Affiatamento: grado %d[/b][color=#6a8a84]%s (cresce combattendo insieme e stando in campo)[/color]\n" % [g, nxt]
	for k in BondsData.BOND_TEXT.size():
		t += "%s [color=%s]%d · %s[/color]\n" % ["✓" if k < g else "·", "#9ff0b8" if k < g else "#6a8a84", k + 1, BondsData.BOND_TEXT[k]]
	return t


static func _move_name(b: String) -> String:
	if BondsData.ISTINTI.has(b):
		return String(BondsData.ISTINTI[b][1])
	return String(BondsData.MOVE_NAMES.get(b, b))


## Dimentica una mossa: l'istinto torna nella Bisaccia.
func forget(rec: Dictionary, b: String) -> void:
	var known: Array = rec.get("istinti", [])
	known.erase(b)
	rec["istinti"] = known
	m.character.bisaccia.add("istinto_" + b, 1)
	m.herd.refresh(rec, true)
	m.hud.toast("%s dimentica: %s (l'istinto torna nella Bisaccia)" % [rec["nome"], _move_name(b)])


func take_charm(rec: Dictionary) -> void:
	var cd := String(rec.get("ciondolo", ""))
	if cd == "":
		return
	rec.erase("ciondolo")
	m.character.bisaccia.add(cd, 1)
	m.herd.refresh(rec)


# ---- voce 317: il Libro dei legami ---------------------------------------------------------------------------------

## La riga in cima al Libro: quante specie, il prossimo traguardo e il suo dono.
func book_head() -> String:
	var bc: Array = m.bonds.book_count()
	var t := "Specie legate: %d su %d." % [bc[0], bc[1]]
	for g in BondsData.BOOK_GOALS:
		if int(bc[0]) < int(g[0]):
			var what := []
			for id in g[1]:
				what.append("%s ×%d" % [ItemsData.get_item(String(id)).get("name", id), int(g[1][id])])
			t += " Al traguardo di %d: %s." % [int(g[0]), ", ".join(what)]
			break
	return t


func _cell_of(p: Vector2) -> int:
	var cols := floori(_grid.size.x / CELL)
	var i := floori(p.y / CELL) * cols + floori(p.x / CELL)
	return i if p.x >= 0.0 and p.x < cols * CELL and i < BondsData.all_species().size() else -1


func _draw_book() -> void:
	var all := BondsData.all_species()
	var cols := floori(_grid.size.x / CELL)
	var seen: Dictionary = m.character.erbario.get("creature", {})
	var f: Font = UiFonts.get_font("nome")
	for i in all.size():
		var sp := String(all[i])
		var r := Rect2(Vector2((i % cols) * CELL, (i / cols) * CELL), Vector2(CELL - 6, CELL - 6))
		var got := int(m.character.stats.get("legata_" + sp, 0)) >= 1
		_grid.draw_style_box(UiFrames.box("casella", "scelto" if got else "normale"), r)
		if got or seen.has(sp):
			var tex := BondBar.portrait({"specie": sp})
			var ts := tex.get_size()
			var k := minf((r.size.x - 8) / ts.x, (r.size.y - 8) / ts.y)
			if k >= 1.0:
				k = floorf(k)
			var sz := ts * k
			_grid.draw_texture_rect(tex, Rect2(r.position + (r.size - sz) * 0.5, sz), false,
				Color(1, 1, 1, 1) if got else Color(0.05, 0.08, 0.08, 0.85))
		else:
			_grid.draw_string(f, r.position + Vector2(r.size.x * 0.5 - 4, r.size.y * 0.5 + 6), "?", HORIZONTAL_ALIGNMENT_LEFT, -1,
				20, UiPalette.TESTO_MUTO)


func _book_tip() -> Variant:
	var i := _cell_of(_grid.get_local_mouse_position())
	if i < 0:
		return null
	var sp := String(BondsData.all_species()[i])
	var got := int(m.character.stats.get("legata_" + sp, 0)) >= 1
	var seen: bool = (m.character.erbario.get("creature", {}) as Dictionary).has(sp)
	if not got and not seen:
		return TipCard.simple("Una specie che non hai ancora incontrato")
	var nat := BondsData.nature_of(sp)
	var how := String(BondsData.NATURE_TEXT[nat]) if nat != "" else "con il Laccio quando è stremata, o con il suo cibo"
	return TipCard.simple("%s — %s · %s" % [CreaturesData.get_data(sp).get("name", sp), "legata" if got else "non ancora legata", how])

