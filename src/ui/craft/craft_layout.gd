class_name CraftLayout
extends RefCounted
## Come è fatto il pannello «Creare» (pulizia del 28 set 2026: crafting_panel.gd aveva passato le 500 righe): cornice,
## titolo, banchi vicini, le categorie in colonna, ricerca e filtri, la griglia per categoria e le Lavorazioni. Lo
## chiama `CraftingPanel.setup` una volta; tutto ciò che il pannello fa dopo (aggiornare, scegliere, creare) resta lì.


static func build(p: CraftingPanel) -> void:
	var frame := Panel.new()
	frame.size = p.size
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", p.panel_box(CraftingPanel.TEAL))
	p.add_child(frame)
	var title := _label(p, Vector2(20, 10), 24, CraftingPanel.AMBER)
	title.text = "Creare"
	UiFonts.set_role(title, "titolo", 25, CraftingPanel.AMBER)
	title.position.y = 8
	p._count = _label(p, Vector2(p.size.x - 330, 18), 14, CraftingPanel.TEXT)
	p._count.size = Vector2(310, 20)
	p._count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bl := _label(p, Vector2(CraftingPanel.SIDE_W + 16, 17), 13, CraftingPanel.MUTED)
	bl.text = "Banchi vicini:"
	p._benches = HBoxContainer.new()
	p._benches.position = Vector2(CraftingPanel.SIDE_W + 108, 10)
	p._benches.add_theme_constant_override("separation", 8)
	p.add_child(p._benches)
	# le categorie, in colonna, sotto i titoli dei loro gruppi (30 set 2026: quindici categorie invece di dieci)
	var y := 52.0
	var group := -1
	for k in CraftingPanel.CATS.size():
		var gi := int(CraftingPanel.CATS[k][2])
		if gi >= 0 and gi != group:
			group = gi
			var gl := _label(p, Vector2(16, y + 1), 11, UiPalette.TESTO_MUTO)
			gl.text = String(CraftCatsData.GROUPS[gi]).to_upper()
			y += 16.0
		if k == CraftingPanel.WORK_CAT:
			y += 6.0
		var cb := Button.new()
		cb.toggle_mode = true
		cb.focus_mode = Control.FOCUS_NONE
		cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		cb.position = Vector2(10, y)
		cb.size = Vector2(CraftingPanel.SIDE_W - 14, 23)
		cb.clip_text = true
		cb.add_theme_font_size_override("font_size", 15)
		_side_style(p, cb, CraftingPanel.CATS[k][1])
		var badge := Label.new()
		badge.name = "n"
		badge.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
		badge.offset_left = -44
		badge.offset_right = -10
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_theme_font_size_override("font_size", 15)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cb.add_child(badge)
		cb.pressed.connect(func() -> void:
			p.cat = k
			p.sub = ""
			p._scroll.scroll_vertical = 0
			p.refresh())
		p.add_child(cb)
		p._cat_buttons.append(cb)
		y += 25.0
	var sep := ColorRect.new()
	sep.color = Color(CraftingPanel.TEAL, 0.5)
	sep.position = Vector2(CraftingPanel.SIDE_W, 50)
	sep.size = Vector2(1, p.size.y - 62)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(sep)
	# ricerca e filtri
	p._search = LineEdit.new()
	p._search.placeholder_text = "Cerca per nome o ingrediente…"
	p._search.position = Vector2(CraftingPanel.SIDE_W + 16, 52)
	p._search.size = Vector2(380, 34)
	p._search.add_theme_font_size_override("font_size", 17)
	p._search.clear_button_enabled = true
	p._search.text_changed.connect(func(_t2: String) -> void: p.refresh())
	p.add_child(p._search)
	p._only = _check(p, "Solo possibili", Vector2(CraftingPanel.SIDE_W + 412, 54), func(on: bool) -> void:
		p.only_possible = on
		p.refresh())
	p._all = _check(p, "Anche i banchi lontani", Vector2(CraftingPanel.SIDE_W + 560, 54), func(on: bool) -> void:
		p.all_benches = on
		p.refresh())
	p._all.tooltip_text = "Mostra anche le ricette dei banchi che non hai vicino: per sapere che cosa serve e dove farle"
	# le sottocategorie della categoria scelta, in una fila di bottoni sopra la griglia (`chips`)
	p._chips = Control.new()
	p._chips.position = Vector2(CraftingPanel.SIDE_W + 16, 94)
	p._chips.size = Vector2(p.size.x - CraftingPanel.SIDE_W - 30, 0)
	p._chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(p._chips)
	# la griglia, per categoria
	p._scroll = ScrollContainer.new()
	p._scroll.position = Vector2(CraftingPanel.SIDE_W + 14, 96)
	p._scroll.size = Vector2(p.size.x - CraftingPanel.SIDE_W - 24, p.size.y - 96 - 34)
	p._scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	p.add_child(p._scroll)
	p._content = VBoxContainer.new()
	p._content.custom_minimum_size = Vector2(p._scroll.size.x - 16, 0)
	p._content.add_theme_constant_override("separation", 6)
	p._scroll.add_child(p._content)
	p._work_head = _head(p, CraftCatsData.WORK)
	p._work_head.text = "Lavorazioni sull'oggetto in mano"
	p._work_box = VBoxContainer.new()
	p._work_box.add_theme_constant_override("separation", 4)
	p._content.add_child(p._work_box)
	# una griglia per sottocategoria (`CraftCatsData.sections`), con la sua intestazione
	for s in CraftCatsData.sections():
		var h := _head(p, CraftCatsData.CATS[s[0]][2])
		var g := GridContainer.new()
		g.columns = CraftingPanel.COLS
		g.add_theme_constant_override("h_separation", 5)
		g.add_theme_constant_override("v_separation", 5)
		p._content.add_child(g)
		p._sec_index["%d|%s" % [s[0], s[1]]] = p._sections.size()
		p._sections.append([h, g, int(s[0]), String(s[1])])
	p._empty = Label.new()
	p._empty.add_theme_color_override("font_color", CraftingPanel.MUTED)
	p._empty.add_theme_font_size_override("font_size", 17)
	p._empty.visible = false
	p._content.add_child(p._empty)
	var hint := _label(p, Vector2(CraftingPanel.SIDE_W + 18, p.size.y - 28), 13, CraftingPanel.MUTED)
	hint.text = "Clic: scegli (la scheda è in Esamina, a destra) · doppio clic: crea · Maiusc+clic: crea 5 · passa sopra per i dettagli"
	p.bisaccia.changed.connect(func() -> void: p._dirty = true)


static func _label(p: CraftingPanel, pos: Vector2, fs: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(l)
	return l


static func _check(p: CraftingPanel, t: String, pos: Vector2, f: Callable) -> CheckBox:
	var c := CheckBox.new()
	c.text = t
	c.focus_mode = Control.FOCUS_NONE
	c.position = pos
	c.add_theme_font_size_override("font_size", 16)
	c.toggled.connect(f)
	p.add_child(c)
	return c


## L'intestazione di una categoria nella griglia: il nome nel suo colore, su una riga sottile dello stesso colore.
static func _head(p: CraftingPanel, col: Color) -> Label:
	var h := Label.new()
	h.custom_minimum_size = Vector2(0, 28)
	h.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	h.add_theme_font_size_override("font_size", 17)
	h.add_theme_color_override("font_color", col)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color(col, 0.55)
	sb.border_width_bottom = 1
	sb.content_margin_left = 4
	sb.content_margin_bottom = 3
	h.add_theme_stylebox_override("normal", sb)
	h.visible = false
	p._content.add_child(h)
	return h


## I bottoni delle sottocategorie: «Tutte» e una per sottocategoria (nome e quante se ne possono fare), a capo quando
## non ci stanno. Restituisce l'altezza della fila (0 se non ce n'è).
static func chips(p: CraftingPanel, list: Array, col: Color) -> float:
	for c in p._chips.get_children():
		p._chips.remove_child(c)
		c.queue_free()
	if list.size() < 2:
		return 0.0
	var x := 0.0
	var y := 0.0
	var w := p._chips.size.x
	for e in [["", -1]] + list:
		var name := String(e[0])
		var b := Button.new()
		b.toggle_mode = true
		b.focus_mode = Control.FOCUS_NONE
		b.text = ("Tutte" if name == "" else name) + ("" if int(e[1]) <= 0 else "  %d" % int(e[1]))   # quante se ne possono fare
		b.add_theme_font_size_override("font_size", 15)
		_compact(b, col)
		b.button_pressed = name == p.sub
		b.pressed.connect(func() -> void:
			p.sub = name
			p._scroll.scroll_vertical = 0
			p.refresh())
		var bw := b.get_combined_minimum_size().x
		if x > 0.0 and x + bw > w:
			x = 0.0
			y += 27.0
		b.position = Vector2(x, y)
		b.size = Vector2(bw, 24)
		p._chips.add_child(b)
		x += bw + 5.0
	return y + 27.0


## Un bottone basso (categorie, sottocategorie): le cornici con meno margine sopra e sotto, acceso quando è scelto.
static func _compact(b: Button, col: Color) -> void:
	var pad := Vector2(9, 1)
	var a := Color(col, 0.7)
	b.add_theme_stylebox_override("normal", UiFrames.padded("pulsante", "normale", a, pad))
	b.add_theme_stylebox_override("hover", UiFrames.padded("pulsante", "sopra", a, pad))
	b.add_theme_stylebox_override("pressed", UiFrames.padded("pulsante", "scelto", col, pad))
	b.add_theme_stylebox_override("hover_pressed", UiFrames.padded("pulsante", "scelto", col, pad))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.3))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)


## Il bottone di una categoria: striscia del colore a sinistra, fondo acceso quando è scelta.
static func _side_style(p: CraftingPanel, b: Button, col: Color) -> void:
	_compact(b, col)                            # la categoria scelta resta accesa (a interruttore: «pressed» = scelta)
