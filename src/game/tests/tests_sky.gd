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


## Voce 154: le zone e le fasce.
func zones() -> void:
	var z: Array = world.sky
	var ok := not z.is_empty()
	var bad := []
	for e in z:
		var x := (int(e["x0"]) + int(e["x1"])) / 2
		var low := SkyData.zone_at(world, x, int(e["base"]) - 3)
		var hi := SkyData.zone_at(world, x, int(e["split"]) - 3)
		var ground := SkyData.zone_at(world, x, int(world.surface[x]) - 1)
		if low != String(e["low"]) or hi != String(e["high"]) or ground != "" \
				or SkyData.band_at(world, x, int(e["base"]) - 3) != "basso" or SkyData.band_at(world, x, int(e["split"]) - 3) != "alto":
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
		z.size(), ", ".join(z.map(func(e: Dictionary) -> String: return "%s/%s" % [e["low"], e["high"]])), bad.size(),
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
	# da che parte è l'isola
	var side := 0
	for dx in range(1, 24):
		if world.solid(x - dx, top):
			side = -1
			break
		if world.solid(x + dx, top):
			side = 1
			break
	m.vitals.hp = m.vitals.hp_max
	m.snap_to(Vector2i(x, int(best["y1"])))
	await kit.frames(2)
	var p: Player = m.player
	var min_y := p.position.y
	var t := 0.0
	while t < 8.0:
		await kit.frames(1)
		t += m.get_process_delta_time()
		min_y = minf(min_y, p.position.y)
		if p.position.y < (top - 1) * S:
			p.auto_dir = float(side)
		if p.on_floor and p.position.y < (top + 1) * S:
			break
	p.auto_dir = 0.0
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
		for x in range(x0, x1, 2):
			for y in range(SkyData.TOP + 2, int(e["split"])):
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
		for band in ["low", "high"]:
			var id := String(e[band])
			if seen.has(id):
				continue
			var b := SkyData.get_biome(id)
			var fl := int(b["floor"])
			var y_top := SkyData.TOP if band == "high" else int(e["split"])
			var y_bot := int(e["split"]) if band == "high" else int(e["base"])
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
			for y in range(SkyData.TOP + 2, int(e["split"]) - 2):
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
			for y in range(SkyData.TOP, int(e["split"])):
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


## Una cella d'aria sopra un'isola della fascia data ("basso"/"alto"), con due celle libere sopra.
func island_spot(band: String) -> Vector2i:
	for e in world.sky:
		var y0 := SkyData.TOP + 2 if band == "alto" else int(e["split"]) + 1
		var y1 := int(e["split"]) - 1 if band == "alto" else int(e["base"])
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
	for i in 200:
		var cr: Creature = f.try_spawn()
		if cr != null:
			born += 1
			var cz := SkyData.zone_at(world, floori(cr.position.x / S), floori(cr.position.y / S))
			if cz != "" and String(cr.data.get("sky", "")) == cz:
				own += 1
		if f.list.size() > 30:
			f.clear()
	f.clear()
	print("nascite nel cielo (zona «%s»): %d nate, %d del bioma del cielo dove sono nate" % [zone, born, own])
	if born < 10 or own < born / 2:
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
