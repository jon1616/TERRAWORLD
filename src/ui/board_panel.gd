class_name BoardPanel
extends UiPage
## La Bacheca dei Giardinieri aperta (voce 67; rifatta nella Roadmap 55 «Il volto chiaro»): quattro richieste come fogli
## appesi, ognuna con il suo tipo (l'etichetta del colore), la cosa chiesta nel medaglione, come si fa, una barra di quanto
## manca, i premi con le loro icone, «Consegna» (quando è pronta; gli oggetti anche dalle casse vicine) e «Cambia».

## Nome e colore di ogni tipo di richiesta.
const KINDS := {
	"fornitura": ["Fornitura", Color("#d8b070")],
	"gene": ["Materiale dei geni", Color("#8ef0d8")],
	"caccia": ["Caccia", Color("#ff8a6a")],
	"mandria": ["Mandria", Color("#b8e070")],
	"prodotto": ["Prodotto della mandria", Color("#f0d060")],
	"firma": ["Firma di un mondo", Color("#c8a0ff")],
	"viaggio": ["Viaggio", Color("#80c0ff")],
	"sigillo": ["Sigillo", Color("#6ff0b8")],
	"cielo": ["Dal cielo", Color("#c8e0ff")],            # Roadmap 16
}
## Icona per le richieste che non chiedono un oggetto.
const GOAL_ICON := {"firma": "mappa_firma", "viaggio": "provetta", "sigillo": "frammento_albero", "caccia": "lumino",
	"mandria": "vasetto"}

const BOARD := Color("#d8b070")

var board: Board
var _grid: GridContainer


func setup(main: Node2D, b: Board) -> void:
	m = main
	board = b
	visible = false
	build_page("La Bacheca dei Giardinieri", "Le richieste nascono da ciò che conosci (geni, famiglie, materiali, poteri): più scopri, più sono varie.",
		ArtLib.tex("interfaccia", "pannello_bacheca") if ArtLib.has("interfaccia", "pannello_bacheca") else null, BOARD)
	set_hints([["Consegna", "quando è pronta: anche dalle casse vicine"], ["Cambia", "un'altra richiesta al suo posto"]])
	_grid = GridContainer.new()
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 24)
	_grid.add_theme_constant_override("v_separation", 22)
	_grid.size = body.size
	body.add_child(_grid)


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


func refresh() -> void:
	set_chips([["%d richieste fatte" % int(m.character.bacheca.get("fatte", 0)), UiPalette.AMBRA]])
	UiKit.clear(_grid)
	var list: Array = board.open_list()
	for i in list.size():
		_grid.add_child(_card(i, list[i]))
	if list.is_empty():
		_grid.columns = 1
		var e := UiKit.empty(ArtLib.tex("interfaccia", "pannello_bacheca") if ArtLib.has("interfaccia", "pannello_bacheca") else null,
			"Nessuna richiesta appesa", "La Bacheca si riempie nel Giardino: quattro richieste alla volta, fatte con ciò che conosci.",
			[["lumino", "I premi: Lumini, materiali, e a volte un Seme di mondo con un gene raro."]], 560.0)
		e.custom_minimum_size = Vector2(body.size.x, body.size.y - 40.0)
		_grid.add_child(e)
	else:
		_grid.columns = 2


func _card(i: int, r: Dictionary) -> Control:
	var tipo := String(r["tipo"])
	var kind: Array = KINDS.get(tipo, ["Richiesta", BOARD])
	var col: Color = kind[1]
	var ok_now := board.can_deliver(r)
	var w := (body.size.x - 24.0) * 0.5
	var card := PanelContainer.new()
	# (voce 280) la cornice tinta del tipo; quella che si può consegnare adesso è «forte» e d'ambra
	card.add_theme_stylebox_override("panel", UiFrames.box("forte", "normale", UiPalette.AMBRA_CHIARA) if ok_now
		else UiFrames.box("riquadro", "normale", Color(col, 0.8)))
	card.custom_minimum_size = Vector2(w, (body.size.y - 22.0) * 0.5)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	card.add_child(vb)
	var top := UiKit.row(8)
	top.add_child(UiKit.chip(String(kind[0]), col))
	if ok_now:
		top.add_child(UiKit.chip("pronta", UiPalette.BUONO))
	vb.add_child(top)
	var row := UiKit.row(16)
	var what := String(r.get("cosa", "")) if tipo in ["fornitura", "gene", "prodotto", "cielo"] else String(GOAL_ICON.get(tipo, "lumino"))
	var md := UiMedal.new()
	md.ring = col
	md.glow = false
	md.icon = TipView.icon_of(what)
	md.custom_minimum_size = Vector2(72, 72)
	row.add_child(md)
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", 4)
	tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tv.add_child(UiKit.para(String(r["testo"]), w - 130.0, 20, UiPalette.TESTO, "forte"))
	# (voce 351) dove si trova o come si fa: il giocatore deve sapere sempre come compiere una richiesta
	var how := HowTo.board_text(r)
	if how != "":
		var hl := UiKit.para(how, w - 130.0, UiPalette.TESTO_PX - 1, UiPalette.TESTO_SPENTO)
		hl.max_lines_visible = 3
		hl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		tv.add_child(hl)
	row.add_child(tv)
	vb.add_child(row)
	var p := board.progress(r)
	var frac := clampf(float(p[0]) / maxf(float(p[1]), 1.0), 0.0, 1.0)
	var pr := UiKit.row(12)
	var bar := UiKit.bar(frac, UiPalette.BUONO if ok_now else col, w - 140.0, 9.0)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pr.add_child(bar)
	pr.add_child(UiKit.label("%d / %d" % [int(p[0]), int(p[1])], UiPalette.GRANDE, UiPalette.BUONO if ok_now else UiPalette.AMBRA_CHIARA, "numeri"))
	vb.add_child(pr)
	var gifts := HFlowContainer.new()
	gifts.add_theme_constant_override("h_separation", 8)
	gifts.add_theme_constant_override("v_separation", 6)
	gifts.add_child(UiKit.caps("Premio"))
	for k in r["premio"]:
		var id := "seme_mondo" if k == "seme" else String(k)
		if not ItemsData.get_item(id).has("name"):
			id = "lumino"
		var txt := "Seme con un gene raro" if k == "seme" else "%d %s" % [int(r["premio"][k]), ItemsData.get_item(id)["name"]]
		gifts.add_child(UiKit.chip(txt, Color(0, 0, 0, 0), TipView.icon_of(id), UiPalette.NOTA + 1))
	vb.add_child(gifts)
	var sp := Control.new()
	sp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(sp)
	var btns := UiKit.row(12)
	var ok := Button.new()
	ok.text = "Consegna"
	ok.custom_minimum_size = Vector2(180, 40)
	ok.disabled = not ok_now
	ok.focus_mode = Control.FOCUS_NONE
	UiFrames.button(ok, Color(0, 0, 0, 0), false, "principale")
	ok.pressed.connect(func() -> void:
		if board.deliver(i):
			m.hud.toast("Richiesta fatta: il premio è nella Bisaccia")
		mark_dirty())
	btns.add_child(ok)
	var sw := Button.new()
	sw.text = "Cambia"
	sw.custom_minimum_size = Vector2(140, 40)
	sw.focus_mode = Control.FOCUS_NONE
	Tips.attach(sw, func() -> Variant: return TipCard.simple("Toglie questa richiesta e ne appende un'altra"))
	sw.pressed.connect(func() -> void:
		board.swap(i)
		mark_dirty())
	btns.add_child(sw)
	vb.add_child(btns)
	return card
