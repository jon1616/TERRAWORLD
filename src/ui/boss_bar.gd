class_name BossBar
extends Control
## La Vita di un Guardiano, in alto al centro: nome e barra lunga che dall'ambra malata passa al rosso quando entra
## nella seconda fase.

const W := 520.0

var boss: Creature
var _name: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.size = Vector2(W, 24)
	_name.position = Vector2(0, -26)
	_name.add_theme_font_size_override("font_size", 18)
	_name.add_theme_color_override("font_color", Color("#e8d8b0"))
	_name.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.05))
	_name.add_theme_constant_override("outline_size", 6)
	add_child(_name)


func follow(c: Creature) -> void:
	boss = c
	visible = c != null
	if c:
		_name.text = String(c.data["name"])
	position = Vector2((get_viewport_rect().size.x - W) * 0.5, 96)


func _process(_dt: float) -> void:
	if visible and (boss == null or not is_instance_valid(boss) or boss.calm):
		visible = false
	queue_redraw()


func _draw() -> void:
	if not visible or not is_instance_valid(boss):
		return
	var f := clampf(float(boss.hp) / boss.hp_max, 0.0, 1.0)
	draw_rect(Rect2(-3, -3, W + 6, 18), Color(0.02, 0.03, 0.05, 0.9))
	var col := Color("#d88a30") if not boss.enraged else Color("#e04a40")
	draw_rect(Rect2(0, 0, W * f, 12), col)
	draw_rect(Rect2(0, 0, W * f, 3), col.lightened(0.35))
