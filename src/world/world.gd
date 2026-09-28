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
var crops := {}                        # il giardino (voce 33): cella -> [coltura, secondi che mancano, annaffiata]
var saplings := {}                     # cella del germoglio Vector2i -> secondi che mancano per diventare albero
var stations := {}                     # angolo in alto a sinistra Vector2i -> id di `StationsData`
var chests := {}                       # angolo di una stazione con `slots` (cesta, scrigno) -> Bisaccia del contenuto
var biomes := PackedByteArray()        # bioma di superficie di ogni colonna (indice di `BiomesData.BIOMES`)
var explored := PackedByteArray()      # mappa: 1 dove il Germogliato ha già visto (vedi `MapReveal`)
var plats := PackedByteArray()         # passerelle: 1 dove c'è una passerella (cella d'aria, si attraversa da sotto)
## Voce 73: i liquidi. Un byte per cella: livello 0-8 nei 4 bit bassi, tipo (0 acqua, 1 Linfa, 2 brace) nei due sopra.
## Le regole di come scorrono in `Liquids`, i tipi in `LiquidsData`.
var tint := PackedByteArray()           # voce 140: i colori delle tinture (4 bit bassi il blocco, 4 alti la parete)
var build := PackedByteArray()          # voce 128: quale costrutto c'è in una cella (0 = nessuno, vedi `BuildData`)
var liquid := PackedByteArray()
## Chiamata quando una tessera cambia (`set_tile`): i liquidi vicini si risvegliano (lo imposta `Liquids`).
var on_change := Callable()
var gen_rng: RandomNumberGenerator = null   # il caso del generatore mentre il mondo nasce (casse, vedi `chest_at`)
var sky: Array = []                    # Roadmap 16: le zone del cielo ({x0, x1, low, high, base, split}, `SkyData`)
var gen_notes := {}                    # gli appunti del generatore (`GenContext.notes`), solo per il mondo appena nato


func setup(width: int, height: int) -> void:
	w = width
	h = height
	tiles.resize(w * h)
	tiles.fill(0)
	walls.resize(w * h)
	walls.fill(0)
	decor.resize(w * h)
	decor.fill(0)
	plats.resize(w * h)
	plats.fill(0)
	liquid.resize(w * h)
	liquid.fill(0)
	build.resize(w * h)
	build.fill(0)
	tint.resize(w * h)
	tint.fill(0)
	explored.resize(w * h)
	explored.fill(0)
	biomes.resize(w)
	biomes.fill(0)
	surface.resize(w)
	sky = []
	torches.clear()
	_torch_buckets.clear()
	trees.clear()
	saplings.clear()
	crops.clear()
	stations.clear()
	chests.clear()
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


## Voce 128: mette un costrutto (`BuildData`), o lo toglie con 0.
func set_build(x: int, y: int, k: int) -> void:
	set_tile(x, y, BuildData.tile_of(k) if k > 0 else TileDefs.AIR)
	build[y * w + x] = k


## Voce 140: il colore di una cella (blocco e parete, 0 = nessuno; `BuilderData.DYES`).
func tint_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= w or y >= h or tint.size() != tiles.size():
		return 0
	return tint[y * w + x]


func block_tint(x: int, y: int) -> int:
	return tint_at(x, y) & 15


func wall_tint(x: int, y: int) -> int:
	return tint_at(x, y) >> 4


func set_tint(x: int, y: int, block: int, wall: int) -> void:
	if tint.size() == tiles.size():
		tint[y * w + x] = (block & 15) | ((wall & 15) << 4)


func build_at(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= w or y >= h or build.size() != tiles.size():
		return 0
	return build[y * w + x]


func set_tile(x: int, y: int, t: int) -> void:
	tiles[y * w + x] = t
	if t != TileDefs.COSTRUTTO and t != TileDefs.COSTRUTTO_T and build.size() == tiles.size():
		build[y * w + x] = 0                       # voce 128: un costrutto tolto non lascia il suo numero
		if tint.size() == tiles.size():
			tint[y * w + x] &= 0xF0                # né il suo colore (voce 140)
	if on_change.is_valid():
		on_change.call(x, y)


func set_decor(x: int, y: int, d: int) -> void:
	decor[y * w + x] = d


func plat(x: int, y: int) -> bool:
	return inside(x, y) and plats[y * w + x] == 1


func set_plat(x: int, y: int, on: bool) -> void:
	plats[y * w + x] = 1 if on else 0


# ---------------------------------------------------------------- stazioni

## La stazione che occupa la cella c: {"origin": angolo, "id": id} oppure {}.
func station_at(c: Vector2i) -> Dictionary:
	for o in stations:
		var size: Array = StationsData.STATIONS[stations[o]]["size"]
		if Rect2i(o, Vector2i(size[0], size[1])).has_point(c):
			return {"origin": o, "id": stations[o]}
	return {}


## Si può mettere la stazione con l'angolo in o? Celle libere (aria, niente torce né passerelle) e pavimento sotto.
func station_fits(id: String, o: Vector2i) -> bool:
	var size: Array = StationsData.STATIONS[id]["size"]
	for dy in size[1]:
		for dx in size[0]:
			var c := o + Vector2i(dx, dy)
			if not inside(c.x, c.y) or solid(c.x, c.y) or torches.has(c) or plat(c.x, c.y) or not station_at(c).is_empty():
				return false
			if tree_at(c).x >= 0:
				return false
	if TrapsData.is_trap(id):
		# voce 88: le trappole si appoggiano a terra, a una parete o al soffitto
		return solid(o.x, o.y + 1) or solid(o.x, o.y - 1) or solid(o.x - 1, o.y) or solid(o.x + 1, o.y)
	if StationsData.role(id) == "lanterna" and solid(o.x, o.y - 1):
		return true                              # voce 145: la lanterna si appende al soffitto
	for dx in size[0]:
		if not solid(o.x + dx, o.y + size[1]):
			return false
	return true


static func chunk_of(c: Vector2i) -> Vector2i:
	return Vector2i(floori(c.x / float(CHUNK)), floori(c.y / float(CHUNK)))


# ---------------------------------------------------------------- torce

func add_torch(c: Vector2i) -> void:
	torches[c] = true
	var b := Vector2i(c.x / BUCKET, c.y / BUCKET)
	if not _torch_buckets.has(b):
		_torch_buckets[b] = []
	(_torch_buckets[b] as Array).append(c)


func remove_torch(c: Vector2i) -> void:
	if not torches.has(c):
		return
	torches.erase(c)
	var b := Vector2i(c.x / BUCKET, c.y / BUCKET)
	(_torch_buckets.get(b, []) as Array).erase(c)


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


## L'albero che occupa la cella c (colonne base-1..base+1, righe base-HEIGHT..base), oppure (-1, -1, -1).
func tree_at(c: Vector2i) -> Vector3i:
	for dx in range(-1, 2):
		for dy in range(0, FloraData.HEIGHT + 1):
			var base := c + Vector2i(dx, dy)
			for t in trees.get(chunk_of(base), []):
				if t.x == base.x and t.y == base.y:
					return t
	return Vector3i(-1, -1, -1)


func remove_tree(t: Vector3i) -> void:
	var list: Array = trees.get(chunk_of(Vector2i(t.x, t.y)), [])
	list.erase(t)


## Un albero può nascere qui? Muschio sotto, spazio libero sopra, nessun altro albero troppo vicino.
func tree_fits(base: Vector2i) -> bool:
	if not TileDefs.is_grass(tile(base.x, base.y + 1)):
		return false
	for k in range(0, FloraData.ROOM):
		if solid(base.x, base.y - k):
			return false
	for dx in range(-3, 4):
		if tree_at(Vector2i(base.x + dx, base.y)).x >= 0:
			return false
	return true


## Quante tessere libere ci sono sopra una base, fino a `most` (per scegliere quanto può essere grande un albero).
func free_above(base: Vector2i, most: int) -> int:
	for k in most:
		if solid(base.x, base.y - k):
			return k
	return most


## Il contenuto di un contenitore (cesta, scrigno) con l'angolo in o; lo crea vuoto la prima volta.
func chest_at(o: Vector2i) -> Bisaccia:
	if not chests.has(o):
		chests[o] = Bisaccia.new(int(StationsData.STATIONS[stations[o]].get("slots", 20)))
		(chests[o] as Bisaccia).rng = gen_rng
	return chests[o]


## Stringa confrontabile di tutti i contenitori (prove di salvataggio).
func chests_key() -> String:
	var keys := chests.keys()
	keys.sort()
	var out := ""
	for o in keys:
		out += "%s:%s;" % [o, (chests[o] as Bisaccia).to_array()]
	return out


## Voce 73: il livello del liquido in una cella (0-8; 0 fuori dal mondo).
func liq(x: int, y: int) -> int:
	if x < 0 or x >= w or y < 0 or y >= h:
		return 0
	return liquid[y * w + x] & 15


## Il tipo del liquido in una cella (0 acqua, 1 Linfa, 2 brace).
func liq_type(x: int, y: int) -> int:
	if x < 0 or x >= w or y < 0 or y >= h:
		return 0
	return (liquid[y * w + x] >> 4) & 3


func set_liq(x: int, y: int, level: int, type: int) -> void:
	if x < 0 or x >= w or y < 0 or y >= h:
		return
	liquid[y * w + x] = 0 if level <= 0 else (clampi(level, 0, 8) | (type << 4))
