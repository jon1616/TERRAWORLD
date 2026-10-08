extends SceneTree
## La misura dei tesori della roccia (voce 457, Roadmap 58): nello stesso mondo con la regola di prima (parametro
## «senza_giacimenti») e con quella di ora, i cristalli di Linfa (tessere, grotte = gruppi di tessere a meno di 8, la
## più grande) e le gemme a grappolo (quante, e quante **al posto giusto**: in una grande caverna o nella zona di una
## grotta di cristallo, la maschera di `PassCristalli`). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/tesori.gd -- --seme 7
## Scrive prove/tesori.txt.

const GEMS := [23, 24, 25, 26]

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
		_p("== %s (seme %d)" % ["prima" if senza else "ora", sd])
		_crystals(w)
		_gems(w)
	var f := FileAccess.open("res://prove/tesori.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _crystals(w: World) -> void:
	var buckets := {}
	var n := 0
	for i in w.tiles.size():
		if w.tiles[i] == TileDefs.CRYSTAL:
			n += 1
			var b := Vector2i((i % w.w) / 8, (i / w.w) / 8)
			buckets[b] = int(buckets.get(b, 0)) + 1
	var seen := {}
	var sizes := []
	for b in buckets:
		if seen.has(b):
			continue
		var tot := 0
		var todo := [b]
		seen[b] = true
		while not todo.is_empty():
			var q: Vector2i = todo.pop_back()
			tot += int(buckets[q])
			for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				if buckets.has(q + o) and not seen.has(q + o):
					seen[q + o] = true
					todo.append(q + o)
		sizes.append(tot)
	sizes.sort()
	var big := 0
	for s in sizes:
		if int(s) >= 40:
			big += 1
	_p("   cristalli: %d tessere in %d gruppi (in media %.0f; %d grotte da 40+; la più grande %d)" % [n, sizes.size(),
		float(n) / maxi(sizes.size(), 1), big, int(sizes.back()) if not sizes.is_empty() else 0])


func _gems(w: World) -> void:
	var rooms := []
	for cv in w.gen_notes.get("caverne", []):
		var r: Array = cv["rect"]
		rooms.append(Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3])).grow(3))
	var mask := FastNoiseLite.new()
	mask.seed = w.world_seed + ("grotte_cristallo".hash() & 0xffff)
	mask.frequency = float(PassCristalli.MASK["freq"])
	mask.fractal_octaves = 2
	var n := 0
	var good := 0
	for y in w.h:
		for x in w.w:
			if not (w.decor_at(x, y) in GEMS):
				continue
			n += 1
			var q := Vector2i(x, y)
			var ok := false
			for r: Rect2i in rooms:
				if r.has_point(q):
					ok = true
			if not ok and mask.get_noise_2d(x, y) >= float(PassCristalli.MASK["at"]):
				ok = true
			if ok:
				good += 1
	_p("   gemme: %d, al posto giusto %d (%.0f%%)" % [n, good, 100.0 * good / maxi(n, 1)])


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
