class_name AutoTests
extends Node
## Prove automatiche con finestra (`-- --prove`): porta il giocatore in punti significativi del mondo, salva
## screenshot in prove/ e misura quanto costano luce e blocchi mentre ci si muove.

const S := 16

var m: Node2D


func run(main: Node2D) -> void:
	m = main
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove"))
	var world: World = m.world
	m.player.control = false
	m.actions.enabled = false
	await _frames(30)
	await _save("01_superficie")
	# grotta con torcia: la torcia più vicina alla partenza, non troppo profonda, con un pavimento accanto
	var f := Vector2i(-1, -1)
	var cands: Array = world.torches.keys().filter(func(c: Vector2i) -> bool: return world.depth(c.x, c.y) in range(14, 80))
	cands.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return Vector2(a - world.spawn).length_squared() < Vector2(b - world.spawn).length_squared())
	for c in cands:
		f = _floor_near(world, c, 6)
		if f.x >= 0:
			break
	if f.x < 0:
		print("ATTENZIONE: nessuna grotta con torcia e pavimento vicino alla partenza")
	else:
		m.snap_to(f)
		await _frames(20)
		await _save("02_grotta_torcia")
		m.player.force_swing = true
		var target := f + Vector2i(1, 0)
		for k in 3:
			if world.solid(target.x, target.y):
				break
			target.x += 1
		var mined := ""
		var had := 0
		if world.solid(target.x, target.y):
			mined = String(TileDefs.DROP[world.tile(target.x, target.y)])
			had = (m.character.bisaccia as Bisaccia).count(mined)
			m.actions.break_tile(target)
		await _frames(6)
		await _save("04_scavo")
		m.player.force_swing = false
		if mined != "":
			await _pickup_and_place(world, mined, target, had)
	# cristalli: il più vicino alla partenza che tocca l'aria
	var crystals: Array = []
	for y in range(world.surface[world.spawn.x] + 340, mini(world.surface[world.spawn.x] + 520, world.h)):
		for x in range(world.spawn.x - 300, world.spawn.x + 300):
			if world.tile(x, y) == TileDefs.CRYSTAL and m.view.mask(Vector2i(x, y)) != 0:
				crystals.append(Vector2i(x, y))
	var cr := _nearest(crystals, world.spawn, func(_c: Vector2i) -> bool: return true)
	if cr.x >= 0:
		var f2 := _floor_near(world, cr, 8)
		if f2.x >= 0:
			m.snap_to(f2)
			await _frames(20)
			await _save("03_cristalli")
	await _trees(world)
	await _movement(world)
	# corsa lungo la superficie: misura i fotogrammi mentre blocchi e luce si aggiornano
	m.snap_to(world.spawn)
	await _frames(10)
	var t0 := Time.get_ticks_msec()
	var frames := 0
	var worst := 0.0
	for k in 180:
		m.player.position.x += 9.0
		m.player.position.y = (world.surface[clampi(int(m.player.position.x / S), 0, world.w - 1)] - 1) * S
		var f0 := Time.get_ticks_usec()
		await get_tree().process_frame
		worst = maxf(worst, (Time.get_ticks_usec() - f0) / 1000.0)
		frames += 1
	var ms := Time.get_ticks_msec() - t0
	print("corsa: %d fotogrammi in %d ms (%.1f fps), fotogramma peggiore %.1f ms, blocchi caricati %d" % [
		frames, ms, frames * 1000.0 / ms, worst, m.view.chunks.size()])
	await _frames(10)
	await _save("05_dopo_la_corsa")
	# salvataggio dal gioco e ricaricamento: il mondo su disco deve essere identico a quello in memoria
	var t1 := Time.get_ticks_msec()
	m.save_game()
	var t_save := Time.get_ticks_msec() - t1
	t1 = Time.get_ticks_msec()
	var l := WorldSave.load_world(m.world_id)
	var t_load := Time.get_ticks_msec() - t1
	var same: bool = l != null and l.tiles == world.tiles and l.walls == world.walls and l.decor == world.decor and l.torches.size() == world.torches.size()
	print("salvataggio dal gioco %d ms, ricaricamento %d ms: %s" % [t_save, t_load, "identico" if same else "DIVERSO"])
	var saved := Character.load_id(m.character.id)
	var bis_ok: bool = saved != null and saved.bisaccia.to_array() == m.character.bisaccia.to_array()
	print("Bisaccia salvata e ricaricata: %s" % ("identica" if bis_ok else "DIVERSA"))
	# la Bisaccia aperta
	m.hud.panel.toggle()
	await _frames(12)
	await _save("07_bisaccia")
	m.hud.panel.toggle()
	get_tree().quit()


## Alberi: si abbatte con l'ascia l'albero più vicino alla partenza, si raccoglie il legno, si pianta un seme dove
## c'era e lo si fa crescere subito.
func _trees(world: World) -> void:
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
	var b: Bisaccia = m.character.bisaccia
	var base := Vector2i(best.x, best.y)
	m.snap_to(base + Vector2i(-2, 0))
	await _frames(10)
	var axe := -1
	for i in Bisaccia.HOTBAR:
		if String(ItemsData.get_item(b.id_at(i)).get("kind", "")) == "ascia":
			axe = i
	m.hud.select(axe)
	var wood_before := b.count("legno")
	var hits := 0
	while world.tree_at(base).x >= 0 and hits < 10:
		m.actions._chop(base + Vector2i(0, -3), m.hud.current(), 1.0)
		hits += 1
		await _frames(3)
	await _frames(10)
	await _save("08_albero_cade")
	for k in 120:
		await get_tree().process_frame
		if b.count("legno") >= wood_before + FloraData.WOOD[0]:
			break
	print("albero: abbattuto in %d colpi, legno raccolto %d" % [hits, b.count("legno") - wood_before])
	# un seme dove c'era l'albero, fatto crescere subito
	if b.count("seme_lanterna") == 0:
		b.add("seme_lanterna", 1)
	var slot := -1
	for i in Bisaccia.HOTBAR:
		if b.id_at(i) == "seme_lanterna":
			slot = i
	if slot < 0:
		print("ATTENZIONE: il seme non è nella barra rapida")
		return
	m.hud.select(slot)
	var planted: bool = m.actions.plant(base, "seme_lanterna")
	m.grow_saplings(99999.0)
	await _frames(70)
	print("germoglio: %s" % ("piantato e cresciuto" if planted and world.tree_at(base).x >= 0 else "NON cresciuto"))
	await _save("09_albero_ricresciuto")


## Movimento sulla zona piana della partenza: velocità massima, altezza del salto pieno, e un muro di 3 blocchi da
## scavalcare correndo e saltando (il salto di base deve bastare, richiesta dell'utente del 24 set 2026).
func _movement(world: World) -> void:
	var p: Player = m.player
	var s := world.spawn
	m.snap_to(s + Vector2i(-6, 0))
	await _frames(5)
	p.auto_dir = 1.0
	var t0 := Time.get_ticks_msec()
	var top := 0.0
	var reach_ms := -1
	while Time.get_ticks_msec() - t0 < 700:
		await get_tree().process_frame
		top = maxf(top, absf(p.vel.x))
		if reach_ms < 0 and absf(p.vel.x) >= Player.RUN - 0.5:
			reach_ms = Time.get_ticks_msec() - t0
	p.auto_dir = 0.0
	await _frames(40)
	var ground := p.position.y
	p.auto_jump = true
	var high := ground
	for k in 90:
		await get_tree().process_frame
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
		m.view.refresh_around(Vector2i(wx, s.y + 1 - dy))
	m.light.dirty = true
	m.snap_to(s + Vector2i(-2, 0))
	await _frames(5)
	p.auto_dir = 1.0
	p.auto_jump = true
	for k in 150:
		await get_tree().process_frame
	await _save("06_muro_3_blocchi")
	p.auto_dir = 0.0
	p.auto_jump = false
	var over := p.position.x > (wx + 1) * S
	print("muro di 3 blocchi: %s" % ("scavalcato" if over else "NON scavalcato"))
	for dy in range(1, 4):
		world.set_tile(wx, s.y + 1 - dy, TileDefs.AIR)
		m.view.refresh_around(Vector2i(wx, s.y + 1 - dy))
	m.light.dirty = true


## Ciò che si scava cade, viene raccolto nella Bisaccia, e con il blocco in mano lo si rimette dov'era.
func _pickup_and_place(world: World, id: String, cell: Vector2i, before: int) -> void:
	var b: Bisaccia = m.character.bisaccia
	for k in 90:
		await get_tree().process_frame
		if b.count(id) > before:
			break
	print("raccolta: %s %s" % [id, "nella Bisaccia" if b.count(id) > before else "NON raccolto"])
	var slot := -1
	for i in Bisaccia.HOTBAR:
		if b.id_at(i) == id:
			slot = i
	if slot < 0 or String(ItemsData.get_item(id).get("kind", "")) != "blocco":
		return
	m.hud.select(slot)
	var ok: bool = m.actions.place_block(cell, id)
	print("piazzamento: %s" % ("blocco rimesso" if ok and world.solid(cell.x, cell.y) else "NON riuscito"))
	await _frames(5)


func _frames(n: int) -> void:
	for k in n:
		await get_tree().process_frame


## Foto della finestra. Si aspettano due fotogrammi normali: `frame_post_draw` a volte non arriva e bloccava la prova
## (succedeva anche in Inkblood).
func _save(name: String) -> void:
	for k in 4:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://prove/%s.png" % name))
	print("salvato ", name)


func _nearest(list: Array, from: Vector2i, ok: Callable) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e12
	for c in list:
		if not ok.call(c):
			continue
		var d := Vector2(c - from).length_squared()
		if d < bd:
			bd = d
			best = c
	return best


func _floor_near(world: World, c: Vector2i, radius: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e9
	for y in range(c.y - radius, c.y + radius + 1):
		for x in range(c.x - radius, c.x + radius + 1):
			if y < 2 or world.solid(x, y) or world.solid(x, y - 1) or not world.solid(x, y + 1):
				continue
			var d := Vector2(x - c.x, y - c.y).length()
			if d < bd and d > 1.5:
				bd = d
				best = Vector2i(x, y)
	return best
