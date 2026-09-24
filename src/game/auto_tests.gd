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
	# grotta con torcia: la torcia più vicina alla partenza tra quelle non troppo profonde
	var best := _nearest(world.torches.keys(), world.spawn, func(c: Vector2i) -> bool: return world.depth(c.x, c.y) in range(14, 60))
	if best.x >= 0:
		var f := _floor_near(world, best, 6)
		if f.x >= 0:
			m.snap_to(f)
			await _frames(20)
			await _save("02_grotta_torcia")
			m.player.force_swing = true
			var target := f + Vector2i(1, 0)
			for k in 3:
				if world.solid(target.x, target.y):
					break
				target.x += 1
			if world.solid(target.x, target.y):
				m.actions.break_tile(target)
			await _frames(6)
			await _save("04_scavo")
			m.player.force_swing = false
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
	get_tree().quit()


func _frames(n: int) -> void:
	for k in n:
		await get_tree().process_frame


func _save(name: String) -> void:
	await RenderingServer.frame_post_draw
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
