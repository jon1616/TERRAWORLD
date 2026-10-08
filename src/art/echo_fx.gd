class_name EchoFx
extends Node2D
## Un eco (Roadmap 36, voce 344; scene in `EchoesData`): due sagome di luce alte e sottili, le mani lunghe come radici,
## che compaiono, si dicono le loro battute (scritte sopra chi parla, nel suo colore) e svaniscono. Sopra il buio: le
## sagome sono fatte di Linfa. Si libera da sola.

var lines: Array = []                    # [[chi, battuta], …]
var _who: Array[String] = []             # le sagome (al più due), nell'ordine in cui parlano
var _t := 0.0
var _label: Label
var _total := 0.0


func setup(scene: Array) -> void:
	lines = scene
	for l in lines:
		if not String(l[0]) in _who and _who.size() < 2:
			_who.append(String(l[0]))
	_total = 1.0 + lines.size() * EchoesData.LINE_TIME + 1.5
	z_as_relative = false
	z_index = 30
	_label = Label.new()
	_label.size = Vector2(220, 12)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_label)


func _process(dt: float) -> void:
	_t += dt
	if _t >= _total:
		queue_free()
		return
	var i := int((_t - 1.0) / EchoesData.LINE_TIME)
	if _t >= 1.0 and i < lines.size():
		var who := String(lines[i][0])
		var sp := EchoesData.speaker(who)
		UiFonts.world(_label, 9, Color(String(sp["color"])).lightened(0.3))      # (Roadmap 55)
		_label.text = String(lines[i][1])
		_label.position = Vector2(_x_of(who) - 110.0, -64.0)
		var k := (_t - 1.0) - i * EchoesData.LINE_TIME
		_label.modulate.a = clampf(minf(k / 0.3, (EchoesData.LINE_TIME - k) / 0.3), 0.0, 1.0)
	else:
		_label.modulate.a = 0.0
	queue_redraw()


func _x_of(who: String) -> float:
	if _who.size() < 2:
		return 0.0
	return -14.0 if who == _who[0] else 14.0


func _draw() -> void:
	var a := clampf(minf(_t / 1.0, (_total - _t) / 1.5), 0.0, 1.0)
	for k in _who.size():
		var sp := EchoesData.speaker(_who[k])
		var c := Color(String(sp["color"]))
		var glow := Color(c.r * 1.5, c.g * 1.5, c.b * 1.5, a * (0.55 + 0.1 * sin(_t * 7.0 + k)))
		var x := _x_of(_who[k])
		var face := 1.0 if (_who.size() == 2 and k == 0) else -1.0
		_figure(x, face, glow)


## Una sagoma: alta e sottile, la testa piccola, le braccia lunghe con le dita a radice, un poco curva verso l'altro.
func _figure(x: float, face: float, c: Color) -> void:
	var sway := sin(_t * 1.3) * 0.6
	draw_rect(Rect2(x - 2 + sway, -40, 4, 4), c)                          # la testa
	for y in 22:
		var w := 3.0 if y < 14 else 3.0 + float(y - 14) * 0.4            # il corpo che si allarga in fondo
		draw_rect(Rect2(x - w * 0.5 + sway * (1.0 - y / 22.0), -35 + y, w, 1), c)
	# il braccio verso l'altro, lungo, e le dita come radici
	var hand := Vector2(x + face * 9.0, -22.0 + sin(_t * 2.0) * 1.5)
	draw_line(Vector2(x + face * 1.5, -32), hand, c, 1.0)
	for f in 3:
		draw_line(hand, hand + Vector2(face * (2.0 + f), 1.5 + f * 1.5), Color(c, c.a * 0.7), 1.0)
	# l'altro braccio, lungo il fianco
	draw_line(Vector2(x - face * 1.5, -32), Vector2(x - face * 3.0, -17), Color(c, c.a * 0.8), 1.0)
