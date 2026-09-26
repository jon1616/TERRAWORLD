class_name TestsTrees
extends RefCounted
## Prove degli alberi (26 set 2026): quanti alberi di ogni specie e di ogni grandezza ha il mondo di prova, se ogni
## bioma ha la sua specie, e una foto in ogni bioma dove ci sono alberi (100_alberi_<bioma>).

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var per_species := {}
	var per_size := [0, 0, 0, 0]
	var wrong := 0
	var best := {}                          # bioma -> [x della colonna con più alberi vicini, quanti]
	for k in world.trees:
		for t in world.trees[k]:
			var d := TreesData.decode(t.z)
			var sp := String(TreesData.SPECIES[d[0]]["id"])
			per_species[sp] = int(per_species.get(sp, 0)) + 1
			per_size[d[1]] += 1
			var b := world.biomes[t.x]
			if TreesData.species_of_biome(b) != d[0] and t.y < world.surface[t.x] + 2:
				wrong += 1
	# per ogni bioma, il tratto di 60 colonne con più alberi (per la foto)
	for x in range(40, world.w - 40, 20):
		var n := 0
		for k in world.trees:
			for t in world.trees[k]:
				if absi(t.x - x) < 30 and absi(t.y - world.surface[x]) < 20:
					n += 1
		var bid := String(BiomesData.BIOMES[world.biomes[x]]["id"])
		if n > int((best.get(bid, [0, 0]) as Array)[1]):
			best[bid] = [x, n]
	print("alberi del mondo di prova: %s; grandezze piccolo %d, medio %d, grande %d, antico %d; fuori dal loro bioma %d" % [
		per_species, per_size[0], per_size[1], per_size[2], per_size[3], wrong])
	var dc: bool = m.day.paused
	m.day.time = 0.5
	for bid in best:
		var x := int(best[bid][0])
		m.snap_to(Vector2i(x, world.surface[x] - 1))
		m.boons.add("bagliore", 3.0)
		await kit.seconds(0.7)
		await kit.save("100_alberi_" + bid)
	m.day.paused = dc
	if per_species.size() < 3 or per_size[0] == 0 or per_size[2] == 0 or wrong > 0:
		print("ATTENZIONE: gli alberi non sono vari come dovrebbero")
