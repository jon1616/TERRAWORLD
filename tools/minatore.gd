extends SceneTree
## Il minatore simulato (voce 458, Roadmap 58 «I tesori della roccia»): quanto rende scavare con le vene sparse di prima
## (parametro «senza_giacimenti») e con i giacimenti di ora. Per ogni metallo, 120 minatori partono da punti a caso dei
## suoi strati e scavano una galleria di 400 passi (dritta, con qualche scarto in alto o in basso); il metallo che vedono
## (entro `SIGHT` tessere dalla galleria) lo raggiungono e seguono il filone finché continua. Costo = tessere scavate
## (galleria, strada fino al metallo, il metallo stesso). Misura: **metallo per 100 tessere scavate** e i minuti per i
## 60 minerali di un set di quel metallo (al ritmo `DIG_S` secondi per tessera). Senza finestra:
##   Godot_console.exe --headless --path . --script res://tools/minatore.gd -- --seme 7
## Scrive prove/minatore.txt.

const METALS := {"radicite": [TileDefs.RADICITE, [1, 2]], "legnoferro": [TileDefs.LEGNOFERRO, [2, 3]],
	"ambra": [TileDefs.AMBRA, [3, 4]]}
const RUNS := 120
const STEPS := 400
const SIGHT := 5
const DIG_S := 0.45
const SET_ORES := 60

var out := ""


func _init() -> void:
	var sd := 7
	var args := OS.get_cmdline_user_args()
	for i in args.size():
		if args[i] == "--seme" and i + 1 < args.size():
			sd = int(args[i + 1])
	var res := {}
	for senza in [true, false]:
		var w := World.new()
		WorldGen.generate(w, sd, WorldGen.WIDTH, WorldGen.HEIGHT, {"vigore": 1, "geni": [], "senza_giacimenti": senza})
		for name in METALS:
			res[[name, senza]] = _mine(w, int(METALS[name][0]), METALS[name][1])
	_p("Il minatore simulato (seme %d): metallo per 100 tessere scavate; minuti per %d minerali (%.2f s a tessera)" % [sd,
		SET_ORES, DIG_S])
	for name in METALS:
		var a: float = res[[name, true]]
		var b: float = res[[name, false]]
		_p("   %-11s prima %5.1f · ora %5.1f (%+.0f%%) · minuti per un set: prima %4.1f, ora %4.1f" % [name, a, b,
			100.0 * (b - a) / maxf(a, 0.01), SET_ORES * 100.0 / maxf(a, 0.01) * DIG_S / 60.0,
			SET_ORES * 100.0 / maxf(b, 0.01) * DIG_S / 60.0])
	var f := FileAccess.open("res://prove/minatore.txt", FileAccess.WRITE)
	if f:
		f.store_string(out)
	quit()


func _mine(w: World, t: int, strata: Array) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = 458
	var ores := 0
	var cost := 0
	var top := StrataData.top(int(strata[0]))
	var bottom := StrataData.top(int(strata[1]) + 1) if int(strata[1]) + 1 < StrataData.STRATA.size() else 400
	for r in RUNS:
		var x := rng.randi_range(60, w.w - 60)
		var y := int(w.surface[x]) + rng.randi_range(top + 5, bottom - 5)
		var dir := 1 if rng.randf() < 0.5 else -1
		var taken := {}
		for s in STEPS:
			x += dir
			if rng.randf() < 0.08:
				y += 1 if rng.randf() < 0.5 else -1
			if not w.inside(x, y + 1):
				break
			if w.solid(x, y):
				cost += 1
			if w.solid(x, y + 1):
				cost += 1                                   # la galleria è alta due
			if s % 2 != 0:
				continue
			for dy in range(-SIGHT, SIGHT + 1):
				for dx in range(-SIGHT, SIGHT + 1):
					var p := Vector2i(x + dx, y + dy)
					if w.tile(p.x, p.y) != t or taken.has(p):
						continue
					# lo raggiunge (la strada costa la distanza) e segue il filone
					cost += maxi(absi(dx) + absi(dy) - 1, 0)
					var todo := [p]
					taken[p] = true
					while not todo.is_empty():
						var q: Vector2i = todo.pop_back()
						ores += 1
						cost += 1
						for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1),
								Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
							var n: Vector2i = q + o
							if not taken.has(n) and w.tile(n.x, n.y) == t:
								taken[n] = true
								todo.append(n)
	return 100.0 * ores / maxi(cost, 1)


func _p(s: String) -> void:
	print(s)
	out += s + "\n"
