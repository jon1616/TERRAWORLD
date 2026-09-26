class_name TestsHero
extends RefCounted
## Prove degli sprite nuovi del Germogliato (Nano Banana, 26 set 2026; vedi `HeroSprites`): i fotogrammi si caricano e
## in ognuno si trova l'occhio (tranne nel battito di ciglia); da fermo e di corsa il Germogliato usa gli sprite nuovi;
## con il corpo alto 30 pixel passa ancora in un cunicolo alto 2 blocchi; al buio l'occhio brilla. Foto
## 71_germogliato_fermo, 72_germogliato_corsa, 73_germogliato_cunicolo, 74_germogliato_salto, 75_germogliato_colpo; nel salto si
## vedono spinta, salita, cima, caduta e atterraggio, nel colpo le 6 pose con il piccone nel pugno.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _uses(anim: String) -> bool:
	var d: Dictionary = HeroSprites.data().get(anim, {})
	return not d.is_empty() and (d["tex"] as Array).has(m.player.spr.texture)


func run() -> void:
	var hero := HeroSprites.data()
	var desc := []
	for anim in HeroSprites.ANIMS:
		if not hero.has(anim):
			desc.append("%s MANCA" % anim)
			continue
		var d: Dictionary = hero[anim]
		var eyes := (d["eye"] as Array).filter(func(e: Vector2) -> bool: return e != Vector2.INF).size()
		desc.append("%s %d pose %dx%d, occhio in %d" % [anim, (d["tex"] as Array).size(), d["size"].x, d["size"].y, eyes])
	print("sprite del Germogliato: %s; corpo %dx%d pixel" % [", ".join(desc), Player.HALF.x * 2, Player.HALF.y * 2])
	if hero.size() < HeroSprites.ANIMS.size():
		print("ATTENZIONE: sprite del Germogliato mancanti in arte/germogliato/ (serve --import?)")
		return
	var p: Player = m.player
	kit.make_room()
	# lontano dalla partenza (nel giro lungo le prove di prima la occupano con le loro stazioni); poi si spiana
	var spot := kit.flat_spot(world.spawn + Vector2i(-300, 0), 6)
	if spot.x < 0:
		spot = kit.flat_spot(world.spawn + Vector2i(260, 0), 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno piano per le prove del Germogliato")
		return
	kit.flatten(spot, 16)
	m.snap_to(spot + Vector2i(-6, 0))
	kit.hold("piccone_radicite")
	await kit.seconds(1.2)
	var idle := _uses("fermo")
	await kit.save("71_germogliato_fermo")
	p.auto_dir = 1.0
	await kit.seconds(0.5)
	var run := _uses("corsa")
	await kit.save("72_germogliato_corsa")
	await kit.seconds(0.4)
	p.auto_dir = 0.0
	await kit.seconds(0.6)
	print("Germogliato: da fermo sprite nuovi %s, di corsa sprite nuovi %s" % ["sì" if idle else "NO", "sì" if run else "NO"])
	# un salto: quali pose si vedono dalla spinta all'atterraggio
	var salto: Array = HeroSprites.data()["salto"]["tex"]
	var seen := {}
	p.auto_jump = true
	var t1 := Time.get_ticks_msec()
	var shot := false
	while Time.get_ticks_msec() - t1 < 1600:
		await kit.frames(1)
		var i := salto.find(p.spr.texture)
		if i >= 0:
			seen[i] = true
		if i == HeroSprites.Salto.CIMA and not shot:
			shot = true
			await kit.save("74_germogliato_salto")
		if Time.get_ticks_msec() - t1 > 200:
			p.auto_jump = false
	p.auto_jump = false
	var names := ["preparazione", "spinta", "salita", "cima", "caduta", "atterraggio"]
	var got := []
	for i in seen.keys():
		got.append(names[i])
	print("salto: pose viste %s" % [got])
	if not (seen.has(HeroSprites.Salto.SALITA) and seen.has(HeroSprites.Salto.CIMA) and seen.has(HeroSprites.Salto.CADUTA)
			and seen.has(HeroSprites.Salto.ATTERRA)):
		print("ATTENZIONE: nel salto mancano delle pose")
	# un colpo di piccone: le pose del colpo, con il piccone nel pugno
	var colpo: Array = HeroSprites.data()["colpo"]["tex"]
	var hits := {}
	var tool_ok := true
	var snapped := false
	kit.hold("piccone_radicite")
	p.force_swing = true
	var t2 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t2 < 1200:
		await kit.frames(1)
		var j := colpo.find(p.spr.texture)
		if j >= 0:
			hits[j] = true
			tool_ok = tool_ok and p.tool.visible
			if j == 3 and not snapped:
				snapped = true
				await kit.save("75_germogliato_colpo")
	p.force_swing = false
	await kit.frames(2)
	print("colpo: pose viste %d su %d, piccone nel pugno %s, di nuovo fermo dopo %s" % [hits.size(), colpo.size(),
		"sì" if tool_ok and not hits.is_empty() else "NO", "sì" if _uses("fermo") else "NO"])
	# un cunicolo alto 2 blocchi: soffitto di pietra a 2 tessere dal pavimento, per 8 tessere
	var x0 := spot.x + 2
	for x in range(x0, x0 + 8):
		for y in range(spot.y - 5, spot.y - 1):
			world.set_tile(x, y, TileDefs.STONE)
		world.set_tile(x, spot.y - 1, TileDefs.AIR)
		world.set_tile(x, spot.y, TileDefs.AIR)
	for x in range(x0 - 1, x0 + 9, 2):
		m.view.refresh_around(Vector2i(x, spot.y - 2))
	m.snap_to(Vector2i(x0 - 3, spot.y))
	await kit.frames(3)
	p.auto_dir = 1.0
	var t0 := Time.get_ticks_msec()
	var half_way := false
	while Time.get_ticks_msec() - t0 < 3500 and p.position.x < (x0 + 9) * S:
		await kit.frames(1)
		if not half_way and p.position.x > (x0 + 4) * S:
			half_way = true
			await kit.save("73_germogliato_cunicolo")
	p.auto_dir = 0.0
	print("cunicolo alto 2 blocchi: attraversato %s" % ("sì" if p.position.x >= (x0 + 9) * S else "NO (fermo a %.1f tessere dall'uscita)" % [((x0 + 9) * S - p.position.x) / S]))
	# al buio l'occhio brilla: il suo bagliore è sopra la luce
	print("occhio che brilla al buio: %s" % ("sì" if p.eye.visible and p.eye.z_index > 20 else "NO"))
	m.snap_to(spot)
