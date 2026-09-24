class_name World
extends RefCounted
## Il mondo: tessere, pareti di fondo, decorazioni e generazione procedurale da un seme.

var w := 260
var h := 150
var world_seed := 0
var tiles := PackedByteArray()
var walls := PackedByteArray()
var decor := PackedByteArray()
var surface := PackedInt32Array()
var torches := {}                      # Vector2i -> true
var trees: Array[Vector2i] = []        # base del tronco (cella d'aria sopra l'erba)
var spawn := Vector2i.ZERO
var slimes: Array[Dictionary] = []


func tile(x: int, y: int) -> int:
	if x < 0 or x >= w or y >= h:
		return Tiles.STONE
	if y < 0:
		return Tiles.AIR
	return tiles[y * w + x]


func solid(x: int, y: int) -> bool:
	return tile(x, y) != Tiles.AIR


func wall(x: int, y: int) -> int:
	if x < 0 or x >= w or y < 0 or y >= h:
		return 0
	return walls[y * w + x]


func depth(x: int, y: int) -> int:
	return y - surface[clampi(x, 0, w - 1)]


func set_tile(x: int, y: int, t: int) -> void:
	tiles[y * w + x] = t


func _noise(s: int, f: float, oct: int) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = s
	n.frequency = f
	n.fractal_octaves = oct
	return n


func generate(s: int) -> void:
	world_seed = s
	var rng := RandomNumberGenerator.new()
	rng.seed = s
	tiles.resize(w * h)
	tiles.fill(0)
	walls.resize(w * h)
	walls.fill(0)
	decor.resize(w * h)
	decor.fill(0)
	surface.resize(w)
	torches.clear()
	trees.clear()
	slimes.clear()
	var n_s := _noise(s, 0.011, 4)
	var n_d := _noise(s + 1, 0.06, 2)
	var n_dd := _noise(s + 2, 0.03, 2)
	var n_p := _noise(s + 3, 0.07, 3)
	var n_worm := _noise(s + 4, 0.022, 3)
	var n_room := _noise(s + 5, 0.035, 3)
	var n_cu := _noise(s + 6, 0.11, 2)
	var n_fe := _noise(s + 7, 0.12, 2)
	var n_au := _noise(s + 8, 0.13, 2)
	var n_cr := _noise(s + 9, 0.08, 2)
	spawn.x = w / 2
	for x in w:
		surface[x] = int(46.0 + n_s.get_noise_1d(x) * 18.0 + n_d.get_noise_1d(x) * 2.0)
	for x in range(spawn.x - 7, spawn.x + 8):
		surface[x] = surface[spawn.x]
	# strati: terra in superficie, roccia sotto, sacche dell'una nell'altra
	for x in w:
		var dd := 9 + int(n_dd.get_noise_1d(x) * 6.0)
		for y in range(surface[x], h):
			var dep := y - surface[x]
			var t := Tiles.DIRT if dep < dd else Tiles.STONE
			var pk := n_p.get_noise_2d(x, y)
			if t == Tiles.DIRT and pk > 0.42 and dep > 3:
				t = Tiles.STONE
			elif t == Tiles.STONE and pk > 0.45:
				t = Tiles.DIRT
			tiles[y * w + x] = t
			if dep > 1:
				walls[y * w + x] = Tiles.WALL_DIRT if dep < dd + 3 else Tiles.WALL_STONE
	# grotte: gallerie a verme e caverne più ampie in profondità
	for y in h:
		for x in w:
			var dep := y - surface[x]
			if dep <= 6:
				continue
			var f := minf(dep / 60.0, 1.0)
			var worm := absf(n_worm.get_noise_2d(x, y * 1.4))
			var room := n_room.get_noise_2d(x, y * 1.2)
			if worm < 0.05 + 0.03 * f or room > 0.4 - 0.14 * f:
				tiles[y * w + x] = Tiles.AIR
	var entrance_end := _carve_entrance(rng)
	# minerali
	for y in h:
		for x in w:
			var t: int = tiles[y * w + x]
			if t != Tiles.STONE and t != Tiles.DIRT:
				continue
			var dep := y - surface[x]
			if dep > 4 and n_cu.get_noise_2d(x, y) > 0.5:
				tiles[y * w + x] = Tiles.COPPER
			elif t == Tiles.STONE and dep > 22 and n_fe.get_noise_2d(x, y) > 0.52:
				tiles[y * w + x] = Tiles.IRON
			elif t == Tiles.STONE and dep > 45 and n_au.get_noise_2d(x, y) > 0.55:
				tiles[y * w + x] = Tiles.GOLD
	# cristalli sulle pareti delle caverne profonde
	var seeds: Array[Vector2i] = []
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			if tiles[y * w + x] == Tiles.STONE and depth(x, y) > 62 and _near_air(x, y) and n_cr.get_noise_2d(x, y) > 0.3:
				seeds.append(Vector2i(x, y))
	for c in seeds:
		tiles[c.y * w + c.x] = Tiles.CRYSTAL
		for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = c + o
			if tile(q.x, q.y) == Tiles.STONE and rng.randf() < 0.25:
				tiles[q.y * w + q.x] = Tiles.CRYSTAL
	# erba: la prima tessera di ogni colonna e la terra scoperta vicino alla superficie
	for x in w:
		for y in h:
			if tiles[y * w + x] != Tiles.AIR:
				if tiles[y * w + x] == Tiles.DIRT:
					tiles[y * w + x] = Tiles.GRASS
				break
		for y in range(surface[x], mini(surface[x] + 6, h)):
			if tiles[y * w + x] == Tiles.DIRT and _near_air(x, y) and walls[y * w + x] == 0:
				tiles[y * w + x] = Tiles.GRASS
	# alberi
	var last_tree := -99
	for x in range(3, w - 3):
		var gy := surface[x]
		if tile(x, gy) != Tiles.GRASS or surface[x - 1] != gy or surface[x + 1] != gy:
			continue
		if x - last_tree < 6 or absi(x - spawn.x) < 4 or rng.randf() > 0.4:
			continue
		trees.append(Vector2i(x, gy - 1))
		last_tree = x
	# decorazioni
	for y in range(1, h - 1):
		for x in w:
			if tiles[y * w + x] != Tiles.AIR or tiles[(y + 1) * w + x] == Tiles.AIR:
				continue
			var below: int = tiles[(y + 1) * w + x]
			var dep := y - surface[x]
			var r := rng.randf()
			var d := 0
			if below == Tiles.GRASS:
				if r < 0.5:
					d = rng.randi_range(1, 3)
				elif r < 0.62:
					d = rng.randi_range(4, 6)
			elif below != Tiles.CRYSTAL:
				if dep > 55 and r < 0.1:
					d = Tiles.DECOR_GLOW
				elif r < 0.06:
					d = rng.randi_range(7, 8)
				elif dep > 8 and dep < 55 and r < 0.09:
					d = 9
			decor[y * w + x] = d
	for t in trees:
		decor[t.y * w + t.x] = 0
	# torce nelle grotte, distanziate
	torches[entrance_end] = true
	for y in range(1, h - 1):
		for x in w:
			if tiles[y * w + x] != Tiles.AIR or walls[y * w + x] == 0 or tiles[(y + 1) * w + x] == Tiles.AIR:
				continue
			if depth(x, y) < 8 or rng.randf() > 0.03:
				continue
			var ok := true
			for k in torches:
				if (k as Vector2i).distance_to(Vector2i(x, y)) < 14.0:
					ok = false
					break
			if ok:
				torches[Vector2i(x, y)] = true
	for k in torches:
		decor[k.y * w + k.x] = 0
	spawn.y = surface[spawn.x] - 1
	# slime: due in superficie, due nelle grotte
	slimes.append({"cell": Vector2i(spawn.x - 12, surface[spawn.x - 12] - 2), "kind": 0})
	slimes.append({"cell": Vector2i(spawn.x + 11, surface[spawn.x + 11] - 2), "kind": 1})
	var cave_torches: Array = torches.keys()
	for k in mini(2, cave_torches.size()):
		var c: Vector2i = cave_torches[cave_torches.size() - 1 - k]
		slimes.append({"cell": c + Vector2i(2, -1), "kind": 2})


func _near_air(x: int, y: int) -> bool:
	return tile(x - 1, y) == Tiles.AIR or tile(x + 1, y) == Tiles.AIR or tile(x, y - 1) == Tiles.AIR or tile(x, y + 1) == Tiles.AIR


## Una galleria che scende dalla superficie vicino al punto di partenza: restituisce la cella in fondo.
func _carve_entrance(rng: RandomNumberGenerator) -> Vector2i:
	var p := Vector2(spawn.x + 16, surface[spawn.x + 16] - 1)
	var ang := PI * 0.5 + 0.35
	for step in 75:
		var r := rng.randf_range(1.7, 2.6)
		for y in range(int(p.y - r) - 1, int(p.y + r) + 2):
			for x in range(int(p.x - r) - 1, int(p.x + r) + 2):
				if x < 1 or x >= w - 1 or y < 0 or y >= h - 1:
					continue
				if Vector2(x + 0.5, y + 0.5).distance_to(p) <= r:
					tiles[y * w + x] = Tiles.AIR
		ang = clampf(ang + rng.randf_range(-0.3, 0.3), 0.5, 2.3)
		p += Vector2(cos(ang), sin(ang))
	var c := Vector2i(int(p.x), int(p.y))
	while c.y < h - 2 and tile(c.x, c.y + 1) == Tiles.AIR:
		c.y += 1
	return c
