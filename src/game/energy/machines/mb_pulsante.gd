class_name MbPulsante
extends MachineBehavior
## Il Pulsante di radice: clic destro = un colpo sui fili che tocca.


func touch(mc: Machine, e: Energy) -> bool:
	e.impulse.pulse(mc)
	mc.set_meta("flash", 0.3)
	e.m.sfx.play("legno", mc.center())
	return true
