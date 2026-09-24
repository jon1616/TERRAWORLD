class_name Hud
extends CanvasLayer
## Barra rapida degli oggetti (in basso al centro, stile «Radici e Linfa»), nome dell'oggetto scelto, aiuto sui comandi.
## Gli oggetti vengono da `ItemDefs.HOTBAR`.

const SLOT := 56
const GAP := 6
const AMBER := Color("#ffb84a")
const TEAL := Color("#2f7a70")

signal selected(item: Dictionary)

var items: Array[Dictionary] = []
var sel := 0
var _slots: Array[Panel] = []
var _name: Label
var _info: Label
var _toast: Label


func _ready() -> void:
	layer = 10
	var row := HBoxContainer.new()
	var n := ItemDefs.HOTBAR.size()
	row.position = Vector2((1600 - (n * SLOT + (n - 1) * GAP)) / 2.0, 900 - SLOT - 18)
	row.add_theme_constant_override("separation", GAP)
	add_child(row)
	for k in ItemDefs.HOTBAR.size():
		var it: Dictionary = (ItemDefs.HOTBAR[k] as Dictionary).duplicate()
		it["tex"] = ImageTexture.create_from_image(ItemDefs.icon(it))
		items.append(it)
		var pn := Panel.new()
		pn.custom_minimum_size = Vector2(SLOT, SLOT)
		row.add_child(pn)
		var tr := TextureRect.new()
		tr.texture = it["tex"]
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.position = Vector2(4, 4)
		tr.size = Vector2(48, 48)
		pn.add_child(tr)
		var num := _label(pn, Vector2(6, 0), 12)
		num.add_theme_color_override("font_color", Color("#9fd8c8"))
		num.text = str((k + 1) % 10)
		_slots.append(pn)
	_name = _label(self, Vector2(0, 900 - SLOT - 50), 20)
	_name.size = Vector2(1600, 28)
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_color_override("font_color", AMBER)
	_info = _label(self, Vector2(16, 10), 14)
	_info.add_theme_color_override("font_color", Color("#9fc8c0"))
	_toast = _label(self, Vector2(1300, 12), 18)
	_toast.modulate.a = 0.0
	_info.text = "A/D muovi · Spazio salta · clic sinistro usa (scava col piccone) · clic destro torcia · 1-0 / rotella oggetti · Esc salva ed esce\nTutto ciò che vedi è generato dal codice: nessuna immagine esterna."
	select(0)


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#fff4dc"))
	l.add_theme_color_override("font_outline_color", Color(0.02, 0.05, 0.07))
	l.add_theme_constant_override("outline_size", 6)
	parent.add_child(l)
	return l


## Messaggio breve in alto a destra che svanisce da solo.
func toast(text: String) -> void:
	_toast.text = text
	_toast.modulate.a = 1.0
	create_tween().tween_property(_toast, "modulate:a", 0.0, 1.2).set_delay(1.5)


func current() -> Dictionary:
	return items[sel]


func select(k: int) -> void:
	sel = (k + items.size()) % items.size()
	for i in _slots.size():
		var sb := StyleBoxFlat.new()
		var on := i == sel
		sb.bg_color = Color(0.1, 0.2, 0.22, 0.92) if on else Color(0.03, 0.09, 0.11, 0.78)
		sb.set_border_width_all(3 if on else 2)
		sb.border_color = AMBER if on else TEAL
		sb.set_corner_radius_all(18)
		if on:
			sb.shadow_color = Color(1.0, 0.72, 0.3, 0.35)
			sb.shadow_size = 8
		_slots[i].add_theme_stylebox_override("panel", sb)
	_name.text = items[sel]["name"]
	selected.emit(items[sel])


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode >= KEY_0 and e.keycode <= KEY_9:
		select((e.keycode - KEY_0 + 9) % 10)
	elif e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			select(sel - 1)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			select(sel + 1)
