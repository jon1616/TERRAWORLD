class_name UiRule
extends Control
## Una riga sottile che sfuma verso destra (dopo il titoletto di una sezione, sotto l'intestazione di un pannello).

var color := Color(UiPalette.BORDO_CHIARO, 0.45)
var fade_both := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 9)


func _draw() -> void:
	var y := roundf(size.y * 0.5) + 0.5
	var c0 := Color(color, 0.0)
	var pts := PackedVector2Array([Vector2(0, y), Vector2(size.x * 0.5, y), Vector2(size.x, y)])
	var cols := PackedColorArray([c0 if fade_both else color, color, c0])
	draw_polyline_colors(pts, cols, 1.0, true)
