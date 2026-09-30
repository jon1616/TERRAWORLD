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
	p._count = _label(p, Vector2(p.size.x - 330, 18), 14, CraftingPanel.TEXT)
	p._count.size = Vector2(310, 20)
	p._count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var bl := _label(p, Vector2(CraftingPanel.SIDE_W + 16, 17), 13, CraftingPanel.MUTED)
	bl.text = "Banchi vicini:"
	p._benches = HBoxContainer.new()
	p._benches.position = Vector2(CraftingPanel.SIDE_W + 108, 10)
	p._benches.add_theme_constant_override("separation", 8)
	p.add_child(p._benches)
	# le categorie, in colonna
	var y := 56.0
	for k in CraftingPanel.CATS.size():
		var cb := Button.new()
		cb.toggle_mode = true
		cb.focus_mode = Control.FOCUS_NONE
		cb.alignment = HORIZONTAL_ALIGNMENT_LEFT
		cb.position = Vector2(12, y + (10.0 if k == CraftingPanel.WORK_CAT else 0.0))
		cb.size = Vector2(CraftingPanel.SIDE_W - 16, 38)
		cb.clip_text = true
		cb.add_theme_font_size_override("font_size", 14)
		_side_style(p, cb, CraftingPanel.CATS[k][1])
		var badge := Label.new()
		badge.name = "n"
		badge.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
		badge.offset_left = -44
		badge.offset_right = -10
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_theme_font_size_override("font_size", 13)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cb.add_child(badge)
		cb.pressed.connect(func() -> void:
			p.cat = k
			p._scroll.scroll_vertical = 0
			p.refresh())
		p.add_child(cb)
		p._cat_buttons.append(cb)
		y += 42.0
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
	p._search.add_theme_font_size_override("font_size", 15)
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
	for c in CraftCatsData.CATS:
		var h := _head(p, c[2])
		var g := GridContainer.new()
		g.columns = CraftingPanel.COLS
		g.add_theme_constant_override("h_separation", 5)
		g.add_theme_constant_override("v_separation", 5)
		p._content.add_child(g)
		p._sections.append([h, g])
	p._empty = Label.new()
	p._empty.add_theme_color_override("font_color", CraftingPanel.MUTED)
	p._empty.add_theme_font_size_override("font_size", 15)
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
	c.add_theme_font_size_override("font_size", 14)
	c.toggled.connect(f)
	p.add_child(c)
	return c


## L'intestazione di una categoria nella griglia: il nome nel suo colore, su una riga sottile dello stesso colore.
static func _head(p: CraftingPanel, col: Color) -> Label:
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
	p._content.add_child(h)
	return h


## Il bottone di una categoria: striscia del colore a sinistra, fondo acceso quando è scelta.
static func _side_style(p: CraftingPanel, b: Button, col: Color) -> void:
	UiFrames.button(b, Color(col, 0.7))
	# la categoria scelta resta accesa (il bottone è a interruttore: «pressed» = scelta)
	b.add_theme_stylebox_override("pressed", UiFrames.box("pulsante", "scelto", col))
	b.add_theme_stylebox_override("hover_pressed", UiFrames.box("pulsante", "scelto", col))
	b.add_theme_color_override("font_color", col.lerp(Color.WHITE, 0.3))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
