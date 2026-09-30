class_name Finale
extends Node
## Il finale (Roadmap 28, voce 264; testi in `FinaleData`). `start` (da `PrimoGarden`, portato il Seme del Seminatore
## all'Albero Antico): il racconto, l'epilogo con i numeri della partita, i titoli di coda; `Character.stats["finale"]` ≥ 1
## (l'Albero-Madre diventa d'oro: `AlberoMadre._apply`), conteggio «finale», diario. `show_epilogue` rilegge l'epilogo.

var m: Node2D
var panel: FinalePanel


func setup(main: Node2D) -> void:
	m = main
	panel = FinalePanel.new()
	m.hud.add_child(panel)
	m.hud.overlays.append(panel)


func done() -> bool:
	return int(m.character.stats.get("finale", 0)) >= 1


func start() -> void:
	var first := not done()
	if first:
		m.objectives.bump("finale")                  # (il conteggio fa anche da segno: ≥ 1 = finale visto)
		if m.get("diary") != null:
			m.diary.note("L'Albero Antico ha raccontato dove andarono i Seminatori", "finale")
	var pages: Array = []
	for p in FinaleData.STORY:
		pages.append([String(p[0]), String(p[1])])
	pages.append(["La tua partita", epilogue()])
	pages.append(["", "\n".join(PackedStringArray(FinaleData.CREDITS))])
	panel.show_pages(pages)
	m.sfx.play("portale")


func show_epilogue() -> void:
	panel.show_pages([["La tua partita", epilogue()], ["", "\n".join(PackedStringArray(FinaleData.CREDITS))]])


func close() -> void:
	panel.close()


## I numeri della partita (BBCode).
func epilogue() -> String:
	var ch: Character = m.character
	var st: Dictionary = ch.stats
	var er: Dictionary = ch.erbario
	var kills := 0
	for k in er.get("creature", {}):
		kills += int(er["creature"][k])
	var grades := []
	for p in MasteryData.ORDER:
		grades.append("%s %d" % [String(MasteryData.PILLARS[p]["name"]).trim_prefix("La ").trim_prefix("Il ").trim_prefix("I ").trim_prefix("Gli ").trim_prefix("L'"),
			m.mastery.grade(String(p)) if m.get("mastery") != null else 0])
	var hours := ch.play_time / 3600.0
	var lines := [
		"Ore di gioco: [b]%.1f[/b]" % hours,
		"Mondi nell'Atlante: [b]%d[/b] · stelle: [b]%d[/b]" % [ch.atlante.size(), int(st.get("stelle", 0))],
		"Creature sconfitte: [b]%d[/b] (specie: %d) · pesci pescati: [b]%d[/b] (specie: %d)" % [kills, (er.get("creature", {}) as Dictionary).size(),
			int(st.get("pesci", 0)), (er.get("pesci", {}) as Dictionary).size()],
		"Erbario: [b]%d%%[/b] · pezzi nel Museo: [b]%d[/b]" % [roundi(m.erbario.percent()), m.museum.exhibited() if m.get("museum") != null else 0],
		"Creature della mandria: [b]%d[/b] · parole dei Seminatori: [b]%d[/b]" % [ch.mandria.size(), ch.lingua.size()],
		"",
		"I pilastri: " + " · ".join(PackedStringArray(grades)),
	]
	return "\n".join(PackedStringArray(lines))
