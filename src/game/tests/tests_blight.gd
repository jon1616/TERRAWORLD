class_name TestsBlight
extends RefCounted
## Prove dell'Avvizzimento (voce 18): zone malate nel mondo nuovo, contagio mentre il Guardiano dorme, ritiro quando è
## curato, purificazione con il Seme di muschio; foto 35_avvizzimento (scritta «Terre avvizzite»).

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var b: Blight = m.blight
	while not b.ready():
		await kit.frames(1)
	var n0 := b.cells.size()
	var grown := b.spread(60)
	var receded := b.recede(30)
	print("Avvizzimento: %d tessere malate all'inizio, contagio +%d, ritiro -%d (ora %d)" % [n0, grown, receded, b.cells.size()])
	# una colonna avvizzita in superficie, la più vicina alla partenza
	var x := -1
	for r in range(0, world.w):
		for side in [1, -1]:
			var xx: int = world.spawn.x + side * r
			if x < 0 and xx > 10 and xx < world.w - 10 and Blight.surface_blighted(world, xx) \
					and Blight.surface_blighted(world, xx - 8) and Blight.surface_blighted(world, xx + 8):
				x = xx
		if x >= 0:
			break
	if x < 0:
		print("Avvizzimento: NESSUNA zona in superficie")
		return
	m.snap_to(Vector2i(x, world.surface[x] - 1))
	await kit.seconds(2.0)
	print("terre avvizzite: scritta %s" % ("sì" if m.depth_watch.biome == DepthWatch.BLIGHT else "NO"))
	await kit.save("35_avvizzimento")
	m.character.bisaccia.add("seme_muschio", 1)
	var before := b.cells.size()
	var ok := b.use_seed(Vector2i(x + 2, world.surface[x]))
	print("Seme di muschio: usato %s, tessere malate da %d a %d" % ["sì" if ok else "NO", before, b.cells.size()])
	await kit.seconds(1.0)
	await kit.save("36_purificato")
