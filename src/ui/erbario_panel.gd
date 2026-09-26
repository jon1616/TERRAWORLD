class_name ErbarioPanel
extends Control
## L'Erbario aperto (tasto L): tre schede (Creature, Oggetti, Pagine di storia), una griglia di caselle — scoperte con
## l'icona, le altre con un punto di domanda — e a destra la scheda della voce scelta. In alto la percentuale.

const COLS := 10
const CELL := 56
const GAP := 6

var m: Node2D
var erbario: Erbario
var section := "creature"
var selected := ""
var _grid: Control
var _title: Label
var _detail: RichTextLabel
var _tabs: Array[Button] = []
var _creature_tex := {}


func setup(main: Node2D, e: Erbario) -> void:
	m = main
	erbario = e
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.03, 0.04)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = Label.new()
	_title.position = Vector2(120, 40)
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color("#8ef0d8"))
	add_child(_title)
	var x := 120.0
	for sec in [["creature", "Creature"], ["famiglie", "Famiglie"], ["oggetti", "Oggetti"], ["pagine", "Pagine di storia"]]:
		var b := Button.new()
		b.text = sec[1]
		b.position = Vector2(x, 96)
		b.size = Vector2(170, 34)
		_frame(b, Color("#2f7a70"))
		var id: String = sec[0]
		b.pressed.connect(func() -> void:
			section = id
			selected = ""
			_refresh())
		add_child(b)
		_tabs.append(b)
		x += 180.0
	_grid = Control.new()
	_grid.position = Vector2(120, 150)
	add_child(_grid)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(780, 150)
	_detail.size = Vector2(680, 640)
	_detail.add_theme_font_size_override("normal_font_size", 16)
	add_child(_detail)
	var hint := Label.new()
	hint.text = "L o Esc per chiudere · clic su una voce per leggerla"
	hint.position = Vector2(120, 850)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)


func toggle() -> void:
	visible = not visible
	if visible:
		_refresh()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode == KEY_L and not m.hud.panel.visible:
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			toggle()
			get_viewport().set_input_as_handled()


func _icon(id: String) -> Texture2D:
	if section == "famiglie":
		id = String(FamiliesData.FAMILIES[id]["members"][0])     # voce 61: la prima specie della famiglia
	match section:
		"famiglie":
			if not _creature_tex.has(id):
				var art0: Array = CreaturesData.CREATURES[id]["art"]
				_creature_tex[id] = ImageTexture.create_from_image(CreatureArt.frames(String(art0[0]), int(art0[1]))["frames"][0])
			return _creature_tex[id]
		"creature":
			if not _creature_tex.has(id):
				var art: Array = CreaturesData.CREATURES[id]["art"]
				var fr: Array = CreatureArt.frames(String(art[0]), int(art[1]))["frames"]
				_creature_tex[id] = ImageTexture.create_from_image(fr[0])
			return _creature_tex[id]
		"oggetti":
			return SlotView.icon(id)
	return SlotView.icon("seme_mondo") if section == "pagine" else null


## Cornice nello stile della Bisaccia (fondo scuro, bordo turchese, angoli tondi) per un bottone.
static func _frame(b: Button, border: Color) -> void:
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.03, 0.08, 0.09) if state != "hover" else Color(0.06, 0.14, 0.15)
		sb.border_color = border
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(10)
		sb.set_content_margin_all(6)
		b.add_theme_stylebox_override(state, sb)


## Il suggerimento di una cella (26 set 2026): la scheda di un oggetto come nelle caselle, di una creatura quante ne hai
## sconfitte; il resto nel riquadro accanto, al clic.
func _cell_tip(sec: String, id: String, known: bool) -> Variant:
	var c: TipCard
	if not known:
		c = TipCard.new()
		c.title("Non ancora scoperto", TipCard.DIM)
		c.hint("Clic: che cosa se ne sa")
		return c
	match sec:
		"oggetti":
			c = ItemTip.card({"id": id, "n": 1}, {"no_compare": true})
		"creature":
			c = TipCard.new()
			c.title(Erbario.title_of(sec, id), Color("#e4f6ee"), _icon(id))
			var fam := FamiliesData.family_of(id)
			if fam != "":
				c.sub("famiglia dei %s" % String(FamiliesData.FAMILIES[fam]["name"]).to_lower())
			c.line("Sconfitte: %d" % int((erbario.data.get("creature", {}) as Dictionary).get(id, 0)), TipCard.SOFT)
		_:
			c = TipCard.simple(Erbario.title_of(sec, id))
	if c != null:
		if not c.blocks.is_empty() and String(c.blocks[-1]["t"]) == "hint":
			c.blocks.pop_back()
		c.hint("Clic: la scheda completa accanto")
	return c


func _refresh() -> void:
	for k in _tabs.size():
		_frame(_tabs[k], Color("#ffb84a") if ["creature", "famiglie", "oggetti", "pagine"][k] == section else Color("#2f7a70"))
	_title.text = "Erbario — %d%% scoperto  (creature %d%% · famiglie %d%% · oggetti %d%% · pagine %d%%)" % [roundi(erbario.percent()),
		roundi(erbario.percent("creature")), roundi(erbario.percent("famiglie")), roundi(erbario.percent("oggetti")),
		roundi(erbario.percent("pagine"))]
	for c in _grid.get_children():
		c.queue_free()
	var list := Erbario.entries(section)
	for k in list.size():
		var id: String = list[k]
		var known := erbario.known(section, id)
		var cell := Button.new()
		cell.position = Vector2((k % COLS) * (CELL + GAP), (k / COLS) * (CELL + GAP))
		cell.size = Vector2(CELL, CELL)
		var sec := section
		Tips.attach(cell, func() -> Variant: return _cell_tip(sec, id, known))
		if known:
			cell.icon = _icon(id)
			cell.expand_icon = true
		else:
			cell.text = "?"
		_frame(cell, Color("#ffb84a") if id == selected else Color("#2f7a70"))
		cell.add_theme_font_size_override("font_size", 22)
		cell.modulate = Color.WHITE if known else Color(0.45, 0.5, 0.5)
		cell.pressed.connect(func() -> void:
			selected = id
			_refresh())
		_grid.add_child(cell)
	_show_detail()


func _show_detail() -> void:
	if selected == "":
		_detail.text = "[color=#6a8a84]Scegli una voce.[/color]"
		return
	if not erbario.known(section, selected):
		# voce 61: una famiglia mai incontrata dice dove cercarla
		_detail.text = BestiaryInfo.hint(selected) if section == "famiglie" else "[color=#6a8a84]Non l'hai ancora scoperta.[/color]"
		return
	var t := "[font_size=24][color=#ffd08a]%s[/color][/font_size]\n\n" % Erbario.title_of(section, selected)
	match section:
		"creature":
			var c: Dictionary = CreaturesData.CREATURES[selected]
			var where := []
			for s in c["strata"]:
				where.append(String(StrataData.STRATA[s]["name"]))
			t += "Vita %d · danno %d · difesa %d\n" % [int(c["hp"]), int(c["damage"]), int(c.get("defense", 0))]
			t += "Dove vive: %s%s\n" % [", ".join(where) if not where.is_empty() else "attorno al Cuore del mondo",
				" (solo di notte)" if c.get("night", false) else ""]
			t += "Sconfitte: %d" % int(erbario.data["creature"][selected])
			# voce 51: debolezze e resistenze scoperte colpendola
			var el: Dictionary = (m.character.erbario.get("elementi", {}) as Dictionary).get(selected, {})
			var weak := []
			var res := []
			for e in el:
				(weak if int(el[e]) > 0 else res).append(ElementsData.tag(String(e)))
			t += "\nDebole a: %s · Resiste a: %s" % [", ".join(weak) if not weak.is_empty() else "[color=#6a8a84]?[/color]",
				", ".join(res) if not res.is_empty() else "[color=#6a8a84]?[/color]"]
			t += BestiaryInfo.creature_extra(m.character, selected)     # voce 61
			var anc := int((erbario.data["antiche"] as Dictionary).get(selected, 0))
			if anc > 0:
				t += "
[color=#ffd08a]Antiche o ancestrali sconfitte: %d[/color]" % anc
		"oggetti":
			var it := ItemsData.get_item(selected)
			t += String(it.get("desc", "")) + "\n\n"
			for f in [["damage", "Danno"], ["defense", "Scorza"], ["power", "Forza"], ["heal", "Cura"]]:
				if it.has(f[0]):
					t += "%s %s\n" % [f[1], it[f[0]]]
		"pagine":
			t += String(LoreData.PAGES[selected]["text"])
		"famiglie":
			t += BestiaryInfo.family(m.character, selected) + "\n" + BestiaryInfo.coats_line(m.character)
	_detail.text = t
