class_name Hud
extends CanvasLayer
## Barra rapida degli oggetti, nome dell'oggetto scelto, aiuto sui comandi. Gli oggetti vengono da `ItemDefs.HOTBAR`.

signal selected(item: Dictionary)

var items: Array[Dictionary] = []
var sel := 0
var _slots: Array[Panel] = []
var _name: Label
var _info: Label


func _ready() -> void:
	layer = 10
	var row := HBoxContainer.new()
	row.position = Vector2(20, 40)
	row.add_theme_constant_override("separation", 6)
	add_child(row)
	for k in ItemDefs.HOTBAR.size():
		var it: Dictionary = (ItemDefs.HOTBAR[k] as Dictionary).duplicate()
		it["tex"] = ImageTexture.create_from_image(ItemDefs.icon(it))
		items.append(it)
		var pn := Panel.new()
		pn.custom_minimum_size = Vector2(60, 60)
		row.add_child(pn)
		var tr := TextureRect.new()
		tr.texture = it["tex"]
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.position = Vector2(6, 6)
		tr.size = Vector2(48, 48)
		pn.add_child(tr)
		var num := _label(pn, Vector2(5, 1), 13)
		num.text = str((k + 1) % 10)
		_slots.append(pn)
	_name = _label(self, Vector2(22, 8), 20)
	_info = _label(self, Vector2(20, 820), 16)
	_info.text = "A/D muovi · Spazio salta · clic sinistro usa (scava col piccone) · clic destro torcia · 1-0 / rotella oggetti · R mondo nuovo\nTutto ciò che vedi è generato dal codice: nessuna immagine esterna."
	select(0)


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#fff4dc"))
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.1))
	l.add_theme_constant_override("outline_size", 6)
	parent.add_child(l)
	return l


func current() -> Dictionary:
	return items[sel]


func select(k: int) -> void:
	sel = (k + items.size()) % items.size()
	for i in _slots.size():
		var sb := StyleBoxFlat.new()
		var on := i == sel
		sb.bg_color = Color(0.22, 0.2, 0.36, 0.9) if on else Color(0.1, 0.12, 0.26, 0.78)
		sb.set_border_width_all(3 if on else 2)
		sb.border_color = Color("#f2cc5a") if on else Color(0.36, 0.42, 0.72)
		sb.set_corner_radius_all(6)
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
