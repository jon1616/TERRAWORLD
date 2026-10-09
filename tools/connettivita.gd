extends SceneTree
## La connettività dei mondi (voce 471, Roadmap 61): con `ReachMap`, dalla partenza e senza scavare, quanta parte dei posti
## dove si sta in piedi si raggiunge in ogni strato e in ogni fascia del cielo, quanti scrigni e punti di riferimento, e
## quanta strada serve (i passi della ricerca, mediana). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/connettivita.gd -- --semi 3
## Scrive prove/connettivita.txt.

const NAMES := ["Superficie", "Sottobosco", "Caverne", "Profondità", "Fondo"]

var out := ""


func _init() -> void:
	var seeds := 3
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--semi" and i + 1 < args.size():
			seeds = int(args[i + 1])
	for sd in range(1, seeds + 1):
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": []})
		var t0 := Time.get_ticks_msec()
		var r := ReachMap.of(w, w.gen_notes.get("correnti", []))
		_measure(w, sd, r, Time.get_ticks_msec() - t0)
	var f := FileAccess.open("res://prove/connettivita.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _measure(w: World, sd: int, r: ReachMap, ms: int) -> void:
	var st_all := [0, 0, 0, 0, 0]
	var st_got := [0, 0, 0, 0, 0]
	var sky := {"basso": [0, 0], "medio": [0, 0], "alto": [0, 0]}
	for y in range(1, w.h - 1):
		for x in w.w:
			var i := y * w.w + x
			if r.stand[i] == 0:
				continue
			var dep := y - int(w.surface[x])
			if dep < 0:
				var bd := SkyData.band_at(w, x, y)
				if sky.has(bd) and w.solid(x, y + 1):
					sky[bd][0] += 1
					if r.dist[i] >= 0:
						sky[bd][1] += 1
				continue
			var k := StrataData.index(x, dep, w.world_seed)
			st_all[k] += 1
			if r.dist[i] >= 0:
				st_got[k] += 1
	var chests := 0
	var chests_got := 0
	var steps := []
	for o in w.stations:
		if ChestsData.is_chest(String(w.stations[o])):
			chests += 1
			var d := r.near(o, 3)
			if d >= 0:
				chests_got += 1
				steps.append(d)
	steps.sort()
	var refs := 0
	for rf in w.gen_notes.get("riferimenti", []):
		if r.near(Vector2i(int(rf[0]), int(rf[1])), 6) >= 0:
			refs += 1
	var cols := 0
	for x in w.w:
		var s := int(w.surface[x])
		for y in range(s - 8, s + 9):
			if r.at(x, y) >= 0:
				cols += 1
				break
	_p("seme %d (ricerca %d ms, %d posti raggiunti): la superficie si percorre a piedi per il %.0f%% delle colonne" % [sd, ms,
		r.reached, 100.0 * cols / w.w])
	for k in 5:
		_p("   %-11s %5.1f%% dei posti dove stare (%d su %d)" % [NAMES[k], 100.0 * int(st_got[k]) / maxi(int(st_all[k]), 1),
			int(st_got[k]), int(st_all[k])])
	for bd in sky:
		_p("   cielo %-6s %5.1f%% dei posti sulle isole e i continenti (%d su %d)" % [bd,
			100.0 * int(sky[bd][1]) / maxi(int(sky[bd][0]), 1), int(sky[bd][1]), int(sky[bd][0])])
	_p("   scrigni raggiunti %d su %d (%.0f%%), passi alla mediana %d · punti di riferimento %d su %d" % [chests_got, chests,
		100.0 * chests_got / maxi(chests, 1), int(steps[steps.size() / 2]) if not steps.is_empty() else -1, refs,
		(w.gen_notes.get("riferimenti", []) as Array).size()])


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
