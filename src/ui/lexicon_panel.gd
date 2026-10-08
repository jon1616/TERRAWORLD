class_name LexiconPanel
extends UiPage
## Il Quaderno delle parole (Roadmap 17, voce 172; tasto «quaderno», U; rifatto nella Roadmap 55 «Il volto chiaro»):
## tutto ciò che il Germogliato sa della lingua dei Seminatori. Le schede in alto sono gli strati di lingua (con le
## parole certe); a sinistra le parole dello strato come tessere (il colore dice lo stato; quelle mai viste restano
## puntini); a destra la scheda della parola: che tipo di parola è, le frasi di questo mondo in cui l'ha vista (tradotte
## per quello che sa), e per un'ipotesi i significati possibili con il pulsante «È questo?» (`Language.guess`).

const COLS := 5
const CELL := Vector2(118, 38)
const GAP := 6
const CLASS_NAME := {"cosa": "una cosa (un nome)", "azione": "un'azione", "luogo": "un luogo o una direzione",
	"quanto": "una quantità"}
const HOW := "[color=#a9bdb6]Leggendo le stele le parole diventano [color=#8aa09a]viste[/color]. Vista in %s frasi diverse, una parola diventa un'[color=#e0b060]ipotesi[/color]: qui scegli tra tre significati possibili, ragionando sulle frasi. Giusto: [color=#ffe8b0]certa[/color]. Sbagliato: quel significato è scartato, e per riprovare devi ritrovarla in una frase nuova (scartati due, resta quello giusto). Diventano certe anche arrivando al luogo che una stele indica, aprendo uno scrigno a parola e con le tavolette.[/color]"
const INK := Color("#e0b060")
const STATE_COL := [Color("#8aa09a"), Color("#e0b060"), Color("#ffe8b0")]

var layer := "comune"
var selected := ""
var _grid: Control
var _opts: HBoxContainer


func setup(main: Node2D) -> void:
	m = main
	key_action = "quaderno"
	visible = false
	build_page("Il Quaderno delle parole", "La lingua dei Seminatori: le parole viste, le ipotesi da provare, quelle certe.",
		ArtLib.tex("interfaccia", "pannello_quaderno") if ArtLib.has("interfaccia", "pannello_quaderno") else null, INK)
	set_tabs(LanguageData.LAYER_ORDER.map(func(l: Variant) -> String: return String(LanguageData.LAYERS[String(l)]["name"])), 0)
	tab_changed.connect(func(i: int) -> void:
		layer = String(LanguageData.LAYER_ORDER[i])
		selected = ""
		mark_dirty())
	set_hints([[Keys.label("quaderno"), "apri e chiudi"], ["Clic", "su una parola: la sua scheda"]])
	var gw := COLS * (CELL.x + GAP) - GAP + 34.0
	var left := Panel.new()
	left.add_theme_stylebox_override("panel", UiFrames.box("sezione"))
	left.size = Vector2(gw, body.size.y)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(left)
	var sc := ScrollContainer.new()
	sc.position = Vector2(14, 14)
	sc.size = left.size - Vector2(20, 28)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(sc)
	_grid = Control.new()
	sc.add_child(_grid)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.position = Vector2(gw + 36.0, 0)
	_detail_scroll.size = Vector2(body.size.x - gw - 36.0, body.size.y - 60.0)
	body.add_child(_detail_scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 22)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(pad)
	detail = UiDetail.new()
	pad.add_child(detail)
	_opts = HBoxContainer.new()
	_opts.position = Vector2(gw + 36.0, body.size.y - 46.0)
	_opts.add_theme_constant_override("separation", 10)
	body.add_child(_opts)
	m.language.changed.connect(func() -> void: mark_dirty())


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func refresh() -> void:
	var lg: Language = m.language
	var chips := []
	var names := []
	for i in LanguageData.LAYER_ORDER.size():
		var l := String(LanguageData.LAYER_ORDER[i])
		var t: Array = lg.tally(l)
		var met := int(t[0]) + int(t[1]) + int(t[2]) > 0
		names.append([String(LanguageData.LAYERS[l]["name"]) if met else "???", ("%d/%d" % [int(t[0]), int(t[3])]) if met else ""])
		if l == layer and met:
			chips = [["certe %d" % int(t[0]), STATE_COL[2]], ["ipotesi %d" % int(t[1]), STATE_COL[1]], ["viste %d" % int(t[2]), STATE_COL[0]],
				["mai viste %d" % (int(t[3]) - int(t[0]) - int(t[1]) - int(t[2]))]]
	var wr := Language.written_recipes(m.character.lingua)
	chips.append(["ricette scritte %d/%d" % [wr.filter(func(e: Array) -> bool: return bool(e[3])).size(), wr.size()], UiPalette.AMBRA])
	set_chips(chips)
	var cur := tab_i
	set_tabs(names, cur)
	UiKit.clear(_grid)
	var words := LanguageData.words_of(layer)
	words.sort_custom(func(a: String, b: String) -> bool: return LanguageData.sem(a) < LanguageData.sem(b))
	for i in words.size():
		var w := String(words[i])
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.position = Vector2((i % COLS) * (CELL.x + GAP), (i / COLS) * (CELL.y + GAP))
		b.size = CELL
		b.add_theme_font_size_override("font_size", 16)
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		var st := lg.state(w)
		var col := UiPalette.TESTO_MUTO
		match st:
			Language.CERTA:
				b.text = "%s · %s" % [LanguageData.sem(w), LanguageData.it(w)]
				col = STATE_COL[2]
			Language.IPOTESI:
				b.text = "%s ?" % LanguageData.sem(w)
				col = STATE_COL[1]
			Language.VISTA:
				b.text = LanguageData.sem(w)
				col = STATE_COL[0]
			_:
				b.text = "· · ·"
				b.disabled = true
		UiFrames.button(b, Color(col, 0.5) if st >= 0 else Color(0, 0, 0, 0), w == selected)
		b.add_theme_color_override("font_color", col)
		b.add_theme_color_override("font_hover_color", col.lightened(0.3))
		b.add_theme_font_override("font", UiFonts.get_font("forte" if st == Language.CERTA else "testo"))
		b.pressed.connect(func() -> void:
			selected = w
			detail_top()
			mark_dirty())
		_grid.add_child(b)
	_grid.custom_minimum_size = Vector2(COLS * (CELL.x + GAP) - GAP, ceili(words.size() / float(COLS)) * (CELL.y + GAP))
	_show_word()


## La scheda della parola scelta, e i pulsanti dei significati possibili.
func _show_word() -> void:
	for c in _opts.get_children():
		c.queue_free()
	var lg: Language = m.language
	detail.reset(INK, detail_w())
	if selected == "" or lg.state(selected) < 0:
		detail.head("Come si decifra", "Scegli una parola a sinistra per leggerne la scheda.")
		detail.text("", HOW % "2 (3 per le lingue più alte)")
		var met := false
		for l in LanguageData.LAYER_ORDER:
			var t: Array = lg.tally(String(l))
			met = met or int(t[0]) + int(t[1]) + int(t[2]) > 0
		if not met:
			detail.callout("Da dove cominciare", "Non hai ancora letto nessuna stele: cercale nelle rovine dei Seminatori (due sono vicino alla partenza di ogni mondo).")
		return
	var w := selected
	var st := lg.state(w)
	var t := "[font_size=30][color=%s]%s[/color][/font_size]\n" % [LanguageData.LAYERS[LanguageData.layer_of(w)]["color"], LanguageData.sem(w)]
	t += "%s · è %s · vista in %d frasi diverse\n" % [["vista", "ipotesi", "certa: «%s»" % LanguageData.it(w)][st],
		CLASS_NAME.get(LanguageData.class_of(w), "una parola"), (lg.rec(w).get("f", []) as Array).size()]
	var lines := []
	for k in lg.stele():
		var e: Dictionary = lg.stele()[k]
		if e.get("letta", false) and w in (e["words"] as Array):
			lines.append("• %s" % lg.line_it(e["words"]))
	if not lines.is_empty():
		t += "\n[b]Dove l'hai vista in questo mondo[/b]\n" + "\n".join(lines.slice(0, 8)) + "\n\n"
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
					b.add_theme_font_size_override("font_size", 18)
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
						mark_dirty())
					_opts.add_child(b)
	for e in Language.written_recipes(m.character.lingua):
		if w in (e[4] as Array):
			t += "\n[color=#ffd08a]È in una ricetta scritta: %s (%d parole certe su %d).[/color]" % [
				String(e[0]) if bool(e[3]) else "una ricetta ancora nascosta", int(e[1]), int(e[2])]
	var inc := IncisionsData.of_word(w)
	if not inc.is_empty():
		t += "\n\n[color=#ffd08a]Si incide al Maglio%s: %s (su %s).[/color]" % ["" if st == Language.CERTA else " quando sarà certa",
			inc["desc"], ", ".join(inc["for"])]
	detail.bbcode(t)
