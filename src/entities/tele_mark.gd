class_name TeleMark
extends Node2D
## Il segnale di un attacco in arrivo (voce 127, Roadmap 15: «ogni attacco si annuncia e ha una contromossa»): mentre
## `Creature.tele` è sopra zero, sopra la testa della creatura lampeggia un «!» color ambra. Lo accendono i
## comportamenti con `Creature.telegraph` (la rincorsa della carica e dello scatto, la bocca che si apre prima di un
## tiro, il colpo che sta per cadere dall'alto); qui cala da solo.
## Voce 485 (dall'analisi del 9 ott 2026: «poco annuncio oltre al "!"»): il «quando» e il «dove». Un anello si stringe
## attorno alla creatura e la tocca nell'istante del colpo (si vede quando schivare); una carica disegna le frecce a
## terra nella sua direzione; chi piomba (picchiata, tuffo, salto, chi sbuca) segna a terra il punto.

const COL := Color("#ffb84a")

var c: Creature
var _t := 0.0
var _alert := false


func _ready() -> void:
	c = get_parent() as Creature
	z_index = 30


func _process(dt: float) -> void:
	if c == null:
		return
	var was := c.tele > 0.0
	c.tele = maxf(c.tele - dt, 0.0)
	_t += dt
	var alert := c.mind.state == Mind.ALERT
	if was or c.tele > 0.0 or alert != _alert:
		queue_redraw()
	_alert = alert


func _draw() -> void:
	if c == null:
		return
	if c.buried:
		if c.tele > 0.0 and c.tele_at != Vector2.INF:
			_draw_timing(true)                     # voce 485: chi sbuca dalla terra segna da dove
		return
	if c.tele <= 0.0:
		if c.mind.state == Mind.ALERT and not c.docile and c.damage > 0:
			# voce 129: ha sentito qualcosa e va a vedere (un «?» pallido, fermo)
			draw_string(ThemeDB.fallback_font, Vector2(-3, -c.half.y - 6.0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
				Color(0.95, 0.9, 0.7, 0.8))
		return
	_draw_timing(false)
	if int(_t * 12.0) % 2 == 1:
		return                                   # lampeggia
	var top := Vector2(0, -c.half.y - 12.0)
	var pts := PackedVector2Array([top + Vector2(-4, -6), top + Vector2(4, -6), top + Vector2(1.5, 3), top + Vector2(-1.5, 3)])
	draw_colored_polygon(pts, COL)
	draw_circle(top + Vector2(0, 6.5), 1.8, COL)
	pts.append(pts[0])
	draw_polyline(pts, Color(0.05, 0.05, 0.08), 1.0)


## Voce 485: l'anello che si stringe, le frecce della carica, il segno di dove piomba.
func _draw_timing(only_at: bool) -> void:
	var k := 1.0 - clampf(c.tele / maxf(c.tele_len, 0.05), 0.0, 1.0)      # 0 all'inizio, 1 quando colpisce
	if only_at:
		_draw_at(k)
		return
	var big := maxf(c.half.x, c.half.y)
	var r := lerpf(big * 2.4 + 12.0, big + 3.0, k)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(COL, 0.25 + 0.6 * k), 1.5 + k, true)
	if c.tele_dir != 0.0:
		var y := c.half.y - 1.0
		for i in 3:
			var x := c.tele_dir * (c.half.x + 8.0 + i * 11.0)
			var a := clampf(k * 1.6 - i * 0.25, 0.15, 0.9)
			var tip := Vector2(x + c.tele_dir * 5.0, y - 4.0)
			draw_polyline(PackedVector2Array([Vector2(x, y - 8.0), tip, Vector2(x, y)]), Color(COL, a), 2.0, true)
	_draw_at(k)


func _draw_at(k: float) -> void:
	if c.tele_at != Vector2.INF:
		var p := to_local(c.tele_at)
		var rr := lerpf(16.0, 7.0, k)
		draw_arc(p, rr, 0.0, TAU, 28, Color(COL, 0.3 + 0.55 * k), 2.0, true)
		draw_line(p + Vector2(-4, 0), p + Vector2(4, 0), Color(COL, 0.5 + 0.4 * k), 1.5, true)
		draw_line(p + Vector2(0, -4), p + Vector2(0, 4), Color(COL, 0.5 + 0.4 * k), 1.5, true)
