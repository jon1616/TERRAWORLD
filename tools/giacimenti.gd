extends SceneTree
## La misura dei giacimenti (voce 455, Roadmap 58): per i metalli di base, nello stesso mondo con i giacimenti e senza (la
## regola di prima, parametro «senza_giacimenti»): quante tessere, quanti giacimenti (gruppi di tessere a meno di 6 l'una
## dall'altra) e la **resa vicino alla vena**: in una finestra 9×9 attorno a ogni tessera di metallo, quante celle sono
## dello stesso metallo (è ciò che trova chi scava seguendo un filone). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/giacimenti.gd -- --seme 7
## Scrive prove/giacimenti.txt.

const METALS := {"radicite": TileDefs.RADICITE, "legnoferro": TileDefs.LEGNOFERRO, "ambra": TileDefs.AMBRA}

var out := ""


func _init() -> void:
	var sd := 7
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seme" and i + 1 < args.size():
			sd = int(args[i + 1])
	for senza in [true, false]:
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": [], "senza_giacimenti": senza})
		_p("== %s (seme %d)" % ["prima: vene sparse" if senza else "ora: giacimenti", sd])
		for name in METALS:
			_measure(w, name, int(METALS[name]))
	var f := FileAccess.open("res://prove/giacimenti.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _measure(w: World, name: String, t: int) -> void:
	var cells := []
	for i in w.tiles.size():
		if w.tiles[i] == t:
			cells.append(Vector2i(i % w.w, i / w.w))
	var near := 0.0
	var step := maxi(cells.size() / 3000, 1)
	var sampled := 0
	for k in range(0, cells.size(), step):
		var p: Vector2i = cells[k]
		var n := 0
		for dy in range(-4, 5):
			for dx in range(-4, 5):
				if w.tile(p.x + dx, p.y + dy) == t:
					n += 1
		near += float(n - 1) / 80.0
		sampled += 1
	# i giacimenti: gruppi di tessere a meno di 6 (su una griglia di celle da 6)
	var buckets := {}
	for p in cells:
		buckets[Vector2i(p.x / 6, p.y / 6)] = true
	var seen := {}
	var groups := 0
	for b in buckets:
		if seen.has(b):
			continue
		groups += 1
		var todo := [b]
		while not todo.is_empty():
			var q: Vector2i = todo.pop_back()
			if seen.has(q) or not buckets.has(q):
				continue
			seen[q] = true
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				todo.append(q + d)
	_p("   %-10s tessere %6d · giacimenti %4d (in media %d tessere) · resa vicino alla vena %.0f%%" % [name, cells.size(),
		groups, cells.size() / maxi(groups, 1), 100.0 * near / maxi(sampled, 1)])


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
