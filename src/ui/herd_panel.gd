class_name HerdPanel
extends Control
## La mandria aperta (tasto G, voce 59): a sinistra le creature (icona, nome, livello, stato), a destra la scheda di
## quella scelta con i comandi — Segui, Riposa, Al recinto, Nel vasetto, Libera — e il nome da cambiare.
## In basso: quante ti seguono, i recinti di questo mondo, i vasetti vuoti. Si ridisegna quando la mandria cambia.

const ROW := 52
const ROWS := 14

var m: Node2D
var selected := -1                     # uid della creatura scelta
var _list: Control
var _detail: RichTextLabel
var _title: Label
var _foot: Label
var _name: LineEdit
var _buttons := {}
var _tex := {}
var _dirty := true
var _page := 0
var _pairing := false                  # voce 60: il prossimo clic nell'elenco sceglie la compagna


func setup(main: Node2D) -> void:
	m = main
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.03, 0.04)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = _label(Vector2(120, 40), 30, Color("#8ef0d8"))
	_list = Control.new()
	_list.position = Vector2(120, 100)
	add_child(_list)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(780, 100)
	_detail.size = Vector2(700, 300)
	_detail.add_theme_font_size_override("normal_font_size", 16)
	add_child(_detail)
	var x := 780.0
	for b in [["segue", "Segui"], ["riposo", "Riposa"], ["recinto", "Al recinto"], ["vasetto", "Nel vasetto"], ["libera", "Libera"],
			["coppia", "Coppia…"]]:
		var btn := Button.new()
		btn.text = b[1]
		btn.position = Vector2(x, 420)
		btn.size = Vector2(128, 36)
		ErbarioPanel._frame(btn, Color("#2f7a70"))
		var what: String = b[0]
		btn.pressed.connect(func() -> void: _act(what))
		add_child(btn)
		_buttons[what] = btn
		x += 138.0
	_name = LineEdit.new()
	_name.position = Vector2(780, 476)
	_name.size = Vector2(260, 36)
	_name.max_length = 18
	_name.placeholder_text = "Nuovo nome (Invio)"
	_name.text_submitted.connect(_rename)
	add_child(_name)
	(_buttons["coppia"] as Button).position = Vector2(1060, 476)      # accanto al nome
	(_buttons["coppia"] as Button).size = Vector2(160, 36)
	var prev := Button.new()
	prev.text = "‹"
	prev.position = Vector2(120, 100 + ROWS * ROW + 6)
	prev.size = Vector2(40, 30)
	prev.pressed.connect(func() -> void:
		_page = maxi(_page - 1, 0)
		_dirty = true)
	add_child(prev)
	var nxt := Button.new()
	nxt.text = "›"
	nxt.position = Vector2(170, 100 + ROWS * ROW + 6)
	nxt.size = Vector2(40, 30)
	nxt.pressed.connect(func() -> void:
		_page += 1
		_dirty = true)
	add_child(nxt)
	_foot = _label(Vector2(230, 100 + ROWS * ROW + 10), 16, Color("#9fc8c0"))
	var hint := _label(Vector2(120, 850), 16, Color("#6a8a84"))
	hint.text = "G o Esc per chiudere · clic destro con il suo cibo per nutrirla · R per cavalcare · il Recinto e l'Incubatrice si fanno al Ceppo"
	m.herd.changed.connect(func() -> void: _dirty = true)


func _label(pos: Vector2, size: int, col: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	add_child(l)
	return l


func toggle() -> void:
	visible = not visible
	_dirty = true


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if Keys.pressed(e, "mandria") and not m.hud.panel.visible and not _name.has_focus():
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			toggle()
			get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		_refresh()


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


func _refresh() -> void:
	var recs: Array = m.herd.records()
	var jars: int = m.character.bisaccia.count("creatura")
	_title.text = "La mandria — %d creature%s" % [recs.size(), (" (e %d nei vasetti)" % jars) if jars > 0 else ""]
	for c in _list.get_children():
		c.queue_free()
	_page = clampi(_page, 0, maxi((recs.size() - 1) / ROWS, 0))
	if selected >= 0 and m.herd.rec_of(selected).is_empty():
		selected = -1
	if selected < 0 and not recs.is_empty():
		selected = int(recs[0]["uid"])
	for k in range(_page * ROWS, mini(recs.size(), (_page + 1) * ROWS)):
		var r: Dictionary = recs[k]
		var b := Button.new()
		b.position = Vector2(0, (k - _page * ROWS) * ROW)
		b.size = Vector2(620, ROW - 6)
		b.icon = _icon(r)
		b.expand_icon = false
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.text = "  %s · liv. %d · %s · %s" % [r["nome"], int(r["lvl"]), HerdInfo.STATES.get(String(r["stato"]), ""),
			HerdInfo.hunger_text(r)]
		ErbarioPanel._frame(b, Color("#ffb84a") if int(r["uid"]) == selected else Color("#2f7a70"))
		var uid := int(r["uid"])
		b.pressed.connect(func() -> void:
			if _pairing:
				_pairing = false
				var why: String = m.herd.pair(m.herd.rec_of(selected), m.herd.rec_of(uid))
				if why != "":
					m.hud.toast(why)
			else:
				selected = uid
			_dirty = true)
		_list.add_child(b)
	var rec: Dictionary = m.herd.rec_of(selected)
	for k in _buttons:
		(_buttons[k] as Button).visible = not rec.is_empty()
	_name.visible = not rec.is_empty()
	if rec.is_empty():
		_detail.text = "[color=#9fc8c0]La mandria è vuota.\n\nPer addomesticare una creatura: dalle il suo cibo con il clic destro quando si fida di te (le docili sempre; le altre quando hanno fame, sono stordite o indebolite), oppure prendila con il Laccio quando è stremata, o fai schiudere un uovo nell'Incubatrice.[/color]"
	else:
		_detail.text = HerdInfo.sheet(rec)
		var mate: Dictionary = m.herd.rec_of(int(rec.get("coppia", -1)))
		if not mate.is_empty():
			_detail.text += "\n" + Breeding.preview(rec, mate)
		if _pairing:
			_detail.text += "\n[color=#ffb84a]Scegli nell'elenco con chi fare coppia (stessa famiglia, livello %d o più)[/color]" % BreedData.MIN_LVL
		(_buttons["coppia"] as Button).text = "Sciogli coppia" if not mate.is_empty() else "Coppia…"
		(_buttons["segue"] as Button).disabled = rec["stato"] == "segue"
		(_buttons["riposo"] as Button).disabled = rec["stato"] == "riposo"
		(_buttons["recinto"] as Button).disabled = rec["stato"] == "recinto" and rec["mondo"] == m.world_id
		(_buttons["vasetto"] as Button).disabled = m.character.bisaccia.count("vasetto") <= 0
	var pens := 0
	var room := 0
	for o in m.pens.pens:
		pens += 1
		room += HerdData.PEN_CAP - m.pens.members(Pens.key(o)).size()
	_foot.text = "Ti seguono %d su %d · recinti in questo mondo: %d (posti liberi %d) · vasetti vuoti: %d" % [m.herd.followers().size(),
		HerdData.FOLLOW_MAX, pens, room, m.character.bisaccia.count("vasetto")]


func _act(what: String) -> void:
	var rec: Dictionary = m.herd.rec_of(selected)
	if rec.is_empty():
		return
	var why := ""
	match what:
		"segue", "riposo", "recinto":
			why = m.herd.set_state(rec, what)
		"vasetto":
			m.taming.jar_record(rec)
		"libera":
			m.herd.free_record(rec)
			selected = -1
		"coppia":
			if rec.has("coppia"):
				m.herd.unpair(rec)
			else:
				_pairing = true
	if why != "":
		m.hud.toast(why)
	_dirty = true


func _rename(t: String) -> void:
	var rec: Dictionary = m.herd.rec_of(selected)
	t = t.strip_edges()
	if not rec.is_empty() and t != "":
		rec["nome"] = t
		_name.text = ""
		_name.release_focus()
		_dirty = true
