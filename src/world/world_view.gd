class_name WorldView
extends Node2D
## Disegna il mondo a blocchi: solo i blocchi vicini alla visuale esistono come nodi, gli altri vengono creati
## quando servono (pochi per fotogramma) e liberati quando ci si allontana. Ogni blocco ha pareti e decorazioni sulla
## griglia normale, il terreno dai contorni morbidi sulla «doppia griglia» (vedi `TerrainPainter`), i suoi alberi e le
## sue torce (gli oggetti sono costruiti da `ViewProps`).

const S := 16
const BUILD_PER_FRAME := 1
const KEEP_MARGIN := 2                # blocchi tenuti oltre la visuale prima di liberarli
const HALF := Vector2(-8, -8)         # spostamento della doppia griglia

var world: World
var ts_terrain: TileSet
var ts_terrain_glow: TileSet
var ts_misc: TileSet
var ts_misc_glow: TileSet
var props: ViewProps                  # alberi, stazioni, torce, scintille (vedi `view_props.gd`)
var chunks := {}                      # Vector2i -> Node2D
var _queue: Array[Vector2i] = []
var _want := Rect2i()
var _member: Array[PackedByteArray] = []   # per ogni strato del terreno: 1 se il tipo di tessera ne fa parte
var _glow_layer := -1                 # strato del terreno che ha anche la versione luminosa


func setup(w: World) -> void:
	world = w
	# trame e tavole uguali in ogni mondo: preparate una volta per sessione, in sottofondo dal menu (`ViewArt`)
	var art := ViewArt.get_all()
	ts_terrain = art["terrain"]
	ts_terrain_glow = art["terrain_glow"]
	ts_misc = art["misc"]
	ts_misc_glow = art["misc_glow"]
	for li in TileDefs.TERRAIN_LAYERS.size():
		var L: Dictionary = TileDefs.TERRAIN_LAYERS[li]
		var m := PackedByteArray()
		m.resize(TileDefs.TYPES + 1)
		for t in L["types"]:
			m[t] = 1
		_member.append(m)
		if L.get("glow", false):
			_glow_layer = li
	props = ViewProps.new()
	props.setup(self, w)

## Rettangolo visibile in celle: decide quali blocchi servono. `immediate` li costruisce tutti subito.
func set_view(view_cells: Rect2i, immediate := false) -> void:
	var c0 := World.chunk_of(view_cells.position) - Vector2i(1, 1)
	var c1 := World.chunk_of(view_cells.end) + Vector2i(1, 1)
	_want = Rect2i(c0, c1 - c0 + Vector2i(1, 1))
	var keep := _want.grow(KEEP_MARGIN)
	for k in chunks.keys():
		if not keep.has_point(k):
			_free_chunk(k)
	_queue.clear()
	var mid := _want.get_center()
	for y in range(_want.position.y, _want.end.y):
		for x in range(_want.position.x, _want.end.x):
			var k := Vector2i(x, y)
			if not chunks.has(k) and _valid(k):
				_queue.append(k)
	_queue.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return Vector2(a - mid).length_squared() < Vector2(b - mid).length_squared())
	if immediate:
		while not _queue.is_empty():
			_build_chunk(_queue.pop_front())


func _valid(k: Vector2i) -> bool:
	return k.x >= 0 and k.y >= 0 and k.x * World.CHUNK < world.w and k.y * World.CHUNK < world.h


func _process(dt: float) -> void:
	for n in BUILD_PER_FRAME:
		if _queue.is_empty():
			break
		var k: Vector2i = _queue.pop_front()
		if not chunks.has(k):
			_build_chunk(k)
	props.animate(dt)


# ---------------------------------------------------------------- blocchi

func _build_chunk(k: Vector2i) -> void:
	var node := Node2D.new()
	node.name = "blocco_%d_%d" % [k.x, k.y]
	add_child(node)
	var walls := _layer(node, ts_misc, -10, Vector2.ZERO)
	var trees := Node2D.new()
	trees.z_index = -5
	node.add_child(trees)
	var terrain: Array[TileMapLayer] = []
	for li in TileDefs.TERRAIN_LAYERS.size():
		terrain.append(_layer(node, ts_terrain, 0, HALF))
	var decor := _layer(node, ts_misc, 1, Vector2.ZERO)
	var plats := _layer(node, ts_misc, 1, Vector2.ZERO)
	var glow_t := _layer(node, ts_terrain_glow, 25, HALF)
	glow_t.modulate = Color(1.0, 1.0, 1.0)
	var glow_d := _layer(node, ts_misc_glow, 25, Vector2.ZERO)
	glow_d.modulate = Color(1.5, 1.5, 1.5)
	var fx := Node2D.new()
	fx.z_index = 26
	node.add_child(fx)
	node.set_meta("terrain", terrain)
	node.set_meta("grid", [walls, decor, glow_d, plats])
	node.set_meta("glow_t", glow_t)
	node.set_meta("fx", fx)
	chunks[k] = node
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for y in range(y0, mini(y0 + World.CHUNK, world.h + 1)):
		for x in range(x0, mini(x0 + World.CHUNK, world.w + 1)):
			_paint_dual(Vector2i(x, y), terrain, glow_t)
			if x < world.w and y < world.h:
				_paint_grid(Vector2i(x, y), walls, decor, glow_d, plats)
	node.set_meta("trees", trees)
	props.fill_chunk(node, k)


func _free_chunk(k: Vector2i) -> void:
	var node: Node2D = chunks[k]
	chunks.erase(k)
	props.forget_chunk(node)
	node.queue_free()


func _layer(parent: Node, ts: TileSet, z: int, offset: Vector2) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.tile_set = ts
	l.z_index = z
	l.position = offset
	parent.add_child(l)
	return l


## Cella della doppia griglia (X, Y): tocca i centri delle tessere (X-1, Y-1), (X, Y-1), (X-1, Y), (X, Y).
func _paint_dual(c: Vector2i, terrain: Array[TileMapLayer], glow: TileMapLayer) -> void:
	var t0 := world.tile(c.x - 1, c.y - 1)
	var t1 := world.tile(c.x, c.y - 1)
	var t2 := world.tile(c.x - 1, c.y)
	var t3 := world.tile(c.x, c.y)
	var v := TerrainPainter.variant_of(c.x, c.y)
	for li in terrain.size():
		var m := _member[li]
		var k := m[t0] | (m[t1] << 1) | (m[t2] << 2) | (m[t3] << 3)
		if k == 0:
			terrain[li].erase_cell(c)
		else:
			terrain[li].set_cell(c, 0, TerrainPainter.coords(li, v, k))
		if li == _glow_layer:
			if k == 0:
				glow.erase_cell(c)
			else:
				glow.set_cell(c, 0, TerrainPainter.coords(li, v, k))


func _paint_grid(c: Vector2i, walls: TileMapLayer, decor: TileMapLayer, glow: TileMapLayer, plats: TileMapLayer) -> void:
	if world.plat(c.x, c.y):
		plats.set_cell(c, 0, DecorPainter.plat_coords(c.x))
	else:
		plats.erase_cell(c)
	# la parete si mette anche dietro i blocchi: i bordi morbidi del terreno lasciano scoperti gli angoli
	var wl := world.wall(c.x, c.y)
	if wl > 0:
		walls.set_cell(c, 0, DecorPainter.wall_coords(wl, c.x, c.y))
	else:
		walls.erase_cell(c)
	var d := world.decor_at(c.x, c.y)
	if d > 0:
		decor.set_cell(c, 0, DecorPainter.decor_coords(d))
		if TileDefs.DECOR_LIGHT.has(d):
			glow.set_cell(c, 0, DecorPainter.decor_coords(d))
		else:
			glow.erase_cell(c)
	else:
		decor.erase_cell(c)
		glow.erase_cell(c)


## Ridisegna ciò che dipende dalla tessera c (dopo uno scavo o un piazzamento), nei blocchi caricati.
func refresh_around(c: Vector2i) -> void:
	for d in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		var q: Vector2i = c + d
		var node: Node2D = chunks.get(World.chunk_of(q))
		if node:
			_paint_dual(q, node.get_meta("terrain"), node.get_meta("glow_t"))
	for dy in range(-1, 2):
		var q := c + Vector2i(0, dy)
		if not world.inside(q.x, q.y):
			continue
		var node: Node2D = chunks.get(World.chunk_of(q))
		if node:
			var g: Array = node.get_meta("grid")
			_paint_grid(q, g[0], g[1], g[2], g[3])


## Ridisegna da capo i blocchi che toccano un rettangolo di celle (luoghi costruiti, porte dei Seminatori): si
## liberano, e la vista li ricostruisce nei fotogrammi dopo.
func refresh_rect(r: Rect2i) -> void:
	for k in chunks.keys():
		if Rect2i(k * World.CHUNK, Vector2i(World.CHUNK, World.CHUNK)).intersects(r.grow(2)):
			_free_chunk(k)
			if _want.has_point(k):
				_queue.push_front(k)          # la coda si riempie solo quando la visuale cambia: si rimette qui


## Combinazione di bordi di una tessera (per le prove: 0 = circondata da blocchi).
func mask(c: Vector2i) -> int:
	var m := 0
	if not world.solid(c.x, c.y - 1):
		m |= 1
	if not world.solid(c.x + 1, c.y):
		m |= 2
	if not world.solid(c.x, c.y + 1):
		m |= 4
	if not world.solid(c.x - 1, c.y):
		m |= 8
	return m


# ---------------------------------------------------------------- oggetti (passano la mano a `props`)

func shake_tree(base: Vector2i) -> void:
	props.shake_tree(base)


func fell_tree(base: Vector2i, dir: int) -> void:
	props.fell_tree(base, dir)


func grow_tree(t: Vector3i) -> void:
	props.grow_tree(t)


func add_station(o: Vector2i) -> void:
	props.add_station(o)


func remove_station(o: Vector2i) -> void:
	props.remove_station(o)


func add_torch(c: Vector2i) -> void:
	props.add_torch(c)


func remove_torch(c: Vector2i) -> void:
	props.remove_torch(c)
