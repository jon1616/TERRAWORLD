class_name WorldView
extends Node2D
## Disegna il mondo a blocchi: solo i blocchi vicini alla visuale esistono come nodi, gli altri vengono creati
## quando servono (pochi per fotogramma) e liberati quando ci si allontana. Ogni blocco ha i suoi livelli di tessere,
## i suoi alberi e le sue torce.

const S := 16
const BUILD_PER_FRAME := 2
const KEEP_MARGIN := 2                # blocchi tenuti oltre la visuale prima di liberarli

var world: World
var ts_main: TileSet
var ts_glow: TileSet
var tex_trees: Array[Texture2D] = []
var tex_flame: Texture2D
var tex_stick: Texture2D
var tex_halo: Texture2D
var chunks := {}                      # Vector2i -> Node2D
var _queue: Array[Vector2i] = []
var _want := Rect2i()
var _flames: Array[Sprite2D] = []
var _t := 0.0


func setup(w: World) -> void:
	world = w
	var atlas := TilePainter.build()
	ts_main = _tileset(ImageTexture.create_from_image(atlas["img"]))
	ts_glow = _tileset(ImageTexture.create_from_image(atlas["glow"]))
	for v in PassAlberi.VARIANTS:
		tex_trees.append(ImageTexture.create_from_image(NatureArt.tree(w.world_seed * 7 + v * 131)))
	tex_flame = ImageTexture.create_from_image(NatureArt.flame())
	tex_stick = ImageTexture.create_from_image(NatureArt.torch_stick())
	var hg := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	gr.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.35), Color(1, 1, 1, 0)])
	hg.gradient = gr
	hg.fill = GradientTexture2D.FILL_RADIAL
	hg.fill_from = Vector2(0.5, 0.5)
	hg.fill_to = Vector2(1.0, 0.5)
	hg.width = 128
	hg.height = 128
	tex_halo = hg


func _tileset(tex: Texture2D) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(S, S)
	for r in TilePainter.ROWS:
		for c in TilePainter.COLS:
			src.create_tile(Vector2i(c, r))
	ts.add_source(src, 0)
	return ts


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
	_t += dt
	for fl in _flames:
		var ph: float = fl.get_meta("ph")
		var f := 1.0 + 0.1 * sin(_t * 11.0 + ph) + 0.06 * sin(_t * 23.0 + ph * 2.0)
		fl.scale = Vector2(1.0 / f, f)


# ---------------------------------------------------------------- blocchi

func _build_chunk(k: Vector2i) -> void:
	var node := Node2D.new()
	node.name = "blocco_%d_%d" % [k.x, k.y]
	add_child(node)
	var walls := _layer(node, ts_main, -10)
	var trees := Node2D.new()
	trees.z_index = -5
	node.add_child(trees)
	var tiles := _layer(node, ts_main, 0)
	var decor := _layer(node, ts_main, 1)
	var glow := _layer(node, ts_glow, 25)
	glow.modulate = Color(1.25, 1.25, 1.25)
	var fx := Node2D.new()
	fx.z_index = 26
	node.add_child(fx)
	node.set_meta("layers", [walls, tiles, decor, glow])
	node.set_meta("fx", fx)
	chunks[k] = node
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for y in range(y0, mini(y0 + World.CHUNK, world.h)):
		for x in range(x0, mini(x0 + World.CHUNK, world.w)):
			_paint_cell(Vector2i(x, y), walls, tiles, decor, glow)
	for t in world.trees.get(k, []):
		var tex: Texture2D = tex_trees[t.z]
		var sp := Sprite2D.new()
		sp.texture = tex
		sp.centered = false
		sp.position = Vector2(t.x * S + 8 - tex.get_width() / 2, (t.y + 1) * S - tex.get_height() + 2)
		trees.add_child(sp)
	for c in world.torches_in(Rect2i(x0, y0, World.CHUNK, World.CHUNK)):
		_torch_nodes(node, c)
	_sparkles(node, k)


func _free_chunk(k: Vector2i) -> void:
	var node: Node2D = chunks[k]
	chunks.erase(k)
	for fl in node.get_meta("flames", []):
		_flames.erase(fl)
	node.queue_free()


func _layer(parent: Node, ts: TileSet, z: int) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.tile_set = ts
	l.z_index = z
	parent.add_child(l)
	return l


func _variant(c: Vector2i) -> int:
	return absi((c.x * 73856093) ^ (c.y * 19349663)) % TilePainter.VARIANTS


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


func _paint_cell(c: Vector2i, walls: TileMapLayer, tiles: TileMapLayer, decor: TileMapLayer, glow: TileMapLayer) -> void:
	var t := world.tile(c.x, c.y)
	var v := _variant(c)
	if t == TileDefs.AIR:
		tiles.erase_cell(c)
	else:
		tiles.set_cell(c, 0, TilePainter.tile_coords(t, mask(c), v))
	var wl := world.wall(c.x, c.y)
	if wl > 0:
		walls.set_cell(c, 0, TilePainter.wall_coords(wl, v))
	else:
		walls.erase_cell(c)
	var d := world.decor_at(c.x, c.y)
	if d > 0:
		decor.set_cell(c, 0, TilePainter.decor_coords(d))
	else:
		decor.erase_cell(c)
	if t == TileDefs.CRYSTAL:
		glow.set_cell(c, 0, TilePainter.tile_coords(t, mask(c), v))
	elif d == TileDefs.DECOR_GLOW:
		glow.set_cell(c, 0, TilePainter.decor_coords(d))
	else:
		glow.erase_cell(c)


## Ridisegna una cella e le sue vicine (dopo uno scavo o un piazzamento), se il loro blocco è caricato.
func refresh_around(c: Vector2i) -> void:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var q := c + Vector2i(dx, dy)
			if not world.inside(q.x, q.y):
				continue
			var node: Node2D = chunks.get(World.chunk_of(q))
			if node:
				var ls: Array = node.get_meta("layers")
				_paint_cell(q, ls[0], ls[1], ls[2], ls[3])


func add_torch(c: Vector2i) -> void:
	var node: Node2D = chunks.get(World.chunk_of(c))
	if node:
		_torch_nodes(node, c)


# ---------------------------------------------------------------- torce e scintille

func _torch_nodes(node: Node2D, c: Vector2i) -> void:
	var fx: Node2D = node.get_meta("fx")
	var base := Vector2(c.x * S + 8, (c.y + 1) * S)
	var st := Sprite2D.new()
	st.texture = tex_stick
	st.position = base + Vector2(0, -5)
	st.z_index = 2
	node.add_child(st)
	var fl := Sprite2D.new()
	fl.texture = tex_flame
	fl.offset = Vector2(0, -4)
	fl.position = base + Vector2(0, -9)
	fl.modulate = Color(2.2, 1.6, 1.0)
	fl.set_meta("ph", float((c.x * 13 + c.y * 7) % 100) * 0.1)
	fx.add_child(fl)
	_flames.append(fl)
	var list: Array = node.get_meta("flames", [])
	list.append(fl)
	node.set_meta("flames", list)
	var halo := Sprite2D.new()
	halo.texture = tex_halo
	halo.position = base + Vector2(0, -10)
	halo.modulate = Color(1.0, 0.62, 0.3, 0.22)
	var hm := CanvasItemMaterial.new()
	hm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = hm
	fx.add_child(halo)
	var p := CPUParticles2D.new()
	p.position = base + Vector2(0, -14)
	p.amount = 5
	p.lifetime = 1.1
	p.direction = Vector2(0, -1)
	p.spread = 25.0
	p.gravity = Vector2(0, -20)
	p.initial_velocity_min = 8.0
	p.initial_velocity_max = 20.0
	p.color_ramp = Fx.fade(Color(2.4, 1.3, 0.5))
	fx.add_child(p)


func _sparkles(node: Node2D, k: Vector2i) -> void:
	var fx: Node2D = node.get_meta("fx")
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for y in range(y0, mini(y0 + World.CHUNK, world.h)):
		for x in range(x0, mini(x0 + World.CHUNK, world.w)):
			if world.tile(x, y) != TileDefs.CRYSTAL or (x * 7 + y * 13) % 4 != 0 or mask(Vector2i(x, y)) == 0:
				continue
			var p := CPUParticles2D.new()
			p.position = Vector2(x * S + 8, y * S + 8)
			p.amount = 2
			p.lifetime = 1.6
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			p.emission_rect_extents = Vector2(9, 9)
			p.gravity = Vector2(0, -6)
			p.initial_velocity_min = 0.0
			p.initial_velocity_max = 3.0
			p.color_ramp = Fx.fade(Color(2.0, 1.6, 3.2))
			fx.add_child(p)
