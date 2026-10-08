class_name HerdPanel
extends UiPage
## La mandria aperta (tasto G, voce 59; rifatta nella Roadmap 55 «Il volto chiaro»): a sinistra le creature come
## schedine (il disegno, il nome, il livello, lo stato, la fame), a destra la scheda di quella scelta con i comandi —
## Nella sacca, Riposa, Al recinto, Di guardia, Nel vasetto, Libera, Coppia, Alla fiera, Lavoro — e il nome da cambiare.
## Nell'intestazione: quante ti seguono, i recinti di questo mondo, i vasetti vuoti, i manti.

const HERD := Color("#b8e070")
const ACTS := [["segue", "Nella sacca"], ["riposo", "Riposa"], ["recinto", "Al recinto"], ["guardia", "Di guardia"],
	["vasetto", "Nel vasetto"], ["libera", "Libera"], ["coppia", "Coppia…"], ["fiera", "Alla fiera"], ["lavoro", "Lavoro…"]]

var selected := -1                     # uid della creatura scelta
var _title: Label
var _name: LineEdit
var _buttons := {}
var _tex := {}
var _pairing := false                  # voce 60: il prossimo clic nell'elenco sceglie la compagna


func setup(main: Node2D) -> void:
	m = main
	key_action = "mandria"
	visible = false
	build_page("La mandria", "Le creature che hai addomesticato: nutrile, falle crescere, mettile al recinto, in coppia o al lavoro.",
		ArtLib.tex("interfaccia", "pannello_mandria") if ArtLib.has("interfaccia", "pannello_mandria") else null, HERD)
	_title = page_title
	set_hints([[Keys.label("mandria"), "apri e chiudi"], ["Clic destro", "con il suo cibo: nutrila"], ["R", "cavalca"],
		["Ceppo", "il Recinto e l'Incubatrice"]])
	split(470.0)
	list.chosen.connect(_on_pick)
	_name = LineEdit.new()
	_name.max_length = 18
	_name.placeholder_text = "Nuovo nome (Invio)"
	_name.custom_minimum_size = Vector2(260, 38)
	_name.text_submitted.connect(_rename)
	for b in ACTS:
		var btn := Button.new()
		btn.text = String(b[1])
		btn.custom_minimum_size = Vector2(140, 38)
		btn.focus_mode = Control.FOCUS_NONE
		UiFrames.button(btn, UiPalette.PERICOLO if String(b[0]) == "libera" else Color(0, 0, 0, 0))
		var what: String = b[0]
		btn.pressed.connect(func() -> void: _act(what))
		_buttons[what] = btn
	m.herd.changed.connect(func() -> void: mark_dirty())


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func can_open() -> bool:
	return super.can_open() and not _name.has_focus()


func _on_pick(id: String) -> void:
	var uid := int(id)
	if _pairing:
		_pairing = false
		var why: String = m.herd.pair(m.herd.rec_of(selected), m.herd.rec_of(uid))
		if why != "":
			m.hud.toast(why)
	else:
		selected = uid
		detail_top()
	mark_dirty()


func _icon(rec: Dictionary) -> Texture2D:
	var specie := String(rec["specie"])
	var more := Breeding.mods(rec.get("doti", {}))
	var k := specie + str(more)
	if not _tex.has(k):
		var d := CreaturesData.get_data(specie)
		var art: Array = d["art"]
		var fr := CreatureArt.frames(String(art[0]), int(art[1]))
		var mods: Dictionary = d.get("art_mods", {}).duplicate()
		mods.merge(more, true)
		if not mods.is_empty():
			fr = VariantArt.apply(fr, mods)
		_tex[k] = ImageTexture.create_from_image(fr["frames"][0])
	return _tex[k]


func refresh() -> void:
	var recs: Array = m.herd.records()
	var jars: int = m.character.bisaccia.count("creatura")
	var pens := 0
	var room := 0
	for o in m.pens.pens:
		pens += 1
		room += HerdData.PEN_CAP - m.pens.members(Pens.key(o)).size()
	set_chips([["%d creature" % recs.size() + ((" · %d nei vasetti" % jars) if jars > 0 else ""), HERD],
		["Sacca %d/%d" % [m.herd.followers().size(), HerdData.FOLLOW_MAX], UiPalette.LINFA],
		["recinti %d · liberi %d" % [pens, room]], ["vasetti %d" % m.character.bisaccia.count("vasetto")],
		["manti %d/%d" % [Lineage.collected(m.character.stats), Lineage.total()], UiPalette.AMBRA]])
	if selected >= 0 and m.herd.rec_of(selected).is_empty():
		selected = -1
	if selected < 0 and not recs.is_empty():
		selected = int(recs[0]["uid"])
	var items := []
	for r in recs:
		var st := String(r["stato"])
		items.append({"id": str(int(r["uid"])), "title": String(r["nome"]), "sub": "liv. %d · %s" % [int(r["lvl"]), HerdInfo.hunger_text(r)],
			"badge": String(HerdInfo.STATES.get(st, "")), "badge_col": UiPalette.LINFA if st == "segue" else HERD,
			"color": HERD, "icon": _icon(r), "on": _pairing and int(r["uid"]) == selected})
	list.set_items(items, str(selected))
	list_shown(not recs.is_empty())
	# i comandi e il nome si staccano prima di svuotare il dettaglio (svuotandolo verrebbero liberati con lui)
	if _name.get_parent() != null:
		_name.get_parent().remove_child(_name)
	for k in _buttons:
		var bt: Button = _buttons[k]
		if bt.get_parent() != null:
			bt.get_parent().remove_child(bt)
	detail.reset(HERD, detail_w())
	var rec: Dictionary = m.herd.rec_of(selected)
	if rec.is_empty():
		detail.empty(ArtLib.tex("interfaccia", "pannello_mandria") if ArtLib.has("interfaccia", "pannello_mandria") else null,
			"La mandria è vuota", "Ogni creatura si può addomesticare, in tre modi:",
			[["gelatina", "Dalle il suo cibo con il clic destro quando si fida di te: le docili sempre, le altre quando hanno fame, sono stordite o indebolite."],
			["laccio_intrecciato", "Prendila con il Laccio quando è stremata."],
			["vasetto", "Fai schiudere un uovo nell'Incubatrice."]])
		detail.note(Fairs.line(m))
		return
	detail.bbcode(HerdInfo.sheet(rec), _icon(rec))
	var mate: Dictionary = m.herd.rec_of(int(rec.get("coppia", -1)))
	if not mate.is_empty():
		detail.text("La coppia", Breeding.preview(rec, mate))
	if _pairing:
		detail.callout("Scegli la compagna", "Clic nell'elenco su con chi fare coppia (stessa famiglia, livello %d o più)." % BreedData.MIN_LVL)
	(_buttons["coppia"] as Button).text = "Sciogli coppia" if not mate.is_empty() else "Coppia…"
	(_buttons["segue"] as Button).disabled = rec["stato"] == "segue"
	(_buttons["riposo"] as Button).disabled = rec["stato"] == "riposo"
	(_buttons["recinto"] as Button).disabled = rec["stato"] == "recinto" and rec["mondo"] == m.world_id
	(_buttons["vasetto"] as Button).disabled = m.character.bisaccia.count("vasetto") <= 0
	var sec := detail.section("I comandi")
	var fl := HFlowContainer.new()
	fl.add_theme_constant_override("h_separation", 8)
	fl.add_theme_constant_override("v_separation", 8)
	for b in ACTS:
		fl.add_child(_buttons[String(b[0])])
	sec.add_child(fl)
	var nm := UiKit.row(10)
	nm.add_child(UiKit.label("Il nome", UiPalette.TESTO_PX, UiPalette.TESTO_MUTO, "chiaro"))
	nm.add_child(_name)
	sec.add_child(nm)
	detail.note(Fairs.line(m))


func _act(what: String) -> void:
	var rec: Dictionary = m.herd.rec_of(selected)
	if rec.is_empty():
		return
	var why := ""
	match what:
		"segue", "riposo", "recinto", "guardia":
			why = m.herd.set_state(rec, what)
		"vasetto":
			m.taming.jar_record(rec)
		"libera":
			m.herd.free_record(rec)
			selected = -1
		"fiera":
			why = Fairs.enter(m, rec)                  # voce 242
		"lavoro":
			why = HerdJobs.next_job(rec)               # voce 243
		"coppia":
			if rec.has("coppia"):
				m.herd.unpair(rec)
			else:
				_pairing = true
	if why != "":
		m.hud.toast(why)
	mark_dirty()


func _rename(t: String) -> void:
	var rec: Dictionary = m.herd.rec_of(selected)
	t = t.strip_edges()
	if not rec.is_empty() and t != "":
		rec["nome"] = t
		_name.text = ""
		_name.release_focus()
		mark_dirty()
