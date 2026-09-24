class_name WorldView
extends Node2D
## Disegna il mondo a blocchi: solo i blocchi vicini alla visuale esistono come nodi, gli altri vengono creati
## quando servono (pochi per fotogramma) e liberati quando ci si allontana. Ogni blocco ha pareti e decorazioni sulla
## griglia normale, il terreno dai contorni morbidi sulla «doppia griglia» (vedi `TerrainPainter`), i suoi alberi e le
## sue torce.

const S := 16
const BUILD_PER_FRAME := 1
const KEEP_MARGIN := 2                # blocchi tenuti oltre la visuale prima di liberarli
const HALF := Vector2(-8, -8)         # spostamento della doppia griglia

var world: World
var ts_terrain: TileSet
var ts_terrain_glow: TileSet
var ts_misc: TileSet
var ts_misc_glow: TileSet
var tex_trees: Array[Dictionary] = []
var tex_flame: Texture2D
var tex_stick: Texture2D
var tex_halo: Texture2D
var chunks := {}                      # Vector2i -> Node2D
var _queue: Array[Vector2i] = []
var _want := Rect2i()
var _flames: Array[Sprite2D] = []
var _t := 0.0
var _member: Array[PackedByteArray] = []   # per ogni strato del terreno: 1 se il tipo di tessera ne fa parte
var _glow_layer := -1                 # strato del terreno che ha anche la versione luminosa


func setup(w: World) -> void:
	world = w
	var terrain := TerrainPainter.build()
	ts_terrain = _tileset(ImageTexture.create_from_image(terrain["img"]), 16 * TerrainPainter.VARIANTS, TileDefs.TERRAIN_LAYERS.size())
	ts_terrain_glow = _tileset(ImageTexture.create_from_image(terrain["glow"]), 16 * TerrainPainter.VARIANTS, TileDefs.TERRAIN_LAYERS.size())
	var misc := DecorPainter.build()
	ts_misc = _tileset(ImageTexture.create_from_image(misc["img"]), DecorPainter.COLS, DecorPainter.ROWS)
	ts_misc_glow = _tileset(ImageTexture.create_from_image(misc["glow"]), DecorPainter.COLS, DecorPainter.ROWS)
	for li in TileDefs.TERRAIN_LAYERS.size():
		var L: Dictionary = TileDefs.TERRAIN_LAYERS[li]
		var m := PackedByteArray()
		m.resize(TileDefs.TYPES + 1)
		for t in L["types"]:
			m[t] = 1
		_member.append(m)
		if L.get("glow", false):
			_glow_layer = li
	for v in PassAlberi.VARIANTS:
		var tr := NatureArt.tree_linfa(w.world_seed * 7 + v * 131)
		tex_trees.append({"img": ImageTexture.create_from_image(tr["img"]), "glow": ImageTexture.create_from_image(tr["glow"])})
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


func _tileset(tex: Texture2D, cols: int, rows: int) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(S, S)
	for r in rows:
		for c in cols:
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
	var walls := _layer(node, ts_misc, -10, Vector2.ZERO)
	var trees := Node2D.new()
	trees.z_index = -5
	node.add_child(trees)
	var terrain: Array[TileMapLayer] = []
	for li in TileDefs.TERRAIN_LAYERS.size():
		terrain.append(_layer(node, ts_terrain, 0, HALF))
	var decor := _layer(node, ts_misc, 1, Vector2.ZERO)
	var glow_t := _layer(node, ts_terrain_glow, 25, HALF)
	glow_t.modulate = Color(1.0, 1.0, 1.0)
	var glow_d := _layer(node, ts_misc_glow, 25, Vector2.ZERO)
	glow_d.modulate = Color(1.5, 1.5, 1.5)
	var fx := Node2D.new()
	fx.z_index = 26
	node.add_child(fx)
	node.set_meta("terrain", terrain)
	node.set_meta("grid", [walls, decor, glow_d])
	node.set_meta("glow_t", glow_t)
	node.set_meta("fx", fx)
	chunks[k] = node
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for y in range(y0, mini(y0 + World.CHUNK, world.h + 1)):
		for x in range(x0, mini(x0 + World.CHUNK, world.w + 1)):
			_paint_dual(Vector2i(x, y), terrain, glow_t)
			if x < world.w and y < world.h:
				_paint_grid(Vector2i(x, y), walls, decor, glow_d)
	node.set_meta("trees", trees)
	for t in world.trees.get(k, []):
		_tree_node(node, t)
	for c in world.torches_in(Rect2i(x0, y0, World.CHUNK, World.CHUNK)):
		_torch_nodes(node, c)
	_sparkles(node, k)


## Un albero: un nodo con il perno alla base (serve per scuoterlo e farlo cadere), l'immagine e i baccelli luminosi.
func _tree_node(chunk: Node2D, t: Vector3i) -> void:
	var tex: Dictionary = tex_trees[t.z]
	var img: Texture2D = tex["img"]
	var pivot := Node2D.new()
	pivot.position = Vector2(t.x * S + 8, (t.y + 1) * S + 3)
	(chunk.get_meta("trees") as Node2D).add_child(pivot)
	var sp := Sprite2D.new()
	sp.texture = img
	sp.centered = false
	sp.position = Vector2(-img.get_width() / 2, -img.get_height())
	pivot.add_child(sp)
	var gl := Sprite2D.new()
	gl.texture = tex["glow"]
	gl.centered = false
	gl.position = sp.position
	gl.modulate = Color(1.6, 1.5, 1.3)
	gl.z_as_relative = false
	gl.z_index = 26
	pivot.add_child(gl)
	var by_base: Dictionary = chunk.get_meta("tree_nodes", {})
	by_base[Vector2i(t.x, t.y)] = pivot
	chunk.set_meta("tree_nodes", by_base)


func _tree_pivot(base: Vector2i) -> Node2D:
	var chunk: Node2D = chunks.get(World.chunk_of(base))
	if chunk == null:
		return null
	return (chunk.get_meta("tree_nodes", {}) as Dictionary).get(base)


## Scuote un albero colpito dall'ascia.
func shake_tree(base: Vector2i) -> void:
	var p := _tree_pivot(base)
	if p:
		var tw := create_tween()
		tw.tween_property(p, "rotation", 0.05, 0.05)
		tw.tween_property(p, "rotation", -0.035, 0.07)
		tw.tween_property(p, "rotation", 0.0, 0.06)


## L'albero cade verso `dir` (-1 sinistra, 1 destra) e sparisce.
func fell_tree(base: Vector2i, dir: int) -> void:
	var chunk: Node2D = chunks.get(World.chunk_of(base))
	var p := _tree_pivot(base)
	if p == null:
		return
	(chunk.get_meta("tree_nodes", {}) as Dictionary).erase(base)
	var tw := create_tween()
	tw.tween_property(p, "rotation", 1.45 * dir, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(p, "modulate:a", 0.0, 0.25)
	tw.tween_callback(p.queue_free)


## Un albero nuovo (germoglio cresciuto), se il suo blocco è caricato.
func grow_tree(t: Vector3i) -> void:
	var chunk: Node2D = chunks.get(World.chunk_of(Vector2i(t.x, t.y)))
	if chunk:
		_tree_node(chunk, t)
		var p := _tree_pivot(Vector2i(t.x, t.y))
		p.scale = Vector2(0.2, 0.2)
		create_tween().tween_property(p, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _free_chunk(k: Vector2i) -> void:
	var node: Node2D = chunks[k]
	chunks.erase(k)
	for fl in node.get_meta("flames", []):
		_flames.erase(fl)
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


func _paint_grid(c: Vector2i, walls: TileMapLayer, decor: TileMapLayer, glow: TileMapLayer) -> void:
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
			_paint_grid(q, g[0], g[1], g[2])


func add_torch(c: Vector2i) -> void:
	var node: Node2D = chunks.get(World.chunk_of(c))
	if node:
		_torch_nodes(node, c)


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


# ---------------------------------------------------------------- torce e scintille

## Toglie i nodi di una torcia (fiamma, bastone, alone, scintille) dal suo blocco, se è caricato.
func remove_torch(c: Vector2i) -> void:
	var node: Node2D = chunks.get(World.chunk_of(c))
	if node == null:
		return
	var by_cell: Dictionary = node.get_meta("torch_nodes", {})
	for n in by_cell.get(c, []):
		if n is Sprite2D:
			_flames.erase(n)
			(node.get_meta("flames", []) as Array).erase(n)
		(n as Node).queue_free()
	by_cell.erase(c)


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
	var by_cell: Dictionary = node.get_meta("torch_nodes", {})
	by_cell[c] = [st, fl, halo, p]
	node.set_meta("torch_nodes", by_cell)


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
			p.color_ramp = Fx.fade(Color(1.4, 2.6, 3.0))
			fx.add_child(p)
