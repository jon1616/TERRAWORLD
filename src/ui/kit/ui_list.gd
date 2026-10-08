class_name UiList
extends ScrollContainer
## L'elenco a sinistra dei pannelli (Roadmap 55): schedine tutte uguali, una per cosa (un pilastro, un mondo, una
## creatura…): la striscia del suo colore, l'icona, il nome, una riga sotto, un'etichetta a destra (il grado, «nuovo»,
## «sei qui»), una barra di avanzamento. Disegnate da sé (centinaia di righe costano poco), scorrono con la rotella.
## `set_items([{id, title, sub, badge, badge_col, frac, color, icon, dim, on, header}, …])`; `selected` = l'id scelto;
## un clic manda `chosen(id)`. «header» = un titoletto tra le righe (non si sceglie); «on» = la riga è accesa anche se
## non è quella scelta (le scelte multiple: i due Semi del Banco dell'Innestatrice).

signal chosen(id: String)

const ROW := 72.0
const GAP := 6.0

var items: Array = []
var selected := ""
var row_h := ROW
var _canvas: Control
var _hover := -1
var _tops: Array = []                     # dove comincia ogni riga (le righe-titolo sono più basse)
const HEAD_H := 34.0
static var _icons := {}


func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_canvas = Control.new()
	_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	_canvas.draw.connect(_draw_rows)
	_canvas.gui_input.connect(_on_input)
	_canvas.mouse_exited.connect(func() -> void:
		_hover = -1
		_canvas.queue_redraw())
	add_child(_canvas)


func set_items(list: Array, sel := "") -> void:
	items = list
	for it in items:
		# le icone diventano texture una volta sola (una creata dentro il disegno sparisce prima di essere mostrata)
		if it.has("icon") and it["icon"] != null and not (it["icon"] is Texture2D):
			it["icon"] = TipView.icon_of(it["icon"])
	if sel != "":
		selected = sel
	_tops.clear()
	var y := 0.0
	for it in items:
		_tops.append(y)
		y += (HEAD_H if it.get("header", false) else row_h) + GAP
	_canvas.custom_minimum_size = Vector2(size.x - 12.0, maxf(y, 1.0))
	_canvas.queue_redraw()


func _row_at(py: float) -> int:
	for i in range(_tops.size() - 1, -1, -1):
		if py >= float(_tops[i]):
			var h := HEAD_H if items[i].get("header", false) else row_h
			return i if py <= float(_tops[i]) + h else -1
	return -1


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _canvas != null:
		_canvas.custom_minimum_size.x = size.x - 12.0
		_canvas.queue_redraw()


func _on_input(e: InputEvent) -> void:
	if e is InputEventMouseMotion:
		var i := _row_at(e.position.y)
		if i != _hover:
			_hover = i
			_canvas.queue_redraw()
	elif e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
		var i := _row_at(e.position.y)
		if i >= 0 and i < items.size() and not items[i].get("header", false):
			selected = String(items[i].get("id", ""))
			_canvas.queue_redraw()
			chosen.emit(selected)
			_canvas.accept_event()


## L'indice della riga di un id (per scorrere fino a lei).
func index_of(id: String) -> int:
	for i in items.size():
		if String(items[i].get("id", "")) == id:
			return i
	return -1


func _icon(v: Variant) -> Texture2D:
	if v == null:
		return null
	if v is Texture2D:
		return v
	return TipView.icon_of(v)


func _draw_rows() -> void:
	var w := _canvas.size.x
	var f_name := UiFonts.get_font("forte")
	var f_sub := UiFonts.get_font("chiaro")
	for i in items.size():
		var it: Dictionary = items[i]
		var y: float = _tops[i] if i < _tops.size() else i * (row_h + GAP)
		if it.get("header", false):
			var hf := UiFonts.get_font("forte")
			var ht := String(it.get("title", "")).to_upper()
			_canvas.draw_string(hf, Vector2(4, y + 22.0), ht, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, it.get("color", UiPalette.TESTO_MUTO))
			var tx := hf.get_string_size(ht, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x + 16.0
			_canvas.draw_line(Vector2(tx, y + 17.5), Vector2(w - 4.0, y + 17.5), Color(UiPalette.BORDO_CHIARO, 0.3), 1.0, true)
			continue
		var col: Color = it.get("color", UiPalette.BORDO_CHIARO)
		var sel := String(it.get("id", "")) == selected or bool(it.get("on", false))
		var dim := bool(it.get("dim", false))
		var r := Rect2(0, y, w, row_h)
		var tint := 0.30 if sel else (0.2 if i == _hover else 0.1)
		if sel:
			# l'alone prima del riquadro: il riquadro ne copre l'interno (l'ombra di uno StyleBoxFlat si vede anche dentro)
			var glow := StyleBoxFlat.new()
			glow.bg_color = Color(0, 0, 0, 0)
			glow.set_corner_radius_all(8)
			glow.shadow_color = Color(col, 0.28)
			glow.shadow_size = 9
			glow.anti_aliasing = true
			_canvas.draw_style_box(glow, r)
		_canvas.draw_style_box(UiFrames.box("sezione", "normale", Color(col, tint)), r)
		if sel:
			var edge := StyleBoxFlat.new()
			edge.bg_color = Color(0, 0, 0, 0)
			edge.border_color = Color(col, 0.85)
			edge.set_border_width_all(1)
			edge.set_corner_radius_all(8)
			edge.anti_aliasing = true
			_canvas.draw_style_box(edge, r)
		# la striscia del colore
		var stripe := StyleBoxFlat.new()
		stripe.bg_color = Color(col, 0.95 if not dim else 0.4)
		stripe.set_corner_radius_all(2)
		stripe.anti_aliasing = true
		_canvas.draw_style_box(stripe, Rect2(6, y + 10, 3, row_h - 20))
		var x := 20.0
		var ic := _icon(it.get("icon"))
		if ic != null:
			var s := 38.0
			var rr := Rect2(x, y + (row_h - s) * 0.5, s, s)
			_canvas.draw_texture_rect(ic, rr, false, Color(1, 1, 1, 0.55 if dim else 1.0))
			x += s + 12.0
		var badge := String(it.get("badge", ""))
		var bw := 0.0
		if badge != "":
			bw = f_name.get_string_size(badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x + 20.0
			var bc: Color = it.get("badge_col", col)
			var chip := StyleBoxFlat.new()
			chip.bg_color = Color(bc.darkened(0.72), 0.95)
			chip.border_color = Color(bc, 0.8)
			chip.set_border_width_all(1)
			chip.set_corner_radius_all(12)
			chip.anti_aliasing = true
			var cr := Rect2(w - bw - 12.0, y + 12.0, bw, 24.0)
			_canvas.draw_style_box(chip, cr)
			_canvas.draw_string(f_name, Vector2(cr.position.x + 10.0, cr.position.y + 17.0), badge, HORIZONTAL_ALIGNMENT_LEFT,
				-1, 15, bc.lightened(0.35))
		var tw := w - x - bw - 28.0
		var title := String(it.get("title", ""))
		var tcol := UiPalette.AMBRA_CHIARA if sel else (UiPalette.TESTO_SPENTO if dim else UiPalette.TESTO)
		var sub := String(it.get("sub", ""))
		var has_bar := it.has("frac")
		var ty := y + (25.0 if sub != "" or has_bar else row_h * 0.5 + 6.0)
		_canvas.draw_string(f_name, Vector2(x, ty), title, HORIZONTAL_ALIGNMENT_LEFT, tw, 17, tcol)
		if sub != "":
			_canvas.draw_string(f_sub, Vector2(x, ty + 19.0), sub, HORIZONTAL_ALIGNMENT_LEFT, w - x - 16.0, 14,
				UiPalette.TESTO_MUTO)
		if has_bar:
			var by := y + row_h - 13.0
			var bar := Rect2(x, by, w - x - 16.0, 6.0)
			var track := StyleBoxFlat.new()
			track.bg_color = Color(0, 0, 0, 0.45)
			track.set_corner_radius_all(3)
			track.anti_aliasing = true
			_canvas.draw_style_box(track, bar)
			var fr := clampf(float(it["frac"]), 0.0, 1.0)
			if fr > 0.0:
				var fill := StyleBoxFlat.new()
				fill.bg_color = col
				fill.set_corner_radius_all(3)
				fill.anti_aliasing = true
				_canvas.draw_style_box(fill, Rect2(bar.position, Vector2(maxf(bar.size.x * fr, 6.0), 6.0)))
