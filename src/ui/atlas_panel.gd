class_name AtlasPanel
extends Control
## L'Atlante (Roadmap 23; tasto «atlante», O): schede in alto (i mondi, e con le voci dopo i biomi, le meraviglie, le
## spedizioni); a sinistra l'elenco con una barra di quanto è completo, a destra la voce scelta. Ogni scheda è una coppia
## di funzioni `_rows_<scheda>` (elenco di [chiave, titolo, sotto, 0..1, colore]) e `_text_<scheda>` (BBCode).

const ROW_H := 52.0
const LEFT := Vector2(90, 130)
const ROW_W := 430.0
const ROWS_SHOWN := 13
const TABS := [["mondi", "I mondi"], ["biomi", "I biomi"], ["meraviglie", "Le meraviglie"], ["spedizioni", "Le spedizioni"]]

var m: Node2D
var at: Atlas
var tab := "mondi"
var sel := ""
var scroll := 0
var _body: RichTextLabel
var _rows_box: Control
var _tabs: Array[Button] = []
var _rows: Array = []
var _dirty := true


func setup(main: Node2D, atlas: Atlas) -> void:
	m = main
	at = atlas
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.04, 0.97)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var title := Label.new()
	title.text = "L'Atlante"
	title.position = Vector2(90, 30)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#5cf0e0"))
	add_child(title)
	for i in TABS.size():
		var b := Button.new()
		b.text = String(TABS[i][1])
		b.position = Vector2(90 + i * 160, 80)
		b.size = Vector2(150, 32)
		var id := String(TABS[i][0])
		b.pressed.connect(func() -> void: pick_tab(id))
		add_child(b)
		_tabs.append(b)
	_rows_box = Control.new()
	_rows_box.position = LEFT
	_rows_box.size = Vector2(ROW_W, ROW_H * ROWS_SHOWN)
	_rows_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_rows_box.draw.connect(_draw_rows)
	_rows_box.gui_input.connect(_on_rows_input)
	add_child(_rows_box)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.position = Vector2(580, 130)
	_body.size = Vector2(930, 690)
	_body.add_theme_font_size_override("normal_font_size", 17)
	_body.add_theme_font_size_override("bold_font_size", 17)
	add_child(_body)
	var hint := Label.new()
	hint.text = "Esc o %s per chiudere · rotella per scorrere l'elenco" % Keys.label("atlante")
	hint.position = Vector2(90, 850)
	hint.add_theme_color_override("font_color", Color("#6a7a84"))
	add_child(hint)


func open() -> void:
	visible = true
	_dirty = true
	if at.here():
		at.check()
		if tab == "mondi":
			sel = m.world_id
	get_parent().move_child(self, -1)


func close() -> void:
	visible = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func pick_tab(id: String) -> void:
	tab = id
	sel = ""
	scroll = 0
	_dirty = true


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	if visible and (e.keycode == KEY_ESCAPE or Keys.pressed(e, "atlante")):
		close()
		get_viewport().set_input_as_handled()
	elif not visible and Keys.pressed(e, "atlante") and not m.hud.panel.visible:
		open()
		get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if not visible or not _dirty:
		return
	_dirty = false
	_rows = call("_rows_" + tab)
	if sel == "" and not _rows.is_empty():
		sel = String(_rows[0][0])
	scroll = clampi(scroll, 0, maxi(_rows.size() - ROWS_SHOWN, 0))
	for i in _tabs.size():
		_tabs[i].modulate = Color(1.3, 1.2, 0.8) if String(TABS[i][0]) == tab else Color(0.8, 0.8, 0.85)
	_rows_box.queue_redraw()
	_body.text = call("_text_" + tab, sel) if sel != "" else "[color=#7a8a94]Qui non c'è ancora niente.[/color]"


func _on_rows_input(e: InputEvent) -> void:
	if not (e is InputEventMouseButton and e.pressed):
		return
	if e.button_index == MOUSE_BUTTON_WHEEL_DOWN or e.button_index == MOUSE_BUTTON_WHEEL_UP:
		scroll += 1 if e.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
		_dirty = true
	elif e.button_index == MOUSE_BUTTON_LEFT:
		var i := int(e.position.y / ROW_H) + scroll
		if i >= 0 and i < _rows.size():
			sel = String(_rows[i][0])
			_dirty = true
	_rows_box.accept_event()


func _draw_rows() -> void:
	var font := get_theme_default_font()
	for k in mini(ROWS_SHOWN, _rows.size() - scroll):
		var r: Array = _rows[k + scroll]
		var y := k * ROW_H
		var col: Color = r[4]
		_rows_box.draw_rect(Rect2(0, y, ROW_W, ROW_H - 6), Color(0.2, 0.13, 0.22) if String(r[0]) == sel else Color(0.1, 0.1, 0.13))
		_rows_box.draw_rect(Rect2(0, y, 5, ROW_H - 6), col)
		_rows_box.draw_string(font, Vector2(14, y + 20), String(r[1]), HORIZONTAL_ALIGNMENT_LEFT, ROW_W - 104, 16, Color("#ece4ea"))
		_rows_box.draw_string(font, Vector2(ROW_W - 84, y + 20), String(r[2]), HORIZONTAL_ALIGNMENT_RIGHT, 72, 15, col)
		_rows_box.draw_rect(Rect2(14, y + 30, ROW_W - 28, 6), Color(0.2, 0.2, 0.24))
		_rows_box.draw_rect(Rect2(14, y + 30, (ROW_W - 28) * clampf(float(r[3]), 0.0, 1.0), 6), col)


# --- la scheda dei mondi (voce 235) ---

func _rows_mondi() -> Array:
	var out := []
	for wid in at.data():
		var e: Dictionary = at.data()[wid]
		var n := (e.get("stelle", {}) as Dictionary).size()
		out.append([String(wid), String(e.get("nome", wid)), "★ %d/%d" % [n, AtlasData.STARS.size()],
			float(n) / AtlasData.STARS.size(), Color("#ffd24a") if n >= AtlasData.STARS.size() else Color("#5cf0e0")])
	out.sort_custom(func(a: Array, b: Array) -> bool: return String(a[1]) < String(b[1]))
	return out


func _text_mondi(wid: String) -> String:
	var e: Dictionary = at.entry(wid)
	if e.is_empty():
		return ""
	var t := "[font_size=26][color=#5cf0e0]%s[/color][/font_size]\n" % e.get("nome", wid)
	t += "Vigore %d" % int(e.get("vigore", 1))
	if wid == m.world_id:
		t += " · [color=#ffd24a]sei qui[/color]"
	t += "\n"
	var genes: Array = e.get("geni", [])
	if not genes.is_empty():
		var names := []
		for g in genes:
			names.append(String(GenesData.GENES.get(String(g), {}).get("name", g)))
		t += "Geni: %s\n" % ", ".join(names)
	t += "\n[b]Le stelle[/b] (%d in tutto l'Atlante; ogni %d un premio)\n" % [at.total(), AtlasData.EVERY]
	var st: Dictionary = e.get("stelle", {})
	for s in AtlasData.STARS:
		var id := String(s[0])
		var done := st.has(id)
		t += "%s [color=%s]%s[/color] — %s\n" % ["★" if done else "☆", "#ffd24a" if done else "#9a8aa4", s[1], AtlasData.star_desc(id)]
	if wid == m.world_id:
		t += "\n[color=#9a8aa4]Mappa scoperta: %.1f%% · Sigilli aperti: %d su %d · Segreti: %d su %d[/color]\n" % [
			at.map_frac() * 100.0, int(m.world_meta.get("sigilli_aperti", 0)), (m.world_meta.get("sigilli", []) as Array).size(),
			int(Secrets.counts_of(m.world_meta)[0]), int(Secrets.counts_of(m.world_meta)[1])]
	return t


# --- la scheda dei biomi (voce 236) ---

func _rows_biomi() -> Array:
	var out := []
	for p in BiomePagesData.pages():
		var pr := at.pages.progress(p)
		var done: bool = at.pages.done(p)
		var col: Color = {"sup": Color("#8ef0a0"), "sot": Color("#e0a060"), "cie": Color("#9ad0ff")}[String(p["kind"])]
		out.append([String(p["id"]), String(p["name"]), "%d/%d" % [int(pr[0]), int(pr[1])],
			float(pr[0]) / maxf(float(pr[1]), 1.0), Color("#ffd24a") if done else col])
	return out


func _text_biomi(id: String) -> String:
	var p := BiomePagesData.page(id)
	if p.is_empty():
		return ""
	return at.pages.text_of(p) + "\n\n[color=#6a7a84]Pagine complete: %d su %d[/color]" % [at.pages.done_count(), BiomePagesData.pages().size()]


# --- la scheda delle meraviglie (voce 237) ---

func _rows_meraviglie() -> Array:
	var out := []
	for k in WondersData.WONDERS:
		var seen := int(m.character.stats.get("mer_" + String(k), 0)) == 1
		var d: Dictionary = WondersData.WONDERS[k]
		var got: bool = m.character.bisaccia.count(WondersData.memento_id(String(k))) > 0 or \
			(m.character.erbario.get("oggetti", {}) as Dictionary).has(WondersData.memento_id(String(k)))
		out.append([String(k), String(d["name"]) if seen else "???", "ricordo ✓" if got else ("vista" if seen else ""),
			1.0 if got else (0.5 if seen else 0.0), Color("#ffd24a") if got else Color("#c8a8ff")])
	return out


func _text_meraviglie(k: String) -> String:
	var d: Dictionary = WondersData.WONDERS.get(k, {})
	if d.is_empty():
		return ""
	var seen := int(m.character.stats.get("mer_" + k, 0)) == 1
	var where := "sulla superficie" if str(d["where"]) == "sup" else "nello strato «%s»" % StrataData.STRATA[int(d["where"])]["name"]
	var t := "[font_size=26][color=#c8a8ff]%s[/color][/font_size]\n" % (d["name"] if seen else "Una meraviglia che non hai ancora visto")
	if seen:
		t += "%s\n" % d["desc"]
	t += "Nasce %s%s.\n" % [where, "; è rara" if int(d["weight"]) <= 1 else ""]
	var gn := []
	for g in d.get("genes", []):
		gn.append(String(GenesData.GENES.get(String(g), {}).get("name", g)) if int(m.character.genario.get(String(g), 0)) > 0 else "?")
	t += "La chiamano più spesso i geni: %s\n" % ", ".join(gn)
	var mm: Array = d["memento"]
	t += "\nNel suo cuore: [b]%s[/b] (%s)\n" % [mm[0] if seen else "???", "un ricordo che esiste solo lì" if not seen else mm[3]]
	if at.here():
		var here := []
		for e in at.wonders.list():
			here.append("%s%s" % [WondersData.WONDERS[String(e["k"])]["name"] if e.get("vista", false) else "una meraviglia non ancora vista",
				" (ricordo preso)" if e.get("preso", false) else ""])
		t += "\n[b]In questo mondo[/b]: %s\n" % (", ".join(here) if not here.is_empty() else "nessuna")
	t += "\n[color=#6a7a84]Tipi visti: %d su %d · con i ricordi, al Maglio: il Mappamondo dei Seminatori e la Bussola del cosmo[/color]" % [
		Wonders.kinds_seen(m.character.stats), WondersData.WONDERS.size()]
	return t


# --- la scheda delle spedizioni (voce 238) ---

func _rows_spedizioni() -> Array:
	at.expeditions.fill()
	var out := []
	var list: Array = at.expeditions.open_list()
	for i in list.size():
		var e: Dictionary = list[i]
		var p: Array = at.expeditions.progress(e)
		out.append([str(i), at.expeditions.title(e), "%d/%d" % [int(p[0]), int(p[1])], float(p[0]) / maxf(float(p[1]), 1.0),
			Color("#ffb84a")])
	return out


func _text_spedizioni(key: String) -> String:
	var list: Array = at.expeditions.open_list()
	var i := int(key)
	if i < 0 or i >= list.size():
		return ""
	var e: Dictionary = list[i]
	var d: Dictionary = ExpeditionsData.KINDS[String(e["k"])]
	var p: Array = at.expeditions.progress(e)
	var t := "[font_size=26][color=#ffb84a]%s[/color][/font_size]\n" % at.expeditions.title(e)
	t += "Il Cartografo ti propone questa spedizione. A che punto sei: %d su %d\n\n" % [int(p[0]), int(p[1])]
	t += "[b]Dove cercare[/b]: %s\n" % d["hint"]
	if String(e["k"]) == "meraviglia":
		var gn := []
		for g in WondersData.WONDERS[String(e["t"])]["genes"]:
			gn.append(String(GenesData.GENES.get(String(g), {}).get("name", g)))
		t += "La chiamano più spesso i geni: %s\n" % ", ".join(gn)
	var parts := []
	for it in d["reward"]:
		parts.append("%s ×%d" % [String(ItemsData.get_item(String(it)).get("name", it)), int(d["reward"][it])])
	if d.get("seed", false):
		var gene := String(e.get("gene", ""))
		parts.append("un Seme di mondo" + (" con il gene «%s»" % GenesData.GENES[gene]["name"] if GenesData.GENES.has(gene) else " con un gene raro"))
	t += "\n[b]Premio[/b]: %s\n" % ", ".join(parts)
	t += "\n[color=#6a7a84]Spedizioni compiute: %d · finita una, se ne apre un'altra[/color]" % int(at.expeditions.data().get("fatte", 0))
	return t
