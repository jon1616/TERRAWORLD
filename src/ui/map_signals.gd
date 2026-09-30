class_name MapSignals
extends PanelContainer
## I segnali del giocatore sulla mappa (30 set 2026, richiesta dell'utente): triangoli del colore scelto con un nome
## scritto a mano. Clic destro su un punto della mappa = segnale nuovo; clic destro su un segnale = cambialo o toglilo.
## Ogni mondo tiene i suoi in `world_meta["segnali"]` = [{x, y, c: colore «rrggbb», n: nome}]. Questo nodo è la
## finestrella che li scrive; `MapPanel` li disegna (e ne mostra il nome sotto il mouse), `Minimap` pure.

const COLORS := ["ff4a4a", "ff7a3a", "ffb84a", "ffe04a", "d8ff5a", "8aff5a", "3ae07a", "3ad8b0",
	"4ae8e8", "4ab8ff", "4a7aff", "7a5aff", "b05aff", "e85ad8", "ff5aa0", "ffffff",
	"c8b89a", "a07050", "8a8a8a", "5a3a2a"]

var m: Node2D
var index := -1                        # il segnale che si cambia (-1 = uno nuovo)
var cell := Vector2i.ZERO              # dove va il segnale nuovo
var color := "ffb84a"
var _name: LineEdit
var _swatches: Array[Button] = []
var _title: Label
var _remove: Button
var _ok: Button


## I segnali di un mondo (li crea se mancano).
static func list(meta: Dictionary) -> Array:
	if not meta.has("segnali"):
		meta["segnali"] = []
	return meta["segnali"]


static func pos_of(s: Dictionary) -> Vector2:
	return Vector2(int(s.get("x", 0)), int(s.get("y", 0))) + Vector2(0.5, 0.5)


static func name_of(s: Dictionary) -> String:
	var n := String(s.get("n", "")).strip_edges()
	return n if n != "" else "Segnale senza nome"


func setup(main: Node2D) -> void:
	m = main
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", UiFrames.padded("forte", "normale", Color(0, 0, 0, 0), Vector2(18, 14)))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	add_child(box)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", UiPalette.SOTTOTITOLO)
	_title.add_theme_color_override("font_color", UiPalette.AMBRA_CHIARA)
	box.add_child(_title)
	_name = LineEdit.new()
	_name.placeholder_text = "Nome del segnale (per esempio «vena d'ambra»)"
	_name.max_length = 40
	_name.custom_minimum_size = Vector2(380, 0)
	_name.text_submitted.connect(func(_t: String) -> void: confirm())
	box.add_child(_name)
	var grid := GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	box.add_child(grid)
	for c in COLORS:
		var b := Button.new()
		b.custom_minimum_size = Vector2(34, 30)
		b.focus_mode = Control.FOCUS_NONE
		var col := String(c)
		b.draw.connect(func() -> void: MapSignals.triangle(b, b.size * 0.5 + Vector2(0, 1), Color(col), 8.0))
		b.pressed.connect(func() -> void: pick(col))
		grid.add_child(b)
		_swatches.append(b)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_END
	box.add_child(row)
	_remove = _button(row, "Togli", func() -> void: remove())
	_button(row, "Annulla", func() -> void: close())
	_ok = _button(row, "Metti", func() -> void: confirm())


func _button(row: HBoxContainer, text: String, f: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	UiFrames.button(b)
	b.pressed.connect(f)
	row.add_child(b)
	return b


## Un triangolo con la punta in su, bordato di scuro (sulla mappa, nella minimappa e nei bottoni dei colori).
static func triangle(ci: CanvasItem, p: Vector2, col: Color, r: float) -> void:
	var o := r + 2.5
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -o * 1.15), p + Vector2(o, o * 0.75), p + Vector2(-o, o * 0.75)]),
		Color(0.02, 0.03, 0.05))
	ci.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r * 1.15), p + Vector2(r, r * 0.75), p + Vector2(-r, r * 0.75)]), col)


## Un segnale nuovo nella cella `c`.
func open_new(c: Vector2i, at: Vector2) -> void:
	index = -1
	cell = c
	_name.text = ""
	_open(at, "Segnale nuovo", "Metti")


## Il segnale numero `i` di questo mondo, da cambiare o togliere.
func open_edit(i: int, at: Vector2) -> void:
	var s: Dictionary = list(m.world_meta)[i]
	index = i
	cell = Vector2i(int(s["x"]), int(s["y"]))
	color = String(s.get("c", color))
	_name.text = String(s.get("n", ""))
	_open(at, "Cambia il segnale", "Salva")


func _open(at: Vector2, title: String, ok: String) -> void:
	_title.text = title
	_ok.text = ok
	_remove.visible = index >= 0
	pick(color)
	visible = true
	reset_size()
	var vs := get_parent_area_size()
	position = Vector2(clampf(at.x + 16.0, 8.0, vs.x - size.x - 8.0), clampf(at.y - size.y * 0.5, 8.0, vs.y - size.y - 8.0))
	_name.grab_focus()
	_name.caret_column = _name.text.length()


func pick(c: String) -> void:
	color = c
	for k in _swatches.size():
		UiFrames.button(_swatches[k], Color(COLORS[k]), COLORS[k] == c)
		_swatches[k].queue_redraw()


func confirm() -> void:
	var s := {"x": cell.x, "y": cell.y, "c": color, "n": _name.text.strip_edges()}
	var all := list(m.world_meta)
	if index >= 0 and index < all.size():
		all[index] = s
	else:
		all.append(s)
	close()


func remove() -> void:
	var all := list(m.world_meta)
	if index >= 0 and index < all.size():
		all.remove_at(index)
	close()


func close() -> void:
	visible = false
	_name.release_focus()
	var p := get_parent() as Control
	if p != null:
		p.queue_redraw()
