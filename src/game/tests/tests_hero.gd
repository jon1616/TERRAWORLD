class_name TestsHero
extends RefCounted
## Prove degli sprite nuovi del Germogliato (Nano Banana, 26 set 2026; vedi `HeroSprites`): i fotogrammi si caricano e
## in ognuno si trova l'occhio (tranne nel battito di ciglia); da fermo e di corsa il Germogliato usa gli sprite nuovi;
## con il corpo alto 30 pixel passa ancora in un cunicolo alto 2 blocchi; al buio l'occhio brilla. Foto
## 71_germogliato_fermo, 72_germogliato_corsa, 73_germogliato_cunicolo, 74_germogliato_salto, 75_germogliato_colpo, 76_germogliato_mira, 77_germogliato_torcia; nel salto si vedono spinta, salita, cima, caduta
## e atterraggio, nel colpo le 6 pose con il piccone nel pugno, nella mira una posa per direzione con l'arco, con la
## torcia in mano la posa ferma e quelle di corsa con la fiamma accesa; ferito le due pose della ferita, appassito le
## quattro dell'appassire e poi di nuovo in piedi (foto 78_germogliato_appassito).

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
	if not run:
		var c: Vector2i = m.player_cell()
		print("ATTENZIONE: il Germogliato non corre: posto %s, cella %s, vel %s, a terra %s, davanti solido %s/%s, stazioni vicine %s" % [
			spot, c, p.vel, p.on_floor, world.solid(c.x + 1, c.y), world.solid(c.x + 1, c.y - 1),
			Crafting.stations_near(world, c).keys()])
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
	# la mira: 6 direzioni, dall'alto al basso davanti; l'arco nel pugno
	var mira: Array = HeroSprites.data()["mira"]["tex"]
	kit.hold("arco_radice")
	var poses := []
	var bow_ok := true
	# la mira la calcola il combattimento dal mouse: nelle prove da un bersaglio finto (`auto_aim`)
	m.combat.auto_fire = true
	for g in [0.0, 30.0, 60.0, 90.0, 120.0, 160.0]:
		var dirv := Vector2(sin(deg_to_rad(g)), -cos(deg_to_rad(g)))
		m.combat.auto_aim = p.position + Vector2(0, -6) + dirv * 120.0
		await kit.frames(3)
		poses.append(mira.find(p.spr.texture))
		bow_ok = bow_ok and p.tool.visible
		if g == 60.0:
			await kit.save("76_germogliato_mira")
	m.combat.auto_fire = false
	m.combat.auto_aim = Vector2.INF
	await kit.frames(2)
	var distinct := {}
	for q in poses:
		distinct[q] = true
	print("mira: pose per 0°, 30°, 60°, 90°, 120°, 160° %s (%d diverse), arco nel pugno %s" % [poses, distinct.size(),
		"sì" if bow_ok else "NO"])
	# la torcia in mano: da fermo e di corsa, con la fiamma
	var torcia: Array = HeroSprites.data()["torcia"]["tex"]
	kit.hold("torcia")
	await kit.frames(3)
	var still := torcia.find(p.spr.texture)
	var lit := p.flame.visible
	p.auto_dir = -1.0
	await kit.seconds(0.4)
	var running := torcia.find(p.spr.texture)
	await kit.save("77_germogliato_torcia")
	p.auto_dir = 0.0
	await kit.seconds(0.3)
	print("torcia: da fermo posa %d, di corsa posa %d, fiamma accesa %s" % [still, running, "sì" if lit and p.flame.visible else "NO"])
	kit.hold("piccone_radicite")
	await kit.frames(2)
	# una ferita (due pose per un attimo) e l'appassire (quattro pose, poi si rinasce)
	var colpito: Array = HeroSprites.data()["colpito"]["tex"]
	var hurt_seen := {}
	m.combat.invuln = 0.0
	var was_god: bool = m.combat.god
	m.combat.god = false
	m.combat.hurt_player(5, p.position.x + 30.0)
	var t3 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t3 < 500:
		await kit.frames(1)
		var j := colpito.find(p.spr.texture)
		if j >= 0:
			hurt_seen[j] = true
	var wilt_seen := {}
	m.vitals.hurt(m.vitals.hp + 50)
	var t4 := Time.get_ticks_msec()
	var lying_shot := false
	while Time.get_ticks_msec() - t4 < 2600:
		await kit.frames(1)
		var j := colpito.find(p.spr.texture)
		if j >= 2:
			wilt_seen[j] = true
		if j == 5 and not lying_shot:
			lying_shot = true
			await kit.save("78_germogliato_appassito")
	await kit.seconds(1.2)
	m.combat.god = was_god
	print("ferita: pose %s; appassire: pose %s; rinato in piedi %s" % [hurt_seen.keys(), wilt_seen.keys(),
		"sì" if not m.life.dead and colpito.find(p.spr.texture) < 0 else "NO"])
	kit.make_room()
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
