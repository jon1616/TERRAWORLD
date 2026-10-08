class_name SemenzaioPanel
extends UiPage
## Il Semenzaio (tasto K, voce 45; rifatto nella Roadmap 55 «Il volto chiaro»): i mondi della rete del Giardino. A
## sinistra l'elenco (il Giardino per primo, poi i mondi per vigore; «sei qui» = dove sei), a destra la scheda del mondo
## scelto: genoma (i geni mai visti come «?»), firma, Cuore e Guardiano, quanto è esplorato. Dal Giardino un mondo nato da
## un'Aiuola si può chiudere (`Aiuole.close`). Le altre schede: il Genario (voce 46), le Catene (voce 69), la Storia
## (voce 83); il loro contenuto lo danno i moduli (`genario_view`, `chains_view`, `diary_view`).

const TABS := [["mondi", "Mondi"], ["genario", "Genario"], ["catene", "Catene"], ["storia", "Storia"]]
const SEED := Color("#8ef0c0")

var tab := "mondi"
var selected := ""
var _title: Label
var _close: Button
var _export: Button
var _worlds: Array[Dictionary] = []
## Il contenuto della scheda del Genario, se c'è (voce 46): () -> [titolo, righe dell'elenco, testo a destra].
var genario_view: Callable
var chains_view: Callable                  # voce 69: il Taccuino delle catene
var diary_view: Callable                   # voce 83: il diario della partita («Storia»)
var diary_export: Callable                 # () -> percorso del file scritto
var _note := ""


func setup(main: Node2D) -> void:
	m = main
	key_action = "semenzaio"
	visible = false
	build_page("Il Semenzaio", "", ArtLib.tex("interfaccia", "pannello_semenzaio") if ArtLib.has("interfaccia", "pannello_semenzaio") else null, SEED)
	_title = page_title
	set_tabs(TABS.map(func(t: Array) -> String: return String(t[1])), 0)
	tab_changed.connect(func(i: int) -> void:
		tab = String(TABS[i][0])
		selected = ""
		refresh())
	set_hints([[Keys.label("semenzaio"), "apri e chiudi"], ["Clic", "leggi la scheda"]])
	split(440.0)
	_detail_scroll.size.y -= 56.0
	list.chosen.connect(func(id: String) -> void:
		selected = id
		detail_top()
		refresh())
	var bar := UiKit.row(14)
	bar.position = Vector2(_detail_scroll.position.x, body.size.y - 44.0)
	body.add_child(bar)
	_close = Button.new()
	_close.text = "Chiudi questo mondo (torna Aiuola, ti resta il Seme dormiente)"
	_close.custom_minimum_size = Vector2(0, 40)
	_close.focus_mode = Control.FOCUS_NONE
	UiFrames.button(_close, UiPalette.PERICOLO)
	_close.pressed.connect(_close_selected)
	bar.add_child(_close)
	_export = Button.new()
	_export.text = "Esporta il diario in un file di testo"
	_export.custom_minimum_size = Vector2(0, 40)
	_export.focus_mode = Control.FOCUS_NONE
	UiFrames.button(_export, SEED)
	_export.pressed.connect(func() -> void:
		if diary_export.is_valid():
			var p := String(diary_export.call())
			_note = ("[color=#9fe070]Diario scritto in:[/color] %s" % p) if p != "" else "[color=#ff8a78]Non si è potuto scrivere il file.[/color]"
			refresh())
	bar.add_child(_export)


func toggle() -> void:
	if visible:
		close()
	else:
		open()
		refresh()


func refresh() -> void:
	for i in TABS.size():
		if String(TABS[i][0]) == tab:
			select_tab(i)
	_close.visible = false
	_export.visible = tab == "storia"
	var ai: Aiuole = m.aiuole
	_worlds = ai.network()
	var home_name := String(_worlds[0].get("nome", "")) if not _worlds.is_empty() else ""
	var aiu := ai.count() if ai.is_home() else int(_worlds[0].get("aiuole", 0)) if not _worlds.is_empty() else 0
	set_chips([["%d mondi" % _worlds.size(), SEED], ["Aiuole %d su %d" % [aiu, ai.max_aiuole()], UiPalette.AMBRA],
		["%d geni conosciuti" % m.character.genario.size()]])
	page_sub.text = "Il Giardino «%s»: i mondi nati dai Semi, i geni che conosci, le catene dei Seminatori, la storia della partita." % home_name
	var views := {"genario": genario_view, "catene": chains_view, "storia": diary_view}
	if views.has(tab) and (views[tab] as Callable).is_valid():
		var view: Array = (views[tab] as Callable).call(selected)
		var items := []
		for row in view[1]:
			items.append({"id": String(row[0]), "title": _plain(String(row[1])), "color": Color(String(row[2]))})
		list.row_h = 50.0
		list.set_items(items, selected)
		detail.reset(SEED, detail_w())
		if _note != "" and tab == "storia":
			detail.callout("Il diario", _note, SEED)
		var txt := String(view[2])
		if txt.strip_edges() == "":
			detail.empty(null, String(view[0]), "Scegli una voce a sinistra.")
		else:
			detail.bbcode(txt)
		return
	_note = ""
	if selected == "" and not _worlds.is_empty():
		selected = m.world_id
	var home: String = ai.home_id()
	var items := []
	for w in _worlds:
		var id := String(w["id"])
		var f: Dictionary = w.get("firma", {})
		var sgc := Secrets.counts_of(w)
		var sub := "il Giardino" if id == home else "vigore %d" % int(w.get("vigore", 1))
		if bool(f.get("trovata", false)):
			sub += " · firma trovata"
		if int(sgc[1]) > 0:
			sub += " · segreti %d/%d" % [sgc[0], sgc[1]]
		items.append({"id": id, "title": String(w.get("nome", id)), "sub": sub, "badge": "sei qui" if id == m.world_id else "",
			"badge_col": UiPalette.AMBRA, "color": SEED if id == home else Color("#8ad0ff"),
			"frac": float(w.get("esplorato", 0)) / 100.0})
	list.row_h = 72.0
	list.set_items(items, selected)
	_show_world()


static func _plain(s: String) -> String:
	var re := RegEx.create_from_string("\\[[^\\]]*\\]")
	return re.sub(s, "", true)


func _show_world() -> void:
	var w := {}
	for x in _worlds:
		if String(x["id"]) == selected:
			w = x
	detail.reset(SEED, detail_w())
	if w.is_empty():
		detail.empty(null, "Scegli un mondo", "A sinistra i mondi della rete del tuo Giardino.")
		return
	var ai: Aiuole = m.aiuole
	var home := String(w["id"]) == ai.home_id()
	var vig := int(w.get("vigore", 1))
	detail.head(String(w.get("nome", "")), "Il Giardino: il mondo di partenza, dove crescono le Aiuole" if home
		else "Creature più forti del %d%%" % roundi((VigorData.creature_mult(vig) - 1.0) * 100.0),
		null, "" if home else str(vig), "" if home else "vigore")
	var g := String(w.get("guardiano", "dorme"))
	var f: Dictionary = w.get("firma", {})
	var sd: Dictionary = SignaturesData.SIGNATURES.get(String(f.get("id", "")), {})
	var firma := "—"
	if bool(f.get("trovata", false)) and not sd.is_empty():
		firma = Signature._cap(String(sd["name"]))
	elif not f.is_empty():
		firma = "non ancora trovata"
	detail.stats("Il mondo", [["Cuore", {"dorme": "il Guardiano dorme ancora", "sconfitto": "Guardiano sconfitto",
		"curato": "Guardiano curato"}.get(g, g), UiPalette.BUONO if g == "curato" else UiPalette.TESTO],
		["Firma", firma, UiPalette.AMBRA_CHIARA if bool(f.get("trovata", false)) else UiPalette.TESTO_SPENTO],
		["Esplorato", "%d%%" % int(w.get("esplorato", 0))], ["Tempo di gioco", "%d minuti" % roundi(float(w.get("tempo_di_gioco", 0.0)) / 60.0)]])
	if bool(f.get("trovata", false)) and not sd.is_empty():
		detail.text("La firma", String(sd["desc"]))
	var genes: Array = w.get("geni", [])
	if genes.is_empty():
		detail.text("Il genoma", "Nessun gene particolare: tutti i biomi.")
	else:
		detail.text("Il genoma", Genome.sheet({"geni": genes, "vigore": vig}))
	_close.visible = ai.is_home() and ai.portal_to(String(w["id"])).x >= 0


func _close_selected() -> void:
	var ai: Aiuole = m.aiuole
	var o := ai.portal_to(selected)
	if o.x >= 0 and ai.close(o):
		selected = m.world_id
		refresh()
