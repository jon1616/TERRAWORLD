class_name MbLeva
extends MachineBehavior
## La Leva di radice: clic destro la alza o la abbassa; alzata accende i fili che tocca (un comando «a stato»).


func touch(mc: Machine, e: Energy) -> bool:
	var up := not bool(mc.st.get("out", false))
	e.impulse.set_out(mc, up)
	e.m.sfx.play("legno", mc.center())
	return true
