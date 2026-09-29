class_name MachinePanel
extends Control
## Roadmap 19, voce 194: il pannello di una macchina della rete (clic destro su una macchina che non ha un gesto suo).
## Dice che cos'è e che cosa fa adesso (e perché, se è ferma), la sua rete (quanto danno le sorgenti, quanto chiedono le
## macchine, quanto c'è nelle riserve) e i fili che la toccano; si sceglie la priorità, la reazione all'Impulso,
## l'accensione a mano (senza fili) e, per la piastra, chi la preme. Si aggiorna a ogni conto del Flusso. Esc chiude.

const PRIO := ["Bassa", "Normale", "Alta"]

var e: Energy
var mc: Machine
var _box: PanelContainer
var _title: Label
var _text: RichTextLabel
var _rows: VBoxContainer


func setup(energy: Energy) -> void:
	e = energy
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = Vector2(1600, 900)
	var dim := ColorRect.new()
	dim.color = Color(0, 0.01, 0.02, 0.55)
	dim.size = size
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)
	_box = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.05, 0.06, 0.97)
	sb.border_color = Color("#5cc8cc")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.set_content_margin_all(22)
	_box.add_theme_stylebox_override("panel", sb)
	add_child(_box)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_box.add_child(v)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 24)
	_title.add_theme_color_override("font_color", Color("#8ef0e8"))
	v.add_child(_title)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = true
	_text.scroll_active = false
	_text.custom_minimum_size = Vector2(620, 0)
	_text.add_theme_font_size_override("normal_font_size", 16)
	v.add_child(_text)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 8)
	v.add_child(_rows)
	var hint := Label.new()
	hint.text = "Esc per chiudere"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	v.add_child(hint)
	e.ticked.connect(func() -> void:
		if visible:
			_fill_text())


func open(m2: Machine) -> void:
	mc = m2
	_title.text = String(mc.d["name"])
	_fill_text()
	_fill_rows()
	visible = true
	_box.reset_size()
	await get_tree().process_frame
	_box.reset_size()
	_box.position = (size - _box.size) / 2.0


func close() -> void:
	visible = false


func _input(ev: InputEvent) -> void:
	if not visible:
		return
	if ev is InputEventKey and ev.pressed and not ev.echo and ev.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _fill_text() -> void:
	if mc == null:
		return
	var role_name: String = {"sorgente": "Sorgente", "riserva": "Riserva", "macchina": "Macchina", "comando": "Comando",
		"nodo": "Nodo della logica"}.get(mc.role(), "")
	var t := "[color=#9fc8c0]%s[/color] · [b]%s[/b]\n" % [role_name, mc.bh.state_text(mc, e)]
	t += "[color=#9fb4b0]%s[/color]\n" % String(mc.d.get("desc", ""))
	if mc.role() == "macchina" and float(mc.d.get("pulsi", 0)) > 0.0:
		t += "Chiede [b]%s[/b] mentre lavora" % Energy.pulsi(float(mc.d["pulsi"]))
		if mc.net >= 0:
			t += ", la vena più stretta fino a lei ne porta %d" % roundi(mc.cap)
		t += ".\n"
	if mc.d.has("colpo"):
		t += "Ogni azione costa [b]%d[/b] gocce della sua rete.\n" % int(mc.d["colpo"])
	t += "\n" + e.net_text(mc.net)
	if not mc.wired.is_empty():
		var ws := []
		for k in mc.wired:
			var on: bool = e.impulse.wnets[k][mc.wired[k]]["state"]
			ws.append("[color=#%s]%s[/color] (%s)" % [(VeinsData.WIRES[k]["color"] as Color).to_html(false),
				String(VeinsData.WIRES[k]["name"]).to_lower(), "acceso" if on else "spento"])
		t += "\nFili che la toccano: " + ", ".join(ws)
	elif mc.role() in ["macchina", "comando"]:
		t += "\n[color=#7a9a94]Nessun filo la tocca: la comanda il pannello (o da sola).[/color]"
	_text.text = t


func _button(parent: Control, txt: String, on: bool, cb: Callable) -> Button:
	var b := Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.toggle_mode = true
	b.button_pressed = on
	b.text = txt
	b.custom_minimum_size = Vector2(110, 32)
	b.add_theme_font_size_override("font_size", 15)
	b.pressed.connect(func() -> void:
		cb.call()
		_fill_rows()
		_fill_text()
		e.refresh_look(mc))
	parent.add_child(b)
	return b


func _row(label: String) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(150, 0)
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color("#cfe6e0"))
	h.add_child(l)
	_rows.add_child(h)
	return h


func _fill_rows() -> void:
	for c in _rows.get_children():
		c.queue_free()
	if mc.role() == "macchina":
		if float(mc.d.get("pulsi", 0)) > 0.0:
			var r1 := _row("Priorità")
			for p in 3:
				var pr := p
				_button(r1, PRIO[p], mc.prio() == p, func() -> void: mc.st["prio"] = pr)
		if mc.wired.is_empty():
			var r2 := _row("Accesa")
			_button(r2, "Accesa", mc.on(), func() -> void:
				mc.st["on"] = true
				mc.st.erase("off_by_hand"))
			_button(r2, "Spenta", not mc.on(), func() -> void:
				mc.st["on"] = false
				mc.st["off_by_hand"] = true)
		else:
			var r3 := _row("All'Impulso")
			var mode := String(mc.st.get("reazione", "segue"))
			_button(r3, "Segue il filo", mode == "segue", func() -> void: mc.st["reazione"] = "segue")
			_button(r3, "Alterna", mode == "alterna", func() -> void: mc.st["reazione"] = "alterna")
	if String(mc.d.get("bh", "")) == "piastra":
		var r4 := _row("La preme")
		var who := String(mc.st.get("chi", "germogliato"))
		for opt in [["germogliato", "Tu"], ["creature", "Le creature"], ["tutti", "Tutti"]]:
			var o := String(opt[0])
			_button(r4, String(opt[1]), who == o, func() -> void: mc.st["chi"] = o)
	for extra in mc.bh.panel_rows(mc, e):
		var r5 := _row(String(extra[0]))
		for opt in extra[1]:
			var cb: Callable = opt[2]
			_button(r5, String(opt[0]), bool(opt[1]), cb)
