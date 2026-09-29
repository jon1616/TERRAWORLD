class_name MbLampada
extends MachineBehavior
## La Lampada a baccello: fa luce quando è accesa e ha tutti i suoi pulsi.


func tick(mc: Machine, _e: Energy, _dt: float) -> void:
	mc.lit = mc.on() and mc.power >= 0.99
