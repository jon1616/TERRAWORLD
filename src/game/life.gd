class_name Life
extends Node
## La vita del Germogliato nella scena: ferite da caduta, lampi sullo schermo, appassire e rinascere alla partenza.
## Le regole dei numeri stanno in `Vitals`; qui c'è ciò che succede attorno.

const FALL_SAFE := 12.0                # tessere di caduta senza ferite
const FALL_HURT := 6                   # punti di Vita per ogni tessera in più

var m: Node2D                          # la scena di gioco
var dead := false


func setup(main: Node2D) -> void:
	m = main
	m.vitals.died.connect(_on_died)
	m.player.landed.connect(_on_landed)


func _on_landed(tiles: float) -> void:
	if tiles > FALL_SAFE and not dead:
		var lost: int = m.vitals.hurt(int((tiles - FALL_SAFE) * FALL_HURT))
		m.hud.toast("Caduta: -%d Vita" % lost)
		flash(Color(1.0, 0.4, 0.3, 0.35))


## Il Germogliato appassisce: si ferma, lo schermo si scurisce, e dopo un momento rinasce alla partenza.
func _on_died() -> void:
	if dead:
		return
	dead = true
	var had_control: bool = m.player.control
	m.player.control = false
	m.actions.enabled = false
	m.player.modulate = Color(0.5, 0.4, 0.3)
	m.hud.toast("Il Germogliato appassisce…")
	flash(Color(0.0, 0.0, 0.0, 0.6), 2.5)
	await get_tree().create_timer(3.0).timeout
	m.player.modulate = Color.WHITE
	m.vitals.refill()
	m.snap_to(m.world.spawn)
	m.player.control = had_control
	m.actions.enabled = true
	dead = false
	m.hud.toast("Rinasci alla partenza")


## Un lampo colorato su tutto lo schermo che svanisce.
func flash(c: Color, secs := 0.4) -> void:
	var r := ColorRect.new()
	r.color = c
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.hud.add_child(r)
	var tw := create_tween()
	tw.tween_property(r, "modulate:a", 0.0, secs)
	tw.tween_callback(r.queue_free)
