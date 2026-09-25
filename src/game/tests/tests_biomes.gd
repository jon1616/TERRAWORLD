class_name TestsBiomes
extends RefCounted
## Prove dei biomi di superficie (voce 13): quante colonne per bioma, la partenza nella foresta, una visita alle paludi
## e alle distese d'ambra (scritta del bioma, foto 31_paludi e 32_ambra) e creature proprie del bioma in superficie.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## La colonna più vicina alla partenza nel mezzo di un tratto del bioma b (30 colonne uguali per parte).
func _column_of(b: int) -> int:
	for r in range(0, world.w):
		for side in [1, -1]:
			var x: int = world.spawn.x + side * r
			if x < 40 or x > world.w - 40:
				continue
			if BiomesData.at(world, x - 30) == b and BiomesData.at(world, x + 30) == b and BiomesData.at(world, x) == b:
				return x
	return -1


func run() -> void:
	var count := [0, 0, 0]
	for x in world.w:
		count[world.biomes[x]] += 1
	print("biomi: foresta %d, paludi %d, ambra %d colonne; partenza nella %s" % [count[0], count[1], count[2],
		BiomesData.BIOMES[BiomesData.at(world, world.spawn.x)]["name"]])
	var names := ["", "31_paludi", "32_ambra"]
	for b in [1, 2]:
		var x := _column_of(b)
		if x < 0:
			print("bioma %s: NON trovato" % BiomesData.BIOMES[b]["id"])
			continue
		m.snap_to(Vector2i(x, world.surface[x] - 1))
		await kit.seconds(2.0)
		# creature del bioma: si provano molte comparse in superficie
		m.fauna.clear()
		var seen := {}
		for k in 300:
			var c: Creature = m.fauna.try_spawn()
			if c and StrataData.at(world, int(c.position.x / 16), int(c.position.y / 16)) == 0:
				seen[c.id] = true
		m.fauna.clear()
		print("bioma %s: scritta %s, creature in superficie: %s" % [BiomesData.BIOMES[b]["name"],
			"sì" if m.depth_watch.biome == b else "NO", ", ".join(seen.keys())])
		await kit.save(names[b])
