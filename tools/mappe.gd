extends SceneTree
## Mappe dei mondi: genera N semi, salva mappe/mondo_<seme>.png (metà grandezza) e stampa i tempi di ogni passata
## e qualche conteggio (grotte, minerali, torce, alberi) per confrontare i semi tra loro.
##   Godot_console.exe --headless --path . --script res://tools/mappe.gd -- --semi 20 --da 1 [--intera]
## Voce 43, i geni: `--geni cavo,fungaie` dà a tutti i mondi quel genoma; `--caso` dà a ogni mondo un genoma a caso
## (con `--vigore N`, di base 5). Sotto ogni mondo si stampa il genoma, e alla fine la **misura della varietà**: la
## distanza tra ogni coppia di mondi (biomi, forma della superficie, grotte per strato, minerali, luoghi del
## sottosuolo, alberi e rovine), confrontata con il «rumore» di due mondi con lo stesso genoma e semi diversi.
## Voce 439 (8 ott 2026, piano «Il generatore eccellente», GENERATORE.md): vigore 1 di base (a 5 i minerali risultavano
## gonfiati), il rumore è la media di `--rumore N` coppie (10; prima era un confronto solo), `--lista 1,7,13` per semi
## scelti, e `--prima <cartella>` salva in prove/<cartella>/ la mappa intera di ogni seme, i ritagli (cielo, superficie,
## sottosuolo) e `numeri.txt` con le misure: il riferimento con cui si confronta ogni voce del piano.

const NAMES := ["biomi", "superficie", "grotte", "minerali", "sottosuolo", "vita", "sagoma"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var n := int(_arg(args, "--semi", "20"))
	var first := int(_arg(args, "--da", "1"))
	var full := "--intera" in args
	var random := "--caso" in args
	var vigor := int(_arg(args, "--vigore", "1"))
	var noise_n := int(_arg(args, "--rumore", "10"))
	var ref := _arg(args, "--prima", "")
	var seeds: Array = []
	var lista := _arg(args, "--lista", "")
	if lista != "":
		for x in lista.split(",", false):
			seeds.append(int(x))
		n = seeds.size()
	else:
		for k in n:
			seeds.append(first + k)
	var report: Array[String] = []
	if ref != "":
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove/" + ref))
	var fixed := _arg(args, "--geni", "")
	var lost := _arg(args, "--perduto", "")          # Roadmap 21: `--perduto sommerso` o `--perduto tutti` (uno per mondo)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://mappe"))
	var totals := {}
	var prints: Array = []
	var genomes: Array = []
	for k in n:
		var sd: int = seeds[k]
		var genes: Array = []
		if fixed != "":
			genes = Array(fixed.split(","))
		elif random:
			var rng := RandomNumberGenerator.new()
			rng.seed = sd * 7919
			genes = Genome.genes(Genome.roll(rng, vigor))
		var params := {"vigore": vigor, "geni": genes}
		if lost != "":
			var lid := String(LostGardensData.ORDER[k % 4]) if lost == "tutti" else lost
			var lg := LostGardensData.genome(lid)
			params = {"vigore": int(lg["vigore"]), "geni": lg["geni"], "perduto": lid}
			genes = lg["geni"]
		var w := World.new()
		var t0 := Time.get_ticks_msec()
		var times := WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, params)
		var ms := Time.get_ticks_msec() - t0
		for t in times:
			totals[t[0]] = int(totals.get(t[0], 0)) + int(t[1])
		var counts := _counts(w)
		print("seme %d: %d ms · aria sotto terra %d%% · radicite %d · legnoferro %d · ambra %d · cristalli %d · torce %d · alberi %d" % [
			sd, ms, counts["cave"], counts[TileDefs.RADICITE], counts[TileDefs.LEGNOFERRO], counts[TileDefs.AMBRA],
			counts[TileDefs.CRYSTAL], w.torches.size(), counts["trees"]])
		var col: Dictionary = w.gen_notes.get("collaudo", {})
		var probs: Array = col.get("problemi", [])
		var fixd: Array = col.get("riparati", [])
		print("   collaudo: %d problemi, %d riparazioni%s" % [probs.size(), fixd.size(),
			("\n      " + "\n      ".join(PackedStringArray(probs + fixd))) if not (probs + fixd).is_empty() else ""])
		if not genes.is_empty():
			print("   geni: %s" % ", ".join(genes.map(func(g: String) -> String: return String(GenesData.info(g)["name"]))))
		var wonders := []
		for e in w.gen_notes.get("meraviglie", []):
			wonders.append(String(e["k"]))
		print("   meraviglie: %s" % ", ".join(PackedStringArray(wonders)))       # Roadmap 23, voce 237
		if w.gen_notes.has("perduto"):
			print("   Giardino perduto: %s" % str(w.gen_notes["perduto"]))
		prints.append(_fingerprint(w))
		genomes.append(genes)
		_save_map(w, "res://mappe/mondo_%d.png" % sd, full)
		if ref != "":
			report.append(_measure(w, sd, ms, counts))
			_save_ref(w, ref, sd)
	var line := "media per passata:"
	for key in totals:
		line += " %s %d ms ·" % [key, int(totals[key]) / n]
	print(line)
	if n >= 2:
		report.append(_variety(prints, genomes, seeds, vigor, noise_n))
	if ref != "":
		var f := FileAccess.open(ProjectSettings.globalize_path("res://prove/%s/numeri.txt" % ref), FileAccess.WRITE)
		f.store_string("\n".join(report) + "\n")
		f.close()
		print("riferimento: prove/%s/ (mappe, ritagli, numeri.txt)" % ref)
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
	var feat := {TileDefs.GRASS_SPORE: 0.0, TileDefs.GRASS_BRINA: 0.0, TileDefs.GRASS_CENERE: 0.0, TileDefs.RADICE: 0.0,
		40: 0.0, 41: 0.0, 42: 0.0, 43: 0.0}                # voce 450: i pavimenti dei biomi del sottosuolo scritti come file
	for u in BiomesData.UNDER:
		feat[int(u["floor"])] = 0.0                     # voce 464: tutti i pavimenti dei biomi del sottosuolo
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
	# voce 464: la grande scala, con misure che non dipendono dal caso del seme: colonne di mare, colonne nei ripiani lunghi
	# (terrazze), colonne molto sotto la mediana (canyon), colonne con roccia subito sopra la terra (pilastri) e con un
	# tetto spesso (guscio)
	var hs := Array(w.surface)
	hs.sort()
	var med := int(hs[hs.size() / 2])
	var sea := 0.0
	var flat := 0.0
	var deep := 0.0
	var tall := 0.0
	var roof := 0.0
	var run := 0
	for x in w.w:
		var s := int(w.surface[x])
		if w.liq(x, s - 1) > 0:
			sea += 1.0
		run = run + 1 if x > 0 and s == int(w.surface[x - 1]) else 0
		if run >= 8:
			flat += 1.0
		if s > med + 70:
			deep += 1.0
		if w.solid(x, s - 12) and w.solid(x, s - 20):
			tall += 1.0
		if w.solid(x, s - 50) and w.solid(x, s - 70):
			roof += 1.0
	var big := [sea / w.w * 4.0, flat / w.w * 2.0, deep / w.w * 6.0, tall / w.w * 20.0, roof / w.w * 2.0]
	return [bio, shape, caves, ore_v, feat_v, life, big]


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


func _variety(prints: Array, genomes: Array, seeds: Array, vigor: int, noise_n: int) -> String:
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
	# il rumore: lo stesso genoma di un mondo con un seme diverso, in media su più coppie (voce 439: uno solo era un
	# campione troppo piccolo per dire se due Semi si somigliano)
	var noise := [0.0, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]]
	var k_n := mini(noise_n, prints.size())
	for i in k_n:
		var w := World.new()
		WorldGen.generate(w, int(seeds[i]) + 9001, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": vigor, "geni": genomes[i]})
		var d: Array = _dist(prints[i], _fingerprint(w))
		noise[0] += float(d[0]) / k_n
		for g in NAMES.size():
			noise[1][g] += float(d[1][g]) / k_n
	var line := "VARIETÀ: distanza media %.2f, minima %.2f (semi %d e %d), mediana %.2f; rumore dello stesso genoma %.2f su %d coppie (%s); rapporto minima/rumore %.2f" % [
		mean, closest[0], int(seeds[closest[1]]), int(seeds[closest[2]]), ds[ds.size() / 2], noise[0], k_n,
		", ".join(range(NAMES.size()).map(func(k: int) -> String: return "%s %.2f" % [NAMES[k], noise[1][k]])),
		closest[0] / maxf(noise[0], 0.001)]
	# voce 464: quante coppie stanno sopra il doppio del rumore (la coppia più vicina, con 30 genomi a caso, spesso ha
	# quasi lo stesso genoma: superficie e forma uguali)
	var over := ds.filter(func(d: float) -> bool: return d >= 2.0 * float(noise[0])).size()
	line += "; coppie oltre il doppio del rumore %d su %d (%.0f%%); media/rumore %.2f" % [over, ds.size(), 100.0 * over / ds.size(),
		mean / maxf(noise[0], 0.001)]
	print(line)
	var worst: Array = _dist(prints[closest[1]], prints[closest[2]])[1]
	var line2 := "   i due mondi più simili differiscono per: %s" % ", ".join(range(NAMES.size()).map(func(k: int) -> String:
		return "%s %.2f" % [NAMES[k], worst[k]]))
	print(line2)
	return line + "\n" + line2


## Le misure di un mondo per il riferimento del piano (voce 439): una riga per seme, da confrontare voce per voce.
func _measure(w: World, sd: int, ms: int, counts: Dictionary) -> String:
	var air := [0, 0, 0, 0, 0]
	var cells := [0, 0, 0, 0, 0]
	var water := 0
	var sky_solid := 0
	var sky_air := 0
	var top := w.h
	for x in w.w:
		top = mini(top, int(w.surface[x]))
	for y in w.h:
		for x in w.w:
			var i := y * w.w + x
			var t := w.tiles[i]
			var dep := y - int(w.surface[x])
			if dep < 0:
				if t == TileDefs.AIR:
					sky_air += 1
				else:
					sky_solid += 1
				continue
			if dep < 8:
				continue
			var st := StrataData.index(x, dep, w.world_seed)
			cells[st] += 1
			if t == TileDefs.AIR:
				air[st] += 1
			if w.liquid[i] & 15 > 0:
				water += 1
	var pct := []
	for k in 5:
		pct.append("%d%%" % (100 * air[k] / maxi(cells[k], 1)))
	var ores := []
	for o in TileDefs.ORES:
		var t: int = int(o["type"])
		var nn := w.tiles.count(t)
		if nn > 0:
			ores.append("%s %d" % [TileDefs.NAMES.get(t, str(t)), nn])
	var isles: Array = w.gen_notes.get("isole_cielo", [])
	var biomes := {}
	for x in w.w:
		var b := String(BiomesData.BIOMES[int(w.biomes[x])]["id"])
		biomes[b] = int(biomes.get(b, 0)) + 1
	return "seme %d · %d ms · %d×%d · superficie più alta %d, media %d\n  aria per strato %s · celle di liquido sotto %d\n  cielo: %d celle solide, %d d'aria (%.2f%%), %d isole, %d zone\n  minerali: %s · cristalli %d\n  biomi: %s" % [
		sd, ms, w.w, w.h, top, _mean_surface(w), " ".join(PackedStringArray(pct)), water, sky_solid, sky_air,
		100.0 * sky_solid / maxf(sky_solid + sky_air, 1.0), isles.size(), (w.gen_notes.get("cielo", []) as Array).size(),
		", ".join(PackedStringArray(ores)), counts[TileDefs.CRYSTAL], str(biomes)]


func _mean_surface(w: World) -> int:
	var s := 0
	for x in w.w:
		s += int(w.surface[x])
	return s / w.w


## Il riferimento visivo: la mappa intera e tre ritagli a grandezza vera (cielo sopra la superficie più alta, la fascia
## della superficie, il sottosuolo fino al Fondo) di un tratto di 900 colonne attorno alla partenza.
func _save_ref(w: World, ref: String, sd: int) -> void:
	var base := "res://prove/%s/mondo_%d" % [ref, sd]
	_save_map(w, base + ".png", true)
	var im := Image.load_from_file(ProjectSettings.globalize_path(base + ".png"))
	var top := w.h
	for x in w.w:
		top = mini(top, int(w.surface[x]))
	var x0 := clampi(w.spawn.x - 450, 0, w.w - 900)
	var s := int(w.surface[w.spawn.x])
	for part in [["cielo", 0, top + 10], ["superficie", maxi(s - 60, 0), mini(s + 80, w.h)], ["sottosuolo", mini(s + 80, w.h - 1), w.h]]:
		var y0: int = part[1]
		var y1: int = part[2]
		if y1 - y0 < 4:
			continue
		im.get_region(Rect2i(x0, y0, 900, y1 - y0)).save_png(ProjectSettings.globalize_path("%s_%s.png" % [base, part[0]]))


const LIQ_COLORS := [Color("#3a6fb8"), Color("#3ccfc0"), Color("#e0602a"), Color("#3a6fb8")]


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
			var lq := w.liquid[i]
			if t == TileDefs.AIR and lq & 15 > 0:
				c = LIQ_COLORS[(lq >> 4) & 3]                  # voce 461: i liquidi (il mare si vede)
			im.set_pixel(x, y, c)
	for t in w.torches:
		im.set_pixelv(t, Color("#ffcc40"))
	im.set_pixelv(w.spawn, Color("#ff2020"))
	if not full:
		im.resize(w.w / 2, w.h / 2, Image.INTERPOLATE_BILINEAR)
	im.save_png(ProjectSettings.globalize_path(path))
