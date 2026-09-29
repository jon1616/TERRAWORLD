class_name Chronicles
extends RefCounted
## Le cronache perdute (Roadmap 26, voce 255; storie in `ChroniclesData`). Quando l'Erbario scopre un frammento
## (`Erbario.discovered`), si guarda se la sua storia ha ora tutti e cinque i frammenti: la storia si ricompone (pagina
## con `LorePanel.show_text`), dà il suo premio e `Character.stats["cronaca_<storia>"]`.

var m: Node2D


func _init(main: Node2D) -> void:
	m = main
	m.erbario.discovered.connect(func(section: String, id: String) -> void:
		if section == "oggetti" and id.begins_with("cronaca_"):
			check())


func found(story: String) -> int:
	var n := 0
	for k in 5:
		if m.erbario.known("oggetti", ChroniclesData.fragment_id(story, k)):
			n += 1
	return n


## Le storie ricomposte adesso.
func check() -> Array:
	var done := []
	var st: Dictionary = m.character.stats
	for s in ChroniclesData.STORIES:
		if int(st.get("cronaca_" + s, 0)) == 1 or found(s) < 5:
			continue
		st["cronaca_" + s] = 1
		done.append(s)
		var d: Array = ChroniclesData.STORIES[s]
		m.objectives.bump("cronache")
		var gift := Lineage._give(m, d[2])
		m.hud.toast("Una cronaca ricomposta: «%s» · %s" % [d[0], gift])
		if m.guardian != null and m.guardian.lore != null:
			m.guardian.lore.show_text("Cronache perdute · " + String(d[0]), "\n\n".join(PackedStringArray(d[3])))
	return done


func line() -> String:
	var n := 0
	for s in ChroniclesData.STORIES:
		n += int(m.character.stats.get("cronaca_" + s, 0))
	return "Cronache ricomposte: %d su %d" % [n, ChroniclesData.STORIES.size()]
