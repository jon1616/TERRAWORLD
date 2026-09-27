class_name FiloMarker
extends Control
## Il segno del filo (`Filo.target`): sopra il posto, se si vede, un rombo che ondeggia; se è fuori dallo schermo, una
## freccia sul bordo che punta verso di lui con la distanza; «più in basso», una freccia in basso con lo strato.

const COL := Color("#ffd08a")
const EDGE := 46.0

var filo: Filo
var _time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(dt: float) -> void:
	_time += dt
	if visible and not filo.target.is_empty():
		queue_redraw()


func _draw() -> void:
	if filo == null or filo.target.is_empty():
		return
	var vs := get_viewport_rect().size
	var font := ThemeDB.fallback_font
	if filo.target.has("down"):
		var at := Vector2(vs.x / 2.0, vs.y - 150.0 + sin(_time * 4.0) * 5.0)
		_arrow(at, Vector2.DOWN, 1.0)
		_text(font, at + Vector2(0, -22), "giù: %s" % StrataData.STRATA[int(filo.target["down"])]["name"])
		return
	var cell: Vector2i = filo.target["cell"]
	var world_p := Vector2(cell) * 16.0 + Vector2(8, 8)
	var p := get_viewport().get_canvas_transform() * world_p
	var inside := Rect2(Vector2(EDGE, EDGE), vs - Vector2(EDGE, EDGE) * 2.0)
	if inside.has_point(p):
		var bob := sin(_time * 5.0) * 4.0
		var c := p + Vector2(0, -26 + bob)
		draw_colored_polygon(PackedVector2Array([c + Vector2(0, -8), c + Vector2(7, 0), c + Vector2(0, 8), c + Vector2(-7, 0)]), COL)
		draw_polyline(PackedVector2Array([c + Vector2(0, -8), c + Vector2(7, 0), c + Vector2(0, 8), c + Vector2(-7, 0),
			c + Vector2(0, -8)]), Color(0.05, 0.05, 0.08), 1.5)
		return
	# fuori dallo schermo: sul bordo, verso di lui
	var mid := vs / 2.0
	var dir := (p - mid).normalized()
	var k := INF
	if absf(dir.x) > 0.001:
		k = minf(k, (inside.size.x / 2.0) / absf(dir.x))
	if absf(dir.y) > 0.001:
		k = minf(k, (inside.size.y / 2.0) / absf(dir.y))
	var at := mid + dir * k
	_arrow(at, dir, 1.0 + sin(_time * 5.0) * 0.08)
	var pc: Vector2i = filo.m.player_cell()
	var dist := roundi(Vector2(cell - pc).length())
	_text(font, at - dir * 30.0, "%d m" % dist)


func _arrow(at: Vector2, dir: Vector2, s: float) -> void:
	var side := Vector2(-dir.y, dir.x)
	var tip := at + dir * 14.0 * s
	var pts := PackedVector2Array([tip, at - dir * 8.0 * s + side * 11.0 * s, at - dir * 3.0 * s, at - dir * 8.0 * s - side * 11.0 * s])
	draw_colored_polygon(pts, COL)
	pts.append(tip)
	draw_polyline(pts, Color(0.05, 0.05, 0.08), 2.0)


func _text(font: Font, at: Vector2, t: String) -> void:
	var w := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
	var p := at - Vector2(w / 2.0, -5)
	draw_string_outline(font, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 5, Color(0.02, 0.05, 0.07))
	draw_string(font, p, t, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COL)
