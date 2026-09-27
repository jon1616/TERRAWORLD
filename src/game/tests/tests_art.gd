class_name TestsArt
extends RefCounted
## Prove della Roadmap 13 (la grafica di Nano Banana): ogni pagina di storia e ogni abitante ha il suo disegno, le
## icone di Vita, Linfa e dei rigori ci sono, e una pagina di storia si apre con la sua vignetta (foto 160_pagina_storia).

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var missing: Array[String] = []
	for id in LoreData.PAGES:
		if not ArtLib.has("storia", id):
			missing.append("storia/" + id)
	for id in NpcData.NPCS:
		if not ArtLib.has("ritratti", id):
			missing.append("ritratti/" + id)
	for id in ["vita", "linfa", "scorza"] + HarshData.KINDS.keys():
		if not ArtLib.has("interfaccia", id):
			missing.append("interfaccia/" + id)
	for id in ["sfondo", "logo"]:
		if not ArtLib.has("titolo", id):
			missing.append("titolo/" + id)
	print("grafica: pagine %d, abitanti %d, disegni mancanti %d %s" % [LoreData.PAGES.size(), NpcData.NPCS.size(),
		missing.size(), missing])
	if not missing.is_empty():
		print("ATTENZIONE: mancano disegni della Roadmap 13")
	var lore: LorePanel = m.guardian.lore
	lore.show_page("albero_sveglio")
	await kit.seconds(0.3)
	print("pagina di storia con la vignetta: %s" % ("sì" if lore._pic.visible and lore._pic.texture != null else "NO"))
	await kit.save("160_pagina_storia")
	lore.visible = false
	# i pulsanti dei pannelli e gli stati sopra una creatura (brucia, rallentata, vulnerabile)
	var pb: Array = m.get_children().filter(func(n: Node) -> bool: return n is PanelButtons)
	print("pulsanti dei pannelli: %d" % (pb[0].buttons.size() if not pb.is_empty() else 0))
	m.combat.god = true
	var c: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(40, -8))
	c.burn_t = 5.0
	c.chill_t = 5.0
	c.weak_t = 5.0
	await kit.seconds(0.5)
	print("stati sopra la creatura: %s" % [StatusMarks.states(c)])
	await kit.save("161_stati_e_pulsanti")
	m.fauna.clear()
	m.combat.god = false
