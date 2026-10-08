extends SceneTree
## La misura del sottosuolo (voce 454, Roadmap 57 «Le profondità vere»): per alcuni semi, per ogni strato l'aria, i posti
## dove si sta in piedi e quanti se ne **raggiungono dalla superficie senza scavare** (si cammina, si salta 3 su e 4 di
## lato, si cade, si nuota, si passa da sotto le passerelle); poi le grandi caverne, le voragini, le regioni, le falde e
## la strada del sottosuolo. Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/sottosuolo.gd -- --semi 3
## Scrive prove/sottosuolo.txt e lo stampa.

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
		_measure(w, sd)
	var f := FileAccess.open("res://prove/sottosuolo.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _measure(w: World, sd: int) -> void:
	var reach := _reach(w)
	var air := [0, 0, 0, 0, 0]
	var cells := [0, 0, 0, 0, 0]
	var stand := [0, 0, 0, 0, 0]
	var got := [0, 0, 0, 0, 0]
	for y in w.h:
		for x in w.w:
			var dep := y - int(w.surface[x])
			if dep < 8:
				continue
			var st := StrataData.index(x, dep, w.world_seed)
			cells[st] += 1
			if not w.solid(x, y):
				air[st] += 1
				if _stand(w, x, y):
					stand[st] += 1
					if reach.has(Vector2i(x, y)):
						got[st] += 1
	var n: Dictionary = w.gen_notes
	_p("seme %d: caverne %d, voragini %d, regioni %s, falde %d, strada %d punti" % [sd, (n.get("caverne", []) as Array).size(),
		(n.get("voragini", []) as Array).size(), str((n.get("regioni", []) as Array).map(func(r: Dictionary) -> String: return String(r["id"]))),
		int(n.get("falde", 0)), (n.get("strada", []) as Array).size()])
	for k in 5:
		_p("   %-11s aria %2d%% · posti dove stare %6d · raggiunti dalla superficie senza scavare %5.1f%% (%d)" % [NAMES[k],
			100 * int(air[k]) / maxi(int(cells[k]), 1), int(stand[k]), 100.0 * int(got[k]) / maxi(int(stand[k]), 1), int(got[k])])
	_p("   il Fondo si raggiunge senza scavare: %s" % ("sì" if int(got[4]) > 0 else "NO"))


func _stand(w: World, x: int, y: int) -> bool:
	return w.inside(x, y) and y > 1 and not w.solid(x, y) and not w.solid(x, y - 1) \
		and (w.solid(x, y + 1) or w.plat(x, y + 1) or w.liq(x, y) > 0)


func _fall(w: World, x: int, y: int) -> Variant:
	if not w.inside(x, y) or w.solid(x, y):
		return null
	var yy := y
	while yy < w.h - 2:
		if w.solid(x, yy + 1) or w.plat(x, yy + 1) or w.liq(x, yy) > 0:
			return Vector2i(x, yy) if not w.solid(x, yy - 1) else null
		yy += 1
	return null


## Dalla superficie (ogni colonna) giù senza scavare.
func _reach(w: World) -> Dictionary:
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
		for dx in [-1, 1]:
			for dy in [0, -1]:
				if _stand(w, p.x + dx, p.y + dy):
					next.append(Vector2i(p.x + dx, p.y + dy))
			var f: Variant = _fall(w, p.x + dx, p.y)
			if f != null:
				next.append(f)
		var below: Variant = _fall(w, p.x, p.y + 1) if w.plat(p.x, p.y + 1) or w.liq(p.x, p.y) > 0 else null
		if below != null:
			next.append(below)                            # giù da una passerella, o nuotando
		var up := 3 + (6 if w.liq(p.x, p.y) > 0 else 0)
		for dy in range(1, up + 1):
			for dx in range(-4, 5):
				if _stand(w, p.x + dx, p.y - dy):
					next.append(Vector2i(p.x + dx, p.y - dy))
		# i salti di lato e in discesa (un buco nel pavimento si salta: senza, ci si cadeva dentro)
		for dy in range(0, 4):
			for dx in [-5, -4, -3, -2, 2, 3, 4, 5]:
				if _stand(w, p.x + dx, p.y + dy) and not w.solid(p.x + signi(dx), p.y - 1):
					next.append(Vector2i(p.x + dx, p.y + dy))
		for q in next:
			if not seen.has(q):
				seen[q] = true
				queue.append(q)
	return seen


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
