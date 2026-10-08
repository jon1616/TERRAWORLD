extends SceneTree
## La misura del cielo (Roadmap 16, voce 166; rifatta con la voce 447, Roadmap 56 «Il cielo grande»): per alcuni semi
## genera il mondo e, per ognuna delle tre fasce (basso, medio, alto), misura:
##  - la **terra calpestabile**: quante colonne della fascia hanno almeno un punto dove stare in piedi (in % della
##    larghezza delle zone);
##  - isole, continenti, mari di nuvole, luoghi dei Seminatori, correnti del cielo;
##  - la **raggiungibilità**: una ricerca di percorso dalla superficie, senza ali né scavo (si cammina, si salta fino a 3
##    tessere in su e 4 di lato, si nuota, si cade, si passa da sotto le passerelle, si sale con le correnti): quante isole e quanti
##    continenti si raggiungono.
## Poi i geni del cielo a confronto (tessere solide). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/cielo.gd -- --semi 3
## Scrive prove/cielo.txt e lo stampa.

const GENOMES := [[], ["cieli_alti"], ["cielo_firmamento"], ["senza_cielo"]]
const JUMP_UP := 3
const JUMP_SIDE := 4

var out := ""


func _init() -> void:
	var seeds := 3
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--semi" and i + 1 < args.size():
			seeds = int(args[i + 1])
	_p("== Le tre fasce (nessun gene), %d semi" % seeds)
	for sd in range(1, seeds + 1):
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": []})
		_bands(w, sd)
	_p("\n== I geni del cielo (tessere solide nel cielo, media dei semi)")
	var base_tiles := 0.0
	for genes in GENOMES:
		var tiles := 0.0
		var zones := 0
		for sd in range(1, seeds + 1):
			var w := World.new()
			WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": genes})
			zones += w.sky.size()
			for z in w.sky:
				for x in range(int(z["x0"]), int(z["x1"])):
					for y in range(SkyData.TOP, int(z["base"]) + 1):
						if w.solid(x, y):
							tiles += 1.0
		tiles /= seeds
		if genes.is_empty():
			base_tiles = tiles
		_p("%-22s zone %.1f · tessere %6d (×%.2f)" % ["nessun gene" if genes.is_empty() else ", ".join(genes),
			float(zones) / seeds, roundi(tiles), tiles / maxf(base_tiles, 1.0)])
	var f := FileAccess.open("res://prove/cielo.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _bands(w: World, sd: int) -> void:
	var reach := _reach(w)
	var cols := {"basso": 0, "medio": 0, "alto": 0}
	var width := 0
	for z in w.sky:
		width += int(z["x1"]) - int(z["x0"])
		for band in SkyData.BANDS:
			var rows := SkyData.band_rows(z, band)
			if rows.is_empty():
				continue
			for x in range(int(z["x0"]), int(z["x1"])):
				for y in range(int(rows[0]), int(rows[1]) + 1):
					if _stand(w, x, y):
						cols[band] += 1
						break
	var isles := {"basso": [0, 0], "medio": [0, 0], "alto": [0, 0]}
	var conts := [0, 0]
	for e in w.gen_notes.get("isole_cielo", []):
		var ok := false
		var x := int(e["x"])
		for dx in range(-int(e["half"]), int(e["half"]) + 1):
			for dy in range(-6, 4):
				if reach.has(Vector2i(x + dx, int(e["top"]) + dy)):
					ok = true
		if e.get("continente", false):
			conts[0] += 1
			conts[1] += 1 if ok else 0
		else:
			isles[String(e["band"])][0] += 1
			isles[String(e["band"])][1] += 1 if ok else 0
	var cur := 0
	for cu in w.gen_notes.get("correnti", []):
		if (cu as Dictionary).get("cielo", false):
			cur += 1
	var line := "seme %d: %d zone · correnti del cielo %d · luoghi dei Seminatori %d · continenti %d (raggiunti senza ali %d)" % [
		sd, w.sky.size(), cur, (w.gen_notes.get("luoghi_cielo", []) as Array).size(), conts[0], conts[1]]
	_p(line)
	for band in SkyData.BANDS:
		_p("   %-6s terra calpestabile in %3d%% delle colonne · isole %3d (raggiunte senza ali %3d)" % [band,
			100 * int(cols[band]) / maxi(width, 1), int(isles[band][0]), int(isles[band][1])])


## Si sta in piedi in (x, y): due celle d'aria e sotto un appoggio (blocco o passerella).
func _stand(w: World, x: int, y: int) -> bool:
	return w.inside(x, y) and y > 1 and not w.solid(x, y) and not w.solid(x, y - 1) \
		and (w.solid(x, y + 1) or w.plat(x, y + 1))


## Dove si atterra cadendo da (x, y): il primo appoggio sotto (o null se si esce dal mondo).
func _fall(w: World, x: int, y: int) -> Variant:
	if not w.inside(x, y) or w.solid(x, y):
		return null
	var yy := y
	while yy < w.h - 2:
		if w.solid(x, yy + 1) or w.plat(x, yy + 1):
			return Vector2i(x, yy) if not w.solid(x, yy - 1) else null
		yy += 1
	return null


## I posti raggiungibili dalla superficie (che si percorre comunque, scavando dove serve): il cielo e la superficie
## stessa. La ricerca parte da ogni colonna della superficie.
func _reach(w: World) -> Dictionary:
	var currents := []
	for cu in w.gen_notes.get("correnti", []):
		currents.append(cu)
	var seen := {}
	var queue: Array = []
	for x in range(1, w.w - 1):
		var f: Variant = _fall(w, x, int(w.surface[x]) - 1)
		if f != null and not seen.has(f):
			seen[f] = true
			queue.append(f)
	var head := 0
	while head < queue.size():
		var p: Vector2i = queue[head]
		head += 1
		var next := []
		# camminare e cadere dai lati
		for dx in [-1, 1]:
			for dy in [0, -1]:
				if _stand(w, p.x + dx, p.y + dy):
					next.append(Vector2i(p.x + dx, p.y + dy))
			var f: Variant = _fall(w, p.x + dx, p.y)
			if f != null:
				next.append(f)
		# saltare (si passa da sotto le passerelle); nell'acqua si nuota in su
		var up := JUMP_UP + (6 if w.liq(p.x, p.y) > 0 or w.liq(p.x, p.y - 1) > 0 else 0)
		for dy in range(1, up + 1):
			for dx in range(-JUMP_SIDE, JUMP_SIDE + 1):
				if _stand(w, p.x + dx, p.y - dy):
					next.append(Vector2i(p.x + dx, p.y - dy))
		# le correnti: dentro la colonna si sale fino in cima
		for cu in currents:
			if absi(p.x - int(cu["x"])) <= int(cu.get("w", 1)) + 1 and p.y >= int(cu["y0"]) - 2 and p.y <= int(cu["y1"]) + 2:
				for dx in range(-4, 5):
					for dy in range(-4, 3):
						var q := Vector2i(int(cu["x"]) + dx, int(cu["y0"]) + dy)
						if _stand(w, q.x, q.y):
							next.append(q)
					var f2: Variant = _fall(w, int(cu["x"]) + dx, int(cu["y0"]))       # in cima, un passo di lato e giù
					if f2 != null:
						next.append(f2)
		for q in next:
			if not seen.has(q) and q.y <= int(w.surface[clampi(q.x, 0, w.w - 1)]) + 25:     # stagni e conche, non le grotte
				seen[q] = true
				queue.append(q)
	return seen


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
