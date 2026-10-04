class_name TestsDeep
extends RefCounted
## Le regole del profondo (voce 354, Roadmap 37). Gruppo «profondo»: i dati crescono scendendo; nelle Caverne e nel
## Fondo nascono branchi e più rare che nel Sottobosco; l'imboscata sbuca alle spalle; il peso del Vuoto sale al buio e
## scende alla luce; una rara del Fondo lascia il Frammento di Vuoto. Foto 354_fondo.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _spot(w: World, stratum: int, seed_n: int) -> Vector2i:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_n
	for t in 6000:
		var x := rng.randi_range(40, w.w - 40)
		var y := rng.randi_range(40, w.h - 40)
		if StrataData.at(w, x, y) == stratum and not w.solid(x, y) and not w.solid(x, y - 1) and w.solid(x, y + 1) \
				and not w.torch_near(Vector2i(x, y), 50.0) and w.liq(x, y) == 0:
			return Vector2i(x, y)
	return Vector2i(-1, -1)


func run() -> void:
	var w: World = m.world
	var fa: Fauna = m.fauna
	# 1. i dati: scendendo l'udito e le rare crescono, e ogni strato sotto la superficie ha la sua regola e il suo materiale
	var grows := true
	for s in range(1, DeepRulesData.RULES.size()):
		var a := DeepRulesData.of(s - 1)
		var b := DeepRulesData.of(s)
		if float(b.get("rare", 1.0)) < float(a.get("rare", 1.0)) or not b.has("loot") or not b.has("name") \
				or ItemsData.get_item(String(b["loot"])).is_empty():
			grows = false
	# 1b. la misura: in ogni strato, su sei posti, quanti punti dell'anello delle nascite sono buoni (spazio, pavimento, buio)
	m.senses.paused = true
	Mind.lit = 0.0
	var survey := {}
	for st in range(1, 5):
		var ok_pts := 0
		var lit_sum := 0.0
		var spots := 0
		for k in 6:
			var sp := _spot(w, st, 100 + st * 10 + k)
			if sp.x < 0:
				continue
			m.snap_to(sp)
			await kit.seconds(0.8)
			var d := _diagnose_n(sp)
			ok_pts += int(d[0])
			lit_sum += float(d[1])
			spots += 1
		survey[st] = "%d posti: punti buoni %.0f su 300 in media, luce sul posto %.2f" % [spots, ok_pts / maxf(spots, 1), lit_sum / maxf(spots, 1)]
		print("profondo, misura dello strato %d: %s" % [st, survey[st]])
	# 2. le nascite: nel Sottobosco e nel Fondo, quante compagne e quante rare
	var counts := {}
	m.senses.paused = true
	Mind.lit = 0.0
	for s in [1, 4]:
		var spot := _spot(w, s, 21 + s)
		if spot.x < 0:
			print("ATTENZIONE: nessun posto nello strato %d per la prova del profondo" % s)
			continue
		m.snap_to(spot)
		await kit.seconds(1.0)
		fa.clear(true)
		var born := 0
		var packs := 0
		var rares := 0
		for t in 160:
			var cr := fa.try_spawn()
			if cr == null:
				continue
			born += 1
			if cr.ancient != null:
				rares += 1
			var mates := fa.list.filter(func(x: Creature) -> bool:
				return x != cr and x.extra and x.has_meta("grp") and int(x.get_meta("grp")) == cr.get_instance_id())
			if not mates.is_empty() and cr.ancient == null and not CreaturesData.get_data(cr.id).has("group"):
				packs += 1
			fa.clear(true)
		counts[s] = [born, packs, rares]
	var pack_ok: bool = counts.has(4) and counts.has(1) and int(counts[4][1]) > 0 and int(counts[1][1]) == 0
	# 3. l'imboscata, nel Fondo, alle spalle
	var fondo := _spot(w, 4, 31)
	var amb := []
	var behind := false
	var meter_up := 0.0
	var meter_down := 0.0
	var loot_ok := false
	if fondo.x >= 0:
		m.snap_to(fondo)
		await kit.seconds(1.0)
		fa.clear(true)
		m.player.facing = 1
		amb = m.deep_rules.ambush(DeepRulesData.of(4)["ambush"], 4)
		behind = not amb.is_empty() and amb.all(func(c: Creature) -> bool: return c.position.x < m.player.position.x)
		await kit.save("354_imboscata")
		fa.clear(true)
		# 4. il peso del Vuoto: sale al buio, scende alla luce
		m.harsh.meters["vuoto"] = 0.0
		await kit.seconds(3.0)
		meter_up = float(m.harsh.meters["vuoto"])
		await kit.save("354_fondo")
		var tc: Vector2i = m.player_cell() + Vector2i(1, 0)
		m.world.add_torch(tc)
		await kit.seconds(2.0)
		meter_down = float(m.harsh.meters["vuoto"])
		m.world.remove_torch(tc)
		m.harsh.meters["vuoto"] = 0.0
		# 5. una rara del Fondo lascia il suo materiale
		var have: int = m.character.bisaccia.count("frammento_vuoto")
		var cr: Creature = fa.add(String(CreaturesData.of_stratum(4, false, "")[0][0]), m.player.position + Vector2(18, -4))
		fa.make_ancient(cr, "antica")
		fa.kill(cr)
		await kit.seconds(2.5)
		loot_ok = m.character.bisaccia.count("frammento_vuoto") > have
		m.character.bisaccia.remove("frammento_vuoto", m.character.bisaccia.count("frammento_vuoto") - have)
	else:
		print("ATTENZIONE: nessun posto nel Fondo per la prova del profondo")
	m.senses.paused = false
	fa.clear(true)
	m.snap_to(w.spawn)
	await kit.frames(3)
	var rigor_ok := meter_up > 0.03 and meter_down < meter_up
	print("profondo: regole che crescono %s; nascite [nate, branchi, rare] Sottobosco %s, Fondo %s; imboscata %d alle spalle %s; peso del Vuoto al buio %.2f, alla luce %.2f; Frammento di Vuoto da una rara %s" % [
		grows, str(counts.get(1, [])), str(counts.get(4, [])), amb.size(), behind, meter_up, meter_down, loot_ok])
	if not grows or not pack_ok or amb.size() < 2 or not behind or not rigor_ok or not loot_ok:
		print("ATTENZIONE: le regole del profondo non vanno come dovrebbero")
	await awaken()


## [punti buoni su 300, luce sul posto].
func _diagnose_n(pc: Vector2i) -> Array:
	var fa: Fauna = m.fauna
	var w: World = m.world
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var good := 0
	for t in 300:
		var ang := rng.randf() * TAU
		var dist := rng.randf_range(DangerData.SPAWN_MIN, DangerData.SPAWN_MAX)
		var q := pc + Vector2i(roundi(cos(ang) * dist), roundi(sin(ang) * dist * 0.6))
		if w.inside(q.x, q.y) and q.y >= 2 and fa._room_below(q):
			good += 1
	return [good, m.light.value_at(pc)]


## Voce 355: il risveglio al Maglio. Costa i materiali del profondo del grado giusto, dà il modo della forma e più forza;
## la spada lancia l'onda ogni terzo colpo, lo spadone schianta attorno, la lancia trafigge chi sta dietro; un pezzo
## d'armatura indossato porta il suo modo; la riga del Maglio e la scheda di Esamina lo dicono (foto 355_risveglio).
func awaken() -> void:
	var b: Bisaccia = m.character.bisaccia
	var fa: Fauna = m.fauna
	var saved := b.slots.duplicate(true)
	var eq0: Dictionary = b.equip.duplicate(true)
	var eqd0: Dictionary = b.equip_data.duplicate(true)
	var missing := []
	for f in AwakenData.FORM:
		if EffectsData.info(String(AwakenData.FORM[f])).is_empty():
			missing.append(f)
	var res := {}
	# la spada di radicite: Midollo di radice e Linfa antica
	var si := kit.hold("spada_radicite")
	m.hud.select(si)
	var cost := AwakenData.cost_of("spada_radicite")
	for k in cost:
		b.add(String(k), int(cost[k]))
	var d0 := float(Gear.stats(b.slots[si])["damage"])
	var rows := CraftWork.rows(m.hud.panel.crafting, si, {"maglio": true})
	res["riga"] = not rows.is_empty() and rows[0].text.begins_with("Risveglia")
	for r in rows:
		r.free()
	var ok := Crafting.awaken(b, si)
	res["risvegliata"] = ok and String((b.slots[si].get("dati", {}) as Dictionary).get("risveglio", "")) == "ris_onda" \
		and b.count("midollo_radice") == 0 and is_equal_approx(float(Gear.stats(b.slots[si])["damage"]), d0 * AwakenData.DAMAGE)
	res["di_nuovo_no"] = not Crafting.awaken(b, si)
	m.effects.refresh()
	res["attiva"] = m.effects.has("ris_onda")
	# l'onda, ogni terzo colpo
	m.snap_to(m.world.spawn)
	await kit.frames(3)
	fa.clear(true)
	var target := fa.add("grumo_muschio", m.player.position + Vector2(30, -4))
	target.set_process(false)
	var shots0: int = m.shots.count()
	for k in 3:
		m.effects._on_struck(target, 10)
	res["onda"] = m.shots.count() > shots0
	# lo schianto e la trafittura (i modi, uno per uno)
	var near := fa.add("grumo_muschio", target.position + Vector2(20, 0))
	near.set_process(false)
	var hp0: int = near.hp
	m.effects._do(EffectsData.info("ris_schianto"), target, 20)
	res["schianto"] = not is_instance_valid(near) or near.hp < hp0
	fa.clear(true)
	var t2 := fa.add("grumo_muschio", m.player.position + Vector2(24, -4))
	var back := fa.add("grumo_muschio", m.player.position + Vector2(48, -4))
	t2.set_process(false)
	back.set_process(false)
	var hb: int = back.hp
	m.effects._do(EffectsData.info("ris_trafigge"), t2, 20)
	res["trafigge"] = not is_instance_valid(back) or back.hp < hb
	fa.clear(true)
	# un pezzo d'armatura indossato e risvegliato
	b.equip["corazza"] = "corazza_radicite"
	b.equip_data["corazza"] = {"risveglio": "ris_rovo"}
	m.effects.refresh()
	res["armatura"] = m.effects.has("ris_rovo")
	# la scheda
	var info := ItemInfo.bbcode("spada_radicite", "", b.slots[si].get("dati", {}))
	res["scheda"] = info.contains("Risvegliato") and Gear.full_name(b.slots[si]).begins_with("✦")
	m.hud.panel.toggle()
	m.hud.panel.examine.show_item("spada_radicite", "", b.slots[si].get("dati", {}))
	await kit.frames(4)
	await kit.save("355_risveglio")
	m.hud.panel.toggle()
	# com'era
	for i in b.slots.size():
		b.slots[i] = saved[i]
	b.equip = eq0
	b.equip_data = eqd0
	b.changed.emit()
	m.effects.refresh()
	var all_ok: bool = res.values().all(func(x: bool) -> bool: return x) and missing.is_empty()
	print("risveglio: %s; forme senza modo %s" % [str(res), str(missing)])
	if not all_ok:
		print("ATTENZIONE: il risveglio dell'equipaggiamento non va come dovrebbe")

