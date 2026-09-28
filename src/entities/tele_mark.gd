class_name TeleMark
extends Node2D
## Il segnale di un attacco in arrivo (voce 127, Roadmap 15: «ogni attacco si annuncia e ha una contromossa»): mentre
## `Creature.tele` è sopra zero, sopra la testa della creatura lampeggia un «!» color ambra. Lo accendono i
## comportamenti con `Creature.telegraph` (la rincorsa della carica e dello scatto, la bocca che si apre prima di un
## tiro, il colpo che sta per cadere dall'alto); qui cala da solo.

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
	if c == null or c.buried:
		return
	if c.tele <= 0.0:
		if c.mind.state == Mind.ALERT and not c.docile and c.damage > 0:
			# voce 129: ha sentito qualcosa e va a vedere (un «?» pallido, fermo)
			draw_string(ThemeDB.fallback_font, Vector2(-3, -c.half.y - 6.0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 12,
				Color(0.95, 0.9, 0.7, 0.8))
		return
	if int(_t * 12.0) % 2 == 1:
		return                                   # lampeggia
	var top := Vector2(0, -c.half.y - 12.0)
	var pts := PackedVector2Array([top + Vector2(-4, -6), top + Vector2(4, -6), top + Vector2(1.5, 3), top + Vector2(-1.5, 3)])
	draw_colored_polygon(pts, COL)
	draw_circle(top + Vector2(0, 6.5), 1.8, COL)
	pts.append(pts[0])
	draw_polyline(pts, Color(0.05, 0.05, 0.08), 1.0)
