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
	# 30 set 2026: ogni pulsante apre il suo pannello (Quaderno, Pilastri, Arti, Atlante erano rimasti senza)
	if not pb.is_empty():
		var bad: Array = []
		for what in ["erbario", "semenzaio", "mandria", "quaderno", "pilastri", "arti", "atlante"]:
			pb[0].press(what)
			await kit.frames(2)
			var open: Array = m.hud.overlays.filter(func(o: Control) -> bool: return o.visible)
			if open.is_empty():
				bad.append(what)
			for o in open:
				if o.has_method("close"):
					o.close()
				else:
					o.toggle()
			await kit.frames(2)
		print("pulsanti che non aprono il loro pannello: %s" % ("nessuno" if bad.is_empty() else "ATTENZIONE: %s" % [bad]))
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
	await _posed_creatures()


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


## 7 ott 2026: le creature con le pose di Nano Banana (`CreaturePosesData`): ogni stato sceglie una posa che esiste, e
## le quattro creature in fila sul terreno. Foto 163_pose_creature.
func _posed_creatures() -> void:
	var w: World = kit.world
	var ids := ["grumo_muschio", "pecora_muschio", "lepre_linfa", "corvo_corteccia", "falena_brace", "bruco_lanterna"]
	var c := kit.flat_spot(w.spawn + Vector2i(60, 0), 12)
	if c.x < 0:
		c = Vector2i(w.spawn.x + 60, w.surface[w.spawn.x + 60] - 1)
	kit.flatten(c, 12)
	m.snap_to(c)
	await kit.seconds(0.3)
	m.combat.god = true
	var made: Array[Creature] = []
	var bad: Array = []
	for i in ids.size():
		var cr: Creature = m.fauna.add(ids[i], Vector2(c.x * 16 + (i - 1.5) * 48 + 8, (c.y - 2) * 16))
		made.append(cr)
		if cr._poses.is_empty():
			bad.append("%s senza pose" % ids[i])
			continue
		# ogni stato deve dare un fotogramma esistente
		var n: int = cr._frames.size()
		for st in [[true, Vector2(0, -200), 0.0, 0.0], [false, Vector2(0, 200), 0.0, 0.0], [true, Vector2(90, 0), 0.0, 0.0],
				[true, Vector2.ZERO, 0.6, 0.0], [true, Vector2.ZERO, -0.6, 0.0], [true, Vector2.ZERO, 0.0, 0.3]]:
			cr.on_floor = st[0]
			cr.vel = st[1]
			cr.crouch = st[2]
			cr._hurt_t = st[3]
			var f := cr._pose_frame(0.05)
			if f < 0 or f >= n:
				bad.append("%s: fotogramma %d su %d" % [ids[i], f, n])
		cr.vel = Vector2.ZERO
		cr.crouch = 0.0
		cr._hurt_t = 0.0
	print("creature con le pose: %s" % ("tutte (%d)" % ids.size() if bad.is_empty() else "ATTENZIONE: %s" % [bad]))
	await kit.seconds(1.2)
	await kit.save("163_pose_creature")
	await kit.seconds(0.9)
	var poses := []
	for cr in made:
		if is_instance_valid(cr):
			poses.append("%s=%s" % [cr.id, cr._pose])
	print("pose del momento: %s" % ", ".join(poses))
	await kit.save("163_pose_creature_b")
	m.fauna.clear()
	m.combat.god = false
