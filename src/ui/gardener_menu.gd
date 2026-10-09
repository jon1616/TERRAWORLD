class_name GardenerMenu
extends UiPage
## Il Menu del Giardiniere (voce 480, 9 ott 2026; dall'analisi: «troppi tasti e troppi pannelli»): un tasto solo che
## mostra tutti i pannelli del gioco come schede, ognuna con il suo tasto, a che cosa serve e a che punto sei. Un clic
## apre il pannello come farebbe il suo tasto (lo stesso evento, così ogni pannello resta l'unico a sapere come aprirsi).
## Sotto, i comandi utili che non sono pannelli (il filo, Osserva, la minimappa, l'aiuto).

## [azione di KeysData (o "pausa"), icona (ArtLib «interfaccia» o id d'oggetto), nome, a che cosa serve]
const ENTRIES := [
	["bisaccia", "pannello_bisaccia", "Bisaccia e Creare", "Ciò che porti, l'equipaggiamento, le ricette e Esamina."],
	["mappa", "pannello_mappa", "Mappa", "Il mondo che hai visto, i tuoi segnali e le radici viandanti."],
	["erbario", "pannello_erbario", "Erbario", "Creature, oggetti, pesci e famiglie scoperte, e dove cercare ciò che manca."],
	["semenzaio", "pannello_semenzaio", "Semenzaio", "I mondi nati dai Semi, il Genario, il Taccuino e il diario."],
	["mandria", "pannello_mandria", "Mandria", "Le creature addomesticate: recinti, coppie, fiere e lavori."],
	["compagni", "laccio_intrecciato", "Compagni", "La Sacca dei legami: chi combatte al tuo fianco, e il Libro dei legami."],
	["quaderno", "pannello_quaderno", "Quaderno delle parole", "La lingua dei Seminatori: ipotesi, parole certe e frasi lette."],
	["pilastri", "pannello_pilastri", "Libro dei pilastri", "I dieci pilastri: gradi, premi e il prossimo passo di ognuno."],
	["arti", "pannello_arti", "Arti del combattimento", "La maestria delle armi, le tecniche, le taglie e le prove."],
	["atlante", "pannello_atlante", "Atlante", "Le stelle dei mondi, le pagine dei biomi, meraviglie e spedizioni."],
	["enciclopedia", "tavoletta_seminatori", "Enciclopedia", "Come funziona ogni cosa del gioco, con la ricerca."],
	["pausa", "pannello_opzioni", "Pausa e Opzioni", "Le opzioni, i comandi, il salvataggio e il ritorno al menu."],
]
## I comandi utili che non aprono un pannello.
const EXTRA := [["filo", "cambia il filo da seguire"], ["osserva", "ferma il mondo e leggi le schede"],
	["minimappa", "minimappa"], ["aiuto", "aiuto dei tasti"], ["riponi", "riponi nelle casse vicine"]]

const CARD := Vector2(488, 104)

var _grid: GridContainer
var _status := {}                      # azione -> Label con «a che punto sei»
var _extra: HBoxContainer


func setup(main: Node2D) -> void:
	m = main
	key_action = "menu"
	visible = false
	build_page("Il Giardiniere", "Tutti i pannelli del gioco: un clic apre, oppure il loro tasto.", _icon("pannello_pilastri"))
	set_hints([[Keys.label("menu"), "apri e chiudi"], ["Clic", "apri il pannello"]])
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 22)
	col.size = body.size
	body.add_child(col)
	_grid = GridContainer.new()
	_grid.columns = 3
	_grid.add_theme_constant_override("h_separation", 14)
	_grid.add_theme_constant_override("v_separation", 14)
	col.add_child(_grid)
	for e in ENTRIES:
		_grid.add_child(_card(e))
	var sec := UiKit.caps("Altri comandi")
	col.add_child(sec)
	_extra = HBoxContainer.new()
	_extra.add_theme_constant_override("separation", 26)
	col.add_child(_extra)


## Un'icona dell'interfaccia di Nano Banana o, se manca, l'icona di un oggetto (null se nessuna delle due).
static func _icon(id: String) -> Variant:
	if ArtLib.has("interfaccia", id):
		return ArtLib.tex("interfaccia", id)
	return id if ItemsData.has(id) else null


static func key_of(action: String) -> String:
	return "Esc" if action == "pausa" else Keys.label(action)


func _card(e: Array) -> Button:
	var action := String(e[0])
	var b := Button.new()
	b.custom_minimum_size = CARD
	b.focus_mode = Control.FOCUS_NONE
	UiFrames.button(b, Color(0, 0, 0, 0), false, "sezione")
	b.pressed.connect(func() -> void: choose(action))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	row.position = Vector2(16, 12)
	row.size = CARD - Vector2(32, 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(row)
	var ic: Variant = _icon(String(e[1]))
	if ic != null:
		var t := UiKit.icon_rect(ic, 52)
		t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(t)
	var txt := VBoxContainer.new()
	txt.add_theme_constant_override("separation", 2)
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(txt)
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(UiKit.name_label(String(e[2]), UiPalette.GRANDE, UiPalette.AMBRA_CHIARA))
	var kc := UiKit.keycap(key_of(action))
	kc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(kc)
	txt.add_child(head)
	var d := UiKit.para(String(e[3]), CARD.x - 120.0, UiPalette.NOTA)
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	txt.add_child(d)
	var st := UiKit.label("", UiPalette.NOTA, UiPalette.LINFA, "forte")
	st.mouse_filter = Control.MOUSE_FILTER_IGNORE
	txt.add_child(st)
	_status[action] = st
	return b


## Apre un pannello: chiude il menu e manda il tasto del pannello, come se lo premesse il giocatore.
func choose(action: String) -> void:
	close()
	var code := KEY_ESCAPE
	if action != "pausa":
		var ks := Settings.keys_of(action)
		if ks.is_empty():
			return
		code = int(ks[0])
	for down in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = code
		ev.pressed = down
		Input.parse_input_event(ev)


func refresh() -> void:
	set_chips([["%d pannelli" % ENTRIES.size(), UiPalette.AMBRA]])
	for a in _status:
		(_status[a] as Label).text = _status_of(String(a))
	UiKit.clear(_extra)
	for x in EXTRA:
		_extra.add_child(UiKit.hint(Keys.label(String(x[0])), String(x[1])))


## A che punto sei in ogni pannello, in poche parole («» = niente da dire).
func _status_of(action: String) -> String:
	match action:
		"bisaccia":
			var free := 0
			for s in m.character.bisaccia.slots:
				if (s as Dictionary).is_empty():
					free += 1
			return "%d caselle libere" % free
		"erbario":
			return "scoperto il %d%%" % roundi(m.erbario.percent())
		"mandria":
			var n: int = m.herd.records().size()
			return "%d creature" % n if n > 0 else "ancora nessuna creatura"
		"compagni":
			var f: int = m.herd.followers().size()
			return "%d nella Sacca dei legami" % f if f > 0 else "la Sacca è vuota"
		"quaderno":
			return "%d parole certe" % m.language.count()
		"pilastri":
			var tot := 0
			for p in MasteryData.ORDER:
				tot += int(m.mastery.grade(String(p)))
			return "%d gradi in tutto" % tot
	return ""
