class_name TestsFishing
extends RefCounted
## La pesca (Roadmap 14 «Le acque vive»). Voce 118: gli stagni di superficie nel mondo di prova, lo specchio riconosciuto
## al momento (`WaterBody`), un laghetto fatto a mano che vale come uno naturale, una pozzanghera troppo piccola.
## Gruppo «pesca».

var kit: TestKit
var m: Node2D
var _pond := {}                         # lo stagno naturale più vicino alla partenza (da `bodies`)


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	# (le prove mettono canne, otri ed esche in mano: alla fine la Bisaccia torna com'era, o le prove dopo non
	# trovano più il seme nella barra rapida)
	var b: Bisaccia = m.character.bisaccia
	var slots0 := b.slots.duplicate(true)
	var equip0 := b.equip.duplicate(true)
	var sel0: int = m.hud.sel
	await bodies()
	await moving()
	await species()
	await gesture()
	await extras()
	await rewards()
	await village()
	await balance()
	for i in slots0.size():
		b.slots[i] = slots0[i]
	b.equip = equip0
	b.changed.emit()
	m.hud.select(sel0)


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
	_pond = pond
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
			"weather": String((f.get("weather", ["sereno"]) as Array)[0]), "genes": [f.get("gene", "")],
			"sky": String((f.get("sky", [""]) as Array)[0])}      # Roadmap 16: i pesci delle pozze del cielo
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


## Voce 121: il gesto. Con la canna in mano, un clic sullo stagno: la lenza parte, un pesce abbocca e sale da solo nella
## Bisaccia e nell'Erbario. La canna di radice non pesca nella brace, quella di tizzonite sì; allontanandosi la lenza
## si ritira. I valori delle canne vengono dal materiale.
func gesture() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var fi: Fishing = m.fishing
	if _pond.is_empty():
		print("ATTENZIONE: nessuno stagno per la prova della pesca")
		return
	kit.make_room()
	b.add("canna_radice", 1)
	kit.hold("canna_radice")
	var x0 := int(_pond["x0"])
	m.snap_to(Vector2i(x0 - 2, w.surface[x0 - 2] - 1))
	await kit.frames(3)
	var target := Vector2i(x0 + 4, int(_pond["top"]) - 2)          # sopra l'acqua: la lenza scende fino al pelo
	var cast_ok := fi.cast(target, "canna_radice")
	await kit.seconds(0.5)
	await kit.save("183_pesca")
	var n0 := fi.caught
	if cast_ok:
		fi.line["t"] = 0.3                                          # (l'attesa vera è di 4-11 secondi)
	await kit.seconds(1.6)
	var lid := String(fi.last.get("id", ""))
	# a volte abbocca una cassa (3%): nella Bisaccia sì, nell'Erbario dei pesci no
	var got: bool = fi.caught > n0 and b.count(lid) > 0 and (m.erbario.known("pesci", lid) or not FishData.all().has(lid))
	print("pesca: lanciata %s, pescato %s (%s, %d cm), nella Bisaccia e nell'Erbario %s" % ["sì" if cast_ok else "NO",
		"sì" if fi.caught > n0 else "NO", FishData.info(String(fi.last.get("id", ""))).get("name", "?"), int(fi.last.get("size", 0)),
		"sì" if got else "NO"])
	# voce 133: una lontra vicino al galleggiante ruba il pesce; presa, lo restituisce
	var st0 := fi.stolen
	var otter: Creature = m.fauna.add("lontra_lago", Vector2(target) * 16.0 + Vector2(40, -20))
	otter.anchored = true
	var steals := 0
	for k in 6:
		if fi.stolen > st0:
			break
		if fi.cast(target, "canna_radice"):
			fi.line["t"] = 0.2
		await kit.seconds(1.2)
	var had: bool = is_instance_valid(otter) and otter.has_meta("rubato")
	var d0: int = m.drops._items.size()
	if is_instance_valid(otter):
		m.fauna.kill(otter)
	steals = fi.stolen - st0
	print("ladri di pesci: la lontra ha rubato %d pesce, lo teneva %s, presa lo restituisce %s" % [steals, "sì" if had else "NO",
		"sì" if m.drops._items.size() > d0 else "NO"])
	if steals < 1 or not had:
		print("ATTENZIONE: la lontra non ruba il pesce dalla lenza")
	m.fauna.clear()
	# allontanarsi ritira la lenza
	fi.cast(target, "canna_radice")
	var p0: Vector2i = m.player_cell()
	m.snap_to(Vector2i(p0.x - 8, w.surface[p0.x - 8] - 1))
	await kit.frames(3)
	var pulled := fi.line.is_empty()
	# i liquidi delle canne: la brace solo con i materiali giusti
	var rad: Array = ItemsData.get_item("canna_radicite").get("fish_liq", [])
	var tiz: Array = ItemsData.get_item("canna_tizzonite").get("fish_liq", [])
	var lin: Array = ItemsData.get_item("canna_linfa").get("fish_liq", [])
	var ste: Array = ItemsData.get_item("canna_stellare").get("fish_liq", [])
	# una vasca di brace in aria accanto al Germogliato: la canna di radice no, quella di tizzonite sì
	m.snap_to(w.spawn)
	await kit.frames(2)
	var pc: Vector2i = m.player_cell()
	var cells := []
	for yy in range(pc.y - 9, pc.y - 4):
		for xx in range(pc.x + 3, pc.x + 9):
			if not w.solid(xx, yy):
				w.set_liq(xx, yy, 8, LiquidsData.BRACE)
				cells.append(Vector2i(xx, yy))
	var lava := Vector2i(pc.x + 5, pc.y - 7)
	var no_brace := not fi.cast(lava, "canna_radice")
	b.add("canna_tizzonite", 1)
	kit.hold("canna_tizzonite")
	var yes_brace := fi.cast(lava, "canna_tizzonite")
	fi.stop()
	for q in cells:
		w.set_liq(q.x, q.y, 0, 0)
	print("canne: radicite %s, tizzonite %s, Linfa %s, stellare %s; nella brace: radice no %s, tizzonite sì %s; allontanandosi si ritira %s" % [
		FishingData.liquids_text(rad), FishingData.liquids_text(tiz), FishingData.liquids_text(lin), FishingData.liquids_text(ste),
		"sì" if no_brace else "NO", "sì" if yes_brace else "NO", "sì" if pulled else "NO"])
	if not cast_ok or not got or not pulled or not no_brace or not yes_brace or 2 in rad or not 2 in tiz or not 1 in lin \
			or ste.size() != 3:
		print("ATTENZIONE: la pesca non funziona come dovrebbe")


## Voce 122: esche, accessori e tempo. L'esca migliore alza la fortuna, accorcia l'attesa e si consuma a ogni pesce;
## l'Amo d'ambra indossato aggiunge fortuna; la pioggia accorcia l'attesa; la Sacca può dare due pesci.
func extras() -> void:
	var w: World = m.world
	var b: Bisaccia = m.character.bisaccia
	var fi: Fishing = m.fishing
	kit.make_room()
	if b.count("canna_radice") == 0:
		b.add("canna_radice", 1)
	kit.hold("canna_radice")
	var luck0 := fi.luck_now("canna_radice")
	var wait0 := fi.wait_mult("canna_radice")
	b.add("esca_humus", 3)
	b.add("esca_squama", 5)
	var luck1 := fi.luck_now("canna_radice")
	var wait1 := fi.wait_mult("canna_radice")
	# l'Amo d'ambra in un posto da accessorio
	var slot := "accessorio_1"
	var old := String(b.equip.get(slot, ""))
	b.equip[slot] = "amo_ambra"
	m.gear.refresh()
	var amo := float(fi.gear["luck"])
	var tip := ItemTip.card({"id": "amo_ambra", "n": 1}, {}).plain()
	if old == "":
		b.equip.erase(slot)
	else:
		b.equip[slot] = old
	m.gear.refresh()
	# il tempo
	var w0 := String(m.weather.id)
	m.weather.set_weather("sereno")
	var sunny := fi.wait_mult("canna_radice")
	m.weather.set_weather("pioggia")
	var rainy := fi.wait_mult("canna_radice")
	m.weather.set_weather(w0)
	# un pesce con l'esca: se ne consuma una (la migliore), e con la Sacca a volte sono due
	var x0 := int(_pond.get("x0", w.spawn.x))
	m.snap_to(Vector2i(x0 - 2, w.surface[x0 - 2] - 1))
	await kit.frames(3)
	var target := Vector2i(x0 + 4, int(_pond.get("top", w.surface[x0])) - 2)
	fi.gear["double"] = 1.0
	var n_sq := b.count("esca_squama")
	var ok := fi.cast(target, "canna_radice")
	if ok:
		fi.line["t"] = 0.2
	await kit.seconds(1.4)
	var used := b.count("esca_squama") == n_sq - 1 and b.count("esca_humus") == 3 and String(fi.last.get("bait", "")) == "esca_squama"
	var two := int(fi.last.get("n", 0)) == 2
	m.gear.refresh()
	print("esche: fortuna %.2f → %.2f, attesa ×%.2f → ×%.2f; Amo d'ambra: fortuna +%.2f (scheda: %s); sereno ×%.2f, pioggia ×%.2f" % [
		luck0, luck1, wait0, wait1, amo, "sì" if tip.contains("Fortuna di pesca") else "NO", sunny, rainy])
	print("pesce con l'esca: presa %s, consumata la migliore (squama) %s, con la Sacca due pesci %s" % ["sì" if ok else "NO",
		"sì" if used else "NO", "sì" if two else "NO"])
	if not (luck1 > luck0 + 0.4 and wait1 < wait0 and absf(amo - 0.3) < 0.001 and tip.contains("Fortuna di pesca") \
			and rainy < sunny and ok and used and two):
		print("ATTENZIONE: esche, accessori o tempo della pesca non vanno come dovrebbero")


## Voce 123: che cosa danno i pesci. Ogni pesce si pulisce nei filetti del suo liquido; i filetti diventano piatti con
## un effetto; le casse pescate si aprono; la cassa giusta per ogni specchio; la serie «Tesori delle acque».
func rewards() -> void:
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	var fr := FishingData.fillet_recipes()
	var all_fish := fr.size() == FishData.all().size()
	# pulire un avannotto (comune, acqua) e una Carpa di fuoco (rara, brace)
	b.add("pesce_avannotto", 1)
	b.add("pesce_carpa_fuoco", 1)
	var f0 := b.count("filetto")
	var p0 := b.count("filetto_pregiato")
	for r in fr:
		if String(r["in"].keys()[0]) in ["pesce_avannotto", "pesce_carpa_fuoco"]:
			Crafting.craft(r, b)
	var cleaned := b.count("filetto") == f0 + 1 and b.count("filetto_pregiato") == p0 + 1
	# un piatto: il Pesce arrosto cura e sazia
	b.add("pesce_arrosto", 1)
	kit.hold("pesce_arrosto")
	m.vitals.hp = m.vitals.hp_max - 40
	m.boons.active.erase("sazio")
	m.actions.drink("pesce_arrosto")
	var ate: bool = m.boons.active.has("sazio") and m.vitals.hp >= m.vitals.hp_max - 10
	m.vitals.refill()
	# una cassa pescata si apre
	b.add("forziere_sommerso", 1)
	kit.hold("forziere_sommerso")
	var opened: bool = m.fishing.open_crate("forziere_sommerso") and not m.fishing.last_crate.is_empty() and b.count("forziere_sommerso") == 0
	# la cassa di ogni specchio
	var ctx := {"liq": 0, "stratum": 0}
	var c0 := FishingData.crate_for(ctx)
	ctx["stratum"] = 2
	var c2 := FishingData.crate_for(ctx)
	ctx["liq"] = 2
	var c4 := FishingData.crate_for(ctx)
	var crates := c0 == "cassetta_alga" and c2 == "forziere_sommerso" and c4 == "scrigno_fondo"
	# la serie degli unici della pesca
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var pool := UniqueSeriesData.pool_items("pesca")
	var u := UniquesData.roll("pesca", rng, {})
	var series := pool.size() == 6 and u in pool and UniqueSeriesData.SERIES.has("tesori_acque")
	print("pesci da pulire: ricette %d per %d pesci %s; avannotto → filetto, Carpa di fuoco → filetto pregiato %s" % [fr.size(),
		FishData.all().size(), "sì" if all_fish else "NO", "sì" if cleaned else "NO"])
	print("Pesce arrosto: cura e sazio %s; Forziere sommerso aperto %s (%s); casse per specchio %s %s %s; serie «Tesori delle acque» %s (%s)" % [
		"sì" if ate else "NO", "sì" if opened else "NO", m.fishing.last_crate, c0, c2, c4, "sì" if series else "NO", u])
	if not (all_fish and cleaned and ate and opened and crates and series):
		print("ATTENZIONE: i frutti della pesca non sono come dovrebbero")


## Voce 124: il Pescatore arriva dopo cinque pesci (e ha il suo disegno), la Bacheca chiede pesci già pescati, gli
## obiettivi della pesca, il consiglio della canna, il valore dei pesci per il commercio.
func village() -> void:
	var ch: Character = m.character
	var stats0: Dictionary = ch.stats.duplicate(true)
	var obj0: Array = ch.obiettivi.duplicate()
	var bac0: Dictionary = ch.bacheca.duplicate(true)
	var pesci0: Dictionary = (ch.erbario.get("pesci", {}) as Dictionary).duplicate(true)
	ch.stats["pesci"] = 2
	var early: bool = m.villagers._ready_for("pescatore")
	ch.stats["pesci"] = 5
	var ready: bool = m.villagers._ready_for("pescatore")
	var art := NpcArt.frames("pescatore")
	# la Bacheca: con un pesce comune nell'Erbario, prima o poi chiede pesci
	m.erbario.add_fish("pesce_carpa_lanterna", 30)
	var asked := ""
	for k in 300:
		var r: Dictionary = m.board.make()
		if String(r.get("tipo", "")) == "pesce":
			asked = String(r["testo"])
			break
	# gli obiettivi della pesca
	ch.stats["specie_pescate"] = 10
	ch.stats["pesci_leggendari"] = 1
	m.objectives.check_all()
	var objs: bool = m.objectives.done("pesca_1") and m.objectives.done("pesca_specie_10") and m.objectives.done("pesca_leggenda")
	# il consiglio della canna, e il valore dei pesci
	var b: Bisaccia = m.character.bisaccia
	if b.count("canna_radice") == 0:
		b.add("canna_radice", 1)
	kit.hold("canna_radice")
	var tip: bool = m.consigli._c_canna()
	var values := [ValueData.value("pesce_avannotto"), ValueData.value("pesce_persico_lume"), ValueData.value("pesce_primo")]
	ch.stats = stats0
	ch.obiettivi = obj0
	ch.bacheca = bac0
	ch.erbario["pesci"] = pesci0
	m.objectives.refresh_label()
	print("Pescatore: con 2 pesci %s, con 5 %s, disegno %d pose; Bacheca: «%s»; obiettivi della pesca %s; consiglio della canna %s; valori %s" % [
		"arriva" if early else "no", "arriva" if ready else "NO", art.size(), asked, "sì" if objs else "NO", "sì" if tip else "NO", values])
	if early or not ready or art.is_empty() or asked == "" or not objs or not tip or not (values[0] < values[1] and values[1] < values[2]):
		print("ATTENZIONE: il Pescatore e l'intreccio della pesca non vanno come dovrebbero")


## Voce 125: la fatica di uno specchio sale a ogni pesce (fino al tetto), allunga l'attesa e scende col tempo.
func balance() -> void:
	var fi: Fishing = m.fishing
	var meta0: Dictionary = (m.world_meta.get("pesca", {}) as Dictionary).duplicate(true)
	var body := {"x0": 4000, "top": 16}
	var key := Fishing.spot_key(body)
	var t0 := fi.tiredness(key)
	for k in int(FishingData.TIRE_MAX) + 4:
		fi._tire(key)
	var full := fi.tiredness(key)
	# dieci minuti dopo (si sposta indietro l'ora dell'ultimo pesce)
	var e: Array = m.world_meta["pesca"][key]
	e[1] = float(e[1]) - 600.0
	var later := fi.tiredness(key)
	m.world_meta["pesca"] = meta0
	print("fatica di uno specchio: all'inizio %.1f, dopo tanti pesci %.1f (tetto %.0f, attesa ×%.2f), dieci minuti dopo %.1f" % [t0,
		full, FishingData.TIRE_MAX, 1.0 + FishingData.TIRE_WAIT * full, later])
	if t0 > 0.01 or absf(full - FishingData.TIRE_MAX) > 0.05 or not (later < full - 3.0 and later > 0.0):
		print("ATTENZIONE: la fatica degli specchi non va come dovrebbe")

