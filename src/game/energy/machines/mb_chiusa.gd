class_name MbChiusa
extends MbPorta
## La Chiusa di radice: come la Porta viva (tessere `PORTA` da chiusa, ogni movimento costa gocce) ma non si apre da
## sola quando arrivi: con un filo segue l'Impulso, senza fili la apre e la chiude il clic destro. Ferma i liquidi.


func frame(mc: Machine, e: Energy, _dt: float) -> void:
	if not mc.st.has("open"):
		_move(mc, e, false)
		return
	var want: bool = mc.on() if not mc.wired.is_empty() else bool(mc.st.get("want", false))
	var open := bool(mc.st["open"])
	if want == open:
		return
	if not want and _busy(mc, e):
		return
	if e.spend(mc, float(mc.d.get("colpo", 0))):
		_move(mc, e, want)


func touch(mc: Machine, _e: Energy) -> bool:
	if not mc.wired.is_empty():
		return false
	mc.st["want"] = not bool(mc.st.get("want", false))
	return true


func state_text(mc: Machine, _e: Energy) -> String:
	var s := "aperta" if bool(mc.st.get("open", false)) else "chiusa"
	return s + (" (la comanda il filo)" if not mc.wired.is_empty() else " (clic destro)")
