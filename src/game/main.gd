extends Node2D
## TERRAWORLD — scena di gioco: carica o genera il mondo scelto nel menu (in un thread, con una schermata d'attesa),
## poi mette insieme vista a blocchi, luce, sfondo, giocatore, creature, barra degli oggetti e azioni, e salva.
## Qui c'è solo il montaggio: ogni parte vive nel suo file.

const S := 16
const MENU_SCENE := "res://src/ui/menu.tscn"
const AUTOSAVE := 300.0                # secondi tra un salvataggio automatico e l'altro

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
var world_id := ""
var world_meta := {}
var character: Character
var _session_time := 0.0              # secondi giocati dall'ultimo salvataggio
var _autosave := AUTOSAVE


func _ready() -> void:
	if Session.character == null:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
		return
	get_tree().set_auto_accept_quit(false)
	character = Session.character
	if Session.world_id != "":
		world_id = Session.world_id
		world_meta = WorldSave.read_meta(world_id)
		_show_loading("Il mondo si risveglia…")
		_gen_task = WorkerThreadPool.add_task(func() -> void: world = WorldSave.load_world(world_id), false, "carica mondo")
	else:
		var nw: Dictionary = Session.new_world
		world_id = nw["id"]
		world_meta = {"nome": nw["nome"], "creato": SavePaths.now_text(), "tempo_di_gioco": 0.0, "giocatori": {}}
		_show_loading("Il seme germoglia…\ngenerazione del mondo")
		world = World.new()
		var sd: int = nw["seme"]
		_gen_task = WorkerThreadPool.add_task(func() -> void: gen_times = WorldGen.generate(world, sd), false, "genera mondo")


func _show_loading(text: String) -> void:
	_loading = CanvasLayer.new()
	_loading.layer = 50
	add_child(_loading)
	var bg := ColorRect.new()
	bg.color = Color("#0f0d18")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_loading.add_child(bg)
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color("#cfe8a0"))
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = Vector2(-200, -40)
	l.size = Vector2(400, 80)
	_loading.add_child(l)


func _build() -> void:
	var t0 := Time.get_ticks_msec()
	if world == null:
		push_error("mondo %s illeggibile" % world_id)
		get_tree().change_scene_to_file(MENU_SCENE)
		return
	if world.slimes.is_empty():
		var rng := RandomNumberGenerator.new()
		rng.seed = world.world_seed
		PassPartenza.place_creatures(world, rng)
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
	_make_spores()
	hud = Hud.new()
	add_child(hud)
	actions = PlayerActions.new()
	add_child(actions)
	actions.setup(world, view, light, player, hud, fx)
	hud.select(character.hotbar)
	var start := world.spawn
	var pos: Array = (world_meta.get("giocatori", {}) as Dictionary).get(character.id, [])
	if pos.size() == 2:
		start = Vector2i(int(pos[0]), int(pos[1]))
	snap_to(start)
	_loading.queue_free()
	built = true
	if Session.world_id == "":
		save_game()          # un mondo appena nato si salva subito
		Session.start_saved_world(world_id)
	var line := "mondo «%s» %d×%d, seme %d ·" % [world_meta.get("nome", world_id), world.w, world.h, world.world_seed]
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


## Spore luminose che fluttuano nell'aria attorno alla visuale, in superficie e nelle grotte.
var _spores: CPUParticles2D


func _make_spores() -> void:
	_spores = CPUParticles2D.new()
	_spores.z_index = 26
	_spores.amount = 70
	_spores.lifetime = 7.0
	_spores.preprocess = 7.0
	_spores.local_coords = false
	_spores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_spores.emission_rect_extents = Vector2(460, 270)
	_spores.direction = Vector2(0.3, -1)
	_spores.spread = 60.0
	_spores.gravity = Vector2(0, -2)
	_spores.initial_velocity_min = 2.0
	_spores.initial_velocity_max = 8.0
	_spores.scale_amount_min = 1.0
	_spores.scale_amount_max = 1.6
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	g.colors = PackedColorArray([Color(0.6, 1.4, 1.3), Color(1.6, 1.2, 0.6), Color(0.9, 0.7, 1.6)])
	_spores.color_initial_ramp = g
	var fade := Gradient.new()
	fade.offsets = PackedFloat32Array([0.0, 0.2, 0.8, 1.0])
	fade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0.8), Color(1, 1, 1, 0)])
	_spores.color_ramp = fade
	add_child(_spores)


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
	_spores.position = cam.get_screen_center_position()
	_session_time += dt
	_autosave -= dt
	if _autosave <= 0.0:
		_autosave = AUTOSAVE
		save_game()
		hud.toast("Salvataggio automatico")


# ---------------------------------------------------------------- salvataggi

## Salva mondo e personaggio (mondo ~15 ms, file ~0,5 MB).
func save_game() -> void:
	if not built or world == null:
		return
	world_meta["tempo_di_gioco"] = float(world_meta.get("tempo_di_gioco", 0.0)) + _session_time
	character.play_time += _session_time
	_session_time = 0.0
	var players: Dictionary = world_meta.get("giocatori", {})
	var pc := player_cell()
	players[character.id] = [pc.x, pc.y]
	world_meta["giocatori"] = players
	var err := WorldSave.save(world, world_id, world_meta)
	if err != OK:
		push_error("salvataggio del mondo non riuscito: %s" % error_string(err))
		hud.toast("Salvataggio NON riuscito")
	character.hotbar = hud.sel
	character.last_world = world_id
	character.save()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE and built:
		save_game()
		get_tree().change_scene_to_file(MENU_SCENE)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
