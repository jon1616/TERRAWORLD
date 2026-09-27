class_name ViewProps
extends RefCounted
## Gli oggetti che la vista mette nei blocchi oltre al terreno: alberi (con il perno alla base per scuoterli e farli
## cadere), stazioni, torce (fiamma che tremola, alone, braci) e scintille dei cristalli. Separato da `WorldView` per
## tenere i file piccoli; `WorldView` chiama `fill_chunk` quando costruisce un blocco.

const S := 16

var view: WorldView
var world: World
var tex_trees := {}                    # variante (`TreesData`) -> {img, glow}: ogni combinazione si disegna una volta
var tex_stations := {}                # id -> {img, glow}
var tex_flame: Texture2D
var tex_stick: Texture2D
var tex_halo: Texture2D
var _flames: Array[Sprite2D] = []
var _t := 0.0


func setup(v: WorldView, w: World) -> void:
	view = v
	world = w
	# gli alberi delle specie dei biomi di questo mondo, in ogni grandezza e forma (subito: disegnarli mentre si
	# cammina faceva uno scatto la prima volta che se ne vedeva uno)
	var species := {}
	for b in w.biomes:
		species[TreesData.species_of_biome(b)] = true
	for sp in species:
		for size in TreesData.SIZES.size():
			for f in TreesData.FORMS:
				_tree_tex(TreesData.encode(int(sp), size, f))
	for id in StationsData.STATIONS:
		var st := StationArt.make(id)
		tex_stations[id] = {"img": ImageTexture.create_from_image(st["img"]), "glow": ImageTexture.create_from_image(st["glow"])}
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


## Riempie un blocco appena costruito con i suoi alberi, torce, stazioni e scintille.
func fill_chunk(node: Node2D, k: Vector2i) -> void:
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for t in world.trees.get(k, []):
		tree_node(node, t)
	for c in world.torches_in(Rect2i(x0, y0, World.CHUNK, World.CHUNK)):
		torch_nodes(node, c)
	for o in world.stations:
		if World.chunk_of(o) == k:
			station_node(node, o, world.stations[o])
	sparkles(node, k)


func forget_chunk(node: Node2D) -> void:
	for fl in node.get_meta("flames", []):
		_flames.erase(fl)


## Le fiamme delle torce tremolano.
func animate(dt: float) -> void:
	_t += dt
	for fl in _flames:
		var ph: float = fl.get_meta("ph")
		var f := 1.0 + 0.1 * sin(_t * 11.0 + ph) + 0.06 * sin(_t * 23.0 + ph * 2.0)
		fl.scale = Vector2(1.0 / f, f)


## Un albero: un nodo con il perno alla base (serve per scuoterlo e farlo cadere), l'immagine e i baccelli luminosi.
func tree_node(chunk: Node2D, t: Vector3i) -> void:
	var tex: Dictionary = _tree_tex(t.z)
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
	gl.modulate = TreesData.SPECIES[TreesData.decode(t.z)[0]]["glow"]
	gl.z_as_relative = false
	gl.z_index = 26
	pivot.add_child(gl)
	var by_base: Dictionary = chunk.get_meta("tree_nodes", {})
	by_base[Vector2i(t.x, t.y)] = pivot
	chunk.set_meta("tree_nodes", by_base)


## Il disegno di una variante d'albero (fatto la prima volta che serve, poi riusato).
func _tree_tex(v: int) -> Dictionary:
	if not tex_trees.has(v):
		var d := TreesData.decode(v)
		var sp: Dictionary = TreesData.SPECIES[d[0]]
		var tr := TreeArt.make(String(sp["art"]), int(TreesData.SIZES[d[1]]["h"]), world.world_seed * 7 + v * 131)
		tex_trees[v] = {"img": ImageTexture.create_from_image(tr["img"]), "glow": ImageTexture.create_from_image(tr["glow"])}
	return tex_trees[v]


func _tree_pivot(base: Vector2i) -> Node2D:
	var chunk: Node2D = view.chunks.get(World.chunk_of(base))
	if chunk == null:
		return null
	return (chunk.get_meta("tree_nodes", {}) as Dictionary).get(base)


## Scuote un albero colpito dall'ascia.
func shake_tree(base: Vector2i) -> void:
	var p := _tree_pivot(base)
	if p:
		var tw := view.create_tween()
		tw.tween_property(p, "rotation", 0.05, 0.05)
		tw.tween_property(p, "rotation", -0.035, 0.07)
		tw.tween_property(p, "rotation", 0.0, 0.06)


## L'albero cade verso `dir` (-1 sinistra, 1 destra) e sparisce.
func fell_tree(base: Vector2i, dir: int) -> void:
	var chunk: Node2D = view.chunks.get(World.chunk_of(base))
	var p := _tree_pivot(base)
	if p == null:
		return
	(chunk.get_meta("tree_nodes", {}) as Dictionary).erase(base)
	var tw := view.create_tween()
	tw.tween_property(p, "rotation", 1.45 * dir, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(p, "modulate:a", 0.0, 0.25)
	tw.tween_callback(p.queue_free)


## Un albero nuovo (germoglio cresciuto), se il suo blocco è caricato.
func grow_tree(t: Vector3i) -> void:
	var chunk: Node2D = view.chunks.get(World.chunk_of(Vector2i(t.x, t.y)))
	if chunk:
		tree_node(chunk, t)
		var p := _tree_pivot(Vector2i(t.x, t.y))
		p.scale = Vector2(0.2, 0.2)
		view.create_tween().tween_property(p, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- stazioni

func station_node(chunk: Node2D, o: Vector2i, id: String) -> void:
	var tex: Dictionary = tex_stations[id]
	var holder := Node2D.new()
	holder.position = Vector2(o) * S
	holder.z_index = 1
	chunk.add_child(holder)
	var sp := Sprite2D.new()
	sp.texture = tex["img"]
	sp.centered = false
	holder.add_child(sp)
	var gl := Sprite2D.new()
	gl.texture = tex["glow"]
	gl.centered = false
	gl.modulate = Color(1.8, 1.5, 1.2)
	gl.z_as_relative = false
	gl.z_index = 26
	holder.add_child(gl)
	var by_origin: Dictionary = chunk.get_meta("station_nodes", {})
	by_origin[o] = holder
	chunk.set_meta("station_nodes", by_origin)


func add_station(o: Vector2i) -> void:
	var chunk: Node2D = view.chunks.get(World.chunk_of(o))
	if chunk:
		station_node(chunk, o, world.stations[o])


func remove_station(o: Vector2i) -> void:
	var chunk: Node2D = view.chunks.get(World.chunk_of(o))
	if chunk == null:
		return
	var by_origin: Dictionary = chunk.get_meta("station_nodes", {})
	if by_origin.has(o):
		(by_origin[o] as Node).queue_free()
		by_origin.erase(o)


func add_torch(c: Vector2i) -> void:
	var node: Node2D = view.chunks.get(World.chunk_of(c))
	if node:
		torch_nodes(node, c)


# ---------------------------------------------------------------- torce e scintille

## Toglie i nodi di una torcia (fiamma, bastone, alone, scintille) dal suo blocco, se è caricato.
func remove_torch(c: Vector2i) -> void:
	var node: Node2D = view.chunks.get(World.chunk_of(c))
	if node == null:
		return
	var by_cell: Dictionary = node.get_meta("torch_nodes", {})
	for n in by_cell.get(c, []):
		if n is Sprite2D:
			_flames.erase(n)
			(node.get_meta("flames", []) as Array).erase(n)
		(n as Node).queue_free()
	by_cell.erase(c)


func torch_nodes(node: Node2D, c: Vector2i) -> void:
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


func sparkles(node: Node2D, k: Vector2i) -> void:
	var fx: Node2D = node.get_meta("fx")
	var x0 := k.x * World.CHUNK
	var y0 := k.y * World.CHUNK
	for y in range(y0, mini(y0 + World.CHUNK, world.h)):
		for x in range(x0, mini(x0 + World.CHUNK, world.w)):
			if world.tile(x, y) != TileDefs.CRYSTAL or (x * 7 + y * 13) % 4 != 0 or view.mask(Vector2i(x, y)) == 0:
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
