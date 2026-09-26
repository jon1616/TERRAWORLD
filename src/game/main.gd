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
var drops: Drops
var vitals: Vitals
var life: Life
var fauna: Fauna
var shots: Projectiles
var combat: Combat
var depth_watch: DepthWatch
var boons: Boons
var guardian: Guardian
var portal: Portal
var day: DayCycle
var gear: GearEffects
var interact: Interact
var map_reveal: MapReveal
var erbario: Erbario
var objectives: Objectives
var sfx: Sfx
var blight: Blight
var hazards: Hazards
var spells: Spells
var keepers: Keepers
var grapple: Grapple
var throwing: Throwing
var garden: Garden
var events: Events
var masonry: Masonry
var villagers: Villagers
var companions: Companions
var travel: Travel
var minimap: Minimap
var world_traits: WorldTraits
var signature: Signature
var aiuole: Aiuole
var sampling: Sampling
var innesto: InnestoPanel
var gene_mats: GeneMaterials
var ecology: Ecology
var giardino: Giardino
var storage: Storage
var herd: Herd
var taming: Taming
var pens: Pens
var _spores: CPUParticles2D
var built := false
var gen_times: Array = []
var _gen_task := -1
var _loading: CanvasLayer
var _view_key := Rect2i()
var world_id := ""
var world_meta := {}
var character: Character
var _session_time := 0.0              # secondi giocati dall'ultimo salvataggio
var _grow_tick := 1.0
var _autosave := AUTOSAVE


func _ready() -> void:
	if Session.character == null:
		get_tree().change_scene_to_file.call_deferred(MENU_SCENE)
		return
	get_tree().set_auto_accept_quit(false)
	Musica.attach(self)                    # la musica guarda se c'è un boss vicino e in che strato si è
	character = Session.character
	Genome.known = character.genario           # i geni che il personaggio conosce (schede dei Semi)
	if not character.erbario.has("oggetti"):
		character.erbario["oggetti"] = {}
	Crafting.known = character.erbario["oggetti"]   # le ricette delle leghe si scoprono (voce 52)
	if Session.world_id != "":
		world_id = Session.world_id
		world_meta = WorldSave.read_meta(world_id)
		_show_loading("Il mondo si risveglia…")
		_gen_task = WorkerThreadPool.add_task(func() -> void: world = WorldSave.load_world(world_id), false, "carica mondo")
	else:
		var nw: Dictionary = Session.new_world
		world_id = nw["id"]
		world_meta = {"nome": nw["nome"], "creato": SavePaths.now_text(), "tempo_di_gioco": 0.0, "giocatori": {},
			"vigore": int(nw.get("vigore", 1)), "geni": nw.get("geni", []), "formato": SaveMigrations.WORLD}
		if nw.has("casa"):
			world_meta["casa"] = nw["casa"]
		if nw.get("giardino", false):
			# voce 62: il Giardino, la casa della partita (il gene del menu andrà nel primo Seme)
			world_meta["giardino"] = true
			world_meta["vigore"] = 0
			world_meta["geni"] = []
			world_meta["primo_geni"] = nw.get("geni", [])
		_show_loading("Il seme germoglia…\ngenerazione del mondo")
		world = World.new()
		var sd: int = nw["seme"]
		var params := {"vigore": int(nw.get("vigore", 1)), "geni": nw.get("geni", []), "giardino": nw.get("giardino", false)}
		var gw := WorldGen.GARDEN_W if params["giardino"] else WorldGen.WIDTH
		var gh := WorldGen.GARDEN_H if params["giardino"] else WorldGen.HEIGHT
		_gen_task = WorkerThreadPool.add_task(func() -> void: gen_times = WorldGen.generate(world, sd, gw, gh, params), false, "genera mondo")


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
	if world.creatures.is_empty():
		var rng := RandomNumberGenerator.new()
		rng.seed = world.world_seed
		PassPartenza.place_creatures(world, rng)
	add_child(Ambience.environment())
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
	_spores = Ambience.spores()
	add_child(_spores)
	vitals = Vitals.new()
	vitals.hp_max = Vitals.HP_MAX + character.vita_extra
	vitals.linfa_max = Vitals.LINFA_MAX + character.linfa_extra
	vitals.hp = character.hp
	vitals.linfa = character.linfa
	vitals.scorza = character.bisaccia.scorza()
	player.set_look(character.bisaccia.equip)
	character.bisaccia.changed.connect(func() -> void:
		vitals.scorza = character.bisaccia.scorza()
		if str(character.bisaccia.equip) != player._look_key_source:
			player._look_key_source = str(character.bisaccia.equip)
			player.set_look(character.bisaccia.equip))
	drops = Drops.new()
	add_child(drops)
	drops.setup(world, player, character.bisaccia)
	shots = Projectiles.new()
	add_child(shots)
	shots.setup(world, Callable())       # chi viene colpito lo decide `Combat`, collegato più sotto
	fauna = Fauna.new()
	add_child(fauna)
	fauna.setup(world, player, drops, shots)
	hud = Hud.new()
	hud.bisaccia = character.bisaccia
	hud.help = character.play_time < 1200.0     # dopo venti minuti di gioco l'aiuto dei tasti parte nascosto (F1)
	hud.stations_near = func() -> Dictionary: return Crafting.stations_near(world, player_cell())
	add_child(hud)
	var vv := VitalsView.new()
	hud.add_child(vv)
	vv.setup(vitals)
	actions = PlayerActions.new()
	add_child(actions)
	actions.setup(world, view, light, player, hud, drops, fx)
	actions.vitals = vitals
	life = _mount(Life.new())
	combat = _mount(Combat.new())
	fauna.killed.connect(combat.on_killed)
	shots.hit = combat.on_shot
	depth_watch = _mount(DepthWatch.new())
	sfx = _mount(Sfx.new())
	actions.sfx = sfx
	fauna.sfx = sfx
	player.jumped.connect(func() -> void: sfx.play("salto"))
	player.landed.connect(func(tiles: float) -> void:
		if tiles > 1.5:
			sfx.play("atterra"))
	drops.picked.connect(func(_id: String, _n: int) -> void: sfx.play("raccogli"))
	fauna.killed.connect(func(c: Creature) -> void: sfx.play("morte", c.position))
	hud.panel.crafting.crafted.connect(func(_id: String, _n: int) -> void: sfx.play("crea"))
	boons = _mount(Boons.new())
	guardian = _mount(Guardian.new())
	portal = _mount(Portal.new())
	day = _mount(DayCycle.new())
	gear = _mount(GearEffects.new())
	interact = _mount(Interact.new())
	map_reveal = _mount(MapReveal.new())
	var mp := MapPanel.new()
	hud.add_child(mp)
	mp.setup(self, map_reveal)
	hud.map = mp
	erbario = _mount(Erbario.new())
	hud.panel.examine.sheet = func() -> String: return CharacterSheet.bbcode(self)
	hud.panel.crafting.luck = func() -> float: return fauna.luck + fauna.boon_luck
	var ep := ErbarioPanel.new()
	hud.add_child(ep)
	ep.setup(self, erbario)
	hud.overlays.append(ep)
	objectives = _mount(Objectives.new())
	blight = _mount(Blight.new())
	hazards = _mount(Hazards.new())
	spells = _mount(Spells.new())
	keepers = _mount(Keepers.new())
	grapple = _mount(Grapple.new())
	throwing = _mount(Throwing.new())
	garden = _mount(Garden.new())
	events = _mount(Events.new())
	masonry = _mount(Masonry.new())
	villagers = _mount(Villagers.new())
	companions = _mount(Companions.new())
	travel = _mount(Travel.new())
	world_traits = _mount(WorldTraits.new())
	signature = _mount(Signature.new())
	aiuole = _mount(Aiuole.new())
	var sp := SemenzaioPanel.new()
	hud.add_child(sp)
	sp.setup(self)
	sp.genario_view = Genario.view
	hud.overlays.append(sp)
	sampling = _mount(Sampling.new())
	gene_mats = _mount(GeneMaterials.new())
	ecology = _mount(Ecology.new())
	storage = _mount(Storage.new())
	giardino = _mount(Giardino.new())      # voce 62: il Giardino sospeso nel Vuoto        # casse: ingredienti per la creazione, impostazioni, pulsanti
	hud.panel.quick_stack = storage.quick_stack
	hud.panel._toast = hud.toast
	interact.chest_panel.storage = storage
	herd = _mount(Herd.new())              # voce 59: la mandria, come si addomestica, recinti e Incubatrice
	taming = _mount(Taming.new())
	pens = _mount(Pens.new())
	var hpn := HerdPanel.new()
	hud.add_child(hpn)
	hpn.setup(self)
	hud.overlays.append(hpn)
	innesto = InnestoPanel.new()
	hud.add_child(innesto)
	innesto.setup(self)
	hud.overlays.append(innesto)
	minimap = Minimap.new()
	hud.add_child(minimap)
	minimap.setup(self, map_reveal)
	_mount(Chronicle.new())                # avvisi, Erbario e conteggi degli obiettivi dagli eventi del gioco
	hud.select(character.hotbar)
	var start := world.spawn
	var pos: Array = (world_meta.get("giocatori", {}) as Dictionary).get(character.id, [])
	if pos.size() == 2:
		start = Vector2i(int(pos[0]), int(pos[1]))
	snap_to(start)
	_loading.queue_free()
	built = true
	fauna.vigor_mult = Portal.vigor_mult(portal.vigor())
	fauna.vigor = portal.vigor()
	fauna.light = light
	if Session.world_id == "":
		if Session.new_world.has("ritorno"):
			portal.place_return(String(Session.new_world["ritorno"]))
			depth_watch.banner.show_stratum(String(world_meta["nome"]), "Vigore %d: creature più forti, minerali più ricchi" % portal.vigor(), Color("#8ef0d8"))
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


## Aggiunge un modulo di gioco (un nodo con `setup(main)`) e lo prepara: il montaggio resta una riga per modulo.
func _mount(n: Node) -> Node:
	add_child(n)
	n.setup(self)
	return n


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
	player.hook = Vector2.INF              # spostato di colpo la corda si stacca (restava agganciata e lo tirava indietro)
	player.reset_fall()
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
	vitals.tick(dt)
	_grow_tick -= dt
	if _grow_tick <= 0.0:
		_grow_tick = 1.0
		grow_saplings(1.0)
	_autosave -= dt
	if _autosave <= 0.0:
		_autosave = AUTOSAVE
		save_game()
		hud.toast("Salvataggio automatico")


## I germogli crescono col tempo (vedi `Growth`); pubblica perché le prove la chiamano con tempi lunghi.
func grow_saplings(dt: float) -> void:
	Growth.tick(world, view, light, dt)


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
	world_meta["esplorato"] = aiuole.explored_percent()
	if aiuole.is_home():
		world_meta["aiuole"] = aiuole.count()
	var err := WorldSave.save(world, world_id, world_meta)
	if err != OK:
		push_error("salvataggio del mondo non riuscito: %s" % error_string(err))
		hud.toast("Salvataggio NON riuscito")
	character.hotbar = hud.sel
	character.last_world = world_id
	character.hp = maxi(vitals.hp, 1)
	character.linfa = vitals.linfa
	character.save()


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE and built:
		save_game()
		get_tree().change_scene_to_file(MENU_SCENE)


## Uscendo dalla scena (menu, portale, chiusura) nessun thread deve restare a lavorare su nodi che spariscono.
func _exit_tree() -> void:
	Musica.detach(self)
	if _gen_task >= 0:
		WorkerThreadPool.wait_for_task_completion(_gen_task)
		_gen_task = -1
	if light:
		light.finish()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
