class_name HarshBar
extends Control
## La barra del rigore (voce 93): a sinistra di Vita e Linfa, compare solo quando una barra di `Harshness` non è
## vuota. Nome del rigore, quanto protegge l'equipaggiamento, e la barra nel colore del rigore (pulsa quando è piena).

const W := 230.0
const H := 34.0

var hs: Harshness
var _font: Font
var _t := 0.0


func setup(h: Harshness) -> void:
	hs = h
	_font = ThemeDB.fallback_font
	position = Vector2(1600.0 - 16.0 - 224.0 - 10.0 - W, VitalsView.TOP)      # a sinistra della minimappa
	size = Vector2(W, H)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _top() -> String:
	var best := ""
	for k in hs.meters:
		if float(hs.meters[k]) > 0.005 and (best == "" or k == hs.kind or float(hs.meters[k]) > float(hs.meters[best])):
			best = k
	return best


func _process(dt: float) -> void:
	_t += dt
	var k := _top()
	visible = k != ""
	if visible:
		queue_redraw()


func _draw() -> void:
	var k := _top()
	if k == "":
		return
	var kd: Dictionary = HarshData.KINDS[k]
	var v := float(hs.meters[k])
	var col := Color(String(kd["color"]))
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.03, 0.06, 0.07, 0.86)
	box.border_color = col.darkened(0.3)
	box.set_border_width_all(1)
	box.set_corner_radius_all(4)
	draw_style_box(box, Rect2(Vector2.ZERO, size))
	var s := hs.shield(k)
	var label := String(kd["name"]) + ("  · protetto %d%%" % roundi(s * 100.0) if s > 0.0 else "")
	# voce 101: l'icona del rigore (16 px) a sinistra, se c'è
	var ic := ArtLib.tex("interfaccia", k)
	var x0 := 8.0
	if ic != null:
		draw_texture(ic, Vector2(6, (H - 16.0) * 0.5).round())
		x0 = 28.0
	draw_string(_font, Vector2(x0, 13), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, col.lightened(0.3))
	var r := Rect2(x0, 18, W - x0 - 8.0, 10)
	draw_rect(r, Color(0, 0, 0, 0.5))
	var c := col if v < 1.0 else col.lerp(Color.WHITE, 0.35 + 0.35 * sin(_t * 8.0))
	draw_rect(Rect2(r.position, Vector2(r.size.x * v, r.size.y)), c)
