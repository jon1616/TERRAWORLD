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
	await _ground_row()


## 29 set 2026: una fila di stazioni su un tratto piano (affondo nel terreno, ombra di contatto, niente contorno sotto;
## l'utente: «sembrano staccate dal terreno»). Foto 162_stazioni_a_terra.
func _ground_row() -> void:
	var w: World = kit.world
	var ids := ["ceppo", "maglio", "alambicco", "cesta", "forziere_ambra", "totem_germoglio_2", "trappola_spuntoni_1",
		"baccello_ardente", "telaio", "mola"]
	var c := kit.flat_spot(w.spawn + Vector2i(30, 0), 14)
	if c.x < 0:
		c = Vector2i(w.spawn.x + 30, w.surface[w.spawn.x + 30] - 1)
	kit.flatten(c, 14)
	var x := c.x - 12
	var placed: Array[Vector2i] = []
	for id in ids:
		var size: Array = StationsData.STATIONS[id]["size"]
		var o := Vector2i(x, c.y - int(size[1]) + 1)
		w.stations[o] = id
		m.view.add_station(o)
		placed.append(o)
		x += int(size[0]) + 1
	m.snap_to(c + Vector2i(0, 0))
	await kit.seconds(0.4)
	await kit.save("162_stazioni_a_terra")
	for o in placed:
		w.stations.erase(o)
		w.chests.erase(o)
		m.view.remove_station(o)
