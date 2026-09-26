class_name HpBar
extends Node2D
## Barretta della vita sopra una creatura: compare solo dopo il primo colpo, sopra il buio (si legge anche nelle
## grotte), verde-turchese che scende verso l'ambra.

static var mode := "ferite"             # Opzioni: "ferite" (dopo il primo colpo), "sempre", "mai"

var value := 1.0
var always := false                    # sempre in vista (creature antiche), anche a Vita piena


func _init() -> void:
	z_as_relative = false
	z_index = 27
	visible = false


func set_value(v: float) -> void:
	value = clampf(v, 0.0, 1.0)
	visible = mode != "mai" and (always or value < 1.0 or mode == "sempre")
	queue_redraw()


func _draw() -> void:
	var w := 18.0
	draw_rect(Rect2(-w / 2 - 1, -1, w + 2, 4), Color(0.02, 0.05, 0.07, 0.85))
	var c := Color("#3aa08a").lerp(Color("#ffb040"), 1.0 - value)
	draw_rect(Rect2(-w / 2, 0, w * value, 2), c)
