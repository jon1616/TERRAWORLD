class_name TestsExtreme
extends RefCounted
## Prove della voce 93, le terre estreme: un mondo per ciascuno dei quattro Semi è fatto soprattutto del suo bioma;
## nel mondo di prova, in ogni bioma estremo allo scoperto la barra del suo rigore sale (e nella foresta no); piena,
## ferisce e toglie (corsa, ricrescita, Linfa, salto); l'equipaggiamento fatto con i materiali di altri biomi la fa salire
## più piano, il rimedio e il Rifugio del viandante la fermano; il vetro e la brace feriscono i piedi, gli Stivali di
## scaglie no. Foto 162-165 (una per bioma, con la barra).

const PHOTOS := {"vetro": "162_deserti_vetro", "ghiacciaio": "163_ghiacciai", "pietra": "164_foreste_pietra", "brace": "165_lande_brace"}

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _find(biome: String) -> int:
	var b := BiomesData.index_of(biome)
	var run := 0
	for x in range(40, world.w - 40):
		run = run + 1 if int(world.biomes[x]) == b else 0
		if run == 60:
			return x - 30
	return -1


func _wear(slot: String, id: String) -> void:
	var b: Bisaccia = m.character.bisaccia
	if id == "":
		b.equip.erase(slot)
	else:
		b.equip[slot] = id
	b.changed.emit()


## Quanto sale la barra in `secs` secondi, partendo da vuota.
func _rise(kind: String, secs: float) -> float:
	m.harsh.meters[kind] = 0.0
	await kit.seconds(secs)
	return float(m.harsh.meters[kind])


const IDS := ["vetro", "ghiacciaio", "pietra", "brace"]


## I mondi che la prova genera (li prepara in anticipo il giro intero: `TestKit.prefetch`).
static func jobs() -> Array:
	var out := []
	for bid in IDS:
		out.append([950 + out.size(), WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 3, "geni": [String(BiomesData.by_id(bid)["gene"])]}])
	return out


func run() -> void:
	var res := {}
	var ids := IDS
	var worlds: Array[World] = await kit.gen_many(jobs())
	for i in ids.size():
		var w := worlds[i]
		var b := BiomesData.index_of(String(ids[i]))
		var cols := 0
		for x in w.w:
			if int(w.biomes[x]) == b:
				cols += 1
		res["mondo_" + String(ids[i])] = cols > w.w * 0.3 and int(w.biomes[w.spawn.x]) == b
		print("mondo %s: %d%% del bioma, partenza lì %s" % [ids[i], roundi(100.0 * cols / w.w), int(w.biomes[w.spawn.x]) == b])
	await kit.frames(2)
	kit.make_room()
	var eq0: Dictionary = m.character.bisaccia.equip.duplicate()
	var god: bool = m.combat.god
	var dp: bool = m.day.paused
	m.day.paused = true
	# nella foresta nessun rigore
	m.snap_to(kit.floor_near(Vector2i(world.spawn.x, world.surface[world.spawn.x] - 1), 8))
	await kit.seconds(0.4)
	res["foresta_niente"] = m.harsh.kind == ""
	for bid in ids:
		var bd: Dictionary = BiomesData.by_id(bid)
		var kind := String(bd["harsh"]["kind"])
		var x := _find(bid)
		var painted := -1
		var orig := PackedByteArray()
		if x < 0:
			# con tanti biomi il mondo di prova non li ha tutti: si «ridipinge» per un momento un tratto di foresta
			x = world.spawn.x + 200
			painted = x
			orig = world.biomes.slice(x - 40, x + 40)
			for k in range(x - 40, x + 40):
				world.biomes[k] = BiomesData.index_of(bid)
			print("%s non c'è nel mondo di prova: ridipinto un tratto per la prova" % bd["name"])
		var c := kit.floor_near(Vector2i(x, world.surface[x] - 1), 8)
		m.snap_to(c)
		m.vitals.refill()
		await kit.seconds(0.3)
		# senza protezioni: sale
		var bare: float = await _rise(kind, 1.0)
		# con la protezione fatta con i materiali di altri biomi
		var gear := ""
		for iid in bd["items"]:
			var it: Dictionary = bd["items"][iid]
			if (it.get("acc", {}) as Dictionary).has(String(HarshData.KINDS[kind]["acc"])) and float(it["acc"][HarshData.KINDS[kind]["acc"]]) >= 0.6:
				gear = iid
		var slot := "mantello" if ItemsData.get_item(gear).get("kind", "") == "mantello" else "accessorio_1"
		_wear(slot, gear)
		var dressed: float = await _rise(kind, 1.0)
		_wear(slot, "")
		# il rimedio la ferma
		m.boons.add(String(HarshData.KINDS[kind]["boon"]), 5.0)
		var cured: float = await _rise(kind, 0.6)
		m.boons.active.erase(String(HarshData.KINDS[kind]["boon"]))
		# piena: ferisce e toglie
		m.combat.god = false
		m.combat.invuln = 0.0
		var hp0: int = m.vitals.hp
		m.harsh.meters[kind] = 1.0
		await kit.seconds(0.3)
		await kit.save(String(PHOTOS[bid]))
		var hurt: bool = m.vitals.hp < hp0
		var pen: Dictionary = HarshData.KINDS[kind]["penalty"]
		var penal: bool = (not pen.has("run") or m.player.harsh_run < 1.0) and (not pen.has("regen") or m.vitals.harsh_regen == 0.0) \
			and (not pen.has("jump") or m.player.harsh_jump < 1.0)
		m.combat.god = god
		m.harsh.meters[kind] = 0.0
		m.vitals.refill()
		if painted >= 0:
			for k in range(painted - 40, painted + 40):
				world.biomes[k] = orig[k - painted + 40]
		res["rigore_" + bid] = m.harsh.kind == kind and bare > 0.0 and dressed < bare * 0.6 and cured <= 0.001 and hurt and penal
		print("%s (%s): in un secondo %.3f senza nulla, %.3f con %s, %.3f con il rimedio; piena ferisce %s e toglie %s" % [
			bd["name"], kind, bare, dressed, gear, cured, hurt, penal])
	# il Rifugio del viandante ferma tutto
	var xg := _find("ghiacciaio")
	if xg >= 0:
		var c2 := kit.floor_near(Vector2i(xg, world.surface[xg] - 1), 8)
		m.snap_to(c2)
		world.stations[c2 + Vector2i(2, -1)] = "totem_rifugio_1"
		m.view.add_station(c2 + Vector2i(2, -1))
		m.zones.rebuild()
		var sheltered: float = await _rise("freddo", 0.8)
		res["rifugio"] = sheltered <= 0.001
		world.stations.erase(c2 + Vector2i(2, -1))
		m.view.remove_station(c2 + Vector2i(2, -1))
		m.zones.rebuild()
	# il terreno che ferisce, e gli stivali
	var xv := _find("vetro")
	if xv >= 0:
		var c3 := kit.floor_near(Vector2i(xv, world.surface[xv] - 1), 8)
		m.fauna.clear()                          # (nel giro intero una creatura lasciata da un'altra prova a volte mordeva)
		m.snap_to(c3)
		m.combat.god = false
		m.vitals.refill()
		m.harsh.meters["sete"] = 0.0
		m.boons.add("riparo_sete", 5.0)
		var hp1: int = m.vitals.hp
		await kit.seconds(1.3)
		var cut: bool = m.vitals.hp < hp1 or world.tile(c3.x, c3.y + 1) != int(BiomesData.by_id("vetro")["grass"])
		_wear("stivali", "stivali_scaglie")
		m.vitals.refill()
		var hp2: int = m.vitals.hp
		await kit.seconds(1.3)
		res["piedi"] = cut and m.vitals.hp == hp2
		_wear("stivali", "")
		m.boons.active.erase("riparo_sete")
		m.combat.god = god
	m.character.bisaccia.equip = eq0
	m.character.bisaccia.changed.emit()
	m.day.paused = dp
	for k in m.harsh.meters:
		m.harsh.meters[k] = 0.0
	m.vitals.refill()
	m.snap_to(world.spawn)
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("terre estreme: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: le terre estreme non funzionano come dovrebbero")
