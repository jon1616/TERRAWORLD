class_name MbCentrale
extends MachineBehavior
## Il Cuore della centrale (voce 206): la sorgente delle Centrali dei Seminatori. Dorme finché il Germogliato non gli
## dà un cristallo di Linfa (clic destro con un cristallo nella Bisaccia); poi dà i suoi pulsi per sempre. Quello della
## Centrale intatta (la firma) è già sveglio (`p.desto`).

const WAKE := "cristallo_linfa"


func _awake(mc: Machine) -> bool:
	return bool(mc.st.get("desto", false)) or bool((mc.d.get("p", {}) as Dictionary).get("desto", false))


func produce(mc: Machine, _e: Energy) -> float:
	return float(mc.d.get("pulsi", 0)) if _awake(mc) else 0.0


func touch(mc: Machine, e: Energy) -> bool:
	if _awake(mc):
		return false                                # sveglio: il pannello
	var b: Bisaccia = e.m.character.bisaccia
	if b.count(WAKE) <= 0:
		e.m.hud.toast("Il cuore della centrale è spento: chiede un cristallo di Linfa")
		return true
	b.remove(WAKE, 1)
	mc.st["desto"] = true
	mc.set_meta("flash", 0.6)
	e.m.sfx.play("stella", mc.center())
	e.m.hud.toast("Il cuore della centrale si risveglia: ora le vene devono portare la sua Linfa")
	e.rebuild()
	return true


func state_text(mc: Machine, e: Energy) -> String:
	if not _awake(mc):
		return "spento: dagli un cristallo di Linfa (clic destro)"
	return super.state_text(mc, e)
