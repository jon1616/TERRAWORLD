class_name MiningCursor
extends Node2D
## Riquadro della tessera puntata e crepe mentre la si scava.

var cell := Vector2i(-1, -1)
var active := false
var progress := 0.0
var _cracks: Array = []


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in 6:
		var p := Vector2(8, 8)
		var segs: Array[Vector2] = [p]
		var ang := k / 6.0 * TAU + rng.randf_range(-0.4, 0.4)
		for s in 3:
			ang += rng.randf_range(-0.6, 0.6)
			p += Vector2(cos(ang), sin(ang)) * rng.randf_range(2.0, 3.5)
			segs.append(p)
		_cracks.append(segs)


func set_state(c: Vector2i, on: bool, prog: float) -> void:
	if c != cell or on != active or absf(prog - progress) > 0.01:
		cell = c
		active = on
		progress = prog
		queue_redraw()


func _draw() -> void:
	if not active:
		return
	var o := Vector2(cell) * 16.0
	draw_rect(Rect2(o, Vector2(16, 16)), Color(1, 0.95, 0.8, 0.6), false, 1.0)
	if progress <= 0.0:
		return
	var n := int(ceil(progress * _cracks.size()))
	for k in mini(n, _cracks.size()):
		var segs: Array = _cracks[k]
		for s in segs.size() - 1:
			draw_line(o + segs[s], o + segs[s + 1], Color(0.05, 0.03, 0.02, 0.75), 1.0)
