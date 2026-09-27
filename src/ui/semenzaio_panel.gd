class_name SemenzaioPanel
extends Control
## Il Semenzaio (tasto K, voce 45): i mondi della rete del Giardino. A sinistra l'elenco (il Giardino per primo, poi i
## mondi per vigore; ★ = dove sei), a destra la scheda del mondo scelto: genoma (i geni mai visti come «?»), firma,
## Cuore e Guardiano, quanto è esplorato. Dal Giardino un mondo nato da un'Aiuola si può chiudere (`Aiuole.close`).
## Seconda scheda (voce 46): il Genario, i geni conosciuti.

const ROW_H := 44

var m: Node2D
var tab := "mondi"
var selected := ""
var _title: Label
var _list: VBoxContainer
var _detail: RichTextLabel
var _close: Button
var _tabs: Array[Button] = []
var _worlds: Array[Dictionary] = []
## Il contenuto della scheda del Genario, se c'è (voce 46): () -> [righe dell'elenco, testo a destra].
var genario_view: Callable
var chains_view: Callable                  # voce 69: il Taccuino delle catene
var diary_view: Callable                   # voce 83: il diario della partita («Storia»)
var diary_export: Callable                 # () -> percorso del file scritto
var _export: Button


func setup(main: Node2D) -> void:
	m = main
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
	for t in [["mondi", "Mondi"], ["genario", "Genario"], ["catene", "Catene"], ["storia", "Storia"]]:
		var b := Button.new()
		b.text = t[1]
		b.position = Vector2(x, 96)
		b.size = Vector2(170, 34)
		var id: String = t[0]
		b.pressed.connect(func() -> void:
			tab = id
			selected = ""
			refresh())
		add_child(b)
		_tabs.append(b)
		x += 180.0
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(120, 150)
	scroll.size = Vector2(620, 680)
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.custom_minimum_size = Vector2(600, 0)
	_list.add_theme_constant_override("separation", 6)
	scroll.add_child(_list)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(780, 150)
	_detail.size = Vector2(700, 620)
	_detail.add_theme_font_size_override("normal_font_size", 16)
	add_child(_detail)
	_close = Button.new()
	_close.text = "Chiudi questo mondo (torna Aiuola, ti resta il Seme dormiente)"
	_close.position = Vector2(780, 790)
	_close.size = Vector2(520, 38)
	ErbarioPanel._frame(_close, Color("#ff9a7a"))
	_close.pressed.connect(_close_selected)
	add_child(_close)
	_export = Button.new()
	_export.text = "Esporta il diario in un file di testo"
	_export.position = Vector2(780, 790)
	_export.size = Vector2(420, 38)
	ErbarioPanel._frame(_export, Color("#8ef0d8"))
	_export.pressed.connect(func() -> void:
		if diary_export.is_valid():
			var p := String(diary_export.call())
			_detail.text = ("[color=#9fe070]Diario scritto in:[/color]\n%s\n\n" % p if p != "" else "[color=#ff8a78]Non si è potuto scrivere il file.[/color]\n\n") + _detail.text)
	add_child(_export)
	var hint := Label.new()
	hint.text = "K o Esc per chiudere · clic su un mondo per leggerne la scheda"
	hint.position = Vector2(120, 850)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)


func toggle() -> void:
	visible = not visible
	if visible:
		refresh()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if Keys.pressed(e, "semenzaio") and not m.hud.panel.visible:
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			toggle()
			get_viewport().set_input_as_handled()


func refresh() -> void:
	for k in _tabs.size():
		ErbarioPanel._frame(_tabs[k], Color("#ffb84a") if ["mondi", "genario", "catene", "storia"][k] == tab else Color("#2f7a70"))
	for c in _list.get_children():
		c.queue_free()
	_close.visible = false
	_export.visible = tab == "storia"
	var views := {"genario": genario_view, "catene": chains_view, "storia": diary_view}
	if views.has(tab) and (views[tab] as Callable).is_valid():
		var view: Array = (views[tab] as Callable).call(selected)
		_title.text = String(view[0])
		for row in view[1]:
			_row(String(row[0]), String(row[1]), Color(String(row[2])))
		_detail.text = String(view[2])
		return
	if tab == "genario":
		_title.text = "Genario"
		_detail.text = "[color=#6a8a84]Arriverà presto.[/color]"
		return
	var ai: Aiuole = m.aiuole
	_worlds = ai.network()
	var home: String = ai.home_id()
	var home_name := String(_worlds[0].get("nome", "")) if not _worlds.is_empty() else ""
	_title.text = "Semenzaio — il Giardino «%s» · %d mondi · Aiuole %d su %d" % [home_name, _worlds.size(),
		ai.count() if ai.is_home() else int(_worlds[0].get("aiuole", 0)), ai.max_aiuole()]
	if selected == "" and not _worlds.is_empty():
		selected = m.world_id
	for w in _worlds:
		var id := String(w["id"])
		var star := "★ " if id == m.world_id else ""
		var f: Dictionary = w.get("firma", {})
		var sgc := Secrets.counts_of(w)
		var text := "%s%s   ·   %s%s%s" % [star, w.get("nome", id), "il Giardino" if id == home else "vigore %d" % int(w.get("vigore", 1)),
			"   ·   firma trovata" if bool(f.get("trovata", false)) else "",
			("   ·   segreti %d/%d" % [sgc[0], sgc[1]]) if int(sgc[1]) > 0 else ""]
		_row(id, text, Color("#ffd08a") if id == selected else Color("#cfeee4"))
	_show_world()


func _row(id: String, text: String, col: Color) -> void:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(600, ROW_H)
	b.add_theme_color_override("font_color", col)
	b.add_theme_font_size_override("font_size", 16)
	ErbarioPanel._frame(b, Color("#ffb84a") if id == selected else Color("#2f7a70"))
	b.pressed.connect(func() -> void:
		selected = id
		refresh())
	_list.add_child(b)


func _show_world() -> void:
	var w := {}
	for x in _worlds:
		if String(x["id"]) == selected:
			w = x
	if w.is_empty():
		_detail.text = "[color=#6a8a84]Scegli un mondo.[/color]"
		return
	var ai: Aiuole = m.aiuole
	var home := String(w["id"]) == ai.home_id()
	var t := "[font_size=24][color=#ffd08a]%s[/color][/font_size]\n" % w.get("nome", "")
	t += "[color=#9fc8c0]%s[/color]\n\n" % ("Il Giardino: il mondo di partenza, dove crescono le Aiuole" if home
		else "Vigore %d · creature più forti del %d%%" % [int(w.get("vigore", 1)), roundi(Portal.VIGOR_STEP * 100 * (int(w.get("vigore", 1)) - 1))])
	var genes: Array = w.get("geni", [])
	if genes.is_empty():
		t += "[color=#9fc8c0]Nessun gene particolare: tutti i biomi.[/color]\n"
	else:
		t += Genome.sheet({"geni": genes, "vigore": int(w.get("vigore", 1))})
	var f: Dictionary = w.get("firma", {})
	var sd: Dictionary = SignaturesData.SIGNATURES.get(String(f.get("id", "")), {})
	if f.is_empty():
		t += "\n[color=#ffd24a]Firma:[/color] —\n"
	elif bool(f.get("trovata", false)):
		t += "\n[color=#ffd24a]Firma:[/color] %s — %s\n" % [Signature._cap(String(sd["name"])), sd["desc"]]
	else:
		t += "\n[color=#ffd24a]Firma:[/color] [color=#6a8a84]non ancora trovata[/color]\n"
	var g := String(w.get("guardiano", "dorme"))
	t += "[color=#8ef0d8]Cuore del mondo:[/color] %s\n" % {"dorme": "il Guardiano dorme ancora", "sconfitto": "Guardiano sconfitto",
		"curato": "Guardiano curato"}.get(g, g)
	t += "[color=#8ef0d8]Esplorato:[/color] %d%% · [color=#8ef0d8]tempo di gioco:[/color] %d minuti\n" % [int(w.get("esplorato", 0)),
		roundi(float(w.get("tempo_di_gioco", 0.0)) / 60.0)]
	_detail.text = t
	_close.visible = ai.is_home() and ai.portal_to(String(w["id"])).x >= 0


func _close_selected() -> void:
	var ai: Aiuole = m.aiuole
	var o := ai.portal_to(selected)
	if o.x >= 0 and ai.close(o):
		selected = m.world_id
		refresh()
