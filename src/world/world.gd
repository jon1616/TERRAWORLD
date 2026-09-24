class_name World
extends RefCounted
## I dati di un mondo: tessere, pareti di fondo, decorazioni, torce, alberi. Nessuna generazione (vedi `WorldGen`)
## e nessun disegno (vedi `WorldView`): solo lo stato e il modo di leggerlo.

const CHUNK := 32                      # lato di un blocco, in tessere
const BUCKET := 16                     # lato delle celle dell'indice delle torce

var w := 3000
var h := 1000
var world_seed := 0
var tiles := PackedByteArray()
var walls := PackedByteArray()
var decor := PackedByteArray()
var surface := PackedInt32Array()      # prima riga di terreno di ogni colonna (prima delle grotte)
var spawn := Vector2i.ZERO
var creatures: Array[Dictionary] = []
var torches := {}                      # Vector2i -> true
var _torch_buckets := {}               # Vector2i(bx, by) -> Array[Vector2i]
var trees := {}                        # blocco Vector2i -> Array[Vector3i(x, y, variante)]


func setup(width: int, height: int) -> void:
	w = width
	h = height
	tiles.resize(w * h)
	tiles.fill(0)
	walls.resize(w * h)
	walls.fill(0)
	decor.resize(w * h)
	decor.fill(0)
	surface.resize(w)
	torches.clear()
	_torch_buckets.clear()
	trees.clear()
	creatures.clear()


func tile(x: int, y: int) -> int:
	if x < 0 or x >= w or y >= h:
		return TileDefs.STONE
	if y < 0:
		return TileDefs.AIR
	return tiles[y * w + x]


func solid(x: int, y: int) -> bool:
	return tile(x, y) != TileDefs.AIR


func wall(x: int, y: int) -> int:
	if x < 0 or x >= w or y < 0 or y >= h:
		return 0
	return walls[y * w + x]


func decor_at(x: int, y: int) -> int:
	if x < 0 or x >= w or y < 0 or y >= h:
		return 0
	return decor[y * w + x]


func depth(x: int, y: int) -> int:
	return y - surface[clampi(x, 0, w - 1)]


func inside(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < w and y < h


func set_tile(x: int, y: int, t: int) -> void:
	tiles[y * w + x] = t


func set_decor(x: int, y: int, d: int) -> void:
	decor[y * w + x] = d


static func chunk_of(c: Vector2i) -> Vector2i:
	return Vector2i(floori(c.x / float(CHUNK)), floori(c.y / float(CHUNK)))


# ---------------------------------------------------------------- torce

func add_torch(c: Vector2i) -> void:
	torches[c] = true
	var b := Vector2i(c.x / BUCKET, c.y / BUCKET)
	if not _torch_buckets.has(b):
		_torch_buckets[b] = []
	(_torch_buckets[b] as Array).append(c)


func torches_in(r: Rect2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for by in range(floori(r.position.y / float(BUCKET)), floori((r.end.y - 1) / float(BUCKET)) + 1):
		for bx in range(floori(r.position.x / float(BUCKET)), floori((r.end.x - 1) / float(BUCKET)) + 1):
			var list: Array = _torch_buckets.get(Vector2i(bx, by), [])
			for c in list:
				if r.has_point(c):
					out.append(c)
	return out


func torch_near(c: Vector2i, dist: float) -> bool:
	var d := int(ceil(dist))
	for t in torches_in(Rect2i(c - Vector2i(d, d), Vector2i(d * 2 + 1, d * 2 + 1))):
		if Vector2(t - c).length() < dist:
			return true
	return false


# ---------------------------------------------------------------- alberi

func add_tree(base: Vector2i, variant: int) -> void:
	var k := chunk_of(base)
	if not trees.has(k):
		trees[k] = []
	(trees[k] as Array).append(Vector3i(base.x, base.y, variant))
