class_name TestsSky
extends RefCounted
## Roadmap 16 «Le Chiome del cielo» (gruppo «cielo»): le zone nel mondo e la fascia di una cella (voce 154), le isole,
## le radici pendenti e le correnti (155): il Germogliato sale con una corrente dalla superficie a un'isola bassa;
## foto 212_cielo_basso e 213_cielo_alto.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await zones()
	await climb()
	await high()
	await biomes()
	await reach()
	await thin()
	mats()
	await beasts()
	await lords()
	await guardian()
	await observatory()
	await sky_weather()
	await life()
	await load_test()


## Voce 154: le zone e le fasce.
func zones() -> void:
	var z: Array = world.sky
	var ok := not z.is_empty()
	var bad := []
	for e in z:
		var x := (int(e["x0"]) + int(e["x1"])) / 2
		var wrong := SkyData.zone_at(world, x, int(world.surface[x]) - 1) != ""
		# voce 442: tre fasce, ognuna con il suo bioma e la sua fascia
		for band in SkyData.BANDS:
			var rows := SkyData.band_rows(e, band)
			if rows.is_empty():
				wrong = true
				continue
			var y := int(rows[1]) - 3
			if SkyData.zone_at(world, x, y) != SkyData.band_biome(e, band) or SkyData.band_at(world, x, y) != band:
				wrong = true
		if wrong:
			bad.append(e)
	var plats := 0
	var sky_tiles := 0
	for e in z:
		for x in range(int(e["x0"]), int(e["x1"]), 3):
			for y in range(SkyData.TOP, int(e["base"])):
				if world.plat(x, y):
					plats += 1
				if world.solid(x, y) and world.tile(x, y) >= 50 and world.tile(x, y) <= 56:
					sky_tiles += 1
	var sky_cur := 0
	for cu in m.gravity.currents:
		if (cu as Dictionary).get("cielo", false):
			sky_cur += 1
	print("cielo: %d zone (%s), fasce sbagliate %d; tessere del cielo (una colonna su 3) %d, passerelle delle radici %d, correnti del cielo %d; in world_meta %s" % [
		z.size(), ", ".join(z.map(func(e: Dictionary) -> String: return "%s/%s/%s" % [e["low"], e.get("mid", "-"), e["high"]])), bad.size(),
		sky_tiles, plats, sky_cur, m.world_meta.has("cielo")])
	if not ok or not bad.is_empty() or sky_tiles < 200 or sky_cur < z.size() or not m.world_meta.has("cielo"):
		print("ATTENZIONE: il cielo non è come dovrebbe")


## Voce 155: una corrente dalla superficie porta il Germogliato su un'isola bassa.
func climb() -> void:
	var best: Dictionary = {}
	var dist := INF
	for cu in m.gravity.currents:
		var d: Dictionary = cu
		if d.get("cielo", false) and SkyData.band_at(world, int(d["x"]), int(d["y0"]) + 2) == "basso" \
				and int(d["y1"]) >= int(world.surface[int(d["x"])]) - 2:
			var dd := absf(float(d["x"]) - world.spawn.x)
			if dd < dist:
				dist = dd
				best = d
	if best.is_empty():
		print("ATTENZIONE: nessuna corrente dalla superficie al cielo basso")
		return
	var x := int(best["x"])
	var top := int(best["y0"]) + 2
	# da che parte è l'isola: quella degli appunti del generatore con la cima alla riga della corrente
	var side := 0
	var bestd := 1e9
	for e in world.gen_notes.get("isole_cielo", []):
		if absi(int(e["top"]) - top) <= 1 and absf(float(e["x"]) - x) < bestd:
			bestd = absf(float(e["x"]) - x)
			side = 1 if int(e["x"]) > x else -1
	m.vitals.hp = m.vitals.hp_max
	m.snap_to(Vector2i(x, int(best["y1"])))
	await kit.frames(2)
	var p: Player = m.player
	var had_control := p.control
	p.control = false                        # si muove con i comandi simulati (`auto_dir`)
	p.auto_jump = true                       # la corrente solleva solo tenendo premuto il salto
	var min_y := p.position.y
	var t := 0.0
	var limit := 4.0 + (int(best["y1"]) - int(best["y0"])) / 12.0     # la corrente sale 15 tessere al secondo
	var wm: float = m.weather.wind_mult
	m.weather.wind_mult = 0.0                # (9 ott 2026) nel giro lungo il vento di un tempo lasciato dalle prove di prima
	while t < limit:                         # spingeva il Germogliato fuori dalla corrente
		await kit.frames(1)
		t += m.get_process_delta_time()
		p.wind = 0.0
		min_y = minf(min_y, p.position.y)
		if p.position.y < (top - 1) * S:
			p.auto_dir = float(side)
		if p.on_floor and p.position.y < (top + 1) * S:
			break
	p.auto_dir = 0.0
	p.auto_jump = false
	p.control = had_control
	m.weather.wind_mult = wm
	var c: Vector2i = m.player_cell()
	var zone := SkyData.zone_at(world, c.x, c.y)
	await kit.seconds(0.6)
	var ok := p.on_floor and zone != "" and c.y <= top
	print("salita con la corrente (x %d, da %d a %d): cima raggiunta %d, sull'isola %s (cella %s, zona «%s», scritta «%s»)" % [
		x, int(best["y1"]), int(best["y0"]), int(min_y / S), "sì" if ok else "NO", c, zone, m.chiome.here])
	if not ok:
		print("ATTENZIONE: la corrente non porta sull'isola")
	await kit.save("212_cielo_basso")


## Il cielo alto: una foto su un'isola alta.
func high() -> void:
	for e in world.sky:
		var x0 := int(e["x0"]) + 20
		var x1 := int(e["x1"]) - 20
		var rows := SkyData.band_rows(e, "alto")
		for x in range(x0, x1, 2):
			for y in range(int(rows[0]) + 2, int(rows[1])):
				if world.solid(x, y + 1) and not world.solid(x, y) and not world.solid(x, y - 1) and world.tile(x, y + 1) >= 50:
					m.snap_to(Vector2i(x, y))
					m.boons.add("bagliore", 5.0)
					await kit.seconds(0.8)
					print("cielo alto: %s nella zona «%s»" % [Vector2i(x, y), SkyData.zone_at(world, x, y)])
					await kit.save("213_cielo_alto")
					return
	print("ATTENZIONE: nessuna isola alta dove posarsi")


## Voce 156: una foto per ogni bioma del cielo che c'è nel mondo (sul suo pavimento); il Firmamento fa notte.
func biomes() -> void:
	var seen := {}
	for e in world.sky:
		for band in SkyData.BANDS:
			var id := SkyData.band_biome(e, band)
			var rows := SkyData.band_rows(e, band)
			if id == "" or rows.is_empty() or seen.has(id):
				continue
			var b := SkyData.get_biome(id)
			var fl := int(b["floor"])
			var y_top := int(rows[0])
			var y_bot := int(rows[1])
			var found := Vector2i(-1, -1)
			for x in range(int(e["x0"]) + 10, int(e["x1"]) - 10):
				for y in range(y_top, y_bot):
					if world.tile(x, y + 1) == fl and not world.solid(x, y) and not world.solid(x, y - 1) and not world.solid(x + 1, y):
						found = Vector2i(x, y)
						break
				if found.x >= 0:
					break
			if found.x < 0:
				continue
			seen[id] = true
			m.snap_to(found)
			await kit.seconds(2.2 if b.has("dark") else 0.8)
			var extra := ""
			if b.has("dark"):
				extra = " (buio del cielo %.2f)" % m.day.high_dark
				if m.day.high_dark < 0.5:
					print("ATTENZIONE: nel Firmamento il cielo non si fa notte")
			print("bioma del cielo %s in %s, la scritta «%s»%s" % [id, found, m.chiome.here, extra])
			await kit.save("214_cielo_" + id)
	print("biomi del cielo fotografati: %d su %d" % [seen.size(), SkyData.BIOMES.size()])


## Voce 157: il Fagiolo di nuvola sale; la nuvola e la Piuma lenta tolgono il danno di una caduta di 30 tessere.
func reach() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(-90, 0), 6)
	if spot.x < 0:
		spot = m.player_cell()
		print("ATTENZIONE: nessun posto piano per il Fagiolo")
	kit.flatten(spot, 6)
	for dy in range(1, 60):
		for dx in range(-1, 2):
			world.set_tile(spot.x + dx, spot.y - dy, TileDefs.AIR)
	m.snap_to(spot + Vector2i(-2, 0))
	await kit.frames(3)
	var b := kit.bisaccia()
	b.add("fagiolo_nuvola", 1)
	var planted: bool = m.chiome.plant_bean(spot, "fagiolo_nuvola")
	for i in 20:
		m.chiome.grow_beans()
	var plats := 0
	for y in range(spot.y - SkyData.BEAN_H - 2, spot.y + 1):
		if world.plat(spot.x, y):
			plats += 1
	await kit.seconds(0.4)
	await kit.save("215_fagiolo_nuvola")
	# la caduta sulla nuvola
	for dx in range(-3, 4):
		world.set_tile(spot.x + 6 + dx, spot.y + 1, 52)
	m.view.refresh_around(spot + Vector2i(6, 0))
	var v: Vitals = m.vitals
	v.hp = v.hp_max
	var hp0 := v.hp
	m.snap_to(spot + Vector2i(6, -30))
	await _land()
	var cloud_ok := v.hp == hp0
	# la caduta con la Piuma lenta sulla terra
	world.set_tile(spot.x + 6, spot.y + 1, TileDefs.STONE)
	for dx in range(-3, 4):
		world.set_tile(spot.x + 6 + dx, spot.y + 1, TileDefs.STONE)
	m.view.refresh_around(spot + Vector2i(6, 0))
	var old: Variant = b.equip.get("accessorio_1", "")
	b.equip["accessorio_1"] = "piuma_lenta"
	m.gear.refresh()
	v.hp = v.hp_max
	m.snap_to(spot + Vector2i(6, -30))
	await _land()
	var feather_ok := v.hp == hp0
	b.equip["accessorio_1"] = old
	m.gear.refresh()
	# senza niente: ci si fa male (la prova che la caduta era vera; da 20, per non appassire)
	v.hp = v.hp_max
	m.snap_to(spot + Vector2i(6, -20))
	await _land()
	var hurt := v.hp < hp0
	v.hp = v.hp_max
	print("Fagiolo di nuvola: piantato %s, passerelle %d; caduta di 30 sulla nuvola senza danno %s, con la Piuma lenta %s, da 20 senza niente ferito %s" % [
		planted, plats, cloud_ok, feather_ok, hurt])
	if not planted or plats < 10 or not cloud_ok or not feather_ok or not hurt:
		print("ATTENZIONE: arrivare in cielo non va come dovrebbe")


func _land() -> void:
	await kit.frames(2)
	var t := 0.0
	while t < 5.0 and not m.player.on_floor:
		await kit.frames(1)
		t += m.get_process_delta_time()
	await kit.seconds(0.2)


## Voce 158: nel cielo alto la barra dell'aria sottile sale; con la Maschera e il Mantello di piume scende.
func thin() -> void:
	var spot := Vector2i(-1, -1)
	for e in world.sky:
		if spot.x >= 0:
			break
		for x in range(int(e["x0"]) + 10, int(e["x1"]) - 10, 2):
			if spot.x >= 0:
				break
			var rows := SkyData.band_rows(e, "alto")
			for y in range(int(rows[0]) + 2, int(rows[1]) - 2):
				if world.solid(x, y + 1) and not world.solid(x, y) and not world.solid(x, y - 1):
					spot = Vector2i(x, y)
					break
	if spot.x < 0:
		print("ATTENZIONE: nessun posto nel cielo alto per l'aria sottile")
		return
	var h: Harshness = m.harsh
	for k in h.meters:
		h.meters[k] = 0.0
	m.snap_to(spot)
	m.vitals.hp = m.vitals.hp_max
	await kit.seconds(3.0)
	var rose := float(h.meters["quota"])
	var b := kit.bisaccia()
	var old1: Variant = b.equip.get("accessorio_1", "")
	var old2: Variant = b.equip.get("accessorio_2", "")
	b.equip["accessorio_1"] = "maschera_nuvola"
	b.equip["accessorio_2"] = "mantello_piume"
	m.gear.refresh()
	await kit.seconds(2.0)
	var after := float(h.meters["quota"])
	b.equip["accessorio_1"] = old1
	b.equip["accessorio_2"] = old2
	m.gear.refresh()
	print("aria sottile in %s («%s»): rigore «%s», dopo 3 s %.3f; con Maschera e Mantello dopo 2 s %.3f (protezione %.2f)" % [
		spot, m.chiome.here, h.kind, rose, after, h.shield("quota") if false else float(h.protect.get("quota", 0.0))])
	if h.kind != "quota" or rose < 0.04 or after >= rose:
		print("ATTENZIONE: l'aria sottile non va come dovrebbe")
	for k in h.meters:
		h.meters[k] = 0.0


## Voce 159: le vene di nimbite e folgorite nel cielo alto, la famiglia della nimbite, il costrutto e gli arredi celesti.
func mats() -> void:
	var nim := 0
	var fol := 0
	for e in world.sky:
		for x in range(int(e["x0"]), int(e["x1"])):
			for y in range(SkyData.TOP, int(e["base"])):            # voce 442: le scogliere di cristallo sono nel medio
				var t := world.tile(x, y)
				if t == 57:
					nim += 1
				elif t == 58:
					fol += 1
	var fam := ["piccone_nimbite", "spada_nimbite", "elmo_nimbite", "lingotto_lega_ambra_nimbite", "costr_mattoni_celeste",
		FurnitureData.id_of("tavolo", "celeste"), "dardo_folgore", "baccello_tuono"]
	var missing := fam.filter(func(id: String) -> bool: return ItemsData.get_item(id).is_empty())
	var pick := ItemsData.get_item("piccone_nimbite")
	var spd := Gear.stats({"id": "spada_nimbite"})
	var spa := Gear.stats({"id": "spada_ambra"})
	print("materiali del cielo: nimbite %d celle, folgorite %d; mancano %s; piccone di nimbite forza %d; spada di nimbite danno %s velocità %s (d'ambra %s, %s); set «%s»" % [
		nim, fol, missing, int(pick.get("power", 0)), spd.get("damage"), spd.get("speed"), spa.get("damage"), spa.get("speed"),
		SetsData.all().get("nimbite", {}).get("name", "-")])
	if nim < 20 or fol < 5 or not missing.is_empty():
		print("ATTENZIONE: i materiali del cielo non ci sono tutti")


## Una cella d'aria sopra un'isola della fascia data ("basso"/"medio"/"alto"), con due celle libere sopra.
func island_spot(band: String) -> Vector2i:
	for e in world.sky:
		var rows := SkyData.band_rows(e, band)
		if rows.is_empty():
			continue
		var y0 := int(rows[0]) + (2 if band == "alto" else 0)
		var y1 := int(rows[1]) - (1 if band != "basso" else 0)
		for x in range(int(e["x0"]) + 20, int(e["x1"]) - 20, 3):
			for y in range(y0, y1):
				if world.solid(x, y + 1) and not world.solid(x, y) and not world.solid(x, y - 1) and not world.solid(x + 1, y) \
						and world.solid(x + 1, y + 1) and world.solid(x - 1, y + 1):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


## Voce 160: il foglio delle creature del cielo; nel cielo nascono le creature del suo bioma (e più forti in alto);
## la picchiata cala sul Germogliato dopo il segnale; il fulmine annunciato cade dove era la colonna.
func beasts() -> void:
	for k in m.harsh.meters:
		m.harsh.meters[k] = 0.0
	m.snap_to(world.spawn)
	await kit.seconds(0.5)
	await TestsAliveBeasts.new(kit).species("cielo", "216_bestiario_cielo")
	var spot := island_spot("basso")
	if spot.x < 0:
		print("ATTENZIONE: nessuna isola bassa per le creature del cielo")
		return
	m.snap_to(spot)
	await kit.frames(3)
	var zone := SkyData.zone_at(world, spot.x, spot.y)
	var f: Fauna = m.fauna
	f.clear()
	var own := 0
	var born := 0
	var in_sky := 0
	for i in 200:
		var cr: Creature = f.try_spawn()
		if cr != null:
			born += 1
			var cz := SkyData.zone_at(world, floori(cr.position.x / S), floori(cr.position.y / S))
			if cz != "":
				in_sky += 1                             # (le altre nascono sotto le isole, sulla terra)
			if cz != "" and String(cr.data.get("sky", "")) == cz:
				own += 1
		if f.list.size() > 30:
			f.clear()
	f.clear()
	print("nascite nel cielo (zona «%s»): %d nate, %d in cielo, %d del bioma del cielo dove sono nate" % [zone, born, in_sky, own])
	if born < 10 or in_sky < 5 or own < in_sky * 0.6:
		print("ATTENZIONE: nel cielo non nascono le creature del cielo")
	# la picchiata
	m.vitals.refill()
	var hawk: Creature = f.add("falco_vento", m.player.position + Vector2(-120, -40))
	hawk.mind.brave = true
	var tele := false
	var dove := false
	var t := 0.0
	var y_top := hawk.position.y
	while t < 10.0 and not dove:
		await kit.frames(1)
		t += m.get_process_delta_time()
		if not is_instance_valid(hawk):
			break
		y_top = minf(y_top, hawk.position.y)
		if hawk.shake > 0.0:
			tele = true
		if tele and hawk.vel.length() > 250.0:
			dove = true
	print("picchiata del falco del vento: salito fino a %.0f px sopra, segnale %s, picchiata %s (in %.1f s)" % [
		m.player.position.y - y_top, tele, dove, t])
	f.clear()
	# il fulmine annunciato
	var st: SkyStrikes = m.strikes
	var fallen0 := st.fallen
	var cloud: Creature = f.add("nube_tuono", m.player.position + Vector2(80, -70))
	cloud.mind.brave = true
	t = 0.0
	var saw_line := false
	while t < 9.0 and st.fallen == fallen0:
		await kit.frames(1)
		t += m.get_process_delta_time()
		if not st.pending.is_empty() and not saw_line:
			saw_line = true
			await kit.seconds(0.5)
			await kit.save("217_fulmine_annunciato")
	f.clear()
	print("fulmine della nube del tuono: colonna accesa prima %s, caduti %d, colpito il Germogliato %d volte" % [saw_line, st.fallen - fallen0, st.hits])
	if not tele or not dove or not saw_line or st.fallen == fallen0:
		print("ATTENZIONE: le mosse del cielo (picchiata, fulmine) non vanno come dovrebbero")
	m.vitals.refill()


## Voce 161: su un'isola del cielo il Signore del posto è quello del bioma del cielo; la sua esca lo chiama, a terra no.
func lords() -> void:
	var spot := island_spot("basso")
	if spot.x < 0:
		print("ATTENZIONE: nessuna isola per i Signori del cielo")
		return
	m.snap_to(spot)
	await kit.frames(3)
	var key: String = m.lords.here()
	var zone := SkyData.zone_at(world, spot.x, spot.y)
	var b: Bisaccia = m.character.bisaccia
	var bait := "esca_signore_" + key
	b.add(bait, 1)
	m.combat.god = true
	var ok: bool = key == zone and m.lords.summon(bait)
	var lord: Creature = m.lords.active
	var hp := lord.hp_max if lord else 0
	var flies: bool = lord != null and lord.fly
	await kit.seconds(0.6)
	await kit.save("218_signore_cielo")
	if lord and is_instance_valid(lord):
		m.fauna.kill(lord)
	m.fauna.clear()
	m.combat.god = false
	# a terra, l'esca del cielo non fa nulla
	m.snap_to(world.spawn)
	await kit.frames(3)
	b.add(bait, 1)
	var no: bool = not m.lords.summon(bait)
	b.remove(bait, b.count(bait))
	print("Signore del cielo: qui «%s» (zona «%s»), chiamato %s, vola %s, Vita %d; a terra l'esca non fa nulla %s" % [
		key, zone, ok, flies, hp, no])
	if not ok or not flies or not no:
		print("ATTENZIONE: i Signori del cielo non vanno come dovrebbero")


## Voce 162: l'Occhio della Tempesta si chiama solo nel cielo alto; i suoi fulmini cadono; in furia oscura il cielo e
## le mosse raddoppiano; sconfitto lascia il Cuore di tempesta.
func guardian() -> void:
	var gg: GreatGuardians = m.great
	var b: Bisaccia = m.character.bisaccia
	m.snap_to(world.spawn)
	await kit.frames(3)
	b.add("richiamo_tempesta", 1)
	var no_ground: bool = not gg.summon("richiamo_tempesta")
	var spot := island_spot("alto")
	if spot.x < 0:
		print("ATTENZIONE: nessuna isola alta per l'Occhio della Tempesta")
		return
	m.snap_to(spot)
	await kit.frames(3)
	m.combat.god = true
	var ok: bool = gg.summon("richiamo_tempesta")
	var boss: Creature = gg.active
	var st: SkyStrikes = m.strikes
	var f0 := st.fallen
	var t := 0.0
	while t < 7.0 and st.fallen == f0:
		await kit.frames(1)
		t += m.get_process_delta_time()
	var bolts := st.fallen - f0
	var n0: int = boss.behaviors.size() if boss else 0
	if boss:
		boss.hp = int(boss.hp_max * 0.4)
		await kit.seconds(1.8)
	var fury: bool = boss != null and is_instance_valid(boss) and boss.behaviors.size() > n0
	var dark: float = m.chiome.extra_dark
	await kit.save("219_occhio_tempesta")
	var d0: int = m.drops._items.size()
	if boss and is_instance_valid(boss):
		m.fauna.kill(boss)
	await kit.frames(2)
	var rec := int((m.world_meta.get("grandi_guardiani", {}) as Dictionary).get("tempesta", 0))
	m.fauna.clear()
	gg.clear_temp()
	m.combat.god = false
	m.vitals.refill()
	await kit.frames(2)
	print("Occhio della Tempesta: a terra no %s, nel cielo alto sì %s; fulmini caduti %d; furia %s, cielo oscurato %.1f; sconfitto %d, bottino %s" % [
		no_ground, ok, bolts, fury, dark, rec, m.drops._items.size() > d0])
	if not no_ground or not ok or bolts < 1 or not fury or dark < 0.5 or rec < 1:
		print("ATTENZIONE: l'Occhio della Tempesta non va come dovrebbe")


## Voce 163: un osservatorio per zona (fino a 4) con lo scrigno pieno e la stele; i nidi delle famiglie del cielo.
func observatory() -> void:
	var obs: Array = world.gen_notes.get("osservatori", [])
	if obs.is_empty():
		print("ATTENZIONE: nessun osservatorio nel cielo")
		return
	var x0 := int(obs[0][0])
	var top := int(obs[0][1])
	var chest_o := Vector2i(x0 + 6, top - 2)
	var full := world.chests.has(chest_o) and not (world.chests[chest_o] as Bisaccia).is_empty()
	var stele := String(world.stations.get(Vector2i(x0 + 3, top - 3), "")) == "stele"
	var built := 0
	for x in range(x0, x0 + 11):
		for y in range(top - 7, top + 1):
			if world.build_at(x, y) > 0:
				built += 1
	var sky_nests := 0
	var nests: Dictionary = m.world_meta.get("nidi", {})
	for k in nests:
		var fam := String((nests[k] as Dictionary).get("fam", ""))
		var fd: Dictionary = FamiliesData.FAMILIES.get(fam, {})
		if not fd.is_empty() and CreaturesData.CREATURES.get(String(fd["members"][0]), {}).has("sky"):
			sky_nests += 1
	m.snap_to(Vector2i(x0 + 4, top - 1))
	m.boons.add("bagliore", 5.0)
	await kit.seconds(0.8)
	await kit.save("220_osservatorio")
	print("osservatori: %d; il primo in (%d, %d): %d blocchi di cristallo celeste, scrigno pieno %s, stele %s; nidi del cielo %d" % [
		obs.size(), x0, top, built, full, stele, sky_nests])
	if built < 20 or not full or sky_nests < 2:
		print("ATTENZIONE: gli osservatori o i nidi del cielo non ci sono come dovrebbero")


## Una cella d'aria su un'isola di un bioma del cielo preciso (o (-1, -1)).
func biome_spot(id: String) -> Vector2i:
	var fl := int(SkyData.get_biome(id)["floor"])
	for e in world.sky:
		if String(e["low"]) != id and String(e.get("mid", "")) != id and String(e["high"]) != id:
			continue
		for x in range(int(e["x0"]) + 10, int(e["x1"]) - 10, 2):
			for y in range(SkyData.TOP, int(e["base"])):
				if world.tile(x, y + 1) == fl and not world.solid(x, y) and not world.solid(x, y - 1) and world.solid(x + 1, y + 1) \
						and world.solid(x - 1, y + 1):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


## Voce 164: i fulmini che cadono da soli nei Nidi di tempesta, la raffica dei Giardini, l'arcobaleno dopo la pioggia,
## la Burrasca delle Chiome fino al capo.
func sky_weather() -> void:
	var ch: Chiome = m.chiome
	m.combat.god = true
	var bolts := -1
	var st: SkyStrikes = m.strikes
	var p := biome_spot("nidi_tempesta")
	if p.x >= 0:
		m.snap_to(p)
		await kit.seconds(0.6)
		var b0 := ch.bolts
		var f0 := st.fallen
		ch._bolt_t = 0.0
		await kit.seconds(2.0)
		bolts = mini(ch.bolts - b0, st.fallen - f0)
	var gust := -1
	p = biome_spot("giardini_vento")
	if p.x >= 0:
		m.snap_to(p)
		await kit.seconds(0.6)
		var g0 := ch.gusts
		ch._gust_t = 0.0
		await kit.seconds(0.3)
		gust = ch.gusts - g0
	# l'arcobaleno
	m.events.stop()
	var rainbow := false
	var ev_paused: bool = m.events.paused
	m.events.paused = false                        # le prove fermano gli eventi: qui serve che l'arcobaleno parta
	for i in 30:
		ch._rained = true
		await kit.frames(1)
		if m.events.active == "arcobaleno":
			rainbow = true
			break
	m.events.stop()
	m.events.paused = ev_paused
	# la Burrasca
	var td: Tides = m.tides
	td.paused = true
	var spot := island_spot("basso")
	m.snap_to(spot)
	await kit.frames(3)
	td.center = m.player_cell()
	td.start("burrasca")
	var waves := 0
	var in_air := 0
	var t0 := Time.get_ticks_msec()
	while td.active != "" and Time.get_ticks_msec() - t0 < 20000:
		await kit.frames(3)
		if td.wave > waves:
			waves = td.wave
			for c in td._wave_list:
				if is_instance_valid(c) and SkyData.zone_at(world, floori(c.position.x / S), floori(c.position.y / S)) != "":
					in_air += 1
		if td.boss and is_instance_valid(td.boss):
			m.fauna.kill(td.boss)
		else:
			for c in td._wave_list.duplicate():
				if is_instance_valid(c):
					m.fauna.kill(c)
	var won := td.wins
	m.fauna.clear()
	td.paused = false
	m.combat.god = false
	m.vitals.refill()
	print("tempo del cielo: fulmini da soli %d, raffiche %d, arcobaleno %s; Burrasca: %d ondate (%d creature nate in cielo), vinte in tutto %d" % [
		bolts, gust, rainbow, waves, in_air, won])
	if bolts < 1 or gust < 1 or not rainbow or waves < 3 or in_air < 6 or won < 1:
		print("ATTENZIONE: il tempo del cielo o la Burrasca non vanno come dovrebbero")


## Voce 165: nelle pozze del cielo si pescano i pesci del cielo (e a terra no); la Balena delle stelle si cavalca e
## vola; il Fiore di vento si pianta sull'erba del cielo.
func life() -> void:
	# la pesca: la prima pozza del cielo abbastanza grande
	var ctx := {}
	var pool := []
	for e in world.sky:
		if not ctx.is_empty():
			break
		for x in range(int(e["x0"]), int(e["x1"])):
			if not ctx.is_empty():
				break
			for y in range(int(e["split"]), int(e["base"])):
				if world.liq(x, y) >= 6:
					var body := WaterBody.at(world, Vector2i(x, y))
					if bool(body.get("ok", false)):
						ctx = m.fishing.context(body)
						pool = FishData.pool(ctx)
						break
	var sky_only := not pool.is_empty()
	for e in pool:
		if not FishData.info(String(e[0])).has("sky"):
			sky_only = false
	var ground := ctx.duplicate()
	ground["sky"] = ""
	var leaks := 0
	for e in FishData.pool(ground) if not ground.is_empty() else []:
		if FishData.info(String(e[0])).has("sky"):
			leaks += 1
	# la Balena delle stelle in sella
	var h: Herd = m.herd
	var spot := island_spot("basso")
	m.snap_to(spot)
	await kit.frames(3)
	var whale := h.new_record("balena_stelle", "nutrita")
	h.add_record(whale)
	await kit.frames(3)
	var rode := h.ride(true)
	await kit.frames(3)
	var wings: Dictionary = m.player.wings
	var flies := not wings.is_empty() and float(wings.get("time", 0.0)) >= 3.0
	h.ride(false)
	await kit.frames(3)
	var off: bool = m.player.wings.get("time", 0.0) != wings.get("time", -1.0) or wings.is_empty()
	for r in h.records():
		if int(r["uid"]) == int(whale["uid"]):
			h.set_state(r, "riposo")
	# il Fiore di vento
	var b: Bisaccia = m.character.bisaccia
	b.add("seme_vento", 1)
	var gp := biome_spot("giardini_vento")
	var planted := false
	if gp.x >= 0:
		m.snap_to(gp + Vector2i(-2, 0))
		await kit.frames(3)
		world.set_decor(gp.x, gp.y, 0)
		planted = m.garden.plant(gp, "seme_vento")
	print("vita del cielo: pozza con %d pesci, tutti del cielo %s, a terra nessuno del cielo %s (%d); Balena in sella %s, vola %s (%s s), scesa %s; Fiore di vento piantato %s" % [
		pool.size(), sky_only, leaks == 0, leaks, rode, flies, wings.get("time", 0.0), off, planted])
	if pool.is_empty() or not sky_only or leaks > 0 or not rode or not flies or not planted:
		print("ATTENZIONE: pesca, mandria o orto del cielo non vanno come dovrebbero")


## Voce 168: 40 creature del cielo attorno al Germogliato su un'isola bassa (fulmini, picchiate, derive): i tempi.
func load_test() -> void:
	var spot := island_spot("basso")
	m.snap_to(spot)
	await kit.frames(3)
	m.combat.god = true
	var ids: Array = ((load("res://src/data/bestiary/cielo.gd") as GDScript).get("DATA")["creatures"] as Dictionary).keys()
	for i in 40:
		var cr: Creature = m.fauna.add(String(ids[i % ids.size()]), m.player.position + Vector2(-300.0 + (i % 20) * 30.0, -60.0 - (i / 20) * 50.0))
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
	m.combat.god = false
	m.vitals.refill()
	print("tempi con 40 creature del cielo: %d fotogrammi in 3 s (media %.1f ms), il peggiore %.1f ms; fulmini chiamati %d" % [
		n, total / maxf(n, 1), worst, m.strikes.fallen])
	if total / maxf(n, 1) > 25.0:
		print("ATTENZIONE: con 40 creature del cielo il gioco rallenta troppo")
