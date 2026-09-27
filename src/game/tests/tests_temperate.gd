class_name TestsTemperate
extends RefCounted
## Prove della voce 92, le terre temperate: un mondo nato da ciascuno dei quattro Semi nuovi è fatto soprattutto del
## suo bioma (erba, alberi della sua specie, partenza lì); nel mondo di prova si va in ognuno dei quattro biomi e lo
## si fotografa con le sue creature (foto 158-161); le creature lasciano i loro materiali; i set e gli unici esistono
## con le loro ricette; i nomi dei mondi hanno il paesaggio del bioma.

const PHOTOS := {"prati": "158_prati_vento", "rossa": "159_selve_rosse", "funghi": "160_colline_cappelli", "torba": "161_torbiere"}

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


const IDS := ["prati", "rossa", "funghi", "torba"]


## I mondi che la prova genera (li prepara in anticipo il giro intero: `TestKit.prefetch`).
static func jobs() -> Array:
	var out := []
	for bid in IDS:
		out.append([900 + out.size(), WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2, "geni": [String(BiomesData.by_id(bid)["gene"])]}])
	return out


func run() -> void:
	var res := {}
	var ids := IDS
	var worlds: Array[World] = await kit.gen_many(jobs())
	for i in ids.size():
		var bid := String(ids[i])
		var w := worlds[i]
		var b := BiomesData.index_of(bid)
		var bd: Dictionary = BiomesData.BIOMES[b]
		var cols := 0
		var grass := 0
		for x in w.w:
			if int(w.biomes[x]) == b:
				cols += 1
				if w.tile(x, w.surface[x]) == int(bd["grass"]):
					grass += 1
		var trees := 0
		var mine := 0
		for blk in w.trees:
			for t in w.trees[blk]:
				trees += 1
				if int(TreesData.decode((t as Vector3i).z)[0]) == b:
					mine += 1
		var pct := 100.0 * cols / w.w
		var ok: bool = pct > 30.0 and grass > cols / 2 and int(w.biomes[w.spawn.x]) == b and (bd["trees"] < 0.1 or mine > 0)
		res["mondo_" + bid] = ok
		print("mondo %s: %s %d%%, erba giusta %d/%d colonne, alberi della specie %d su %d, partenza lì %s" % [
			bid, bd["name"], roundi(pct), grass, cols, mine, trees, "sì" if int(w.biomes[w.spawn.x]) == b else "NO"])
	# nel mondo di prova (senza gene di superficie ci sono tutti i biomi): foto con le creature
	await kit.frames(2)
	kit.make_room()
	for bid in ids:
		var x := _find(bid)
		if x < 0:
			print("ATTENZIONE: nel mondo di prova non ci sono %s" % BiomesData.by_id(bid)["name"])
			res["foto_" + bid] = false
			continue
		var c := kit.floor_near(Vector2i(x, world.surface[x] - 1), 8)
		m.snap_to(c)
		await kit.seconds(0.6)
		var made: Array[Creature] = []
		var k := 0
		var pack: Dictionary = BiomesData.by_id(bid).get("creatures", {})
		for cid in pack:
			var cr: Creature = m.fauna.add(String(cid), m.player.position + Vector2(50 + k * 40, -24 - k * 12))
			cr.calm = true
			made.append(cr)
			k += 1
		await kit.seconds(0.4)
		await kit.save(String(PHOTOS[bid]))
		# i materiali
		var before: int = m.drops.count()
		for cr in made:
			if is_instance_valid(cr) and m.fauna.list.has(cr):
				m.fauna.kill(cr)
		await kit.frames(2)
		res["bottino_" + bid] = m.drops.count() > before
		res["foto_" + bid] = int(world.biomes[m.player_cell().x]) == BiomesData.index_of(bid)
		m.fauna.clear()
	# set, unici, Semi, nomi
	for bid in ids:
		var bd: Dictionary = BiomesData.by_id(bid)
		var sets_ok := true
		for sid in bd.get("sets", {}):
			for p in SetsData.all()[sid]["pieces"]:
				sets_ok = sets_ok and ItemsData.has(String(p)) and not RecipesData.making(String(p)).is_empty()
		var uniq := false
		for iid in bd.get("items", {}):
			if bd["items"][iid].get("unique", false):
				uniq = not RecipesData.making(String(iid)).is_empty()
		var gene := String(bd["gene"])
		var seed_ok := ItemsData.has(String(GenesData.GENES[gene]["item"]))
		var wname := NamesData.world_name([gene], 12345)
		var land_ok := false
		for l in NamesData.LANDS.get(gene, []):
			land_ok = land_ok or wname.begins_with(String(l[0]))
		res["pacchetto_" + bid] = sets_ok and uniq and seed_ok and land_ok
		print("%s: set %s, unico %s, Seme %s, un mondo si chiama «%s»" % [bid, sets_ok, uniq, seed_ok, wname])
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("terre temperate: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: le terre temperate non funzionano come dovrebbero")
