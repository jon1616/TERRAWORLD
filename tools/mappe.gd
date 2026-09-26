extends SceneTree
## Mappe dei mondi: genera N semi, salva mappe/mondo_<seme>.png (metà grandezza) e stampa i tempi di ogni passata
## e qualche conteggio (grotte, minerali, torce, alberi) per confrontare i semi tra loro.
##   Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1 [--intera]
## Voce 43, i geni: `--geni cavo,fungaie` dà a tutti i mondi quel genoma; `--caso` dà a ogni mondo un genoma a caso
## (con `--vigore N`, di base 5). Sotto ogni mondo si stampa il genoma, e alla fine la **misura della varietà**: la
## distanza tra ogni coppia di mondi (biomi, forma della superficie, grotte per strato, minerali, luoghi del
## sottosuolo, alberi e rovine), confrontata con il «rumore» di due mondi con lo stesso genoma e semi diversi.

const NAMES := ["biomi", "superficie", "grotte", "minerali", "sottosuolo", "vita"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var n := int(_arg(args, "--semi", "20"))
	var first := int(_arg(args, "--da", "1"))
	var full := "--intera" in args
	var random := "--caso" in args
	var vigor := int(_arg(args, "--vigore", "5"))
	var fixed := _arg(args, "--geni", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://mappe"))
	var totals := {}
	var prints: Array = []
	var genomes: Array = []
	for k in n:
		var sd := first + k
		var genes: Array = []
		if fixed != "":
			genes = Array(fixed.split(","))
		elif random:
			var rng := RandomNumberGenerator.new()
			rng.seed = sd * 7919
			genes = Genome.genes(Genome.roll(rng, vigor))
		var w := World.new()
		var t0 := Time.get_ticks_msec()
		var times := WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": vigor, "geni": genes})
		var ms := Time.get_ticks_msec() - t0
		for t in times:
			totals[t[0]] = int(totals.get(t[0], 0)) + int(t[1])
		var counts := _counts(w)
		print("seme %d: %d ms · aria sotto terra %d%% · radicite %d · legnoferro %d · ambra %d · cristalli %d · torce %d · alberi %d" % [
			sd, ms, counts["cave"], counts[TileDefs.RADICITE], counts[TileDefs.LEGNOFERRO], counts[TileDefs.AMBRA],
			counts[TileDefs.CRYSTAL], w.torches.size(), counts["trees"]])
		if not genes.is_empty():
			print("   geni: %s" % ", ".join(genes.map(func(g: String) -> String: return String(GenesData.info(g)["name"]))))
		prints.append(_fingerprint(w))
		genomes.append(genes)
		_save_map(w, "res://mappe/mondo_%d.png" % sd, full)
	var line := "media per passata:"
	for key in totals:
		line += " %s %d ms ·" % [key, int(totals[key]) / n]
	print(line)
	if n >= 2:
		_variety(prints, genomes, first, vigor)
	quit()


func _arg(args: PackedStringArray, key: String, def: String) -> String:
	var i := args.find(key)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else def


func _counts(w: World) -> Dictionary:
	var c := {TileDefs.RADICITE: 0, TileDefs.LEGNOFERRO: 0, TileDefs.AMBRA: 0, TileDefs.CRYSTAL: 0, "cave": 0, "trees": 0}
	var under := 0
	var air := 0
	for y in w.h:
		for x in w.w:
			var t := w.tiles[y * w.w + x]
			if c.has(t):
				c[t] += 1
			if y > w.surface[x] + 6:
				under += 1
				if t == TileDefs.AIR:
					air += 1
	c["cave"] = 100 * air / maxi(under, 1)
	for k in w.trees:
		c["trees"] += (w.trees[k] as Array).size()
	return c


## L'impronta di un mondo: una serie di numeri già in scala (circa 0-1 ciascuno), a gruppi (`NAMES`).
func _fingerprint(w: World) -> Array:
	var bio := []
	for b in BiomesData.BIOMES.size():
		bio.append(0.0)
	for x in w.w:
		bio[int(w.biomes[x])] += 1.0 / w.w
	var mean := 0.0
	for x in w.w:
		mean += w.surface[x]
	mean /= w.w
	var rough := 0.0
	var dev := 0.0
	for x in range(1, w.w):
		rough += absf(w.surface[x] - w.surface[x - 1])
		dev += absf(w.surface[x] - mean)
	var shape := [mean / 100.0, dev / w.w / 20.0, rough / w.w]
	var air := [0.0, 0.0, 0.0, 0.0, 0.0]
	var cells := [0.0, 0.0, 0.0, 0.0, 0.0]
	var ores := {TileDefs.RADICITE: 0.0, TileDefs.LEGNOFERRO: 0.0, TileDefs.AMBRA: 0.0, TileDefs.PALLIDITE: 0.0,
		TileDefs.TIZZONITE: 0.0, TileDefs.CRYSTAL: 0.0}
	var feat := {TileDefs.GRASS_SPORE: 0.0, TileDefs.GRASS_BRINA: 0.0, TileDefs.GRASS_CENERE: 0.0, TileDefs.RADICE: 0.0}
	for y in range(0, w.h, 2):
		for x in range(0, w.w, 2):
			var dep := y - w.surface[x]
			if dep < 8:
				continue
			var st := StrataData.index(x, dep, w.world_seed)
			var t := w.tiles[y * w.w + x]
			cells[st] += 1.0
			if t == TileDefs.AIR:
				air[st] += 1.0
			if ores.has(t):
				ores[t] += 1.0
			if feat.has(t):
				feat[t] += 1.0
	var caves := []
	for k in 5:
		caves.append(air[k] / maxf(cells[k], 1.0) * 3.0)
	var under := 0.0
	for k in 5:
		under += cells[k]
	var ore_v := []
	for t in ores:
		ore_v.append(ores[t] / under * 40.0)
	var feat_v := []
	for t in feat:
		feat_v.append(feat[t] / under * 60.0)
	var trees := 0.0
	for k in w.trees:
		trees += (w.trees[k] as Array).size()
	var life := [trees / 300.0, w.stations.values().count("scrigno") / 60.0]
	return [bio, shape, caves, ore_v, feat_v, life]


static func _dist(a: Array, b: Array) -> Array:
	var parts := []
	var tot := 0.0
	for g in a.size():
		var d := 0.0
		for i in (a[g] as Array).size():
			d += absf(float(a[g][i]) - float(b[g][i]))
		parts.append(d)
		tot += d
	return [tot, parts]


func _variety(prints: Array, genomes: Array, first: int, vigor: int) -> void:
	var ds := []
	var closest := [999.0, 0, 0]
	for i in prints.size():
		for j in range(i + 1, prints.size()):
			var d: float = _dist(prints[i], prints[j])[0]
			ds.append(d)
			if d < closest[0]:
				closest = [d, i, j]
	ds.sort()
	var mean := 0.0
	for d in ds:
		mean += d
	mean /= ds.size()
	# il rumore: lo stesso genoma del primo mondo con un seme diverso
	var w := World.new()
	WorldGen.generate(w, first + 9001, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": vigor, "geni": genomes[0]})
	var noise: Array = _dist(prints[0], _fingerprint(w))
	print("VARIETÀ: distanza media %.2f, minima %.2f (semi %d e %d), mediana %.2f; rumore dello stesso genoma %.2f (%s)" % [
		mean, closest[0], first + closest[1], first + closest[2], ds[ds.size() / 2], noise[0],
		", ".join(range(NAMES.size()).map(func(k: int) -> String: return "%s %.2f" % [NAMES[k], noise[1][k]]))])
	var worst: Array = _dist(prints[closest[1]], prints[closest[2]])[1]
	print("   i due mondi più simili differiscono per: %s" % ", ".join(range(NAMES.size()).map(func(k: int) -> String:
		return "%s %.2f" % [NAMES[k], worst[k]])))


func _save_map(w: World, path: String, full: bool) -> void:
	var im := Image.create_empty(w.w, w.h, false, Image.FORMAT_RGB8)
	var cols := {}
	for t in TileDefs.MAP_COLOR:
		cols[t] = Color(TileDefs.MAP_COLOR[t])
	var sky := Color("#8aa8e0")
	var wall := Color("#2a2420")
	for y in w.h:
		for x in w.w:
			var i := y * w.w + x
			var t := w.tiles[i]
			var c: Color = cols[t] if t != TileDefs.AIR else (wall if w.walls[i] != 0 else sky)
			im.set_pixel(x, y, c)
	for t in w.torches:
		im.set_pixelv(t, Color("#ffcc40"))
	im.set_pixelv(w.spawn, Color("#ff2020"))
	if not full:
		im.resize(w.w / 2, w.h / 2, Image.INTERPOLATE_BILINEAR)
	im.save_png(ProjectSettings.globalize_path(path))
