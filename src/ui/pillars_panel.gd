class_name PillarsPanel
extends Control
## Il Libro dei pilastri (Roadmap 20, voce 216; tasto «pilastri», P): a sinistra i dieci pilastri con il grado e la barra
## dei punti verso il grado dopo; a destra il pilastro scelto: che cos'è, a che punto sei, il prossimo passo, da quanto
## non lo curi, e tutti i dieci gradi con i loro premi (quelli presi segnati).

const ROW_H := 62.0
const LEFT := Vector2(90, 96)
const ROW_W := 430.0

var m: Node2D
var ms: Mastery
var sel := "storia"
var _body: RichTextLabel
var _rows: Control
var _dirty := true


func setup(main: Node2D, mastery: Mastery) -> void:
	m = main
	ms = mastery
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = Color(0.03, 0.02, 0.04, 0.97)
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var title := Label.new()
	title.text = "Il Libro dei pilastri"
	title.position = Vector2(90, 34)
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#ffd24a"))
	add_child(title)
	_rows = Control.new()
	_rows.position = LEFT
	_rows.size = Vector2(ROW_W, ROW_H * MasteryData.ORDER.size())
	_rows.mouse_filter = Control.MOUSE_FILTER_STOP
	_rows.draw.connect(_draw_rows)
	_rows.gui_input.connect(_on_rows_input)
	add_child(_rows)
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.position = Vector2(580, 96)
	_body.size = Vector2(930, 720)
	_body.add_theme_font_size_override("normal_font_size", 17)
	_body.add_theme_font_size_override("bold_font_size", 17)
	add_child(_body)
	var hint := Label.new()
	hint.text = "Esc o %s per chiudere · ogni pilastro sale di grado con ciò che fai nel suo campo, e ogni grado dà un premio" % Keys.label("pilastri")
	hint.position = Vector2(90, 850)
	hint.add_theme_color_override("font_color", Color("#7a6a84"))
	add_child(hint)
	ms.gained.connect(func(_p: String, _x: float) -> void: _dirty = true)


func open() -> void:
	visible = true
	_dirty = true
	get_parent().move_child(self, -1)


func close() -> void:
	visible = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _unhandled_input(e: InputEvent) -> void:
	if not (e is InputEventKey and e.pressed and not e.echo):
		return
	if visible and (e.keycode == KEY_ESCAPE or Keys.pressed(e, "pilastri")):
		close()
		get_viewport().set_input_as_handled()
	elif not visible and Keys.pressed(e, "pilastri") and not m.hud.panel.visible:
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
		if i >= 0 and i < MasteryData.ORDER.size():
			sel = String(MasteryData.ORDER[i])
			_dirty = true
			_rows.accept_event()


func _draw_rows() -> void:
	var font := get_theme_default_font()
	for i in MasteryData.ORDER.size():
		var p := String(MasteryData.ORDER[i])
		var d: Dictionary = MasteryData.PILLARS[p]
		var col: Color = d["color"]
		var y := i * ROW_H
		var r := Rect2(0, y, ROW_W, ROW_H - 8)
		_rows.draw_rect(r, Color(0.12, 0.08, 0.14) if p != sel else Color(0.2, 0.13, 0.22))
		_rows.draw_rect(Rect2(0, y, 5, ROW_H - 8), col)
		var g := ms.grade(p)
		_rows.draw_string(font, Vector2(16, y + 24), String(d["name"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#ece4ea"))
		_rows.draw_string(font, Vector2(ROW_W - 110, y + 24), "grado %d" % g, HORIZONTAL_ALIGNMENT_RIGHT, 96, 18, col)
		var f := progress(p)
		_rows.draw_rect(Rect2(16, y + 34, ROW_W - 32, 8), Color(0.25, 0.18, 0.28))
		_rows.draw_rect(Rect2(16, y + 34, (ROW_W - 32) * f, 8), col)


## Quanto manca al grado dopo, da 0 a 1 (1 al grado massimo).
func progress(p: String) -> float:
	var g := ms.grade(p)
	if g >= MasteryData.GRADES:
		return 1.0
	var a := MasteryData.points_for(p, g)
	var b := MasteryData.points_for(p, g + 1)
	return clampf((ms.points(p) - a) / maxf(b - a, 1.0), 0.0, 1.0)


## La scheda di un pilastro (BBCode).
func text_of(p: String) -> String:
	var d: Dictionary = MasteryData.PILLARS[p]
	var col := (d["color"] as Color).to_html(false)
	var g := ms.grade(p)
	var t := "[font_size=26][color=#%s]%s[/color][/font_size]\n%s\n\n" % [col, d["name"], d["desc"]]
	if g < MasteryData.GRADES:
		t += "[b]Grado %d[/b] · %d punti su %d per il grado %d\n" % [g, int(ms.points(p)), int(MasteryData.points_for(p, g + 1)), g + 1]
	else:
		t += "[b]Grado %d, il massimo[/b] · %d punti\n" % [g, int(ms.points(p))]
	t += "Il prossimo passo: [color=#ffd24a]%s[/color]\n" % d["hint"]
	if p == "giardino" and m.get("beauty") != null:
		t += m.beauty.line() + "\n"             # Roadmap 22: la bellezza del Giardino
	if p == "rete" and m.get("contracts") != null:
		t += m.contracts.line() + "
"          # voce 260: i contratti della rete
	if p == "pesca" and m.get("angler") != null:
		t += m.angler.line() + "\n"             # voce 258: i record di pesca
	if p == "misteri" and m.get("museum") != null:
		t += m.museum.line() + "\n"             # voce 253: il Museo
	if p == "orto" and m.get("garden") != null:
		t += m.garden.line() + "\n"             # voce 244: varietà e raccolti ottimi
	var idle := ms.idle(p)
	if idle < 0.0:
		t += "[color=#9a8aa4]Non l'hai ancora cominciato.[/color]\n"
	elif idle > 1800.0:
		t += "[color=#9a8aa4]Non lo curi da %d minuti di gioco.[/color]\n" % int(idle / 60.0)
	t += "\n[b]I gradi[/b]\n"
	for k in range(1, MasteryData.GRADES + 1):
		var r := MasteryData.reward(p, k)
		var what := []
		for id in r.get("items", {}):
			what.append("%s ×%d" % [String(ItemsData.get_item(String(id)).get("name", id)), int(r["items"][id])])
		if r.has("text"):
			what.append(String(r["text"]))
		var done := k <= g
		t += "%s [color=%s]%2d[/color]  [color=%s]%s[/color]\n" % ["✓" if done else "·", "#" + col if done else "#7a6a84", k,
			"#cfeee4" if done else "#9a8aa4", ", ".join(what)]
	return t
