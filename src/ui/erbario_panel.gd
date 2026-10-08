class_name ErbarioPanel
extends UiPage
## L'Erbario aperto (tasto L; rifatto nella Roadmap 55 «Il volto chiaro»): cinque schede (Creature, Famiglie, Oggetti,
## Pagine di storia, Pesci), a sinistra la collezione come griglia di caselle — scoperte con l'icona, le altre spente con
## il punto di domanda — e a destra la scheda della voce scelta. Nell'intestazione le percentuali.

const COLS := 10
const CELL := 60
const GAP := 6
const SECTIONS := [["creature", "Creature"], ["famiglie", "Famiglie"], ["oggetti", "Oggetti"], ["pagine", "Pagine di storia"],
	["pesci", "Pesci"]]
const LEAF := Color("#9ff0a0")

var erbario: Erbario
var section := "creature"
var selected := ""
var _grid: Control
var _title: Label
var _scroll: ScrollContainer           # la griglia scorre: le voci sono centinaia (voce 281: uscivano dallo schermo)
var _creature_tex := {}


func setup(main: Node2D, e: Erbario) -> void:
	m = main
	erbario = e
	key_action = "erbario"
	visible = false
	build_page("L'Erbario", "Tutto ciò che hai scoperto: le creature sconfitte, le famiglie, gli oggetti, le pagine di storia, i pesci.",
		ArtLib.tex("interfaccia", "pannello_erbario") if ArtLib.has("interfaccia", "pannello_erbario") else null, LEAF)
	_title = page_title
	set_tabs(SECTIONS.map(func(t: Array) -> String: return String(t[1])), 0)
	tab_changed.connect(func(i: int) -> void:
		section = String(SECTIONS[i][0])
		selected = ""
		_refresh())
	set_hints([[Keys.label("erbario"), "apri e chiudi"], ["Clic", "leggi una voce"], ["Mouse", "sopra una casella: la scheda breve"]])
	var gw := COLS * (CELL + GAP) - GAP + 34.0
	var left := Panel.new()
	left.add_theme_stylebox_override("panel", UiFrames.box("sezione"))
	left.size = Vector2(gw, body.size.y)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(left)
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(14, 14)
	_scroll.size = left.size - Vector2(20, 28)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(_scroll)
	_grid = Control.new()
	_scroll.add_child(_grid)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.position = Vector2(gw + 36.0, 0)
	_detail_scroll.size = Vector2(body.size.x - gw - 36.0, body.size.y)
	body.add_child(_detail_scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 22)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(pad)
	detail = UiDetail.new()
	pad.add_child(detail)


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func refresh() -> void:
	_refresh()


func _icon(id: String) -> Texture2D:
	if section == "famiglie":
		id = String(FamiliesData.FAMILIES[id]["members"][0])     # voce 61: la prima specie della famiglia
	match section:
		"famiglie":
			if not _creature_tex.has(id):
				_creature_tex[id] = ImageTexture.create_from_image(CreatureArt.of_creature(id)["frames"][0])
			return _creature_tex[id]
		"creature":
			if not _creature_tex.has(id):
				# com'è nel gioco: il disegno suo (i capi) o i colori e la misura della variante
				_creature_tex[id] = ImageTexture.create_from_image(CreatureArt.of_creature(id)["frames"][0])
			return _creature_tex[id]
		"oggetti", "pesci":
			return SlotView.icon(id)
	return SlotView.icon("seme_mondo") if section == "pagine" else null


## Cornice nello stile della Bisaccia (fondo scuro, bordo turchese, angoli tondi) per un bottone.
static func _frame(b: Button, border: Color) -> void:
	var ac := Color(0, 0, 0, 0) if border == UiPalette.BORDO else border
	for state in ["normal", "hover", "pressed"]:
		var st := {"normal": "normale", "hover": "sopra", "pressed": "premuto"}[state] as String
		b.add_theme_stylebox_override(state, UiFrames.padded("pulsante", st, ac, Vector2(6, 6)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


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
	for i in SECTIONS.size():
		if String(SECTIONS[i][0]) == section:
			select_tab(i)
	var fish := (erbario.data.get("pesci", {}) as Dictionary).size()
	set_chips([["%d%% scoperto" % roundi(erbario.percent()), LEAF], ["creature %d%%" % roundi(erbario.percent("creature"))],
		["famiglie %d%%" % roundi(erbario.percent("famiglie"))], ["oggetti %d%%" % roundi(erbario.percent("oggetti"))],
		["pesci %d/%d" % [fish, FishData.all().size()]]])
	UiKit.clear(_grid)
	var list := Erbario.entries(section)
	for k in list.size():
		var id: String = list[k]
		var known := erbario.known(section, id)
		var cell := Button.new()
		cell.position = Vector2((k % COLS) * (CELL + GAP), (k / COLS) * (CELL + GAP))
		cell.size = Vector2(CELL, CELL)
		cell.focus_mode = Control.FOCUS_NONE
		var sec := section
		Tips.attach(cell, func() -> Variant: return _cell_tip(sec, id, known))
		if known:
			cell.icon = _icon(id)
			cell.expand_icon = true
			cell.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST if cell.icon != null and cell.icon.get_width() <= 24 \
				else CanvasItem.TEXTURE_FILTER_LINEAR
		else:
			cell.text = "?"
			cell.add_theme_color_override("font_color", UiPalette.TESTO_MUTO)
		var st := "scelto" if id == selected else "normale"
		for s in ["normal", "hover", "pressed", "hover_pressed"]:
			cell.add_theme_stylebox_override(s, UiFrames.padded("casella", st if s == "normal" else ("scelto" if id == selected else "sopra"),
				Color(LEAF, 0.35) if known else Color(0, 0, 0, 0), Vector2(6, 6)))
		cell.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		cell.add_theme_font_override("font", UiFonts.get_font("nome"))
		cell.add_theme_font_size_override("font_size", 24)
		cell.modulate = Color.WHITE if known else Color(0.75, 0.8, 0.8)
		cell.pressed.connect(func() -> void:
			selected = id
			detail_top()
			_refresh())
		_grid.add_child(cell)
	var rows := ceili(list.size() / float(COLS))
	_grid.custom_minimum_size = Vector2(COLS * (CELL + GAP) - GAP, maxi(rows, 1) * (CELL + GAP) - GAP)
	_show_detail()


func _show_detail() -> void:
	detail.reset(LEAF, detail_w())
	if selected == "":
		detail.empty(ArtLib.tex("interfaccia", "pannello_erbario") if ArtLib.has("interfaccia", "pannello_erbario") else null,
			"Scegli una voce", "Le caselle accese sono ciò che hai scoperto; quelle con il punto di domanda ti aspettano.")
		return
	if not erbario.known(section, selected):
		# voce 61: una famiglia mai incontrata dice dove cercarla
		var why := BestiaryInfo.hint(selected) if section == "famiglie" else (FishData.where(selected) if section == "pesci" else "")
		detail.head("Non ancora scoperta" if section != "pesci" else "Non l'hai ancora pescato", "", null)
		if why != "":
			detail.callout("Dove cercare", why, UiPalette.AMBRA)
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
		"pesci":
			var f := FishData.info(selected)
			var e: Dictionary = erbario.data["pesci"][selected]
			t += String(f.get("desc", "")) + "\n\n"
			t += "[color=%s]%s[/color] · da %d a %d cm\n" % [FishData.RARITY[f["rar"]]["color"], FishData.RARITY[f["rar"]]["name"],
				int(f["size"][0]), int(f["size"][1])]
			t += "Dove: %s\n" % FishData.where(selected)
			t += "Pescati: %d · il più grande: %d cm" % [int(e.get("n", 0)), int(e.get("max", 0))]
	detail.bbcode(t, _icon(selected))
