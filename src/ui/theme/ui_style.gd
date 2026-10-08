class_name UiStyle
extends StyleBox
## Una cornice dell'interfaccia (Roadmap 55 «Il volto chiaro»): disegnata a vettori, nitida a ogni grandezza dello
## schermo (prima era un'immagine a pixel doppi stirata). Sopra il riquadro di base (`flat`: fondo, bordo sottile, angoli
## morbidi, ombra) aggiunge ciò che lo rende vivo:
##   sheen   una luce appena accennata che scende dall'alto (il vetro dell'inchiostro)
##   thread  il filo luminoso sul bordo alto, che sfuma ai lati (Linfa per i riquadri, ambra per i principali)
##   glow    un alone del colore dell'accento (ciò che è scelto)
##   gem     una piccola gemma al centro del filo (i pannelli principali)

var flat := StyleBoxFlat.new()
var glow := Color(0, 0, 0, 0)
var thread := Color(0, 0, 0, 0)
var sheen := 0.0
var gem := false
var _glow_box: StyleBoxFlat


func setup(fill: Color, border: Color, radius: int, shadow: int, bw := 1) -> UiStyle:
	flat.bg_color = fill
	flat.border_color = border
	flat.set_border_width_all(bw)
	flat.set_corner_radius_all(radius)
	flat.corner_detail = 8
	flat.anti_aliasing = true
	flat.anti_aliasing_size = 0.8
	if shadow > 0:
		flat.shadow_color = Color(0, 0, 0, 0.42)
		flat.shadow_size = shadow
		flat.shadow_offset = Vector2(0, roundf(shadow * 0.3))
	return self


func set_glow(c: Color) -> UiStyle:
	glow = c
	if c.a > 0.0:
		_glow_box = StyleBoxFlat.new()
		_glow_box.bg_color = Color(0, 0, 0, 0)
		_glow_box.set_corner_radius_all(flat.corner_radius_top_left)
		_glow_box.shadow_color = c
		_glow_box.shadow_size = 9
		_glow_box.anti_aliasing = true
	return self


func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow(float(maxi(flat.shadow_size, 10)))


func _draw(ci: RID, rect: Rect2) -> void:
	if _glow_box != null:
		_glow_box.draw(ci, rect)
	flat.draw(ci, rect)
	var r := float(flat.corner_radius_top_left)
	if sheen > 0.0 and rect.size.y >= 80.0:
		# la luce dall'alto (solo i riquadri alti: sui pulsanti faceva una banda): sotto gli angoli, sfuma in 90 px
		var ya := rect.position.y + r * 0.6
		var y1 := rect.position.y + minf(rect.size.y * 0.4, 110.0)
		var x0 := rect.position.x + 1.0
		var x1 := rect.end.x - 1.0
		var top := Color(1, 1, 1, sheen)
		var bot := Color(1, 1, 1, 0)
		RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array([Vector2(x0 + r * 0.5, ya), Vector2(x1 - r * 0.5, ya),
			Vector2(x1, y1), Vector2(x0, y1)]), PackedColorArray([top, top, bot, bot]))
	if thread.a > 0.0 and rect.size.x > r * 2.0 + 8.0:
		# il filo: trasparente ai lati, pieno al centro
		var y := rect.position.y + float(flat.border_width_top) * 0.5
		var xa := rect.position.x + r
		var xb := rect.end.x - r
		var xm := (xa + xb) * 0.5
		var c0 := Color(thread, 0.0)
		var pts := PackedVector2Array([Vector2(xa, y), Vector2(xm, y), Vector2(xb, y)])
		var cols := PackedColorArray([c0, thread, c0])
		RenderingServer.canvas_item_add_polyline(ci, pts, cols, 1.6, true)
		if gem:
			var g := Color(thread, minf(thread.a * 1.6, 1.0))
			var s := 4.0
			RenderingServer.canvas_item_add_polygon(ci, PackedVector2Array([Vector2(xm, y - s), Vector2(xm + s, y),
				Vector2(xm, y + s), Vector2(xm - s, y)]), PackedColorArray([g, g, g, g]))
