class_name UiBar
extends Control
## Una barra morbida (Roadmap 55): la scanalatura scura, il riempimento del suo colore con una luce in alto, gli angoli
## tondi. `marks` = le tacche (frazioni 0-1) dei traguardi lungo la barra.

var frac := 0.0:
	set(v):
		frac = clampf(v, 0.0, 1.0)
		queue_redraw()
var color := UiPalette.LINFA
var marks: Array = []


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var h := size.y
	var r := h * 0.5
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0, 0, 0, 0.45)
	track.border_color = Color(UiPalette.BORDO, 0.7)
	track.set_border_width_all(1)
	track.set_corner_radius_all(int(r))
	track.anti_aliasing = true
	draw_style_box(track, Rect2(Vector2.ZERO, size))
	if frac > 0.0:
		var w := maxf(size.x * frac, h)
		var fill := StyleBoxFlat.new()
		fill.bg_color = color
		fill.set_corner_radius_all(int(r))
		fill.anti_aliasing = true
		draw_style_box(fill, Rect2(0, 0, w, h))
		if h >= 6.0:
			var hi := StyleBoxFlat.new()
			hi.bg_color = Color(1, 1, 1, 0.22)
			hi.set_corner_radius_all(int(r * 0.6))
			hi.anti_aliasing = true
			draw_style_box(hi, Rect2(r * 0.6, 1.0, maxf(w - r * 1.2, 1.0), maxf(h * 0.3, 1.0)))
	for mk in marks:
		var x := roundf(size.x * float(mk)) + 0.5
		draw_line(Vector2(x, 1), Vector2(x, h - 1), Color(UiPalette.FONDO, 0.85), 1.0)
