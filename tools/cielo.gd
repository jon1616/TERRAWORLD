extends SceneTree
## La misura del cielo (Roadmap 16, voce 166): per alcuni semi genera il mondo con e senza i geni del cielo e conta
## le zone, le tessere delle isole, le isole alte e basse, gli osservatori, le correnti del cielo e i biomi. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/cielo.gd -- --semi 3
## Scrive prove/cielo.txt e lo stampa. «Cieli alti» deve dare almeno il doppio delle tessere del cielo.

const GENOMES := [[], ["cieli_alti"], ["cielo_firmamento"], ["senza_cielo"]]

var out := ""


func _init() -> void:
	var seeds := 3
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--semi" and i + 1 < args.size():
			seeds = int(args[i + 1])
	var base_tiles := 0.0
	for genes in GENOMES:
		var tot := {"zone": 0, "tessere": 0, "basse": 0, "alte": 0, "oss": 0, "correnti": 0}
		var biomes := {}
		for sd in range(1, seeds + 1):
			var w := World.new()
			WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": genes})
			tot["zone"] += w.sky.size()
			for z in w.sky:
				biomes[String(z["low"])] = int(biomes.get(String(z["low"]), 0)) + 1
				biomes[String(z["high"])] = int(biomes.get(String(z["high"]), 0)) + 1
				for x in range(int(z["x0"]), int(z["x1"])):
					for y in range(SkyData.TOP, int(z["base"]) + 1):
						if w.solid(x, y):
							tot["tessere"] += 1
			for e in w.gen_notes.get("isole_cielo", []):
				tot["basse" if String(e["band"]) == "basso" else "alte"] += 1
			tot["oss"] += (w.gen_notes.get("osservatori", []) as Array).size()
			for cu in w.gen_notes.get("correnti", []):
				if (cu as Dictionary).get("cielo", false):
					tot["correnti"] += 1
		var tiles := float(tot["tessere"]) / seeds
		if genes.is_empty():
			base_tiles = tiles
		_p("%-22s zone %.1f · tessere %6d (×%.2f) · isole basse %.1f, alte %.1f · osservatori %.1f · correnti %.1f" % [
			"nessun gene" if genes.is_empty() else ", ".join(genes), float(tot["zone"]) / seeds, roundi(tiles),
			tiles / maxf(base_tiles, 1.0), float(tot["basse"]) / seeds, float(tot["alte"]) / seeds, float(tot["oss"]) / seeds,
			float(tot["correnti"]) / seeds])
		_p("    biomi: %s" % biomes)
	var f := FileAccess.open("res://prove/cielo.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
