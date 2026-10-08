class_name BossBar
extends Control
## La Vita di un Guardiano, in alto al centro: nome e barra lunga che dall'ambra malata passa al rosso quando entra
## nella seconda fase.

const W := 520.0

var boss: Creature
var _name: Label
var _trail := 1.0                       # (voce 291) la Vita appena persa, che si svuota con un attimo di ritardo
var _t := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_to_group("boss_bar")
	visible = false
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.size = Vector2(W, UiFonts.size(2))
	_name.position = Vector2(0, -UiFonts.size(2) - 6)
	UiFonts.apply(_name, 2, Color("#f0dcb0"), true)          # (voce 291) il nome nel carattere di pixel
	add_child(_name)


func follow(c: Creature) -> void:
	boss = c
	visible = c != null
	if c:
		_name.text = String(c.data["name"])
	position = Vector2((get_viewport_rect().size.x - W) * 0.5, top_y() if is_inside_tree() else 96.0)


func _process(dt: float) -> void:
	_t += dt
	if visible and is_instance_valid(boss):
		var f := clampf(float(boss.hp) / boss.hp_max, 0.0, 1.0)
		_trail = f if _trail < f else move_toward(_trail, f, dt * 0.35)
	if visible and (boss == null or not is_instance_valid(boss) or boss.calm):
		visible = false
	if visible:
		position = Vector2((get_viewport_rect().size.x - W) * 0.5, top_y())
	queue_redraw()


## Dove comincia la barra: sotto le scritte in alto al centro (sfida, filo), che possono andare su più righe, e sotto
## le altre barre dei boss già visibili (più Guardiani insieme).
func top_y() -> float:
	var y := 96.0
	for n in get_tree().get_nodes_in_group("hud_alto"):
		var c := n as Control
		if c and c.is_visible_in_tree() :
			var t: String = c.text if "text" in c else ""
			if t.strip_edges() != "":
				y = maxf(y, c.position.y + maxf(c.size.y, c.get_combined_minimum_size().y) + 34.0)
	for n in get_tree().get_nodes_in_group("boss_bar"):
		if n == self:
			break
		if (n as Control).visible:
			y += 50.0
	return y


func _draw() -> void:
	if not visible or not is_instance_valid(boss):
		return
	var f := clampf(float(boss.hp) / boss.hp_max, 0.0, 1.0)
	# (voce 291) una cornice del tema, la parte persa che si svuota piano, il liquido con un'onda di luce, le tacche dei
	# quarti e il segno della seconda fase a metà
	draw_style_box(UiFrames.box("campo", "normale", Color("#e04a40") if boss.enraged else Color(0, 0, 0, 0)),
		Rect2(-8, -6, W + 16, 26))
	var col := Color("#d88a30") if not boss.enraged else Color("#e04a40")
	if _trail > f:
		draw_rect(Rect2(W * f, 0, W * (_trail - f), 14), Color(1.0, 0.92, 0.75, 0.75))
	draw_rect(Rect2(0, 0, W * f, 14), col.darkened(0.2))
	draw_rect(Rect2(0, 0, W * f, 4), col.lightened(0.35))
	var wave := fmod(_t * 0.4, 1.4) - 0.2
	if wave > 0.0 and wave < f:
		draw_rect(Rect2(W * wave - 12.0, 4, 24, 10), Color(col.lightened(0.6), 0.25))
	for q in [0.25, 0.5, 0.75]:
		draw_rect(Rect2(W * q - 1.0, 0, 2, 14), Color(0.02, 0.03, 0.05, 0.7 if q != 0.5 else 0.95))
	# il segno della seconda fase: un piccolo rombo sopra la metà
	var mx := W * 0.5
	var dia := PackedVector2Array([Vector2(mx, -7), Vector2(mx + 4, -3), Vector2(mx, 1), Vector2(mx - 4, -3)])
	draw_colored_polygon(dia, Color("#e04a40") if boss.enraged else Color("#8a6a50"))
