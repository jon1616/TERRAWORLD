class_name MbNastro
extends MachineBehavior
## Il Nastro vivo: con i suoi pulsi porta gli oggetti a terra sopra di lui (`Drops.push`), il doppio più svelto dei
## nastri delle farm. Il verso (`st.dir`, 1 destra, -1 sinistra) lo cambia un impulso o il pannello.

const SPEED := 140.0


func frame(mc: Machine, e: Energy, _dt: float) -> void:
	if not mc.on() or mc.power < 0.99:
		return
	var r := Rect2(Vector2(mc.o) * 16.0 + Vector2(0, -4), Vector2(mc.size().x * 16.0, 20.0))
	e.m.drops.push(r, SPEED * float(mc.st.get("dir", 1)))


func on_impulse(mc: Machine, _e: Energy, _k: int, kind: String) -> void:
	if kind == "su" or kind == "colpo":
		mc.st["dir"] = -int(mc.st.get("dir", 1))


func panel_rows(mc: Machine, e: Energy) -> Array:
	var d := int(mc.st.get("dir", 1))
	return [["Verso", [["← Sinistra", d < 0, func() -> void:
		mc.st["dir"] = -1
		e.refresh_look(mc)], ["Destra →", d > 0, func() -> void:
		mc.st["dir"] = 1
		e.refresh_look(mc)]]]]


func state_text(mc: Machine, e: Energy) -> String:
	var s := super.state_text(mc, e)
	return s + (" · verso destra" if int(mc.st.get("dir", 1)) > 0 else " · verso sinistra")
