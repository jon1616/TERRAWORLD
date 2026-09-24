class_name TestsStrata
extends RefCounted
## Prove degli strati di profondità: in ogni strato sotto la superficie si cerca una grotta con il pavimento vicino alla
## colonna di partenza, ci si porta il Germogliato e si fa una foto; si controlla che la scritta dello strato compaia e
## che il chiarore di fondo prenda il colore dello strato. Si contano anche le tessere di ogni roccia.

const S := 16

var kit: TestKit
var world: World


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world


## Una cella d'aria con il pavimento, a metà dello strato k, vicina alla colonna x0 (cerca allargandosi).
func _spot_in(k: int, x0: int) -> Vector2i:
	var t0 := StrataData.top(k)
	var t1 := StrataData.top(k + 1) if k + 1 < StrataData.STRATA.size() else t0 + 300
	for r in range(0, 600, 3):
		for side in [1, -1]:
			var x: int = x0 + side * r
			if x < 2 or x > world.w - 3:
				continue
			var s := world.surface[x]
			for dep in range(t0 + (t1 - t0) / 4, t0 + (t1 - t0) * 3 / 4):
				var y := s + dep
				if y >= world.h - 8:
					break
				if StrataData.at(world, x, y) == k and not world.solid(x, y) and not world.solid(x, y - 1) \
						and not world.solid(x, y - 2) and world.solid(x, y + 1) and not world.solid(x + 1, y) \
						and not world.solid(x - 1, y) and (k != 1 or _roots_near(x, y)):
					return Vector2i(x, y)
	return Vector2i(-1, -1)


## Nel Sottobosco la foto deve mostrare una radice gigante.
func _roots_near(x: int, y: int) -> bool:
	var n := 0
	for dy in range(-6, 7):
		for dx in range(-8, 9):
			if world.tile(x + dx, y + dy) == TileDefs.RADICE:
				n += 1
	return n >= 12


func run() -> void:
	var m := kit.m
	var names := ["", "17_sottobosco", "18_caverne", "19_linfa", "20_fondo"]
	for k in range(1, StrataData.STRATA.size()):
		var c := _spot_in(k, world.spawn.x + 40)
		if c.x < 0:
			print("strato %s: NESSUNA grotta trovata" % StrataData.STRATA[k]["name"])
			continue
		m.snap_to(c)
		await kit.seconds(2.5)
		var amb: Color = m.light.ambient
		var goal: Color = StrataData.STRATA[k]["ambient"]
		print("strato %s a profondità %d: scritta %s, chiarore %s" % [StrataData.STRATA[k]["name"],
			world.depth(c.x, c.y), "sì" if m.depth_watch.stratum == k else "NO",
			"giusto" if absf(amb.r - goal.r) + absf(amb.g - goal.g) + absf(amb.b - goal.b) < 0.03 else "NON ancora"])
		await kit.save(names[k])
	var count := {}
	for t in world.tiles:
		if t != TileDefs.AIR:
			count[t] = int(count.get(t, 0)) + 1
	var line := "tessere:"
	for t in [TileDefs.RADICE, TileDefs.SCISTO, TileDefs.VUOTITE]:
		line += " %s %d ·" % [TileDefs.NAMES[t], int(count.get(t, 0))]
	print(line)
