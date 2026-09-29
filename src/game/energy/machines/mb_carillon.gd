class_name MbCarillon
extends MachineBehavior
## Il Carillon di radice: a ogni impulso che si accende (o un colpo, o il clic destro) suona la sua nota (`st.nota`,
## 0-7: una scala pentatonica, che suona bene in qualunque ordine). Costa `colpo` gocce; senza Linfa tace.

const NOTES := [0, 2, 4, 7, 9, 12, 14, 16]
const NAMES := ["do", "re", "mi", "sol", "la", "do²", "re²", "mi²"]
const SOUND := "stella"


func ring(mc: Machine, e: Energy) -> void:
	if not e.spend(mc, float(mc.d.get("colpo", 0))):
		return
	var n := clampi(int(mc.st.get("nota", 0)), 0, NOTES.size() - 1)
	e.m.sfx.play(SOUND, mc.center(), pow(2.0, NOTES[n] / 12.0))
	mc.set_meta("flash", 0.3)
	mc.st["suoni"] = int(mc.st.get("suoni", 0)) + 1


func on_impulse(mc: Machine, e: Energy, _k: int, kind: String) -> void:
	if kind == "su" or kind == "colpo":
		ring(mc, e)


func touch(mc: Machine, e: Energy) -> bool:
	if Keys.held("confronta"):
		return false                          # con Maiusc: il pannello (la nota)
	ring(mc, e)
	return true


func panel_rows(mc: Machine, _e: Energy) -> Array:
	var row := []
	for k in NOTES.size():
		var n := k
		row.append([NAMES[k], int(mc.st.get("nota", 0)) == k, func() -> void: mc.st["nota"] = n])
	return [["Nota", row]]


func state_text(mc: Machine, _e: Energy) -> String:
	return "nota %s (Maiusc+clic destro: il pannello)" % NAMES[clampi(int(mc.st.get("nota", 0)), 0, 7)]
