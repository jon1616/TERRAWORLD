class_name ArtsPanel
extends Control
## Le arti (Roadmap 25, voce 251; tasto «arti», I): a sinistra le dieci forme d'arma con il rango della maestria, poi le
## taglie e le prove del Cerchio; a destra la voce scelta (tecnica, ranghi, taglie aperte e registro, record).

const ROW_H := 50.0
const LEFT := Vector2(90, 100)
const ROW_W := 430.0

var m: Node2D
var sel := "spada"
var _body: RichTextLabel
var _rows: Control
var _dirty := true


func _keys() -> Array:
	return ArtsData.FORMS.keys() + ["taglie", "prove"]


func setup(main: Node2D) -> void:
	m = main
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.02, 0.02)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var title := Label.new()
	title.text = "Le arti del combattimento"
	title.position = Vector2(90, 34)
	UiFonts.apply(title, 3)                  # (Roadmap 55) il titolo in Alegreya
	title.add_theme_color_override("font_color", Color("#ff9a6a"))
	add_child(title)
	_rows = Control.new()
	_rows.position = LEFT
	_rows.size = Vector2(ROW_W, ROW_H * _keys().size())
	_rows.mouse_filter = Control.MOUSE_FILTER_STOP
	_rows.draw.connect(_draw_rows)
	_rows.gui_input.connect(_on_rows_input)
	add_child(_rows)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.position = Vector2(580, 100)
	_body.size = Vector2(930, 720)
	_body.add_theme_font_size_override("normal_font_size", 19)
	_body.add_theme_font_size_override("bold_font_size", 19)
	add_child(_body)
	var hint := Label.new()
	hint.text = "Esc o %s per chiudere · %s: la tecnica dell'arma in mano" % [Keys.label("arti"), Keys.label("tecnica")]
	hint.position = Vector2(90, 850)
	hint.add_theme_color_override("font_color", Color("#84706a"))
	add_child(hint)


func open() -> void:
	visible = true
	_dirty = true
	var f: String = m.arts.held_form()
	if f != "":
		sel = f
	m.bounties.fill()
	get_parent().move_child(self, -1)


func close() -> void:
	visible = false


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	if visible and (e.keycode == KEY_ESCAPE or Keys.pressed(e, "arti")):
		close()
		get_viewport().set_input_as_handled()
	elif not visible and Keys.pressed(e, "arti") and not m.hud.panel.visible:
		open()
		get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		_rows.queue_redraw()
		_body.text = text_of(sel)


func _on_rows_input(e: InputEvent) -> void:
	if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var i := int(e.position.y / ROW_H)
		if i >= 0 and i < _keys().size():
			sel = String(_keys()[i])
			_dirty = true
			_rows.accept_event()


func _row(k: String) -> Array:
	match k:
		"taglie":
			return ["Le taglie", "%d riscosse" % int(m.character.taglie.get("fatte", 0)), 0.0]
		"prove":
			var r := int(m.character.stats.get("prova_record", 0))
			return ["Le prove del Cerchio", "record %d" % r, float(r) / Trials.WAVES]
	var rk: int = m.arts.rank(k)
	var p: int = m.arts.points(k)
	var a := ArtsData.points_for(rk)
	var b := ArtsData.points_for(mini(rk + 1, ArtsData.RANKS))
	var f := 1.0 if rk >= ArtsData.RANKS else clampf(float(p - a) / maxf(float(b - a), 1.0), 0.0, 1.0)
	return [String(FormsData.FORMS[k]["name"]), "rango %d" % rk, f]


func _draw_rows() -> void:
	var font := get_theme_default_font()
	var ks := _keys()
	for i in ks.size():
		var k := String(ks[i])
		var r := _row(k)
		var y := i * ROW_H
		var col := Color("#ff9a6a") if k in ["taglie", "prove"] else Color("#ffd08a")
		_rows.draw_rect(Rect2(0, y, ROW_W, ROW_H - 6), Color(0.2, 0.12, 0.1) if k == sel else Color(0.12, 0.08, 0.08))
		_rows.draw_rect(Rect2(0, y, 5, ROW_H - 6), col)
		_rows.draw_string(font, Vector2(14, y + 20), String(r[0]), HORIZONTAL_ALIGNMENT_LEFT, ROW_W - 130, 16, Color("#f0e4e0"))
		_rows.draw_string(font, Vector2(ROW_W - 124, y + 20), String(r[1]), HORIZONTAL_ALIGNMENT_RIGHT, 112, 15, col)
		_rows.draw_rect(Rect2(14, y + 30, ROW_W - 28, 6), Color(0.25, 0.18, 0.16))
		_rows.draw_rect(Rect2(14, y + 30, (ROW_W - 28) * float(r[2]), 6), col)


## La scheda di una voce (BBCode).
func text_of(k: String) -> String:
	match k:
		"taglie":
			return _bounties_text()
		"prove":
			return "[font_size=26][color=#ff9a6a]Le prove del Cerchio[/color][/font_size]\n" + \
				"Al Cerchio dei Seminatori, clic destro due volte: %d ondate delle creature dello strato, sempre più forti, un capo ogni %d.\n" % [
					Trials.WAVES, Trials.BOSS_EVERY] + \
				"Il premio cresce con le ondate vinte (schegge di vigore, polvere iridata; vincendole tutte anche Linfa antica).\n\n" + \
				"[b]Il tuo record[/b]: %d ondate · prove vinte: %d" % [int(m.character.stats.get("prova_record", 0)),
					int(m.character.stats.get("prove_vinte", 0))]
	var t: Dictionary = ArtsData.TECHS[k]
	var rk: int = m.arts.rank(k)
	var g := ArtsData.tech_grade(rk)
	var out := "[font_size=26][color=#ffd08a]La maestria %s[/color][/font_size]\n" % ArtsData.FORMS[k]
	out += "Rango %d · %d punti%s · danno con questa forma +%d%%\n" % [rk, m.arts.points(k),
		(" su %d per il rango %d" % [ArtsData.points_for(rk + 1), rk + 1]) if rk < ArtsData.RANKS else " (il massimo)",
		roundi(ArtsData.DMG_PER_RANK * 100.0 * rk)]
	out += "Si cresce sconfiggendo creature con quest'arma in mano.\n\n"
	out += "[b]La tecnica: %s[/b] — %s\n" % [t["name"], t["desc"]]
	out += "Costa %d Linfa, poi %d secondi d'attesa.\n" % [int(t["linfa"]), roundi(float(t["cd"]))]
	for i in 3:
		var open := g > i
		out += "%s [color=%s]grado %d (rango %d): danno ×%.1f[/color]\n" % ["✓" if open else "·", "#cfeee4" if open else "#9a8aa4",
			i + 1, int(ArtsData.TECH_RANKS[i]), float(t["mult"][i])]
	return out


func _bounties_text() -> String:
	var bt: Bounties = m.bounties
	var out := "[font_size=26][color=#ff9a6a]Le taglie[/color][/font_size]\n"
	if int(m.character.stats.get("guardiani", 0)) < 1:
		return out + "Il Cacciatore di taglie arriva dopo il tuo primo Guardiano."
	out += "Vai nel posto giusto: la preda nasce poco lontano. È ancestrale, più forte, con un tratto antico.\n\n"
	for b in bt.open_list():
		out += "[b]%s[/b] — %s\n   tratto: %s\n" % [bt.title(b), bt.where_text(b), String(AncientData.TRAITS[String(b["tratto"])]["name"])]
	var reg: Array = m.character.taglie.get("registro", [])
	out += "\n[b]Il registro[/b] (%d)\n" % reg.size()
	for e in reg.slice(maxi(reg.size() - 10, 0)):
		out += "✓ %s (%s, vigore %d)\n" % [e[0], String(CreaturesData.get_data(String(e[1]))["name"]).to_lower(), int(e[2])]
	return out
