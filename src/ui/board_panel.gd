class_name BoardPanel
extends Control
## La Bacheca dei Giardinieri aperta (voce 67): quattro richieste come fogli appesi, ognuna con il suo tipo (colore),
## l'oggetto o la meta, una barra di quanto manca, i premi con le loro icone, «Consegna» (quando è pronta; gli oggetti
## anche dalle casse vicine) e «Cambia» (un'altra al suo posto).

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

var m: Node2D
var board: Board
var _cards: Control
var _title: Label
var _dirty := true
var _tex := {}


func setup(main: Node2D, b: Board) -> void:
	m = main
	board = b
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.color = UiPalette.FONDO                 # opaco: la fusione è lineare, al 97% il mondo si vedeva ancora
	bg.size = Vector2(1600, 900)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	_title = Label.new()
	_title.position = Vector2(120, 40)
	_title.add_theme_font_size_override("font_size", UiPalette.TITOLO)
	_title.add_theme_color_override("font_color", UiPalette.AMBRA)
	add_child(_title)
	_cards = Control.new()
	_cards.position = Vector2(120, 110)
	add_child(_cards)
	var hint := Label.new()
	hint.text = "Esc per chiudere · le richieste nascono da ciò che conosci (geni, famiglie, materiali, poteri): più scopri, più sono varie"
	hint.position = Vector2(120, 850)
	hint.add_theme_color_override("font_color", Color("#6a8a84"))
	add_child(hint)


func open() -> void:
	visible = true
	_dirty = true


func _unhandled_input(e: InputEvent) -> void:
	if visible and e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE:
		visible = false
		get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		_refresh()


func _icon(id: String) -> TextureRect:
	if not _tex.has(id):
		_tex[id] = ImageTexture.create_from_image(ItemIcons.of(id))
	var t := TextureRect.new()
	t.texture = _tex[id]
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t


func _label(text: String, pos: Vector2, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l


func _refresh() -> void:
	_title.text = "La Bacheca dei Giardinieri — richieste fatte: %d" % int(m.character.bacheca.get("fatte", 0))
	for c in _cards.get_children():
		c.queue_free()
	var list: Array = board.open_list()
	for i in list.size():
		_card(i, list[i])


func _card(i: int, r: Dictionary) -> void:
	var tipo := String(r["tipo"])
	var kind: Array = KINDS.get(tipo, ["Richiesta", Color("#d8b070")])
	var col: Color = kind[1]
	var ok_now := board.can_deliver(r)
	var card := Panel.new()
	# (voce 280) la cornice del tema tinta del tipo; quella che si può consegnare adesso è «forte» e d'ambra
	card.add_theme_stylebox_override("panel", UiFrames.box("forte", "normale", UiPalette.AMBRA_CHIARA) if ok_now
		else UiFrames.box("riquadro", "normale", Color(col, 0.8)))
	card.position = Vector2((i % 2) * 690, (i / 2) * 330)
	card.size = Vector2(660, 300)
	_cards.add_child(card)
	# il tipo, l'icona grande della cosa chiesta e il testo
	card.add_child(_label(String(kind[0]).to_upper(), Vector2(28, 14), 13, col))
	var what := String(r.get("cosa", "")) if tipo in ["fornitura", "gene", "prodotto", "cielo"] else String(GOAL_ICON.get(tipo, "lumino"))
	var ic := _icon(what)
	ic.position = Vector2(28, 44)
	ic.size = Vector2(64, 64)
	card.add_child(ic)
	var body := Label.new()
	body.text = String(r["testo"])
	body.position = Vector2(110, 44)
	body.size = Vector2(520, 70)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 19)
	body.add_theme_color_override("font_color", Color("#ffe8c0"))
	card.add_child(body)
	# la barra di quanto manca
	var p := board.progress(r)
	var frac := clampf(float(p[0]) / maxf(float(p[1]), 1.0), 0.0, 1.0)
	var bar_bg := ColorRect.new()
	bar_bg.color = col.darkened(0.72)
	bar_bg.position = Vector2(28, 130)
	bar_bg.size = Vector2(500, 14)
	card.add_child(bar_bg)
	var bar := ColorRect.new()
	bar.color = Color("#9ff0b8") if ok_now else col
	bar.position = bar_bg.position
	bar.size = Vector2(500 * frac, 14)
	card.add_child(bar)
	card.add_child(_label("%d / %d" % [int(p[0]), int(p[1])], Vector2(544, 124), 17,
		Color("#9ff0b8") if ok_now else Color("#e0c8a0")))
	# i premi, ognuno con la sua icona
	card.add_child(_label("Premio", Vector2(28, 166), 14, Color("#9fc8c0")))
	var x := 28.0
	for k in r["premio"]:
		var id := "seme_mondo" if k == "seme" else String(k)
		if not ItemsData.get_item(id).has("name"):
			id = "lumino"
		var pic := _icon(id)
		pic.position = Vector2(x, 192)
		pic.size = Vector2(32, 32)
		card.add_child(pic)
		var txt := "Seme con un gene raro" if k == "seme" else "%d %s" % [int(r["premio"][k]), ItemsData.get_item(id)["name"]]
		var l := _label(txt, Vector2(x + 38, 196), 15, Color("#d8f0e8"))
		card.add_child(l)
		x += 38 + l.get_minimum_size().x + 24
	var ok := Button.new()
	ok.text = "Consegna"
	ok.position = Vector2(28, 246)
	ok.size = Vector2(180, 40)
	ok.disabled = not ok_now
	ok.pressed.connect(func() -> void:
		if board.deliver(i):
			m.hud.toast("Richiesta fatta: il premio è nella Bisaccia")
		_dirty = true)
	card.add_child(ok)
	var sw := Button.new()
	sw.text = "Cambia"
	sw.position = Vector2(226, 246)
	sw.size = Vector2(140, 40)
	sw.tooltip_text = "Toglie questa richiesta e ne appende un'altra"
	sw.pressed.connect(func() -> void:
		board.swap(i)
		_dirty = true)
	card.add_child(sw)
