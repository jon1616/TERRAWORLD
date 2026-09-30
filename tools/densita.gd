extends SceneTree
## Quanto è pieno un mondo, strato per strato (30 set 2026, l'utente dopo un'ora di gioco: «poco da trovare, pochi
## mostri»). Per ogni strato: lo spazio d'aria (grotte), le cose da raccogliere (decorazioni che lasciano qualcosa,
## scrigni e stazioni trovate, tessere preziose) ogni 1000 celle d'aria, e le creature: tetto, ogni quanto si prova a
## farne nascere una e quante prove riescono (la stessa geometria di `Fauna.try_spawn`: un punto a 28-44 tessere, uno
## spazio 2×2 libero con il pavimento entro 12 tessere sotto). → prove/densita.txt
## Uso: -- --semi 3 --vigore 1

var w: World


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var seeds := 3
	var vigor := 1
	for i in args.size():
		if args[i] == "--semi":
			seeds = int(args[i + 1])
		elif args[i] == "--vigore":
			vigor = int(args[i + 1])
	var n_strata := StrataData.STRATA.size()
	var air := []
	var decor := []
	var stations := []
	var rich := []
	var pods := []
	var floors := []
	var tries := []
	var ok := []
	for s in n_strata:
		air.append(0)
		decor.append(0)
		stations.append(0)
		rich.append(0)
		pods.append(0)
		floors.append(0)
		tries.append(0)
		ok.append(0)
	var st_kinds := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in seeds:
		w = World.new()
		WorldGen.generate(w, 5000 + k * 17, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": vigor})
		var floor_cells := []
		for s in n_strata:
			floor_cells.append([])
		for y in range(2, w.h - 2):
			for x in range(2, w.w - 2):
				var s := StrataData.at(w, x, y)
				if not w.solid(x, y):
					air[s] += 1
					if w.solid(x, y + 1) and not w.solid(x, y - 1) and rng.randf() < 0.02:
						(floor_cells[s] as Array).append(Vector2i(x, y))
				var d := w.decor_at(x, y)
				if PodsData.KINDS.has(d):
					pods[s] += 1
				if not w.solid(x, y) and w.solid(x, y + 1):
					floors[s] += 1
				if d != 0 and (TileDefs.DECOR_DROP.has(d) or HarvestData.DECOR.has(d) or PodsData.KINDS.has(d)):
					decor[s] += 1
				var t := w.tile(x, y)
				if t != TileDefs.AIR and TileDefs.DROP.has(t):
					var drop := String(TileDefs.DROP[t])
					if drop.contains("gemma") or drop.contains("cristall") or drop.contains("geode") or drop.contains("perla"):
						rich[s] += 1
		for o in w.stations:
			var id := String(w.stations[o])
			var s := StrataData.at(w, o.x, o.y)
			stations[s] += 1
			st_kinds[id] = int(st_kinds.get(id, 0)) + 1
		# le creature: da punti di pavimento a caso di ogni strato, la geometria di `Fauna.try_spawn`
		for s in n_strata:
			var cells: Array = floor_cells[s]
			for i in mini(cells.size(), 300):
				var pc: Vector2i = cells[rng.randi_range(0, cells.size() - 1)]
				for j in 20:
					tries[s] += 1
					if _spawn_ok(pc, rng):
						ok[s] += 1
	var lines := ["Densità dei mondi: %d semi, vigore %d" % [seeds, vigor], ""]
	lines.append("strato                     aria/seme   da raccogliere per 1000 celle d'aria        creature")
	lines.append("                                       decorazioni  stazioni  tessere preziose    tetto  una prova ogni  riuscite  una nascita ogni")
	for s in n_strata:
		var a := maxf(float(air[s]), 1.0)
		var danger: float = DangerData.STRATUM[s] + DangerData.VIGOR * (vigor - 1)
		var every := DangerData.SPAWN_EVERY / danger
		var rate := float(ok[s]) / maxf(float(tries[s]), 1.0)
		lines.append("%-26s %9d   %11.2f  %8.2f  %16.2f    %5d  %12.1f s  %7.0f%%  %13.1f s" % [
			String(StrataData.STRATA[s]["name"]), air[s] / seeds, 1000.0 * decor[s] / a, 1000.0 * stations[s] / a,
			1000.0 * rich[s] / a, DangerData.cap(danger), every, 100.0 * rate, every / maxf(rate, 0.001)])
	lines.append("")
	for s in n_strata:
		lines.append("%-26s baccelli per mondo %6d · pavimenti %7d" % [String(StrataData.STRATA[s]["name"]), pods[s] / seeds, floors[s] / seeds])
	lines.append("")
	var ks := st_kinds.keys()
	ks.sort_custom(func(a, b) -> bool: return int(st_kinds[a]) > int(st_kinds[b]))
	var parts := []
	for id in ks:
		parts.append("%s %.1f" % [id, float(st_kinds[id]) / seeds])
	lines.append("stazioni per mondo: " + ", ".join(parts))
	var f := FileAccess.open("res://prove/densita.txt", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	print("\n".join(lines))
	quit()


## Come `Fauna.try_spawn`, senza luce né torce (al buio): il punto nell'anello e lo spazio libero con il pavimento.
func _spawn_ok(pc: Vector2i, rng: RandomNumberGenerator) -> bool:
	var ang := rng.randf() * TAU
	var dist := rng.randf_range(DangerData.SPAWN_MIN, DangerData.SPAWN_MAX)
	var c := pc + Vector2i(roundi(cos(ang) * dist), roundi(sin(ang) * dist * 0.6))
	if not w.inside(c.x, c.y) or c.y < 2:
		return false
	for k in 12:
		var y := c.y + k
		if not w.inside(c.x + 1, y + 1):
			return false
		if _free(c.x, y) and w.solid(c.x, y + 1):
			return true
	return false


func _free(x: int, y: int) -> bool:
	return not w.solid(x, y) and not w.solid(x, y - 1) and not w.solid(x + 1, y) and not w.solid(x + 1, y - 1)
