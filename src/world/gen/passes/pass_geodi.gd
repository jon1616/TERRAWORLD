class_name PassGeodi
extends GenPass
## I geodi (voce 28): sfere cave chiuse nella roccia delle Caverne e delle Profondità. Fuori un guscio della roccia
## dello strato, dentro uno strato di cristalli di Linfa e, nel vuoto al centro, gemme a grappolo sul fondo e gocce di
## Linfa che pendono. Chiusi: si trovano scavando, o vedendo il chiarore dei cristalli sulla mappa.

const COUNT := 30
const R_MIN := 4
const R_MAX := 6


func title() -> String:
	return "Geodi"


func run(w: World, c: GenContext) -> void:
	var rng := c.rng
	var made := 0
	var want := roundi(COUNT * float(c.genes()["geodes"]))          # gene «Geodi fitti» (voce 43)
	for tries in want * 60:
		if made >= want:
			break
		var x := rng.randi_range(20, w.w - 21)
		var st := 2 if rng.randf() < 0.55 else 3
		var y := w.surface[x] + rng.randi_range(StrataData.top(st) + 10, StrataData.top(st + 1) - 10)
		var r := rng.randi_range(R_MIN, R_MAX)
		if y + r + 2 >= w.h or not _solid_ball(w, Vector2i(x, y), r + 1):
			continue
		_build(w, Vector2i(x, y), r, st, rng)
		made += 1
	c.notes["geodi"] = made


func _solid_ball(w: World, ctr: Vector2i, r: int) -> bool:
	for y in range(ctr.y - r, ctr.y + r + 1):
		for x in range(ctr.x - r, ctr.x + r + 1):
			if Vector2(x - ctr.x, y - ctr.y).length() <= r and not w.solid(x, y):
				return false
	return true


func _build(w: World, ctr: Vector2i, r: int, st: int, rng: RandomNumberGenerator) -> void:
	var rock := int(StrataData.STRATA[st]["rock"])
	var gem: int = TileDefs.DECOR_GEMS[0] if st == 2 else TileDefs.DECOR_GEMS[2]
	for y in range(ctr.y - r, ctr.y + r + 1):
		for x in range(ctr.x - r, ctr.x + r + 1):
			var d := Vector2(x - ctr.x, y - ctr.y).length()
			if d > r:
				continue
			var i := y * w.w + x
			if d > r - 1.0:
				w.tiles[i] = rock
			elif d > r - 2.2:
				w.tiles[i] = TileDefs.CRYSTAL
			else:
				w.tiles[i] = TileDefs.AIR
				w.decor[i] = 0
				w.walls[i] = int(StrataData.STRATA[st]["wall"])
	# dentro: gemme sul fondo, gocce di Linfa dal soffitto
	for x in range(ctr.x - r + 2, ctr.x + r - 1):
		for y in range(ctr.y, ctr.y + r):
			if not w.solid(x, y) and w.solid(x, y + 1):
				if rng.randf() < 0.6:
					w.set_decor(x, y, gem)
				break
		for y in range(ctr.y, ctr.y - r, -1):
			if not w.solid(x, y) and w.solid(x, y - 1):
				if rng.randf() < 0.4:
					w.set_decor(x, y, TileDefs.DECOR_LINFA)
				break
