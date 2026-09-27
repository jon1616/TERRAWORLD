class_name TestsRareBiomes
extends RefCounted
## Prove della voce 94: un mondo con i quattro geni del sottosuolo nuovi ha le caverne cantanti, le giungle, i laghi
## (con l'acqua) e le catacombe (con lo scrigno); sopra i loro pavimenti nascono le loro creature; i tre biomi rari
## nascono dai loro geni (solo per mutazione) con la loro creatura; tutte le creature nuove hanno il disegno; i biomi
## sono almeno 20. Foto 166_sottosuolo_nuovo.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


const UNDER := ["cristalli_cantanti", "giungle_radici", "laghi_profondi", "catacombe"]
const RARES := ["iride_viva", "cielo_caduto", "sussurri"]


## I mondi che la prova genera (li prepara in anticipo il giro intero: `TestKit.prefetch`).
static func jobs() -> Array:
	var out := [[1201, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 3, "geni": UNDER.duplicate()}]]
	for g in RARES:
		out.append([1300 + out.size(), WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2, "geni": [g]}])
	return out


func run() -> void:
	var res := {}
	var rares := RARES
	var worlds: Array[World] = await kit.gen_many(jobs())
	# il sottosuolo
	var w := worlds[0]
	var count := {}
	for u in BiomesData.UNDER:
		count[int(u["floor"])] = 0
	var water := 0
	for i in w.tiles.size():
		var t := int(w.tiles[i])
		if count.has(t):
			count[t] = int(count[t]) + 1
	for y in range(StrataData.top(2), w.h, 3):
		for x in range(0, w.w, 3):
			if w.liq(x, y) > 0 and w.liq_type(x, y) == LiquidsData.ACQUA:
				water += 1
	var chests := 0
	for o in w.stations:
		if String(w.stations[o]) == "scrigno_antico":
			chests += 1
	for u in BiomesData.UNDER:
		res["sotto_" + String(u["id"])] = int(count[int(u["floor"])]) > 50
	res["lago_acqua"] = water > 50
	res["catacombe_scrigno"] = chests > 0
	print("sottosuolo nuovo: tessere %s, acqua %d, scrigni antichi %d" % [count, water, chests])
	# le nascite sopra i pavimenti
	var pools_ok := true
	for u in BiomesData.UNDER:
		var fl := int(u["floor"])
		var found := Vector2i(-1, -1)
		for i in range(w.w * 60, w.tiles.size()):
			if int(w.tiles[i]) == fl and w.tiles[i - w.w] == TileDefs.AIR:
				found = Vector2i(i % w.w, i / w.w - 1)
				break
		var pool: Array = UnderBiomesData.pool_at(w, found) if found.x >= 0 else []
		var ok := not pool.is_empty() and (u["creatures"] as Dictionary).has(String(pool[0][0]))
		pools_ok = pools_ok and ok
		print("  %s: sul pavimento nascono %s" % [u["name"], pool])
	res["nascite"] = pools_ok
	# i biomi rari
	for i in rares.size():
		var rw := worlds[i + 1]
		var bid := String((GenesData.GENES[rares[i]]["gen"]["biomes"] as Dictionary).keys()[0])
		var b := BiomesData.index_of(bid)
		var cols := 0
		for x in rw.w:
			if int(rw.biomes[x]) == b:
				cols += 1
		var bd: Dictionary = BiomesData.BIOMES[b]
		res["raro_" + bid] = cols > rw.w * 0.3 and String(GenesData.GENES[rares[i]].get("only", "")) == "mutazione" \
			and int(bd["weight"]) == 0 and not (bd.get("creatures", {}) as Dictionary).is_empty()
		print("mondo raro %s: %d%% del bioma" % [bd["name"], roundi(100.0 * cols / rw.w)])
	# i disegni delle creature nuove
	var drawn := true
	for b in BiomesData.BIOMES + BiomesData.UNDER:
		for cid in (b.get("creatures", {}) as Dictionary):
			var art: Array = b["creatures"][cid].get("art", [cid, 0])      # (il disegno ha il nome scritto in "art")
			var fr: Dictionary = CreatureArt.frames(String(art[0]), int(art[1]))
			drawn = drawn and (fr["frames"][0] as Image).get_width() > 8
	res["disegni"] = drawn
	res["venti_biomi"] = BiomesData.BIOMES.size() + UnderBiomesData.UNDER.size() >= 20
	# la mutazione può dare un gene raro
	var rng := RandomNumberGenerator.new()
	var mut := Genome.mutate({"geni": ["lanterna"], "vigore": 2}, rng, 1.0, "iride_viva")
	res["mutazione"] = "iride_viva" in Genome.genes(mut)
	# una foto: le caverne cantanti nel mondo di prova (ne scava una accanto alla partenza)
	var tw: World = m.world
	var spot := tw.spawn + Vector2i(60, 30)
	for y in range(spot.y - 6, spot.y + 2):
		for x in range(spot.x - 12, spot.x + 12):
			tw.set_tile(x, y, TileDefs.AIR)
			tw.walls[y * tw.w + x] = TileDefs.WALL_STONE
	for x in range(spot.x - 12, spot.x + 12):
		tw.set_tile(x, spot.y + 2, 40)
		if x % 5 == 0:
			tw.set_tile(x, spot.y + 1, 40)
	m.view.refresh_rect(Rect2i(spot.x - 14, spot.y - 8, 28, 12)) if m.view.has_method("refresh_rect") else m.view.refresh_around(spot)
	m.snap_to(Vector2i(spot.x - 6, spot.y + 1))
	m.boons.add("bagliore", 5.0)
	var made: Array[Creature] = []
	for k in 2:
		var cid := "cantore_cristallo" if k == 0 else "grillo_eco"
		var cr: Creature = m.fauna.add(cid, m.player.position + Vector2(60 + k * 50, -20))
		cr.calm = true
		made.append(cr)
	await kit.seconds(0.6)
	await kit.save("166_sottosuolo_nuovo")
	m.fauna.clear()
	m.snap_to(tw.spawn)
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("biomi rari e sottosuolo: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i biomi rari o del sottosuolo non funzionano come dovrebbero")
