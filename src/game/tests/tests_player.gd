class_name TestsPlayer
extends RefCounted
## Prove del giocatore: alberi e semi, fabbricazione e stazioni, equipaggiamento e vita, movimento a 60 e 144 fps.

const S := 16

var kit: TestKit
var world: World


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world


## Alberi: si abbatte con l'ascia l'albero più vicino alla partenza, si raccoglie il legno, si pianta un seme dove
## c'era e lo si fa crescere subito.
func trees() -> void:
	var best := Vector3i(-1, -1, -1)
	var bd := 1e12
	for k in world.trees:
		for t in world.trees[k]:
			var d := Vector2(t.x - world.spawn.x, t.y - world.spawn.y).length_squared()
			if d < bd:
				bd = d
				best = t
	if best.x < 0:
		print("ATTENZIONE: nessun albero vicino alla partenza")
		return
	var b: Bisaccia = kit.m.character.bisaccia
	var base := Vector2i(best.x, best.y)
	kit.m.snap_to(base + Vector2i(-2, 0))
	await kit.frames(10)
	var axe := -1
	for i in Bisaccia.HOTBAR:
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "ascia":
			axe = i
	kit.m.hud.select(axe)
	var wood_before := b.count("legno")
	var hits := 0
	kit.m.player.force_swing = true
	await kit.frames(8)
	var axe_seen: bool = kit.m.player.tool.visible and kit.m.player.tool.texture != null
	print("ascia in mano durante il colpo: %s" % ("visibile" if axe_seen else "NON visibile"))
	kit.m.player.force_swing = false
	while world.tree_at(base).x >= 0 and hits < 10:
		kit.m.actions._chop(base + Vector2i(0, -3), kit.m.hud.current(), 1.0)
		hits += 1
		await kit.frames(3)
	await kit.frames(10)
	await kit.save("08_albero_cade")
	for k in 120:
		await kit.node.get_tree().process_frame
		if b.count("legno") >= wood_before + FloraData.WOOD[0]:
			break
	print("albero: abbattuto in %d colpi, legno raccolto %d" % [hits, b.count("legno") - wood_before])
	# un seme dove c'era l'albero, fatto crescere subito
	if b.count("seme_lanterna") == 0:
		b.add("seme_lanterna", 1)
	var slot := kit.hold("seme_lanterna")        # (Roadmap 53: ciò che si raccoglie va nel suo scomparto)
	if slot < 0:
		print("ATTENZIONE: il seme non è nella barra rapida")
		return
	kit.m.hud.select(slot)
	var planted: bool = kit.m.actions.plant(base, "seme_lanterna")
	kit.m.grow_saplings(99999.0)
	await kit.frames(70)
	print("germoglio: %s" % ("piantato e cresciuto" if planted and world.tree_at(base).x >= 0 else "NON cresciuto"))
	await kit.save("09_albero_ricresciuto")


## Fabbricazione: a mano il Ceppo del Giardiniere, lo si piazza, al ceppo si fanno passerelle e il Baccello ardente,
## si piazzano, e si fotografa la colonna «Creare».
func crafting() -> void:
	var b: Bisaccia = kit.m.character.bisaccia
	if b.count("legno") < 20:
		b.add("legno", 20 - b.count("legno"))
	b.add("ardesia", 25)
	b.add("gelatina", 3)
	var ok_ceppo := kit.craft("ceppo")
	var here: Vector2i = kit.m.player_cell()
	var placed := kit.place_station_near("ceppo", here)
	var near := Crafting.stations_near(world, kit.m.player_cell())
	var ok_pass := kit.craft("passerella") and kit.craft("torcia")
	var ok_bacc := kit.craft("baccello_ardente")
	# il baccello va su un tratto di muschio piano e libero, cercato vicino
	var spot := kit.flat_spot(here, 6)
	if spot.x >= 0:
		kit.m.snap_to(spot + Vector2i(-3, 0))
		await kit.frames(5)
		ok_bacc = ok_bacc and kit.place_station_near("baccello_ardente", spot)
		await kit.frames(15)
		await kit.save("11_baccello_ardente")
		kit.m.snap_to(here)
		await kit.frames(5)
	else:
		ok_bacc = false
	print("creare: ceppo %s, piazzato %s, ceppo vicino %s, passerelle e torce %s, baccello ardente %s" % [
		ok_ceppo, placed, near.has("ceppo"), ok_pass, ok_bacc])
	# una passerella piazzata e ripresa
	var pslot := kit.slot_of("passerella")
	if pslot >= 0:
		kit.m.hud.select(pslot)
		var pc := Vector2i(-1, -1)
		var put := false
		for dx in [-2, -3, 2, 3, -1, 1]:
			var cand: Vector2i = here + Vector2i(dx, 0)
			if world.station_at(cand).is_empty() and kit.m.actions.build.place_plat(cand, "passerella"):
				pc = cand
				put = true
				break
		var before := b.count("passerella")
		if put:
			kit.m.actions.build.take_plat(pc)
		var t0 := Time.get_ticks_msec()
		while Time.get_ticks_msec() - t0 < 2000:     # in secondi: il tempo che la passerella vola nella Bisaccia
			await kit.node.get_tree().process_frame
			if b.count("passerella") > before:
				break
		print("passerella: %s" % ("piazzata e ripresa" if put and b.count("passerella") > before else "NON riuscita"))
	await kit.frames(20)
	kit.m.hud.panel.toggle()
	await kit.frames(12)
	await kit.save("10_creare")
	kit.m.hud.panel.toggle()


## Equipaggiamento, Scorza, caduta, pozione, appassire e rinascere.
func vitals() -> void:
	var b: Bisaccia = kit.m.character.bisaccia
	var v: Vitals = kit.m.vitals
	for piece in [["elmo", "elmo_ambra"], ["corazza", "corazza_legnoferro"], ["gambali", "gambali_radicite"]]:
		b.wear(piece[0], {"id": piece[1], "n": 1})
	await kit.frames(5)
	print("equipaggiamento: Scorza %d (attesa 7), Vitals.scorza %d" % [b.scorza(), v.scorza])
	var spot := kit.flat_spot(kit.m.player_cell(), 3)
	if spot.x >= 0:
		kit.m.snap_to(spot)
	kit.m.hud.panel.toggle()
	await kit.frames(12)
	await kit.save("12_equipaggiamento")
	kit.m.hud.panel.toggle()
	# caduta da 20 tessere
	v.refill()
	kit.m.player.position.y -= 20 * S
	kit.m.player.vel = Vector2.ZERO
	kit.m.player._was_floor = false
	kit.m.player._air_top = kit.m.player.position.y
	for k in 240:
		await kit.node.get_tree().process_frame
		if kit.m.player.on_floor:
			break
	await kit.frames(3)
	print("caduta da 20 tessere: Vita %d (persi %d)" % [v.hp, Vitals.HP_MAX - v.hp])
	# pozione
	b.add("pozione_rugiada", 1)
	var ps := kit.slot_of("pozione_rugiada")
	var before := v.hp
	if ps >= 0:
		kit.m.hud.select(ps)
		kit.m.actions.drink("pozione_rugiada")
	print("pozione di rugiada: Vita da %d a %d" % [before, v.hp])
	await kit.save("13_vita_e_linfa")
	# appassire e rinascere; appassire costa: prima si mette qualcosa nella parte grande della Bisaccia
	b.slots[Bisaccia.HOTBAR + 5] = {"id": "legno", "n": 9}
	b.changed.emit()
	v.hurt(999)
	await kit.frames(10)
	await kit.save("14_appassito")
	await kit.node.get_tree().create_timer(3.4).timeout
	await kit.frames(5)
	var back: bool = v.hp == Vitals.HP_MAX and absi(kit.m.player_cell().x - world.spawn.x) <= 1
	print("appassito e rinato: %s" % ("sì, alla partenza con tutte le foglie" if back else "NO"))
	# il fagotto: c'è, contiene il legno, e svuotato sparisce
	var o: Vector2i = kit.m.life.bundle
	var has_bundle: bool = o.x >= 0 and world.stations.get(o, "") == "fagotto"
	var inside: int = world.chest_at(o).count("legno") if has_bundle else 0
	if has_bundle:
		kit.m.snap_to(o + Vector2i(1, 0))
		await kit.frames(5)
		kit.m.interact.touch(o)
		kit.m.interact.chest_panel.take_all()
		await kit.frames(5)
		kit.m.hud.panel.visible = false
	print("fagotto: lasciato %s con %d legni dentro, recuperato %s" % ["sì" if has_bundle else "NO", inside,
		"sì" if has_bundle and not world.stations.has(o) else "NO"])


## Movimento sulla zona piana della partenza: velocità massima, altezza del salto pieno, e un muro di 3 blocchi da
## scavalcare correndo e saltando (il salto di base deve bastare, richiesta dell'utente del 24 set 2026).
func movement() -> void:
	# lo stesso giro a 60 e a 144 fotogrammi al secondo: il salto non deve dipendere dallo schermo
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	for fps in [60, 144]:
		Engine.max_fps = fps
		print("— a %d fotogrammi al secondo" % fps)
		await movement_at()
	Engine.max_fps = 0
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func movement_at() -> void:
	var p: Player = kit.m.player
	var s := world.spawn
	kit.m.snap_to(s + Vector2i(-6, 0))
	await kit.frames(5)
	p.auto_dir = 1.0
	var t0 := Time.get_ticks_msec()
	var top := 0.0
	var reach_ms := -1
	while Time.get_ticks_msec() - t0 < 700:
		await kit.node.get_tree().process_frame
		top = maxf(top, absf(p.vel.x))
		if reach_ms < 0 and absf(p.vel.x) >= Player.RUN - 0.5:
			reach_ms = Time.get_ticks_msec() - t0
	p.auto_dir = 0.0
	await kit.seconds(0.7)
	var ground := p.position.y
	p.auto_jump = true
	var high := ground
	for k in 90:
		await kit.node.get_tree().process_frame
		high = minf(high, p.position.y)
		if k > 10 and p.on_floor:
			break
	p.auto_jump = false
	print("movimento: corsa %.0f px/s (%.1f tessere/s), velocità piena in %d ms, salto pieno %.2f tessere" % [
		top, top / S, reach_ms, (ground - high) / S])
	# muro di 3 blocchi davanti alla partenza
	var wx := s.x + 3
	for dy in range(1, 4):
		world.set_tile(wx, s.y + 1 - dy, TileDefs.STONE)
		kit.m.view.refresh_around(Vector2i(wx, s.y + 1 - dy))
	kit.m.light.dirty = true
	kit.m.snap_to(s + Vector2i(-2, 0))
	await kit.frames(5)
	p.auto_dir = 1.0
	p.auto_jump = true
	var t_wall := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t_wall < 2500:
		await kit.node.get_tree().process_frame
	await kit.save("06_muro_3_blocchi")
	p.auto_dir = 0.0
	p.auto_jump = false
	var over := p.position.x > (wx + 1) * S
	print("muro di 3 blocchi: %s" % ("scavalcato" if over else "NON scavalcato"))
	for dy in range(1, 4):
		world.set_tile(wx, s.y + 1 - dy, TileDefs.AIR)
		kit.m.view.refresh_around(Vector2i(wx, s.y + 1 - dy))
	kit.m.light.dirty = true
