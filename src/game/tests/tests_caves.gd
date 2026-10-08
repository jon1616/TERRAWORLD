class_name TestsCaves
extends RefCounted
## Roadmap 30 «Le grotte piene»: raccolti delle piante, baccelli dormienti, nascite delle creature, piccoli incontri,
## curiosità degli strati (gruppo `grotte`). Ogni prova rimette com'erano Bisaccia e conteggi.

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	await harvest()
	await pods()
	await spawns()
	await encounters()
	await curiosities()


func _counts(ids: Array) -> Dictionary:
	var out := {}
	for id in ids:
		out[id] = m.character.bisaccia.count(String(id))
	return out


func _give_back(before: Dictionary) -> void:
	for id in before:
		var extra: int = m.character.bisaccia.count(String(id)) - int(before[id])
		if extra > 0:
			m.character.bisaccia.remove(String(id), extra)


## Voce 300: una pianta dei biomi tolta lascia il suo raccolto; una bacca si mangia, una fibra fa corda.
func harvest() -> void:
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("piante_raccolte", 0))
	var before := _counts(["bacche_lanterna", "cardo_ambra"])
	var c: Vector2i = m.player_cell() + Vector2i(1, 0)
	var w: World = m.world
	var old := w.decor_at(c.x, c.y)
	w.set_decor(c.x, c.y, 33)
	m.actions.pick_decor(c)
	w.set_decor(c.x, c.y, 38)
	m.actions.pick_decor(c)
	await kit.seconds(1.5)
	var got_b: int = m.character.bisaccia.count("bacche_lanterna") - int(before["bacche_lanterna"])
	var got_c: int = m.character.bisaccia.count("cardo_ambra") - int(before["cardo_ambra"])
	var bumped := int(st.get("piante_raccolte", 0)) - n0
	var food := ItemsData.get_item("bacche_lanterna")
	var rope := false
	for r in RecipesData.making("corda_liana"):
		if (r["in"] as Dictionary).has("fronda_felce"):
			rope = true
	var dye := not RecipesData.making("tintura_arancio").filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has("cardo_ambra")).is_empty()
	var plants := 0
	for d in HarvestData.DECOR:
		if d >= 33:
			plants += 1
	var ok: bool = got_b >= 1 and got_c == 1 and bumped == 2 and String(food.get("kind", "")) == "consumabile" and rope and dye \
		and plants >= 55
	print("raccolti delle piante: %d piante dei biomi con un raccolto; bacche-lanterna +%d, cardo d'ambra +%d, conteggio +%d, le bacche si mangiano %s, la felce fa corda %s, il cardo tinge %s" % [
		plants, got_b, got_c, bumped, String(food.get("kind", "")) == "consumabile", rope, dye])
	if not ok:
		print("ATTENZIONE: i raccolti delle piante non vanno")
	w.set_decor(c.x, c.y, old)
	_give_back(before)
	st["piante_raccolte"] = n0


## Voce 301: il mondo ha i suoi baccelli dormienti (a centinaia per strato); aperto, uno lascia il bottino del suo strato;
## ogni tipo ha il suo disegno.
func pods() -> void:
	var w: World = m.world
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("baccelli_aperti", 0))
	var count := 0
	var near := Vector2i(-1, -1)
	var best := 1e9
	var sp := Vector2(w.spawn)
	for y in range(0, w.h):
		for x in range(0, w.w):
			var d := w.decor_at(x, y)
			if d >= PodsData.FIRST and d <= PodsData.LAST:
				count += 1
				var dist := Vector2(x, y).distance_to(sp)
				if dist < best and StrataData.at(w, x, y) >= 1:
					best = dist
					near = Vector2i(x, y)
	var drawn := true
	for id in range(PodsData.FIRST, PodsData.LAST + 1):
		var img: Image = DecorPainter.decor(id)["img"]
		drawn = drawn and not img.get_used_rect().size.x < 4
	var ids := ["lumino", "torcia", "dardo", "gelatina", "pozione_rugiada", "minerale_radicite", "humus", "seta_radice",
		"fibra_radice", "minerale_legnoferro", "pozione_bagliore", "scisto", "pietra_seminatori", "polvere_iridata",
		"scheggia_vigore", "linfa_antica", "seme_lanterna", "bacche_lanterna"]
	var before := _counts(ids)
	var loot := []
	if near.x >= 0:
		m.snap_to(near + Vector2i(-2, 0))
		await kit.seconds(0.5)
		await kit.save("303_baccello")
		var d := w.decor_at(near.x, near.y)
		m.actions.pick_decor(near)
		loot = m.harvest.last_loot
		# il Germogliato resta accanto al baccello (dove il mondo di prova non ha pavimento accanto cadeva via
		# e il bottino restava a terra, lontano)
		for k in 5:
			m.snap_to(near)
			await kit.seconds(0.3)
		w.set_decor(near.x, near.y, d)
		m.view.refresh_around(near)
	var gained := 0
	for id in ids:
		gained += m.character.bisaccia.count(String(id)) - int(before[id])
	var opened := int(st.get("baccelli_aperti", 0)) - n0
	var ok: bool = count >= 300 and near.x >= 0 and drawn and opened == 1 and not loot.is_empty() and gained >= 1
	print("baccelli dormienti: %d nel mondo di prova, disegni %s, aperto il più vicino (%s): %s → nella Bisaccia +%d" % [count, drawn,
		near, loot, gained])
	if not ok:
		print("ATTENZIONE: i baccelli dormienti non vanno")
	_give_back(before)
	st["baccelli_aperti"] = n0
	m.snap_to(w.spawn)


## Voce 302: in una grotta delle Caverne d'ardesia le prove di nascita riescono quasi sempre (quattro punti per prova), e
## il tetto di creature è più alto di prima.
func spawns() -> void:
	var w: World = m.world
	var fa: Fauna = m.fauna
	var spot := Vector2i(-1, -1)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for t in 4000:
		var x := rng.randi_range(40, w.w - 40)
		var y := rng.randi_range(40, w.h - 40)
		if StrataData.at(w, x, y) == 2 and not w.solid(x, y) and not w.solid(x, y - 1) and w.solid(x, y + 1) 				and not w.torch_near(Vector2i(x, y), 50.0) and Vector2(x, y).distance_to(Vector2(w.spawn)) > 120.0:
			# lontano dalle stazioni che fanno luce (scrigni, casse dei biomi, Pozza): la prova misura le nascite al buio
			var lit := false
			for so in w.stations:
				if Vector2(so - Vector2i(x, y)).length() < 30.0 and StationsData.STATIONS.get(String(w.stations[so]), {}).get("light", false):
					lit = true
					break
			if lit:
				continue
			spot = Vector2i(x, y)
			break
	var made := 0
	var tries := 60
	if spot.x >= 0:
		m.snap_to(spot)
		await kit.seconds(1.0)                        # (la luce si ricalcola attorno al posto nuovo: si nasce solo al buio)
		fa.clear(true)
		var fm0: Dictionary = fa.family_mult
		fa.family_mult = {}                           # (non dipende dalle famiglie assenti del mondo di prova)
		for k in tries:
			var cr := fa.try_spawn()
			if cr != null:
				made += 1
		fa.family_mult = fm0
		fa.clear(true)
		m.snap_to(w.spawn)
	var rate := float(made) / tries
	var ok: bool = spot.x >= 0 and rate >= 0.5 and DangerData.cap(1.0) == 3 and DangerData.SPAWN_TRIES >= 4
	print("nascite nelle Caverne d'ardesia: %d su %d prove (%.0f%%; prima ~33%%), tetto di giorno in superficie %d" % [made, tries,
		rate * 100.0, DangerData.cap(1.0)])
	if not ok:
		print("ATTENZIONE: le nascite delle creature non vanno")


## Il più vicino alla partenza tra gli incontri di un tipo.
func _nearest(k: String) -> Vector2i:
	var w: World = m.world
	var best := Vector2i(-1, -1)
	for o in w.stations:
		if String(w.stations[o]) == k and (best.x < 0 or Vector2(o).distance_to(Vector2(w.spawn)) < Vector2(best).distance_to(Vector2(w.spawn))):
			best = o
	return best


## Voce 303: il mondo ha i suoi incontri; lo zaino ha la pagina del diario; la tana sveglia i guardiani e resta chiusa
## finché non sono sconfitti; la vena madre dà il suo dono una volta; il diario letto tutto dà la lanterna.
func encounters() -> void:
	var w: World = m.world
	var en: Encounters = m.encounters
	var counts := {}
	for o in w.stations:
		var k := String(w.stations[o])
		if EncountersData.KINDS.has(k):
			counts[k] = int(counts.get(k, 0)) + 1
	var zaino := _nearest("zaino_perduto")
	var page_in := zaino.x >= 0 and w.chest_at(zaino).count(EncountersData.PAGE_ITEM) == 1
	var ids := ["minerale_legnoferro", "minerale_ambra", "minerale_tizzonite", "cristallo_linfa", "polvere_iridata", "linfa_antica",
		EncountersData.PAGE_REWARD, EncountersData.PAGE_ITEM]
	var before := _counts(ids)
	# la tana
	var tana := _nearest("osso_tana")
	var woke := 0
	var closed := false
	var opened_after := false
	if tana.x >= 0:
		m.snap_to(tana + Vector2i(-6, 0))
		await kit.seconds(1.2)
		woke = en.guards_alive(tana)
		await kit.save("304_tana")
		closed = en.touch(tana, "osso_tana")
		for c in m.fauna.list.duplicate():
			if String(c.get_meta("incontro", "")) == "%d,%d" % [tana.x, tana.y]:
				m.fauna.kill(c)
		opened_after = not en.touch(tana, "osso_tana")
	# la vena madre
	var vena := _nearest("vena_madre")
	var gift := false
	var once := false
	if vena.x >= 0:
		m.snap_to(vena + Vector2i(-5, 1))
		await kit.seconds(1.2)
		for c in m.fauna.list.duplicate():
			if String(c.get_meta("incontro", "")) == "%d,%d" % [vena.x, vena.y]:
				m.fauna.kill(c)
		gift = en.touch(vena, "vena_madre")
		await kit.seconds(1.5)
		var st: Dictionary = en._state(vena)
		once = st.has("p") and en.touch(vena, "vena_madre")
	# il diario
	var pages0 := int(m.character.stats.get("pagine_tessa", 0))
	m.character.stats["pagine_tessa"] = 0
	m.character.bisaccia.add(EncountersData.PAGE_ITEM, EncountersData.DIARY.size())
	var read := 0
	for i in EncountersData.DIARY.size():
		if en.read_page(EncountersData.PAGE_ITEM):
			read += 1
	await kit.frames(3)
	await kit.save("305_diario_tessa")
	m.guardian.lore.visible = false
	var lantern: bool = m.character.bisaccia.count(EncountersData.PAGE_REWARD) > int(before[EncountersData.PAGE_REWARD])
	var ok: bool = int(counts.get("zaino_perduto", 0)) >= 6 and int(counts.get("osso_tana", 0)) >= 4 and int(counts.get("vena_madre", 0)) >= 3 		and int(counts.get("fungo_re", 0)) >= 2 and page_in and woke >= 2 and closed and opened_after and gift and once 		and read == EncountersData.DIARY.size() and lantern
	print("incontri: %s; nello zaino la pagina %s; tana: %d guardiani svegli, chiusa %s, aperta dopo %s; vena madre: dono %s, una volta sola %s; diario letto %d/%d, lanterna %s" % [
		counts, page_in, woke, closed, opened_after, gift, once, read, EncountersData.DIARY.size(), lantern])
	if not ok:
		print("ATTENZIONE: i piccoli incontri non vanno")
	m.character.stats["pagine_tessa"] = pages0
	_give_back(before)
	m.fauna.clear(true)
	m.snap_to(w.spawn)


## Voce 304: trenta curiosità in cinque serie, ognuna con la sua sala nel Museo; si trovano più spesso quelle che mancano;
## una nuova si annuncia e conta.
func curiosities() -> void:
	var all := CuriositiesData.items()
	var halls_ok := true
	for k in CuriositiesData.SERIES.size():
		halls_ok = halls_ok and MuseumData.pieces(String(CuriositiesData.SERIES[k]["hall"])).size() == 6 			and MuseumData.HALLS.has(String(CuriositiesData.SERIES[k]["hall"]))
	var ids := CuriositiesData.of_stratum(2)
	var known := {}
	for i in 5:
		known[ids[i]] = 1
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var fresh := 0
	for i in 400:
		if CuriositiesData.pick(2, rng, known) == ids[5]:
			fresh += 1
	var st: Dictionary = m.character.stats
	var n0 := int(st.get("curiosita", 0))
	var er: Dictionary = m.character.erbario["oggetti"]
	var had := er.has(ids[5])
	er.erase(ids[5])
	m.erbario.add("oggetti", String(ids[5]))
	var bumped := int(st.get("curiosita", 0)) - n0
	if not had:
		er.erase(ids[5])
	st["curiosita"] = n0
	var ok: bool = all.size() == 30 and halls_ok and fresh > 400 * 0.35 and bumped == 1 and BackpackData.accepts("cercatore", ids[0])
	print("curiosità: %d in %d serie, sale del Museo %s, la mancante esce %d volte su 400 (le altre cinque già trovate), annunciata e contata %s, nella Borsa del cercatore %s" % [
		all.size(), CuriositiesData.SERIES.size(), halls_ok, fresh, bumped == 1, BackpackData.accepts("cercatore", ids[0])])
	if not ok:
		print("ATTENZIONE: le curiosità degli strati non vanno")
