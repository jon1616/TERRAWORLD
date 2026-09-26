class_name TestsWorld
extends RefCounted
## Prove del mondo: superficie, grotta con torcia, scavo e raccolta, cristalli, corsa con misura dei fotogrammi,
## salvataggio dal gioco e ricaricamento.

const S := 16

var kit: TestKit
var world: World


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world


## Foto della superficie, della grotta con torcia, dello scavo e dei cristalli.
func places() -> void:
	await kit.frames(30)
	await kit.save("01_superficie")
	# grotta buia e poi con una torcia: una grotta aperta vicino alla partenza, non troppo profonda
	var f := _open_cave()
	if f.x < 0:
		print("ATTENZIONE: nessuna grotta aperta vicino alla partenza")
	else:
		kit.m.snap_to(f)
		await kit.seconds(1.0)
		await kit.save("02_grotta_buia")
		var far := f + Vector2i(8, 0)
		var near_dark: float = kit.m.light.value_at(f)
		var far_dark: float = kit.m.light.value_at(far)
		kit.m.actions.place_torch(f + Vector2i(1, 0))
		kit.m.light.compute_now(kit.m.player_cell(), kit.m.player_cell())
		var far_lit: float = kit.m.light.value_at(far)
		print("buio: attorno al Germogliato %.2f, a 8 tessere %.2f; con una torcia a 8 tessere %.2f" % [near_dark, far_dark, far_lit])
		await kit.seconds(1.0)
		await kit.save("02_grotta_torcia")
		kit.m.player.force_swing = true
		# si scava nel pavimento accanto (la grotta scelta ha aria a destra per la misura del buio)
		var target := f + Vector2i(2, 1)
		for k in 4:
			if world.solid(target.x, target.y):
				break
			target.x += 1
		# nessun pavimento lì (una buca): il blocco pieno più vicino che tocca l'aria e che si raggiunge
		# (non quello sotto i piedi: il Germogliato ci cadrebbe dentro e il blocco non si potrebbe rimettere)
		if not world.solid(target.x, target.y):
			var best := 1e9
			for dy in range(-3, 4):
				for dx in range(-5, 6):
					var c := f + Vector2i(dx, dy)
					var d := Vector2(dx, dy).length()
					if d >= 2.0 and d < best and world.solid(c.x, c.y) and not world.solid(c.x, c.y - 1) 							and kit.m.actions.in_reach(c) and TileDefs.POWER.get(world.tile(c.x, c.y), 0) < 35:
						best = d
						target = c
		var mined := ""
		var had := 0
		if world.solid(target.x, target.y):
			mined = String(TileDefs.DROP[world.tile(target.x, target.y)])
			had = (kit.m.character.bisaccia as Bisaccia).count(mined)
			kit.m.actions.break_tile(target)
		await kit.frames(6)
		await kit.save("04_scavo")
		kit.m.player.force_swing = false
		if mined != "":
			await pickup_and_place(mined, target, had)
		else:
			print("ATTENZIONE: nessun blocco da scavare accanto alla grotta di prova")
	# cristalli: il più vicino alla partenza che tocca l'aria
	var crystals: Array = []
	for y in range(world.surface[world.spawn.x] + 340, mini(world.surface[world.spawn.x] + 520, world.h)):
		for x in range(world.spawn.x - 300, world.spawn.x + 300):
			if world.tile(x, y) == TileDefs.CRYSTAL and kit.m.view.mask(Vector2i(x, y)) != 0:
				crystals.append(Vector2i(x, y))
	var cr := kit.nearest(crystals, world.spawn, func(_c: Vector2i) -> bool: return true)
	if cr.x >= 0:
		var f2 := kit.floor_near(cr, 8)
		if f2.x >= 0:
			kit.m.snap_to(f2)
			await kit.frames(20)
			await kit.save("03_cristalli")


## Una cella di pavimento in una grotta aperta (aria per 9 tessere a destra), tra 20 e 80 tessere di profondità,
## la più vicina alla partenza.
func _open_cave() -> Vector2i:
	for r in range(0, 600):
		for side in [1, -1]:
			var x: int = world.spawn.x + side * r
			for dep in range(20, 80):
				var y := world.surface[x] + dep
				var ok := world.solid(x, y + 1) and world.wall(x, y) != 0
				for dx in range(0, 10):
					if not ok:
						break
					ok = not world.solid(x + dx, y) and not world.solid(x + dx, y - 1)
				if ok:
					return Vector2i(x, y)
	return Vector2i(-1, -1)


## Corsa in superficie (fotogrammi), salvataggio e ricaricamento di mondo e Bisaccia.
func run_and_save() -> void:
	# corsa lungo la superficie: misura i fotogrammi mentre blocchi e luce si aggiornano
	kit.m.snap_to(world.spawn)
	await kit.frames(10)
	var t0 := Time.get_ticks_msec()
	var frames := 0
	var worst := 0.0
	var worst_at := 0
	var worst_split := []
	var worst_engine := ""
	# la sonda dice quale modulo ha preso il tempo del fotogramma peggiore
	var probe := FrameProbe.new()
	probe.attach(kit.m)
	await kit.node.get_tree().process_frame
	for k in 180:
		kit.m.player.position.x += 9.0
		kit.m.player.position.y = (world.surface[clampi(int(kit.m.player.position.x / S), 0, world.w - 1)] - 1) * S
		var f0 := Time.get_ticks_usec()
		probe.mark()
		await kit.node.get_tree().process_frame
		var dt := (Time.get_ticks_usec() - f0) / 1000.0
		var split := probe.split()
		if dt > worst:
			worst = dt
			worst_at = k
			worst_split = split
			worst_engine = probe.engine()          # riferiti all'ultimo giro completo del motore: questo
		frames += 1
	probe.detach()
	var ms := Time.get_ticks_msec() - t0
	print("corsa: %d fotogrammi in %d ms (%.1f fps), fotogramma peggiore %.1f ms (il %d°), blocchi caricati %d" % [
		frames, ms, frames * 1000.0 / ms, worst, worst_at, kit.m.view.chunks.size()])
	print("  il fotogramma peggiore: %s" % ", ".join(worst_split.map(func(e: Array) -> String: return "%s %.1f ms" % [e[0], e[1]])))
	print("  motore: %s" % worst_engine)
	await kit.frames(10)
	await kit.save("05_dopo_la_corsa")
	# salvataggio dal gioco e ricaricamento: il mondo su disco deve essere identico a quello in memoria
	var t1 := Time.get_ticks_msec()
	kit.m.save_game()
	var t_save := Time.get_ticks_msec() - t1
	t1 = Time.get_ticks_msec()
	var l := WorldSave.load_world(kit.m.world_id)
	var t_load := Time.get_ticks_msec() - t1
	var same: bool = l != null and l.tiles == world.tiles and l.walls == world.walls and l.decor == world.decor and l.torches.size() == world.torches.size() 			and l.chests_key() == world.chests_key() and l.stations == world.stations and l.explored == world.explored
	print("salvataggio dal gioco %d ms, ricaricamento %d ms: %s" % [t_save, t_load, "identico" if same else "DIVERSO"])
	var saved := Character.load_id(kit.m.character.id)
	var bis_ok: bool = saved != null and saved.bisaccia.to_array() == kit.m.character.bisaccia.to_array() 			and saved.bisaccia.equip == kit.m.character.bisaccia.equip 			and saved.bisaccia.equip_traits == kit.m.character.bisaccia.equip_traits
	print("Bisaccia salvata e ricaricata: %s" % ("identica" if bis_ok else "DIVERSA"))


## Ciò che si scava cade, viene raccolto nella Bisaccia, e con il blocco in mano lo si rimette dov'era.
func pickup_and_place(id: String, cell: Vector2i, before: int) -> void:
	var b: Bisaccia = kit.m.character.bisaccia
	for k in 90:
		await kit.node.get_tree().process_frame
		if b.count(id) > before:
			break
	print("raccolta: %s %s" % [id, "nella Bisaccia" if b.count(id) > before else "NON raccolto"])
	var slot := -1
	for i in Bisaccia.HOTBAR:
		if b.id_at(i) == id:
			slot = i
	if slot < 0 or String(ItemsData.get_item(id).get("kind", "")) != "blocco":
		return
	kit.m.hud.select(slot)
	var ok: bool = kit.m.actions.place_block(cell, id)
	print("piazzamento: %s" % ("blocco rimesso" if ok and world.solid(cell.x, cell.y) else "NON riuscito"))
	await kit.frames(5)
