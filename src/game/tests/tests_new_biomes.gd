class_name TestsNewBiomes
extends RefCounted
## Prove della voce 40: un mondo di cenere è fatto soprattutto di Cenerarie (e ci si parte); nel mondo di prova si
## cercano i Boschi di brina e le Cenerarie, ci si va e si fotografano con le loro creature (foto 69_boschi_brina,
## 70_cenerarie); le quattro creature nuove lasciano i loro materiali; i due set nuovi danno il loro bonus.

const S := 16
const MATS := ["vello_brina", "palco_brina", "piuma_gelo", "squama_brace", "cenere_viva", "fungo_brace"]

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Una colonna in mezzo a un tratto di quel bioma, lontana dai bordi (-1 se nel mondo non c'è).
func _find(biome: String) -> int:
	var b := BiomesData.index_of(biome)
	var run := 0
	for x in range(40, world.w - 40):
		run = run + 1 if int(world.biomes[x]) == b else 0
		if run == 60:
			return x - 30
	return -1


## Quanti materiali dei biomi nuovi ci sono, nella Bisaccia e a terra.
func _totals() -> Dictionary:
	var out := {}
	for id in MATS:
		out[id] = m.character.bisaccia.count(id)
	for d in m.drops._items:
		if d["id"] in MATS:
			out[d["id"]] = int(out[d["id"]]) + int(d["n"])
	return out


func run() -> void:
	# un mondo nato da un Seme di cenere
	var ash := World.new()
	WorldGen.generate(ash, 777, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 2, "geni": ["cenere"]})
	var n := 0
	for x in ash.w:
		if int(ash.biomes[x]) == BiomesData.index_of("cenere"):
			n += 1
	var grass := 0
	for x in range(0, ash.w, 3):
		if ash.tile(x, ash.surface[x]) == TileDefs.GRASS_CENERE:
			grass += 1
	print("mondo di cenere: Cenerarie %d%%, colonne con cenere viva in superficie %d, partenza nelle Cenerarie %s" % [
		roundi(100.0 * n / ash.w), grass * 3, "sì" if int(ash.biomes[ash.spawn.x]) == BiomesData.index_of("cenere") else "NO"])
	await kit.frames(2)
	kit.make_room()
	# le due foto, con le loro creature
	for pair in [["brina", "69_boschi_brina", ["cervo_brina", "gufo_gelo"]],
			["cenere", "70_cenerarie", ["salamandra_brace", "fatuo_cenere"]]]:
		var x := _find(String(pair[0]))
		if x < 0:
			print("ATTENZIONE: nel mondo di prova non ci sono %s" % BiomesData.BIOMES[BiomesData.index_of(String(pair[0]))]["name"])
			continue
		var c := kit.floor_near(Vector2i(x, world.surface[x] - 1), 8)
		m.snap_to(c)
		await kit.seconds(0.6)
		var made := []
		for k in (pair[2] as Array).size():
			var id := String(pair[2][k])
			var cr: Creature = m.fauna.add(id, m.player.position + Vector2(60 + k * 50, -30 - k * 20))
			made.append(cr)
		await kit.seconds(0.4)
		await kit.save(String(pair[1]))
		# i materiali: ogni creatura sconfitta lascia i suoi
		var before := _totals()
		for cr in made:
			if is_instance_valid(cr) and m.fauna.list.has(cr):
				m.fauna.kill(cr)
		await kit.frames(2)
		var after := _totals()
		var got := []
		for id in after:
			if int(after[id]) > int(before[id]):
				got.append(id)
		print("%s: bioma «%s», le creature sconfitte lasciano %s" % [pair[1],
			BiomesData.BIOMES[BiomesData.at(world, x)]["name"], got])
	# i set nuovi
	var b: Bisaccia = m.character.bisaccia
	var saved := b.equip.duplicate()
	for set_id in ["brina", "cenere"]:
		var pieces: Array = SetsData.all()[set_id]["pieces"]
		for p in pieces:
			b.equip[String(ItemsData.get_item(String(p))["kind"])] = p
		m.gear.refresh()
		print("set %s indossato: attivo %s, Scorza del set %d, corsa ×%.2f, danno ×%.2f, spine %d, cadute sicure %s" % [
			set_id, "sì" if set_id in m.gear.sets else "NO", m.vitals.set_scorza, m.player.run_mult, m.combat.dmg_mult,
			m.combat.thorns, "sì" if m.life.fall_safe else "no"])
	b.equip = saved
	m.gear.refresh()
