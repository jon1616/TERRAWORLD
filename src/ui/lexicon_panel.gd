class_name LexiconPanel
extends Control
## Il Quaderno delle parole (Roadmap 17, voce 172; tasto «quaderno», U): tutto ciò che il Germogliato sa della lingua
## dei Seminatori, da consultare quando vuole. In alto come si decifra e a che punto è ogni strato di lingua; a sinistra
## le parole dello strato scelto (colore dello stato; quelle mai viste restano puntini); a destra la scheda della parola:
## che tipo di parola è, le frasi di questo mondo in cui l'ha vista (tradotte per quello che sa), e per un'ipotesi i
## significati possibili con il pulsante «È questo?» (`Language.guess`).

const COLS := 5
const CELL := Vector2(118, 34)
const GAP := 6
const CLASS_NAME := {"cosa": "una cosa (un nome)", "azione": "un'azione", "luogo": "un luogo o una direzione",
	"quanto": "una quantità"}
const HOW := "[color=#9fc8c0][b]Come si decifra[/b] · Leggendo le stele le parole diventano [color=#8aa09a]viste[/color]. Vista in %s frasi diverse, una parola diventa un'[color=#e0b060]ipotesi[/color]: qui scegli tra tre significati possibili, ragionando sulle frasi. Giusto: [color=#ffe8b0]certa[/color]. Sbagliato: quel significato è scartato, e per riprovare devi ritrovarla in una frase nuova (scartati due, resta quello giusto). Diventano certe anche arrivando al luogo che una stele indica, aprendo uno scrigno a parola e con le tavolette.[/color]"

var m: Node2D
var layer := "comune"
var selected := ""
var _grid: Control
var _head: RichTextLabel
var _detail: RichTextLabel
var _opts: HBoxContainer
var _tabs: Array[Button] = []
var _dirty := true


func setup(main: Node2D) -> void:
	m = main
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiPalette.FONDO                 # opaco: la fusione è lineare, al 97% il mondo si vedeva ancora
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# (voce 281) i riquadri delle colonne
	UiScreen.box(self, Rect2(60, 220, 684, 624))
	UiScreen.box(self, Rect2(748, 220, 792, 624))
	var title := Label.new()
	title.text = "Il Quaderno delle parole"
	title.position = Vector2(80, 26)
	title.add_theme_font_size_override("font_size", UiPalette.TITOLO)
	title.add_theme_color_override("font_color", UiPalette.AMBRA)
	add_child(title)
	_head = RichTextLabel.new()
	_head.bbcode_enabled = true
	_head.position = Vector2(80, 72)
	_head.size = Vector2(1440, 110)
	_head.add_theme_font_size_override("normal_font_size", 15)
	_head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_head)
	var x := 80.0
	for l in LanguageData.LAYER_ORDER:
		var b := Button.new()
		b.position = Vector2(x, 186)
		b.size = Vector2(250, 34)
		b.focus_mode = Control.FOCUS_NONE
		var id := String(l)
		b.pressed.connect(func() -> void:
			layer = id
			selected = ""
			_dirty = true)
		add_child(b)
		_tabs.append(b)
		x += 260.0
	_grid = Control.new()
	_grid.position = Vector2(80, 236)
	add_child(_grid)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(760, 236)
	_detail.size = Vector2(760, 470)
	_detail.add_theme_font_size_override("normal_font_size", 16)
	add_child(_detail)
	_opts = HBoxContainer.new()
	_opts.position = Vector2(760, 716)
	_opts.add_theme_constant_override("separation", 10)
	add_child(_opts)
	var hint := Label.new()
	hint.text = "U o Esc per chiudere · clic su una parola per leggerne la scheda"
	hint.position = Vector2(80, 856)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)
	m.language.changed.connect(func() -> void: _dirty = true)


func toggle() -> void:
	visible = not visible
	_dirty = true


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if Keys.pressed(e, "quaderno") and not m.hud.panel.visible:
			toggle()
			get_viewport().set_input_as_handled()
		elif e.keycode == KEY_ESCAPE and visible:
			toggle()
			get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		refresh()


func refresh() -> void:
	var lg: Language = m.language
	var parts := []
	for i in LanguageData.LAYER_ORDER.size():
		var l := String(LanguageData.LAYER_ORDER[i])
		var t: Array = lg.tally(l)
		var met := int(t[0]) + int(t[1]) + int(t[2]) > 0
		_tabs[i].text = "%s  %d/%d" % [LanguageData.LAYERS[l]["name"], int(t[0]), int(t[3])] if met else "??? (mai incontrata)"
		_tabs[i].modulate = Color(1, 1, 1) if l == layer else Color(0.6, 0.7, 0.68)
		if met:
			parts.append("[color=%s]%s[/color]: certe %d · ipotesi %d · viste %d · mai viste %d" % [LanguageData.LAYERS[l]["color"],
				LanguageData.LAYERS[l]["name"], int(t[0]), int(t[1]), int(t[2]), int(t[3]) - int(t[0]) - int(t[1]) - int(t[2])])
	var wr := Language.written_recipes(m.character.lingua)
	var shown := wr.filter(func(e: Array) -> bool: return bool(e[3])).size()
	parts.append("[color=#ffd08a]Ricette scritte[/color]: svelate %d su %d" % [shown, wr.size()])
	_head.text = HOW % "2 (3 per le lingue più alte)" + "\n" + ("  ·  ".join(parts) if not parts.is_empty() else
		"[color=#6a8a84]Non hai ancora letto nessuna stele: cercale nelle rovine dei Seminatori (due sono vicino alla partenza di ogni mondo).[/color]")
	for c in _grid.get_children():
		c.queue_free()
	var words := LanguageData.words_of(layer)
	words.sort_custom(func(a: String, b: String) -> bool: return LanguageData.sem(a) < LanguageData.sem(b))
	for i in words.size():
		var w := String(words[i])
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2((i % COLS) * (CELL.x + GAP), (i / COLS) * (CELL.y + GAP))
		b.size = CELL
		b.add_theme_font_size_override("font_size", 14)
		var st := lg.state(w)
		match st:
			Language.CERTA:
				b.text = "%s · %s" % [LanguageData.sem(w), LanguageData.it(w)]
				b.add_theme_color_override("font_color", Color("#ffe8b0"))
			Language.IPOTESI:
				b.text = "%s ?" % LanguageData.sem(w)
				b.add_theme_color_override("font_color", Color("#e0b060"))
			Language.VISTA:
				b.text = LanguageData.sem(w)
				b.add_theme_color_override("font_color", Color("#8aa09a"))
			_:
				b.text = "· · ·"
				b.disabled = true
		if w == selected:
			b.add_theme_color_override("font_color", Color("#6ff0b8"))
		b.pressed.connect(func() -> void:
			selected = w
			_dirty = true)
		_grid.add_child(b)
	_show_word()


## La scheda della parola scelta, e i pulsanti dei significati possibili.
func _show_word() -> void:
	for c in _opts.get_children():
		c.queue_free()
	var lg: Language = m.language
	if selected == "" or lg.state(selected) < 0:
		_detail.text = "[color=#6a8a84]Scegli una parola.[/color]"
		return
	var w := selected
	var st := lg.state(w)
	var t := "[font_size=30][color=%s]%s[/color][/font_size]   " % [LanguageData.LAYERS[LanguageData.layer_of(w)]["color"], LanguageData.sem(w)]
	t += ["[color=#8aa09a]vista[/color]", "[color=#e0b060]ipotesi[/color]", "[color=#ffe8b0]certa: «%s»[/color]" % LanguageData.it(w)][st]
	t += "\n[color=#9fc8c0]È %s. Vista in %d frasi diverse.[/color]\n" % [CLASS_NAME.get(LanguageData.class_of(w), "una parola"),
		(lg.rec(w).get("f", []) as Array).size()]
	var lines := []
	for k in lg.stele():
		var e: Dictionary = lg.stele()[k]
		if e.get("letta", false) and w in (e["words"] as Array):
			lines.append("• %s" % lg.line_it(e["words"]))
	if not lines.is_empty():
		t += "\n[b]Dove l'hai vista in questo mondo[/b]\n" + "\n".join(lines.slice(0, 8)) + "\n"
	else:
		t += "\n[color=#6a8a84]In questo mondo non l'hai ancora vista su una stele letta.[/color]\n"
	match st:
		Language.VISTA:
			var need := int(LanguageData.LAYERS[LanguageData.layer_of(w)]["hyp"]) - (lg.rec(w).get("f", []) as Array).size()
			t += "\n[color=#8aa09a]Ritrovala in altre %d frasi e te ne farai un'ipotesi.[/color]" % maxi(need, 1)
		Language.IPOTESI:
			var x: Array = lg.rec(w).get("x", [])
			if not x.is_empty():
				t += "\n[color=#a07060]Scartati: %s.[/color]" % ", ".join(x.map(func(o: String) -> String: return "«%s»" % LanguageData.it(o)))
			if lg.rec(w).has("r"):
				t += "\n[color=#a07060]Hai appena sbagliato: ritrovala in una frase nuova per riprovare.[/color]"
			else:
				t += "\n[color=#e0b060]Che cosa vuol dire? Scegli, ragionando sulle frasi qui sopra.[/color]"
				for o in lg.options_left(w):
					var b := Button.new()
					b.focus_mode = Control.FOCUS_NONE
					b.text = "«%s»?" % LanguageData.it(String(o))
					b.add_theme_font_size_override("font_size", 16)
					b.custom_minimum_size = Vector2(150, 40)
					UiFrames.button(b, Color(0, 0, 0, 0), false, "principale")
					var meaning := String(o)
					b.pressed.connect(func() -> void:
						var r := lg.guess(w, meaning)
						match r:
							"giusto":
								m.hud.toast("Giusto: «%s» vuol dire «%s»" % [LanguageData.sem(w), LanguageData.it(w)])
							"dedotto":
								m.hud.toast("Sbagliato, ma ora resta un solo significato: «%s» vuol dire «%s»" % [LanguageData.sem(w), LanguageData.it(w)])
							"sbagliato":
								m.hud.toast("No: «%s» non vuol dire «%s»" % [LanguageData.sem(w), LanguageData.it(meaning)])
						_dirty = true)
					_opts.add_child(b)
	for e in Language.written_recipes(m.character.lingua):
		if w in (e[4] as Array):
			t += "\n[color=#ffd08a]È in una ricetta scritta: %s (%d parole certe su %d).[/color]" % [
				String(e[0]) if bool(e[3]) else "una ricetta ancora nascosta", int(e[1]), int(e[2])]
	var inc := IncisionsData.of_word(w)
	if not inc.is_empty():
		t += "\n\n[color=#ffd08a]Si incide al Maglio%s: %s (su %s).[/color]" % ["" if st == Language.CERTA else " quando sarà certa",
			inc["desc"], ", ".join(inc["for"])]
	_detail.text = t
