class_name UiPage
extends Control
## Lo scheletro dei pannelli a schermo intero (Roadmap 55 «Il volto chiaro»): tutti uguali, così il giocatore sa sempre
## dove guardare.
##   intestazione  il medaglione della meccanica, il titolo (Alegreya), una riga che dice a cosa serve; a destra i numeri
##                 chiave in etichette tonde (`set_chips`); sotto una riga sottile
##   schede        (facoltative, `set_tabs`) sotto l'intestazione, tutte della stessa forma
##   corpo         `body` (un Control dentro `body_rect()`): lo riempie il pannello
##   piede         i comandi come tasti disegnati (`set_hints`), «Esc chiudi» sempre in fondo a destra
## Lo sfondo copre il mondo (opaco: con `hdr_2d` uno sfondo trasparente lascia vedere troppo) con una luce morbida in alto.
## Un pannello che lo usa chiama `build_page` in `setup` e poi lavora dentro `body`.

const W := 1600.0
const H := 900.0
const M := 48.0
const HEAD := 108.0
const FOOT := 842.0

signal tab_changed(i: int)

var page_title: Label
var page_sub: Label
var medal: UiMedal
var body: Control
var tab_i := 0
var _chips: HBoxContainer
var _tabs: HBoxContainer
var _hints: HBoxContainer
var _esc_hint: HBoxContainer
var _tab_names: Array = []
var accent := UiPalette.AMBRA
## (facoltativi) il gioco, il tasto che apre e chiude, l'elenco e il dettaglio di `split`
var m: Node2D
var key_action := ""
var list: UiList
var detail: UiDetail
var _detail_scroll: ScrollContainer
var _dirty := true


func build_page(title: String, sub: String, icon: Variant = null, col := UiPalette.AMBRA) -> void:
	accent = col
	size = Vector2(W, H)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := UiBackdrop.new()
	bg.tint = col
	bg.size = Vector2(W, H)
	add_child(bg)
	medal = UiMedal.new()
	medal.ring = col
	medal.position = Vector2(M - 4, 22)
	medal.size = Vector2(70, 70)
	if icon != null:
		medal.icon = TipView.icon_of(icon) if not (icon is Texture2D) else icon
	add_child(medal)
	page_title = UiKit.title(title, 34, UiPalette.AMBRA_CHIARA.lerp(col, 0.35))
	page_title.position = Vector2(M + 82, 14)
	add_child(page_title)
	page_sub = UiKit.label(sub, UiPalette.TESTO_PX, UiPalette.TESTO_SPENTO, "chiaro")
	page_sub.position = Vector2(M + 84, 64)
	page_sub.size = Vector2(820, 24)
	page_sub.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	add_child(page_sub)
	_chips = HBoxContainer.new()
	_chips.alignment = BoxContainer.ALIGNMENT_END
	_chips.add_theme_constant_override("separation", 8)
	_chips.position = Vector2(W - M - 640, 42)
	_chips.size = Vector2(640, 30)
	_chips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_chips)
	var rule := UiRule.new()
	rule.fade_both = true
	rule.color = Color(col, 0.35)
	rule.position = Vector2(M, HEAD - 6)
	rule.size = Vector2(W - M * 2, 9)
	add_child(rule)
	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override("separation", 8)
	_tabs.position = Vector2(M, HEAD + 10)
	_tabs.visible = false
	add_child(_tabs)
	body = Control.new()
	body.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(body)
	_place_body()
	var foot := HBoxContainer.new()
	foot.position = Vector2(M, FOOT + 14)
	foot.size = Vector2(W - M * 2, 26)
	foot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(foot)
	_hints = HBoxContainer.new()
	_hints.add_theme_constant_override("separation", 24)
	_hints.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hints.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(_hints)
	_esc_hint = UiKit.hint("Esc", "chiudi")
	foot.add_child(_esc_hint)
	var frule := UiRule.new()
	frule.fade_both = true
	frule.color = Color(UiPalette.BORDO_CHIARO, 0.25)
	frule.position = Vector2(M, FOOT)
	frule.size = Vector2(W - M * 2, 9)
	add_child(frule)


## Il rettangolo del corpo (dove il pannello mette le sue cose), in coordinate del pannello.
func body_rect() -> Rect2:
	var top := HEAD + (62.0 if _tabs.visible else 14.0)
	return Rect2(M, top, W - M * 2, FOOT - 12.0 - top)


func _place_body() -> void:
	var r := body_rect()
	body.position = r.position
	body.size = r.size


## I numeri chiave a destra dell'intestazione: [[testo, colore?, icona?], …].
func set_chips(list: Array) -> void:
	UiKit.clear(_chips)
	for c in list:
		var a: Array = c if c is Array else [c]
		var col: Color = a[1] if a.size() > 1 and a[1] is Color else Color(0, 0, 0, 0)
		var ic: Texture2D = TipView.icon_of(a[2]) if a.size() > 2 and a[2] != null else null
		_chips.add_child(UiKit.chip(String(a[0]), col, ic, UiPalette.TESTO_PX - 1))


## Le schede (nomi, o [nome, contatore]); `tab` = quella aperta. Un clic manda `tab_changed`.
func set_tabs(names: Array, current := 0) -> void:
	_tab_names = names
	tab_i = current
	_tabs.visible = not names.is_empty()
	_place_body()
	_draw_tabs()


func _draw_tabs() -> void:
	UiKit.clear(_tabs)
	for i in _tab_names.size():
		var n: Variant = _tab_names[i]
		var b := Button.new()
		b.text = String(n[0]) if n is Array else String(n)
		if n is Array and n.size() > 1 and String(n[1]) != "":
			b.text += "  ·  " + String(n[1])
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(150, 36)
		UiFrames.button(b, Color(0, 0, 0, 0), i == tab_i)
		b.add_theme_color_override("font_color", UiPalette.AMBRA_CHIARA if i == tab_i else UiPalette.TESTO_SPENTO)
		b.add_theme_font_override("font", UiFonts.get_font("forte"))
		b.add_theme_font_size_override("font_size", UiPalette.TESTO_PX)
		var k := i
		b.pressed.connect(func() -> void: choose_tab(k))
		_tabs.add_child(b)


func choose_tab(i: int) -> void:
	if i == tab_i or i < 0 or i >= _tab_names.size():
		return
	tab_i = i
	_draw_tabs()
	tab_changed.emit(i)


## I comandi del piede: [[tasto, che cosa fa], …] («Esc chiudi» c'è sempre).
func set_hints(pairs: Array) -> void:
	UiKit.clear(_hints)
	for pr in pairs:
		_hints.add_child(UiKit.hint(String(pr[0]), String(pr[1])))


## Divide il corpo: a sinistra l'elenco (`list`), a destra il dettaglio che scorre (`detail`). Le schede vanno messe prima.
func split(list_w := 420.0) -> void:
	var r := body_rect()
	list = UiList.new()
	list.size = Vector2(list_w, r.size.y)
	body.add_child(list)
	_detail_scroll = ScrollContainer.new()
	_detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_detail_scroll.position = Vector2(list_w + 40.0, 0)
	_detail_scroll.size = Vector2(r.size.x - list_w - 40.0, r.size.y)
	body.add_child(_detail_scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_right", 22)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_scroll.add_child(pad)
	detail = UiDetail.new()
	pad.add_child(detail)


## La larghezza utile del dettaglio.
func detail_w() -> float:
	return _detail_scroll.size.x - 40.0 if _detail_scroll != null else body.size.x


## Il dettaglio torna in cima (scegliendo un'altra voce).
func detail_top() -> void:
	if _detail_scroll != null:
		_detail_scroll.scroll_vertical = 0


func open() -> void:
	visible = true
	_dirty = true
	on_open()
	get_parent().move_child(self, -1)


func on_open() -> void:
	pass


func close() -> void:
	visible = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func mark_dirty() -> void:
	_dirty = true


## Si può aprire con il tasto adesso? (Non con la Bisaccia aperta.)
func can_open() -> bool:
	return m == null or m.get("hud") == null or not m.hud.panel.visible


func _unhandled_input(e: InputEvent) -> void:
	if key_action == "" or not (e is InputEventKey and e.pressed and not e.echo):
		return
	if visible and (e.keycode == KEY_ESCAPE or Keys.pressed(e, key_action)):
		close()
		get_viewport().set_input_as_handled()
	elif not visible and Keys.pressed(e, key_action) and can_open():
		open()
		get_viewport().set_input_as_handled()


func _process(_dt: float) -> void:
	if visible and _dirty:
		_dirty = false
		refresh()


## Ridisegna il pannello (lo scrive chi lo usa).
func refresh() -> void:
	pass


## Tutto il testo che il pannello mostra adesso (le prove lo leggono per controllare che una cosa ci sia).
func shown_text() -> String:
	var out := []
	_collect(self, out)
	return "\n".join(out)


static func _collect(n: Node, out: Array) -> void:
	if n is CanvasItem and not (n as CanvasItem).visible:
		return
	if n is RichTextLabel:
		out.append((n as RichTextLabel).get_parsed_text())
	elif n is Label:
		out.append((n as Label).text)
	elif n is UiList:
		for it in (n as UiList).items:
			out.append("%s %s %s" % [it.get("title", ""), it.get("sub", ""), it.get("badge", "")])
	for ch in n.get_children():
		_collect(ch, out)



## Accende una scheda senza mandare `tab_changed` (quando la sceglie il codice, non il giocatore).
func select_tab(i: int) -> void:
	if i != tab_i and i >= 0 and i < _tab_names.size():
		tab_i = i
		_draw_tabs()


## Senza voci nell'elenco il dettaglio prende tutto il corpo (il vuoto spiegato al centro, non mezzo schermo nero).
func list_shown(on: bool) -> void:
	if list == null or list.visible == on:
		return
	list.visible = on
	var r := body_rect()
	var lw := list.size.x + 40.0 if on else 0.0
	_detail_scroll.position.x = lw
	_detail_scroll.size.x = r.size.x - lw
