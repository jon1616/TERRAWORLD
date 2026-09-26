class_name TestsGenes
extends RefCounted
## Prove del piano «Il Giardiniere dei mondi» (voci 43-48). Voce 43: i geni del generatore cambiano davvero il mondo
## (tre mondi piccoli dallo stesso seme: semplice, «cavo» e «compatto» con altri geni a confronto), un Seme trovato ha
## sempre un gene di forma, grotte o sottosuolo; una fungaia e un fiume di brace copiati nel mondo di prova e
## fotografati (80_fungaia, 81_fiume_brace).


const S := 16
const W := 1400                        # mondi piccoli: la prova resta svelta

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	await generator()


func _census(w: World) -> Dictionary:
	var under := 0
	var air := 0
	for y in w.h:
		for x in range(0, w.w, 2):
			if y > w.surface[x] + 8:
				under += 1
				if w.tiles[y * w.w + x] == TileDefs.AIR:
					air += 1
	var rough := 0
	for x in range(1, w.w):
		rough += absi(w.surface[x] - w.surface[x - 1])
	var trees := 0
	for k in w.trees:
		trees += (w.trees[k] as Array).size()
	var ore := 0
	for t in w.tiles:
		if t == TileDefs.RADICITE:
			ore += 1
	return {"grotte": roundi(100.0 * air / maxi(under, 1)), "salti": rough, "alberi": trees, "radicite": ore,
		"sottosuolo": w.gen_notes.get("sottosuolo", {}), "avvizzimento": (w.gen_notes.get("avvizzimento", []) as Array).size()}


func generator() -> void:
	var sd := 5150
	var plain := World.new()
	WorldGen.generate(plain, sd, W, WorldGen.HEIGHT, {"vigore": 3})
	var a := World.new()
	WorldGen.generate(a, sd, W, WorldGen.HEIGHT, {"vigore": 3,
		"geni": ["sporangio", "montagne", "cavo", "fungaie", "radicite_diffusa", "rigoglioso", "sano"]})
	var b := World.new()
	WorldGen.generate(b, sd, W, WorldGen.HEIGHT, {"vigore": 3,
		"geni": ["cenere", "pianure", "compatto", "fiumi_brace", "spoglio", "avvizzito"]})
	var cp := _census(plain)
	var ca := _census(a)
	var cb := _census(b)
	print("geni del generatore: semplice %s · A (montagne, cavo, fungaie, radicite diffusa, rigoglioso, sano) %s · B (pianure, compatto, fiumi di brace, spoglio, avvizzito) %s" % [cp, ca, cb])
	var ok: bool = int(ca["grotte"]) > int(cp["grotte"]) and int(cb["grotte"]) < int(cp["grotte"]) \
		and int(ca["salti"]) > int(cb["salti"]) and int(ca["alberi"]) > int(cb["alberi"]) \
		and int(ca["radicite"]) > int(cp["radicite"]) and int(ca["sottosuolo"].get("fungaie", 0)) > 0 \
		and int(cb["sottosuolo"].get("fiumi_brace", 0)) > 0 and int(ca["avvizzimento"]) == 0 \
		and int(cb["avvizzimento"]) > int(cp["avvizzimento"])
	print("i geni cambiano il mondo come dicono: %s" % ("sì" if ok else "NO"))
	if not ok:
		print("ATTENZIONE: un gene del generatore non ha l'effetto promesso")
	# un Seme trovato ha sempre un gene che cambia la forma del mondo
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var shaped := 0
	for k in 40:
		var gs := Genome.genes(Genome.roll(rng, 1 + k % 8))
		if gs.any(func(g: String) -> bool: return GenesData.cat_of(g) in Genome.SHAPE_CATS):
			shaped += 1
	print("Semi trovati con un gene di forma, grotte o sottosuolo: %d su 40" % shaped)
	# le foto: una fungaia e un fiume di brace copiati lontano dalla partenza del mondo di prova
	await _photo(a, "fungaie", "80_fungaia", Vector2i(420, 0))
	await _photo(b, "fiumi_brace", "81_fiume_brace", Vector2i(-420, 0))


## Copia il primo luogo di quel tipo dal mondo generato al mondo di prova (stessa profondità sotto la superficie,
## spostato di `shift` colonne dalla partenza), ci porta il Germogliato con la luce e fotografa.
func _photo(src: World, what: String, photo: String, shift: Vector2i) -> void:
	var list: Array = src.gen_notes.get("sottosuolo_pos", {}).get(what, [])
	if list.is_empty():
		print("ATTENZIONE: nessun luogo «%s» da fotografare" % what)
		return
	var p: Vector2i = list[0]
	var dep: int = p.y - src.surface[p.x]
	var to := Vector2i(world.spawn.x + shift.x, 0)
	to.y = world.surface[to.x] + dep
	var half := Vector2i(44, 20)
	for dy in range(-half.y, half.y + 1):
		for dx in range(-half.x, half.x + 1):
			var s := p + Vector2i(dx, dy)
			var d := to + Vector2i(dx, dy)
			if not src.inside(s.x, s.y) or not world.inside(d.x, d.y):
				continue
			var si := s.y * src.w + s.x
			var di := d.y * world.w + d.x
			world.tiles[di] = src.tiles[si]
			world.walls[di] = src.walls[si]
			world.decor[di] = src.decor[si]
	for dy in range(-half.y, half.y + 1, 8):
		for dx in range(-half.x, half.x + 1, 8):
			m.view.refresh_around(to + Vector2i(dx, dy))
	# il Germogliato in un punto d'aria vicino al centro, con la Lanterna per vedere
	var stand := to
	for r in 20:
		if not world.solid(to.x, to.y + r) and world.solid(to.x, to.y + r + 1):
			stand = Vector2i(to.x, to.y + r)
			break
	m.snap_to(stand)
	m.boons.add("bagliore", 6.0)             # nel buio vero la foto non mostrerebbe nulla
	m.boons.add("vista", 6.0)
	m.light.dirty = true
	await kit.seconds(1.2)
	await kit.save(photo)
	m.boons.active.erase("bagliore")
	m.boons.active.erase("vista")

