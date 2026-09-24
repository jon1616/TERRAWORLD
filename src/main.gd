extends Node2D
## TERRAWORLD, scena di prova: tutto ciò che si vede è generato dal codice, senza nessuna immagine esterna.
## A/D muovi · Spazio salta · clic sinistro scava · clic destro torcia · 1-0 o rotella oggetti · R mondo nuovo

const S := 16
const REACH := 16.0 * 5.5

static var next_seed := 20260924

var world: World
var light: LightMap
var player: Player
var cam: Camera2D
var layer_walls: TileMapLayer
var layer_tiles: TileMapLayer
var layer_decor: TileMapLayer
var layer_glow: TileMapLayer
var cursor: Node2D
var fx_lit: Node2D                     # effetti sotto il buio (polvere)
var fx_glow: Node2D                    # effetti luminosi sopra il buio (fiamme, scintille)
var bg: Node2D
var bg_layers: Array[Dictionary] = []
var clouds: Array[Sprite2D] = []
var sun: Sprite2D
var flames: Array[Sprite2D] = []
var mining_cell := Vector2i(-9999, -9999)
var mining_t := 0.0
var last_ptile := Vector2i(-999, -999)
var shots := false
var t_time := 0.0
# barra degli oggetti
var items: Array[Dictionary] = []
var sel := 0
var slot_panels: Array[Panel] = []
var item_label: Label
var info_label: Label
var tex_flame: Texture2D
var tex_stick: Texture2D
var tex_halo: Texture2D


func _ready() -> void:
	shots = "--prove" in OS.get_cmdline_user_args()
	var t0 := Time.get_ticks_msec()
	world = World.new()
	world.generate(next_seed)
	var t1 := Time.get_ticks_msec()
	_make_environment()
	_make_background()
	var atlas := Tiles.build()
	var t2 := Time.get_ticks_msec()
	var tex_main := ImageTexture.create_from_image(atlas["img"])
	var tex_glow := ImageTexture.create_from_image(atlas["glow"])
	var ts_main := _tileset(tex_main)
	var ts_glow := _tileset(tex_glow)
	layer_walls = _layer(ts_main, -10)
	var trees := Node2D.new()
	trees.z_index = -5
	add_child(trees)
	layer_tiles = _layer(ts_main, 0)
	layer_decor = _layer(ts_main, 1)
	for y in world.h:
		for x in world.w:
			_refresh_cell(Vector2i(x, y))
	for k in world.trees.size():
		var tc: Vector2i = world.trees[k]
		var ti := Art.tree(world.world_seed + k * 13)
		var sp := Sprite2D.new()
		sp.texture = ImageTexture.create_from_image(ti)
		sp.centered = false
		sp.position = Vector2(tc.x * S + 8 - ti.get_width() / 2, (tc.y + 1) * S - ti.get_height() + 2)
		trees.add_child(sp)
	fx_lit = Node2D.new()
	fx_lit.z_index = 6
	add_child(fx_lit)
	# luce
	light = LightMap.new()
	light.setup(world)
	var t3 := Time.get_ticks_msec()
	var overlay := Sprite2D.new()
	overlay.texture = light.tex
	overlay.centered = false
	overlay.scale = Vector2(S, S)
	overlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	overlay.material = mat
	overlay.z_index = 20
	overlay.visible = not ("--senza-luce" in OS.get_cmdline_user_args())
	add_child(overlay)
	layer_glow = _layer(ts_glow, 25)
	layer_glow.modulate = Color(1.25, 1.25, 1.25)
	for y in world.h:
		for x in world.w:
			_refresh_glow(Vector2i(x, y))
	fx_glow = Node2D.new()
	fx_glow.z_index = 26
	add_child(fx_glow)
	cursor = Node2D.new()
	cursor.set_script(load("res://src/cursor.gd"))
	cursor.z_index = 27
	add_child(cursor)
	# torce e scintille dei cristalli
	tex_flame = ImageTexture.create_from_image(Art.flame())
	tex_stick = ImageTexture.create_from_image(Art.torch_stick())
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
	for c in world.torches:
		_spawn_torch(c)
	_spawn_sparkles()
	# giocatore e slime
	player = Player.new()
	player.setup(world)
	player.z_index = 4
	player.position = Vector2(world.spawn.x * S + 8, (world.spawn.y + 1) * S - Player.HALF.y - 0.1)
	add_child(player)
	for k in world.slimes.size():
		var sd: Dictionary = world.slimes[k]
		var sl := Slime.new()
		var sc: Vector2i = sd["cell"]
		sl.position = Vector2(sc.x * S + 8, sc.y * S)
		sl.z_index = 3
		sl.setup(world, sd["kind"], player, world.world_seed + k)
		add_child(sl)
	cam = Camera2D.new()
	cam.zoom = Vector2(2, 2)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = world.w * S
	cam.limit_bottom = world.h * S
	cam.position = player.position
	add_child(cam)
	cam.make_current()
	_make_hud()
	print("mondo %d ms · tessere %d ms · luce %d ms" % [t1 - t0, t2 - t1, t3 - t2])
	if shots:
		_run_shots()


# ---------------------------------------------------------------- costruzione

func _make_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_strength = 1.0
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	for k in 7:
		env.set_glow_level(k, 1.0 if k >= 1 and k <= 4 else 0.0)
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sky := CanvasLayer.new()
	sky.layer = -10
	add_child(sky)
	var tr := TextureRect.new()
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array([0.0, 0.42, 0.74, 1.0])
	gr.colors = PackedColorArray([Color("#4a60a8"), Color("#8a94d0"), Color("#f0a890"), Color("#ffdca8")])
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 256
	tr.texture = gt
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	sky.add_child(tr)


func _make_background() -> void:
	bg = Node2D.new()
	bg.z_index = -30
	add_child(bg)
	var sy := float(world.surface[world.spawn.x] * S)
	sun = Sprite2D.new()
	sun.texture = ImageTexture.create_from_image(Art.sun())
	sun.modulate = Color(2.6, 2.2, 1.6)
	bg.add_child(sun)
	for k in 6:
		var cl := Sprite2D.new()
		cl.texture = ImageTexture.create_from_image(Art.cloud(world.world_seed + k * 31))
		cl.set_meta("x", k * 260.0 + (k % 2) * 90.0)
		cl.set_meta("y", -150.0 - (k % 3) * 40.0)
		cl.modulate = Color(1, 1, 1, 0.92)
		bg.add_child(cl)
		clouds.append(cl)
	var defs := [
		[0.1, -20.0, 512, 150.0, 80.0, 0.012, "#c4b4e0", "#d4c0dc", true, Color(0, 0, 0, 0)],
		[0.22, 20.0, 512, 150.0, 55.0, 0.016, "#8e84c0", "#7a76ac", false, Color(0, 0, 0, 0)],
		[0.42, 60.0, 512, 150.0, 35.0, 0.02, "#4f6090", "#3e4e78", false, Color("#34466e")],
	]
	for k in defs.size():
		var d: Array = defs[k]
		var im := Art.mountains(d[2], 420, world.world_seed + 50 + k, d[3], d[4], d[5], Color(d[6]), Color(d[7]), d[8], d[9])
		var tex := ImageTexture.create_from_image(im)
		var node := Node2D.new()
		bg.add_child(node)
		var sprites: Array[Sprite2D] = []
		for n in 4:
			var sp := Sprite2D.new()
			sp.texture = tex
			sp.centered = false
			node.add_child(sp)
			sprites.append(sp)
		bg_layers.append({"node": node, "f": d[0], "anchor": sy - 150.0 + d[1], "w": float(d[2]), "sprites": sprites})


func _tileset(tex: Texture2D) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(S, S)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(S, S)
	for r in Tiles.ROWS:
		for c in Tiles.COLS:
			src.create_tile(Vector2i(c, r))
	ts.add_source(src, 0)
	return ts


func _layer(ts: TileSet, z: int) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.tile_set = ts
	l.z_index = z
	add_child(l)
	return l


func _variant(c: Vector2i) -> int:
	return absi((c.x * 73856093) ^ (c.y * 19349663)) % Tiles.VARIANTS


func _mask(c: Vector2i) -> int:
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


func _refresh_cell(c: Vector2i) -> void:
	if c.x < 0 or c.y < 0 or c.x >= world.w or c.y >= world.h:
		return
	var t := world.tile(c.x, c.y)
	var v := _variant(c)
	if t == Tiles.AIR:
		layer_tiles.erase_cell(c)
	else:
		layer_tiles.set_cell(c, 0, Vector2i(_mask(c) * Tiles.VARIANTS + v, t - 1))
	var wl := world.wall(c.x, c.y)
	if wl > 0:
		layer_walls.set_cell(c, 0, Vector2i((wl - 1) * Tiles.VARIANTS + v, Tiles.WALL_ROW))
	var d: int = world.decor[c.y * world.w + c.x]
	if d > 0:
		layer_decor.set_cell(c, 0, Vector2i(d - 1, Tiles.DECOR_ROW))
	else:
		layer_decor.erase_cell(c)


func _refresh_glow(c: Vector2i) -> void:
	if c.x < 0 or c.y < 0 or c.x >= world.w or c.y >= world.h:
		return
	var t := world.tile(c.x, c.y)
	var d: int = world.decor[c.y * world.w + c.x]
	if t == Tiles.CRYSTAL:
		layer_glow.set_cell(c, 0, Vector2i(_mask(c) * Tiles.VARIANTS + _variant(c), t - 1))
	elif d == Tiles.DECOR_GLOW:
		layer_glow.set_cell(c, 0, Vector2i(d - 1, Tiles.DECOR_ROW))
	else:
		layer_glow.erase_cell(c)


func _spawn_torch(c: Vector2i) -> void:
	var base := Vector2(c.x * S + 8, (c.y + 1) * S)
	var st := Sprite2D.new()
	st.texture = tex_stick
	st.position = base + Vector2(0, -5)
	st.z_index = 2
	add_child(st)
	var fl := Sprite2D.new()
	fl.texture = tex_flame
	fl.offset = Vector2(0, -4)
	fl.position = base + Vector2(0, -9)
	fl.modulate = Color(2.2, 1.6, 1.0)
	fl.set_meta("ph", randf() * 10.0)
	fx_glow.add_child(fl)
	flames.append(fl)
	var halo := Sprite2D.new()
	halo.texture = tex_halo
	halo.position = base + Vector2(0, -10)
	halo.modulate = Color(1.0, 0.62, 0.3, 0.22)
	var hm := CanvasItemMaterial.new()
	hm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = hm
	fx_glow.add_child(halo)
	var p := CPUParticles2D.new()
	p.position = base + Vector2(0, -14)
	p.amount = 5
	p.lifetime = 1.1
	p.direction = Vector2(0, -1)
	p.spread = 25.0
	p.gravity = Vector2(0, -20)
	p.initial_velocity_min = 8.0
	p.initial_velocity_max = 20.0
	p.color = Color(2.4, 1.3, 0.5)
	p.color_ramp = _fade(Color(2.4, 1.3, 0.5))
	fx_glow.add_child(p)


func _spawn_sparkles() -> void:
	var n := 0
	for y in world.h:
		for x in world.w:
			if world.tile(x, y) != Tiles.CRYSTAL or _mask(Vector2i(x, y)) == 0:
				continue
			if (x * 7 + y * 13) % 4 != 0 or n > 80:
				continue
			n += 1
			var p := CPUParticles2D.new()
			p.position = Vector2(x * S + 8, y * S + 8)
			p.amount = 2
			p.lifetime = 1.6
			p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
			p.emission_rect_extents = Vector2(9, 9)
			p.gravity = Vector2(0, -6)
			p.initial_velocity_min = 0.0
			p.initial_velocity_max = 3.0
			p.color = Color(2.0, 1.6, 3.2)
			p.color_ramp = _fade(Color(2.0, 1.6, 3.2))
			fx_glow.add_child(p)


func _fade(c: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.3, 1.0])
	var c0 := c
	c0.a = 0.0
	g.colors = PackedColorArray([c0, c, c0])
	return g


func _make_hud() -> void:
	var metals := {"rame": Art.M_COPPER, "ferro": Art.M_IRON, "oro": Art.M_GOLD, "cristallo": Art.M_CRYSTAL}
	items = [
		{"name": "Piccone di rame", "img": Art.icon_pickaxe(Art.M_COPPER), "use": "scava"},
		{"name": "Spada di rame", "img": Art.icon_sword(Art.M_COPPER), "use": "colpo"},
		{"name": "Spada di ferro", "img": Art.icon_sword(Art.M_IRON), "use": "colpo"},
		{"name": "Spada d'oro", "img": Art.icon_sword(Art.M_GOLD), "use": "colpo"},
		{"name": "Lama di cristallo", "img": Art.icon_sword(Art.M_CRYSTAL), "use": "colpo"},
		{"name": "Arco di legno", "img": Art.icon_bow(), "use": ""},
		{"name": "Torcia", "img": Art.icon_torch(), "use": "torcia"},
		{"name": "Lingotto di rame", "img": Art.icon_bar(Art.M_COPPER), "use": ""},
		{"name": "Lingotto d'oro", "img": Art.icon_bar(metals["oro"]), "use": ""},
		{"name": "Pozione di cura", "img": Art.icon_potion(), "use": ""},
	]
	var hud := CanvasLayer.new()
	hud.layer = 10
	add_child(hud)
	var row := HBoxContainer.new()
	row.position = Vector2(20, 40)
	row.add_theme_constant_override("separation", 6)
	hud.add_child(row)
	for k in items.size():
		var it: Dictionary = items[k]
		it["tex"] = ImageTexture.create_from_image(it["img"])
		var pn := Panel.new()
		pn.custom_minimum_size = Vector2(60, 60)
		row.add_child(pn)
		var tr := TextureRect.new()
		tr.texture = it["tex"]
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.position = Vector2(6, 6)
		tr.size = Vector2(48, 48)
		pn.add_child(tr)
		var num := Label.new()
		num.text = str((k + 1) % 10)
		num.position = Vector2(5, 1)
		num.add_theme_font_size_override("font_size", 13)
		num.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		num.add_theme_constant_override("outline_size", 4)
		pn.add_child(num)
		slot_panels.append(pn)
	item_label = _label(hud, Vector2(22, 8), 20)
	info_label = _label(hud, Vector2(20, 820), 16)
	info_label.text = "A/D muovi · Spazio salta · clic sinistro usa (scava col piccone) · clic destro torcia · 1-0 / rotella oggetti · R mondo nuovo\nTutto ciò che vedi è generato dal codice: nessuna immagine esterna."
	_select(0)


func _label(parent: Node, pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color("#fff4dc"))
	l.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.1))
	l.add_theme_constant_override("outline_size", 6)
	parent.add_child(l)
	return l


func _select(k: int) -> void:
	sel = (k + items.size()) % items.size()
	for i in slot_panels.size():
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.1, 0.12, 0.26, 0.78) if i != sel else Color(0.22, 0.2, 0.36, 0.9)
		sb.set_border_width_all(2 if i != sel else 3)
		sb.border_color = Color(0.36, 0.42, 0.72) if i != sel else Color("#f2cc5a")
		sb.set_corner_radius_all(6)
		slot_panels[i].add_theme_stylebox_override("panel", sb)
	item_label.text = items[sel]["name"]
	var use: String = items[sel]["use"]
	player_tool_update(use)


func player_tool_update(use: String) -> void:
	if player == null:
		return
	player.tool_tex = items[sel]["tex"] if use == "scava" or use == "colpo" else null


# ---------------------------------------------------------------- gioco

func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if e.keycode >= KEY_0 and e.keycode <= KEY_9:
			_select((e.keycode - KEY_0 + 9) % 10)
		elif e.keycode == KEY_R:
			next_seed += 1
			get_tree().reload_current_scene()
	elif e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_WHEEL_UP:
			_select(sel - 1)
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_select(sel + 1)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			_try_torch(_mouse_cell())
		elif e.button_index == MOUSE_BUTTON_LEFT and items[sel]["use"] == "torcia":
			_try_torch(_mouse_cell())


func _mouse_cell() -> Vector2i:
	var mp := get_global_mouse_position()
	return Vector2i(int(floor(mp.x / S)), int(floor(mp.y / S)))


func _in_reach(c: Vector2i) -> bool:
	return (Vector2(c) * S + Vector2(8, 8)).distance_to(player.position) <= REACH


func _process(dt: float) -> void:
	t_time += dt
	cam.position = player.position + Vector2(0, -12)
	var pt := Vector2i(int(player.position.x / S), int(player.position.y / S))
	if pt != last_ptile:
		last_ptile = pt
		light.set_player(pt)
	_update_background()
	for fl in flames:
		var ph: float = fl.get_meta("ph")
		var f := 1.0 + 0.1 * sin(t_time * 11.0 + ph) + 0.06 * sin(t_time * 23.0 + ph * 2.0)
		fl.scale = Vector2(1.0 / f, f)
	if shots:
		return
	var c := _mouse_cell()
	var reach := _in_reach(c)
	var use: String = items[sel]["use"]
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	player.swinging = down and (use == "scava" or use == "colpo")
	if player.swinging:
		player.facing = 1 if get_global_mouse_position().x >= player.position.x else -1
	var prog := 0.0
	if down and use == "scava" and reach and world.solid(c.x, c.y) and c.y < world.h - 1:
		if c != mining_cell:
			mining_cell = c
			mining_t = 0.0
		mining_t += dt
		var hard: float = Tiles.HARD[world.tile(c.x, c.y)]
		prog = mining_t / hard
		if mining_t >= hard:
			_break(c)
			mining_t = 0.0
			prog = 0.0
	else:
		mining_t = 0.0
	cursor.set_state(c, reach and (world.solid(c.x, c.y) or use == "torcia"), prog)


func _break(c: Vector2i) -> void:
	var t := world.tile(c.x, c.y)
	world.set_tile(c.x, c.y, Tiles.AIR)
	var up := c + Vector2i(0, -1)
	if up.y >= 0 and world.decor[up.y * world.w + up.x] != 0:
		world.decor[up.y * world.w + up.x] = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			_refresh_cell(c + Vector2i(dx, dy))
			_refresh_glow(c + Vector2i(dx, dy))
	light.tile_changed(c)
	_dust(c, t)


func _try_torch(c: Vector2i) -> void:
	if not _in_reach(c) or world.solid(c.x, c.y) or world.torches.has(c):
		return
	if not world.solid(c.x, c.y + 1) and world.wall(c.x, c.y) == 0:
		return
	world.torches[c] = true
	world.decor[c.y * world.w + c.x] = 0
	_refresh_cell(c)
	_refresh_glow(c)
	_spawn_torch(c)
	light.tile_changed(c)


func _dust(c: Vector2i, t: int) -> void:
	var cols := Tiles.dust_colors(t)
	var p := CPUParticles2D.new()
	p.position = Vector2(c) * S + Vector2(8, 8)
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 16
	p.lifetime = 0.7
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(6, 6)
	p.direction = Vector2(0, -1)
	p.spread = 180.0
	p.gravity = Vector2(0, 520)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 110.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([cols[1], cols[2], cols[cols.size() - 1]])
	p.color_initial_ramp = g
	fx_lit.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.2).timeout.connect(p.queue_free)


func _update_background() -> void:
	var cp := cam.get_screen_center_position()
	var view := get_viewport_rect().size / cam.zoom
	sun.position = Vector2(cp.x * 0.97, 0.0) + Vector2(view.x * 0.22, 0.0)
	sun.position.y = cp.y * 0.95 + (world.surface[world.spawn.x] * S - 200.0) * 0.05
	for cl in clouds:
		var bx: float = cl.get_meta("x")
		var by: float = cl.get_meta("y")
		var wrap := 1560.0
		var x := fposmod(bx + t_time * 6.0 - cp.x * 0.05, wrap) - wrap * 0.5
		cl.position = Vector2(cp.x + x, cp.y * 0.93 + (world.surface[world.spawn.x] * S) * 0.07 + by)
	for L in bg_layers:
		var f: float = L["f"]
		var node: Node2D = L["node"]
		var iw: float = L["w"]
		var anchor: float = L["anchor"]
		var sy := float(world.surface[world.spawn.x] * S)
		node.position = Vector2(cp.x * (1.0 - f), anchor + (cp.y - sy) * (1.0 - f))
		var k0 := floorf((cp.x - view.x * 0.5 - node.position.x) / iw)
		var sprites: Array = L["sprites"]
		for i in sprites.size():
			var sp: Sprite2D = sprites[i]
			sp.position = Vector2((k0 + i) * iw, 0)


# ---------------------------------------------------------------- prove automatiche (screenshot)

func _frames(n: int) -> void:
	for k in n:
		await get_tree().process_frame


func _save(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path("res://prove/%s.png" % name))
	print("salvato ", name)


func _teleport(c: Vector2i) -> void:
	player.position = Vector2(c.x * S + 8, (c.y + 1) * S - Player.HALF.y - 0.1)
	player.vel = Vector2.ZERO
	cam.position = player.position + Vector2(0, -12)
	cam.reset_smoothing()


func _floor_near(c: Vector2i, radius: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var bd := 1e9
	for y in range(c.y - radius, c.y + radius + 1):
		for x in range(c.x - radius, c.x + radius + 1):
			if world.solid(x, y) or world.solid(x, y - 1) or not world.solid(x, y + 1) or y < 1:
				continue
			var d := Vector2(x - c.x, y - c.y).length()
			if d < bd and d > 1.5:
				bd = d
				best = Vector2i(x, y)
	return best


func _run_shots() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://prove"))
	player.control = false
	await _frames(30)
	await _save("01_superficie")
	# grotta con torcia: la torcia più vicina alla partenza tra quelle non troppo profonde
	var best := Vector2i(-1, -1)
	var bd := 1e9
	for k in world.torches:
		var c: Vector2i = k
		var dep := world.depth(c.x, c.y)
		if dep < 14 or dep > 45:
			continue
		var d := Vector2(c - world.spawn).length()
		if d < bd:
			bd = d
			best = c
	if best.x >= 0:
		var f := _floor_near(best, 6)
		if f.x >= 0:
			_teleport(f)
			await _frames(25)
			await _save("02_grotta_torcia")
			player.force_swing = true
			var target := f + Vector2i(1, 0)
			for k in 3:
				if world.solid(target.x, target.y):
					break
				target.x += 1
			if world.solid(target.x, target.y):
				_break(target)
			await _frames(4)
			await _save("04_scavo")
			player.force_swing = false
	# cristalli
	var cr := Vector2i(-1, -1)
	bd = 1e9
	for y in world.h:
		for x in world.w:
			if world.tile(x, y) == Tiles.CRYSTAL and _mask(Vector2i(x, y)) != 0:
				var d := Vector2(x - world.spawn.x, y - world.spawn.y).length()
				if d < bd:
					bd = d
					cr = Vector2i(x, y)
	if cr.x >= 0:
		var f2 := _floor_near(cr, 8)
		if f2.x >= 0:
			_teleport(f2)
			await _frames(25)
			await _save("03_cristalli")
	_save_map()
	get_tree().quit()


func _save_map() -> void:
	var im := Image.create_empty(world.w, world.h, false, Image.FORMAT_RGB8)
	var cols := {Tiles.DIRT: Color("#7a4e33"), Tiles.GRASS: Color("#3f8733"), Tiles.STONE: Color("#676d7a"),
		Tiles.COPPER: Color("#cf7a3e"), Tiles.IRON: Color("#c0c0cc"), Tiles.GOLD: Color("#f0c83a"), Tiles.CRYSTAL: Color("#b08aff")}
	for y in world.h:
		for x in world.w:
			var t := world.tile(x, y)
			var c: Color
			if t != Tiles.AIR:
				c = cols[t]
			elif world.wall(x, y) != 0:
				c = Color("#2a2420")
			else:
				c = Color("#8aa8e0")
			if world.torches.has(Vector2i(x, y)):
				c = Color("#ffcc40")
			im.set_pixel(x, y, c)
	im.resize(world.w * 4, world.h * 4, Image.INTERPOLATE_NEAREST)
	im.save_png(ProjectSettings.globalize_path("res://prove/mappa.png"))
