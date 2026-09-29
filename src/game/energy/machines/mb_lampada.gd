class_name MbLampada
extends MachineBehavior
## La Lampada a baccello: fa luce quando è accesa e ha tutti i suoi pulsi.


func tick(mc: Machine, _e: Energy, _dt: float) -> void:
	mc.lit = mc.on() and mc.power >= 0.99


## L'Insegna (`colori` nei dati): il colore si sceglie nel pannello.
const COLORS := [["Linfa", "#5cf0e0"], ["Ambra", "#ffc050"], ["Corallo", "#ff8a6a"], ["Viola", "#c090ff"], ["Muschio", "#8ef070"],
	["Luna", "#e0e8ff"]]


func panel_rows(mc: Machine, e: Energy) -> Array:
	if not mc.d.get("colori", false):
		return []
	var row := []
	var cur := String(mc.st.get("col", COLORS[0][1]))
	for c in COLORS:
		var h := String(c[1])
		row.append([String(c[0]), cur == h, func() -> void:
			mc.st["col"] = h
			e.m.light.dirty = true])
	return [["Colore", row]]
