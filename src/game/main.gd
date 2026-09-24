extends Node2D
## TERRAWORLD — scena di gioco: genera il mondo (in un thread, con una schermata d'attesa), poi mette insieme vista a
## blocchi, luce, sfondo, giocatore, creature, barra degli oggetti e azioni. Qui c'è solo il montaggio: ogni parte
## vive nel suo file.

const S := 16

static var next_seed := 20260924

var world: World
var view: WorldView
var light: LightMap
var background: Background
var player: Player
var cam: Camera2D
var hud: Hud
var actions: PlayerActions
var overlay: Sprite2D
var fx: Node2D
var built := false
var gen_times: Array = []
var _gen_task := -1
var _loading: CanvasLayer
var _view_key := Rect2i()


func _ready() -> void:
	_show_loading()
	world = World.new()
	_gen_task = WorkerThreadPool.add_task(func() -> void: gen_times = WorldGen.generate(world, next_seed), false, "genera mondo")


func _show_loading() -> void:
	_loading = CanvasLayer.new()
	_loading.layer = 50
	add_child(_loading)
	var bg := ColorRect.new()
	bg.color = Color("#0f0d18")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_loading.add_child(bg)
	var l := Label.new()
	l.text = "Il seme germoglia…\ngenerazione del mondo"
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color("#cfe8a0"))
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = Vector2(-200, -40)
	l.size = Vector2(400, 80)
	_loading.add_child(l)


func _build() -> void:
	var t0 := Time.get_ticks_msec()
	_make_environment()
	background = Background.new()
	add_child(background)
	background.setup(world)
	view = WorldView.new()
	add_child(view)
	view.setup(world)
	fx = Node2D.new()
	fx.z_index = 6
	add_child(fx)
	player = Player.new()
	player.setup(world)
	player.z_index = 4
	player.position = cell_to_feet(world.spawn)
	add_child(player)
	for k in world.slimes.size():
		var sd: Dictionary = world.slimes[k]
		var sl := Slime.new()
		var sc: Vector2i = sd["cell"]
		sl.position = Vector2(sc.x * S + 8, sc.y * S)
		sl.z_index = 3
		sl.setup(world, sd["kind"], player, world.world_seed + k)
		add_child(sl)
	light = LightMap.new()
	light.setup(world)
	overlay = Sprite2D.new()
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
	cam = Camera2D.new()
	cam.zoom = Vector2(2, 2)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = world.w * S
	cam.limit_bottom = world.h * S
	add_child(cam)
	cam.make_current()
	hud = Hud.new()
	add_child(hud)
	actions = PlayerActions.new()
	add_child(actions)
	actions.setup(world, view, light, player, hud, fx)
	snap_to(world.spawn)
	_loading.queue_free()
	built = true
	var line := "mondo %d×%d, seme %d ·" % [world.w, world.h, world.world_seed]
	for t in gen_times:
		line += " %s %d ms ·" % [t[0], t[1]]
	print(line, " montaggio %d ms" % (Time.get_ticks_msec() - t0))
	if "--prove" in OS.get_cmdline_user_args():
		var pr := AutoTests.new()
		add_child(pr)
		pr.run(self)


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


func cell_to_feet(c: Vector2i) -> Vector2:
	return Vector2(c.x * S + 8, (c.y + 1) * S - Player.HALF.y - 0.1)


func player_cell() -> Vector2i:
	return Vector2i(floori(player.position.x / S), floori(player.position.y / S))


func view_cells() -> Rect2i:
	var cp := cam.get_screen_center_position()
	var size := get_viewport_rect().size / cam.zoom
	return Rect2i(Vector2i((cp - size * 0.5) / S), Vector2i(size / S) + Vector2i(1, 1))


## Porta il giocatore su una cella e aggiorna subito tutto (blocchi, luce, sfondo), senza attese.
func snap_to(c: Vector2i) -> void:
	player.position = cell_to_feet(c)
	player.vel = Vector2.ZERO
	cam.position = player.position + Vector2(0, -12)
	cam.reset_smoothing()
	cam.force_update_scroll()
	view.set_view(view_cells(), true)
	light.compute_now(player_cell(), player_cell())
	overlay.position = Vector2(light.origin) * S
	background.follow(cam.get_screen_center_position(), get_viewport_rect().size / cam.zoom, 0.0, true)


func _process(dt: float) -> void:
	if not built:
		if _gen_task >= 0 and WorkerThreadPool.is_task_completed(_gen_task):
			WorkerThreadPool.wait_for_task_completion(_gen_task)
			_gen_task = -1
			_build()
		return
	cam.position = player.position + Vector2(0, -12)
	var vc := view_cells()
	var key := Rect2i(World.chunk_of(vc.position), World.chunk_of(vc.end))
	if key != _view_key:
		_view_key = key
		view.set_view(vc)
	var pc := player_cell()
	if light.update(pc, pc):
		overlay.position = Vector2(light.origin) * S
	background.follow(cam.get_screen_center_position(), get_viewport_rect().size / cam.zoom, dt)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_R and built:
		next_seed += 1
		get_tree().reload_current_scene()
