class_name TestsFishing
extends RefCounted
## La pesca (Roadmap 14 «Le acque vive»). Voce 118: gli stagni di superficie nel mondo di prova, lo specchio riconosciuto
## al momento (`WaterBody`), un laghetto fatto a mano che vale come uno naturale, una pozzanghera troppo piccola.
## Gruppo «pesca».

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await bodies()
	await moving()
	await species()


## Due conche vuote affiancate su terreno piano vicino a c: [sinistra, destra] (i centri della prima riga), e ciò che
## c'era prima (per rimetterlo). Ogni conca è larga 11 e profonda 4, con il bordo di pietra.
func _basins(c: Vector2i, saved: Array) -> Array:
	var w: World = m.world
	var out := []
	for k in 2:
		var cx := c.x - 8 + k * 16
		for xx in range(cx - 6, cx + 7):
			for yy in range(c.y + 1, c.y + 7):
				saved.append([xx, yy, w.tile(xx, yy)])
				var edge := absi(xx - cx) == 6 or yy == c.y + 6
				w.set_tile(xx, yy, TileDefs.STONE if edge else TileDefs.AIR)
				w.set_liq(xx, yy, 0, 0)
		out.append(Vector2i(cx, c.y + 1))
	m.view.refresh_around(c)
	return out


func _restore(saved: Array) -> void:
	var w: World = m.world
	for s in saved:
		w.set_tile(int(s[0]), int(s[1]), int(s[2]))
		w.set_liq(int(s[0]), int(s[1]), 0, 0)


## Voce 119: l'otre raccoglie da un bacino e versa nell'altro senza perdere liquido; una fonte riempie una conca vuota
## finché non diventa pescabile.
func moving() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var spot := kit.flat_spot(w.spawn + Vector2i(-60, 0), 8)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per le prove dei liquidi")
		return
	kit.flatten(spot, 16)
	var saved := []
	var bs := _basins(spot, saved)
	m.snap_to(spot + Vector2i(0, -1))
	for yy in range(bs[0].y, bs[0].y + 5):
		for xx in range(bs[0].x - 5, bs[0].x + 6):
			w.set_liq(xx, yy, 8, LiquidsData.ACQUA)
	var before := WaterBody.at(w, bs[0])
	# l'otre in mano
	kit.make_room()
	b.add("otre_legnoferro", 1)
	kit.hold("otre_legnoferro")
	var took: bool = m.liquid_tools.use_container(bs[0] + Vector2i(4, 1), "otre_legnoferro")
	var d: Dictionary = b.data_at(m.hud.sel)
	var after := WaterBody.at(w, bs[0] + Vector2i(0, 4))
	var poured: bool = m.liquid_tools.use_container(bs[1] + Vector2i(-5, 1), "otre_legnoferro")
	for k in 60:
		m.liquids.step()
	var there := WaterBody.at(w, bs[1] + Vector2i(0, 4))
	var kept := not there.is_empty() and absf(float(there["volume"]) + float(after["volume"]) - float(before["volume"])) < 0.2
	print("otre: raccolto %s (%s), versato %s; nel bacino di prima %.1f → %.1f celle, nell'altro %.1f: niente perso %s" % [
		"sì" if took else "NO", LiquidTools.content_text("otre_legnoferro", d), "sì" if poured else "NO",
		float(before["volume"]), float(after.get("volume", 0.0)), float(there.get("volume", 0.0)), "sì" if kept else "NO"])
	# la fonte: nella conca di destra, svuotata, versa finché non è pescabile
	for yy in range(bs[1].y, bs[1].y + 5):
		for xx in range(bs[1].x - 5, bs[1].x + 6):
			w.set_liq(xx, yy, 0, 0)
	var fo := Vector2i(bs[1].x - 8, spot.y - 1)            # accanto alla conca, sul terreno spianato
	w.stations[fo] = "fonte_acqua"
	m.view.add_station(fo)
	var mouth: Vector2i = m.liquid_tools.mouth(fo, "fonte_acqua")
	var t0 := Time.get_ticks_msec()
	var filled := {}
	for k in 3000:
		m.liquid_tools.tick()
		m.liquids.step()
		filled = WaterBody.at(w, bs[1] + Vector2i(0, 4))
		if not filled.is_empty() and filled["ok"]:
			break
	await kit.frames(4)
	await kit.save("181_fonte")
	var full_ok := not filled.is_empty() and bool(filled["ok"])
	print("fonte di muschio: bocca %s, la conca vuota diventa pescabile %s (%s, %d ms)" % [mouth, "sì" if full_ok else "NO",
		WaterBody.describe(filled), Time.get_ticks_msec() - t0])
	w.stations.erase(fo)
	m.view.remove_station(fo)
	_restore(saved)
	m.view.refresh_around(spot)
	if not took or not poured or not kept or not full_ok:
		print("ATTENZIONE: i liquidi non si spostano come dovrebbero")


func bodies() -> void:
	var w: World = m.world
	# 1. uno stagno naturale in superficie
	var pond := {}
	var ponds := 0
	var x := 0
	while x < w.w:
		var y := w.surface[x]
		if w.liq(x, y) > 0:
			var b := WaterBody.at(w, Vector2i(x, y))
			if int(b["stratum"]) == 0:
				ponds += 1
				if pond.is_empty() or absi(x - w.spawn.x) < absi(int(pond["x0"]) - w.spawn.x):
					pond = b
				x = int(b["x1"]) + 1
				continue
		x += 1
	print("stagni di superficie nel mondo di prova: %d; il più vicino: %s" % [ponds, WaterBody.describe(pond)])
	if not pond.is_empty():
		var c: Vector2i = pond["center"]
		m.snap_to(Vector2i(int(pond["x0"]) - 6, w.surface[int(pond["x0"]) - 6] - 1))
		await kit.frames(6)
		await kit.save("180_stagno")
	# 2. un laghetto fatto a mano: una conca scavata e riempita
	var spot := kit.flat_spot(w.spawn + Vector2i(70, 0), 17)
	var made := {}
	var saved := []
	if spot.x < 0:
		print("ATTENZIONE: nessun posto piano per il laghetto fatto a mano")
	else:
		for xx in range(spot.x - 8, spot.x + 9):
			for yy in range(spot.y + 1, spot.y + 6):
				saved.append([xx, yy, w.tile(xx, yy)])
				var edge := absi(xx - spot.x) == 8 or yy == spot.y + 5
				w.set_tile(xx, yy, TileDefs.STONE if edge else TileDefs.AIR)
				w.set_liq(xx, yy, 0 if edge else 8, LiquidsData.ACQUA)
		made = WaterBody.at(w, spot + Vector2i(0, 2))
		print("laghetto fatto a mano: %s" % WaterBody.describe(made))
	# 3. una pozzanghera: troppo piccola
	var q := Vector2i(w.spawn.x + 300, 20)
	w.set_liq(q.x, q.y, 8, LiquidsData.ACQUA)
	w.set_liq(q.x + 1, q.y, 8, LiquidsData.ACQUA)
	var puddle := WaterBody.at(w, q)
	w.set_liq(q.x, q.y, 0, 0)
	w.set_liq(q.x + 1, q.y, 0, 0)
	print("pozzanghera di due celle: %s" % WaterBody.describe(puddle))
	# rimette il terreno del laghetto com'era
	for s in saved:
		w.set_tile(int(s[0]), int(s[1]), int(s[2]))
		w.set_liq(int(s[0]), int(s[1]), 0, 0)
	if spot.x >= 0:
		m.view.refresh_around(spot)
	if ponds == 0 or pond.is_empty() or not pond["ok"] or made.is_empty() or not made["ok"] or int(made["stratum"]) != 0 \
			or puddle.is_empty() or puddle["ok"]:
		print("ATTENZIONE: gli specchi d'acqua non si riconoscono come dovrebbero")


## Voce 120: i pesci come dati. Ogni pesce ha campi validi e si può davvero pescare (esiste uno specchio in cui
## vive); gli stagni del bioma giusto danno i pesci giusti; la rarità segue i pesi; la sezione Pesci dell'Erbario
## non cambia la percentuale.
func species() -> void:
	var bad := []
	var reach := 0
	for id in FishData.all():
		var f: Dictionary = FishData.all()[id]
		for k in ["name", "rar", "size", "color"]:
			if not f.has(k):
				bad.append("%s: manca %s" % [id, k])
		if not FishData.RARITY.has(String(f.get("rar", ""))):
			bad.append("%s: rarità %s" % [id, f.get("rar", "")])
		if not ItemIcons.has_palette(String(f.get("color", ""))):
			bad.append("%s: colore %s" % [id, f.get("color", "")])
		for b in f.get("biomes", []):
			if BiomesData.by_id(String(b)).is_empty():
				bad.append("%s: bioma %s" % [id, b])
		for sn in f.get("season", []):
			if not SeasonsData.SEASONS.any(func(x: Dictionary) -> bool: return String(x["id"]) == String(sn)):
				bad.append("%s: stagione %s" % [id, sn])
		for wk in f.get("weather", []):
			if not WeatherData.STATES.has(String(wk)):
				bad.append("%s: tempo %s" % [id, wk])
		if f.has("gene") and GenesData.info(String(f["gene"])).is_empty():
			bad.append("%s: gene %s" % [id, f["gene"]])
		if not ItemsData.get_item(String(id)).get("kind", "") == "pesce":
			bad.append("%s: manca l'oggetto" % id)
		# lo specchio fatto apposta per lui: il pesce deve esserci
		var ctx := {"liq": int(f.get("liq", 0)), "stratum": int((f.get("strata", [0]) as Array)[0]),
			"biome": String((f.get("biomes", ["foresta"]) as Array)[0]), "depth": int(f.get("depth", 1)),
			"volume": float(f.get("big", 30.0)), "night": String(f.get("time", "")) == "notte",
			"season": String((f.get("season", ["germoglio"]) as Array)[0]),
			"weather": String((f.get("weather", ["sereno"]) as Array)[0]), "genes": [f.get("gene", "")]}
		if FishData.pool(ctx).any(func(e: Array) -> bool: return String(e[0]) == String(id)):
			reach += 1
		else:
			bad.append("%s: nessuno specchio lo ospita" % id)
	# lo stagno della foresta e quello delle torbiere
	var base := {"liq": 0, "stratum": 0, "depth": 4, "volume": 40.0, "night": false, "season": "germoglio",
		"weather": "sereno", "genes": []}
	var forest := base.duplicate()
	forest["biome"] = "foresta"
	var peat := base.duplicate()
	peat["biome"] = "torba"
	var ids_f := FishData.pool(forest).map(func(e: Array) -> String: return String(e[0]))
	var ids_t := FishData.pool(peat).map(func(e: Array) -> String: return String(e[0]))
	var right := "pesce_trota_lanterna" in ids_f and not "pesce_torbina" in ids_f and "pesce_torbina" in ids_t \
		and "pesce_avannotto" in ids_t and not "pesce_persico_lume" in ids_f
	# la rarità in una grotta d'acqua delle Caverne, 6000 abboccate
	var cave := base.duplicate()
	cave["stratum"] = 2
	cave["biome"] = "foresta"
	var rng := RandomNumberGenerator.new()
	rng.seed = 12
	var by := {}
	for k in 6000:
		var id := FishData.roll(cave, rng)
		var r := String(FishData.info(id)["rar"])
		by[r] = int(by.get(r, 0)) + 1
	var lucky := {}
	for k in 6000:
		var r := String(FishData.info(FishData.roll(cave, rng, 1.0))["rar"])
		lucky[r] = int(lucky.get(r, 0)) + 1
	# l'Erbario: la sezione dei pesci non cambia la percentuale
	var er: Erbario = m.erbario
	var pct0 := er.percent()
	var saved: Dictionary = (er.data.get("pesci", {}) as Dictionary).duplicate(true)
	var fresh := er.add_fish("pesce_avannotto", 7)
	var rec := er.add_fish("pesce_avannotto", 5)
	var same_pct := absf(er.percent() - pct0) < 0.001 and er.known("pesci", "pesce_avannotto")
	var ep: ErbarioPanel = null
	for o in m.hud.overlays:
		if o is ErbarioPanel:
			ep = o
	if ep != null:
		ep.toggle()
		ep.section = "pesci"
		ep.selected = "pesce_avannotto"
		ep._refresh()
		await kit.frames(4)
		await kit.save("182_erbario_pesci")
		ep.toggle()
	print("pesci: %d in tutto, %d pescabili da qualche parte; problemi %s" % [FishData.all().size(), reach, bad])
	print("stagno della foresta: %s" % ", ".join(ids_f.map(func(i: String) -> String: return String(FishData.info(i)["name"]))))
	print("stagno delle torbiere: %s; giusti %s" % [", ".join(ids_t.map(func(i: String) -> String: return String(FishData.info(i)["name"]))),
		"sì" if right else "NO"])
	print("rarità nelle Caverne (6000): %s; con fortuna 1: %s" % [by, lucky])
	print("Erbario dei pesci: nuovo %s, 5 cm dopo 7 non è un record %s, percentuale uguale %s" % ["sì" if fresh else "NO",
		"sì" if not rec else "NO", "sì" if same_pct else "NO"])
	er.data["pesci"] = saved
	if not bad.is_empty() or not right or not fresh or rec or not same_pct or int(by.get("raro", 0)) == 0 \
			or int(lucky.get("raro", 0)) <= int(by.get("raro", 0)):
		print("ATTENZIONE: i pesci non sono come dovrebbero")

