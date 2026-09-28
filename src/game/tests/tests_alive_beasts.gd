class_name TestsAliveBeasts
extends RefCounted
## Roadmap 15 «Il mondo abitato», le prove del bestiario (le chiama `TestsAlive`, gruppo «vivo»): le specie nuove e
## le condizioni (voci 132-134), i Signori (135), i tre Guardiani (136), le maree (137), lo studio (138), i tempi (150).

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


## Voci 132-134: ogni specie di un pacchetto del bestiario nasce, vive qualche istante accanto al Germogliato (a gruppi
## di otto) senza errori, e la sua scheda si scrive; una foto del primo gruppo.
func species(pack: String, photo: String) -> void:
	var data: Dictionary = (load("res://src/data/bestiary/%s.gd" % pack) as GDScript).get("DATA")
	var ids: Array = (data["creatures"] as Dictionary).keys()
	m.snap_to(m.player_cell())
	m.combat.god = true
	var P: Vector2 = m.player.position
	var alive := 0
	var cards := 0
	for g in range(0, ids.size(), 8):
		for i in range(g, mini(g + 8, ids.size())):
			var id := String(ids[i])
			var cd: Dictionary = CreaturesData.get_data(id)
			var at := P + Vector2(-140.0 + (i - g) * 40.0, -40.0 if cd.get("fly", false) else -8.0)
			var cr: Creature = m.fauna.add(id, at)
			cr.mind.brave = true
			if not WorldTip.creature(m, cr).plain().is_empty():
				cards += 1
		await kit.seconds(1.2)
		if g == 0:
			await kit.save(photo)
		for cr in m.fauna.list:
			if is_instance_valid(cr) and cr.hp > 0:
				alive += 1
		m.fauna.clear()
	m.combat.god = false
	m.vitals.refill()
	print("bestiario «%s»: %d specie nate, %d vive dopo un attimo, %d schede scritte" % [pack, ids.size(), alive, cards])
	if cards < ids.size():
		print("ATTENZIONE: alcune specie del bestiario «%s» non hanno la scheda" % pack)


## Voce 134: le specie a condizione nascono solo quando la condizione c'è (notte, stagione, tempo, eclissi).
func conditions() -> void:
	var s0 := CreaturesData.now_season
	var w0 := CreaturesData.now_weather
	var e0 := CreaturesData.now_eclipse
	var ids := func(night: bool) -> Array:
		return CreaturesData.of_stratum(0, night, "foresta").map(func(e: Array) -> String: return String(e[0]))
	CreaturesData.now_season = "germoglio"
	CreaturesData.now_weather = "sereno"
	CreaturesData.now_eclipse = false
	var calm: Array = ids.call(false)
	var no_other := not "cinghiale_raccolto" in calm and not "rana_tuono" in calm and not "eclissimo" in calm and not "lupo_lunare" in calm
	var has_season := "bruco_germoglio" in calm
	CreaturesData.now_season = "raccolto"
	CreaturesData.now_weather = "temporale"
	CreaturesData.now_eclipse = true
	var storm: Array = ids.call(true)
	var all_in := "cinghiale_raccolto" in storm and "rana_tuono" in storm and "eclissimo" in storm and "lupo_lunare" in storm 		and not "bruco_germoglio" in storm
	CreaturesData.now_season = s0
	CreaturesData.now_weather = w0
	CreaturesData.now_eclipse = e0
	print("specie a condizione: col sereno di giorno in Germoglio solo quelle giuste %s (bruco sì %s); di notte col temporale in Raccolto e l'eclissi le altre %s" % [
		"sì" if no_other else "NO", "sì" if has_season else "NO", "sì" if all_in else "NO"])
	if not no_other or not has_season or not all_in:
		print("ATTENZIONE: le specie a condizione non nascono come dovrebbero")


## Voce 135: nella foresta l'esca del Cervo-lanterna lo chiama; a metà Vita entra in furia; sconfitto lascia il suo
## materiale e il trofeo; l'esca di un altro luogo qui non fa nulla.
func lords() -> void:
	var w: World = m.world
	m.snap_to(w.spawn)
	await kit.frames(3)
	var key: String = m.lords.here()
	var b: Bisaccia = m.character.bisaccia
	var wrong := "esca_signore_brace" if key != "brace" else "esca_signore_foresta"
	b.add(wrong, 1)
	var no: bool = not m.lords.summon(wrong)
	var bait := "esca_signore_" + key
	b.add(bait, 1)
	m.combat.god = true
	var ok: bool = key != "" and m.lords.summon(bait)
	var lord: Creature = m.lords.active
	var n0: int = lord.behaviors.size() if lord else 0
	if lord:
		lord.hp = lord.hp_max / 3
		await kit.seconds(0.3)
	var fury: bool = lord != null and is_instance_valid(lord) and lord.behaviors.size() > n0
	await kit.save("204_signore")
	var d0: int = m.drops._items.size()
	if lord and is_instance_valid(lord):
		m.fauna.kill(lord)
	var rec: int = int((m.world_meta.get("signori", {}) as Dictionary).get(key, 0))
	var dropped: bool = m.drops._items.size() > d0
	m.fauna.clear()
	m.combat.god = false
	b.remove(wrong, b.count(wrong))
	print("Signori: qui «%s», l'esca sbagliata non fa nulla %s, quella giusta lo chiama %s, furia a metà Vita %s, sconfitto (%d) e bottino %s" % [
		key, "sì" if no else "NO", "sì" if ok else "NO", "sì" if fury else "NO", rec, "sì" if dropped else "NO"])
	if key == "" or not no or not ok or not fury or rec < 1 or not dropped:
		print("ATTENZIONE: i Signori dei luoghi non vanno come dovrebbero")


## Voce 136: la Signora delle correnti si chiama all'aperto (il Leviatano senza lago no); le mosse: la raffica spinge
## e fa nascere correnti e nuvole, i pilastri si alzano solo nell'aria e crollano, la marea versa acqua; alla fine non
## resta nulla di temporaneo.
func great() -> void:
	var w: World = m.world
	var gg: GreatGuardians = m.great
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.combat.god = true
	var b: Bisaccia = m.character.bisaccia
	b.add("richiamo_leviatano", 1)
	var no_lake: bool = not gg.summon("richiamo_leviatano")
	b.add("richiamo_correnti", 1)
	var sky: bool = gg.summon("richiamo_correnti")
	var boss: Creature = gg.active
	var P: Vector2 = m.player.position
	var v0: float = m.player.vel.x
	var cur0: int = m.gravity.currents.size()
	if boss:
		gg.act(boss, {"kind": "correnti", "at": P, "from": P - Vector2(80, 0)})
	var pushed: bool = m.player.vel.x - v0 > 100.0
	var winds: bool = m.gravity.currents.size() > cur0   # (le nuvole nascono solo nell'aria libera: attorno può esserci già costruito)
	await kit.seconds(0.3)
	await kit.save("206_correnti")
	if boss:
		gg.act(boss, {"kind": "pilastri", "at": P + Vector2(0, 0), "n": 3})
	var raised: int = gg.pillars.size()
	var solid_ok := true
	for e in gg.pillars:
		solid_ok = solid_ok and w.tile((e[0] as Vector2i).x, (e[0] as Vector2i).y) == TileDefs.RADICE
	var t0: int = gg.tides
	if boss:
		gg.act(boss, {"kind": "marea", "at": P + Vector2(0, 16), "to": P + Vector2(64, 0), "n": 4})
	var tide: bool = gg.tides > t0
	gg.clear_temp()
	var cleared: bool = gg.pillars.is_empty() and gg.clouds.is_empty() and m.gravity.currents.size() == cur0
	if boss and is_instance_valid(boss):
		m.fauna.kill(boss)
	var rec: int = int((m.world_meta.get("grandi_guardiani", {}) as Dictionary).get("correnti", 0))
	m.fauna.clear()
	m.combat.god = false
	print("grandi Guardiani: il Leviatano senza lago no %s; la Signora delle correnti all'aperto sì %s; raffica %s, correnti e nuvole %s; %d pilastri di radice %s; marea %s; poi tutto sparito %s; sconfitta (%d)" % [
		"sì" if no_lake else "NO", "sì" if sky else "NO", "sì" if pushed else "NO", "sì" if winds else "NO", raised,
		"sì" if solid_ok else "NO", "sì" if tide else "NO", "sì" if cleared else "NO", rec])
	if not no_lake or not sky or not pushed or not winds or raised < 3 or not tide or not cleared or rec < 1:
		print("ATTENZIONE: i grandi Guardiani non vanno come dovrebbero")


## Voce 137: lo Stormo arriva a ondate, poi il capo; sconfitto, il premio. L'assedio c'è solo con una base, accende
## i morsi alle porte e poi non torna nella stessa stagione.
func tides() -> void:
	var w: World = m.world
	var td: Tides = m.tides
	td.paused = true
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.combat.god = true
	td.center = m.player_cell()
	td.start("stormo")
	var waves_seen := 0
	var t0 := Time.get_ticks_msec()
	while td.active != "" and Time.get_ticks_msec() - t0 < 20000:
		await kit.frames(3)
		waves_seen = maxi(waves_seen, td.wave)
		if td.boss and is_instance_valid(td.boss):
			if waves_seen >= 3 and td.wins == 0:
				await kit.save("207_marea")
			m.fauna.kill(td.boss)
		else:
			for c in td._wave_list.duplicate():
				if is_instance_valid(c):
					m.fauna.kill(c)
	var won_ok := td.wins >= 1
	m.fauna.clear()
	# l'assedio: senza base no; con Focolare e porta sì, e accende i morsi
	var no_base: bool = not td.siege_allowed() or td._base().x >= 0
	var fo: Vector2i = m.player_cell() + Vector2i(-6, -1)
	var dr: Vector2i = m.player_cell() + Vector2i(-10, 1 - m.masonry.door_h())
	var had_f: bool = w.stations.has(fo)
	w.stations[fo] = "focolare"
	w.stations[dr] = "porta_aperta"
	m.world_meta.erase("assedio")
	var can: bool = td.siege_allowed()
	td.center = td._base()
	td.start("assedio")
	var gnaw: bool = Wiles.siege
	td._end(false)
	var again: bool = td.siege_allowed()
	w.stations.erase(fo)
	w.stations.erase(dr)
	m.fauna.clear()
	m.combat.god = false
	td.paused = false
	print("maree: lo Stormo %d ondate, capo sconfitto e premio %s (%d nate); l'assedio con la base %s, porte rosicchiate %s, di nuovo nella stessa stagione no %s" % [
		waves_seen, "sì" if won_ok else "NO", td.spawned, "sì" if can else "NO", "sì" if gnaw else "NO", "sì" if not again else "NO"])
	if waves_seen < 3 or not won_ok or not can or not gnaw or again:
		print("ATTENZIONE: le maree del mondo non vanno come dovrebbero")


## Voce 138: una specie passa da sconosciuta a vista, sconfitta e studiata (con le sconfitte e la Provetta); la scheda
## svela le debolezze da sconfitta e le contromosse da studiata; studiata fa +6% di danno.
func study() -> void:
	var w: World = m.world
	var st: Study = m.study
	var base := "tessispore"
	var er: Dictionary = m.character.erbario
	er["creature"].erase(base)
	er["viste"].erase(base)
	er["studio"].erase(base)
	m.snap_to(w.spawn)
	await kit.frames(2)
	var g0 := st.grade(base)
	var cr: Creature = m.fauna.add(base, m.player.position + Vector2(40, -8))
	cr.mind.brave = true
	await kit.seconds(1.2)
	var g1 := st.grade(base)
	var tip1: String = WorldTip.creature(m, cr).plain()
	m.fauna.kill(cr)
	await kit.frames(2)
	var g2 := st.grade(base)
	er["creature"][base] = st.need(base) - 4
	var cr2: Creature = m.fauna.add(base, m.player.position + Vector2(24, -8))
	m.character.bisaccia.add("provetta", 1)
	var c2 := Vector2i(floori(cr2.position.x / 16.0), floori(cr2.position.y / 16.0))
	var sampled: bool = st.sample(c2, "provetta")
	var g3 := st.grade(base)
	var tip3: String = WorldTip.creature(m, cr2).plain()
	var mult: float = st.mult(base)
	m.fauna.clear()
	print("studio: %s da %d a %d (vista), %d (sconfitta), %d (studiata con la Provetta %s); prima la scheda nasconde %s, dopo mostra %s; danno ×%.2f" % [
		base, g0, g1, g2, g3, "sì" if sampled else "NO", "sì" if tip1.contains("studiala") else "NO",
		"sì" if tip3.contains("fuoco") or tip3.contains("Debole") else "NO", mult])
	if g0 != 0 or g1 != 1 or g2 != 2 or g3 != 3 or not sampled or mult <= 1.0 or not tip1.contains("studiala"):
		print("ATTENZIONE: lo studio delle creature non va come dovrebbe")


## Voce 150: i tempi con molte creature nuove (astuzie, cervello, tattiche) e i costrutti attorno: il fotogramma peggiore
## e la media in 3 secondi con 40 creature vicine.
func load_test() -> void:
	var w: World = m.world
	m.snap_to(w.spawn)
	await kit.frames(3)
	m.combat.god = true
	var pool: Array = []
	for f in ["superficie", "sottosuolo", "tempo"]:
		var d: Dictionary = (load("res://src/data/bestiary/%s.gd" % f) as GDScript).get("DATA")
		for cid in d["creatures"]:
			if not (d["creatures"][cid] as Dictionary).get("water", false):
				pool.append(cid)
	for i in 40:
		var cid := String(pool[i % pool.size()])
		var cr: Creature = m.fauna.add(cid, m.player.position + Vector2(-300.0 + (i % 20) * 30.0, -30.0 - (i / 20) * 40.0))
		cr.mind.brave = true
	await kit.frames(10)
	var worst := 0.0
	var total := 0.0
	var n := 0
	var t0 := Time.get_ticks_usec()
	var last := t0
	while Time.get_ticks_usec() - t0 < 3000000:
		await kit.frames(1)
		var now := Time.get_ticks_usec()
		var dt := float(now - last) / 1000.0
		last = now
		worst = maxf(worst, dt)
		total += dt
		n += 1
	m.fauna.clear()
	m.wiles.webs.clear()
	m.combat.god = false
	m.vitals.refill()
	print("tempi con 40 creature nuove: %d fotogrammi in 3 s (media %.1f ms), il peggiore %.1f ms" % [n, total / maxf(n, 1), worst])
	if total / maxf(n, 1) > 25.0:
		print("ATTENZIONE: con 40 creature il gioco rallenta troppo")
