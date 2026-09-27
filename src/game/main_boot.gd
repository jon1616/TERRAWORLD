class_name MainBoot
extends RefCounted
## I pezzi di `main.gd` che non sono montaggio (pulizia del 28 set 2026: main.gd aveva passato le 500 righe): il mondo
## nuovo (i suoi appunti e la generazione in un thread), la schermata d'attesa, le basi della scena (sfondo, vista a
## blocchi, giocatore, luce, camera) e il salvataggio. Stesso codice di prima, con `m` al posto di main.

const S := 16                          # come `main.S`: i pixel di una tessera


## Un mondo nuovo scelto nel menu: i suoi appunti e la generazione (in un thread).
static func new_world(m: Node2D) -> void:
	var nw: Dictionary = Session.new_world
	m.world_id = nw["id"]
	m.world_meta = {"nome": nw["nome"], "creato": SavePaths.now_text(), "tempo_di_gioco": 0.0, "giocatori": {},
		"vigore": int(nw.get("vigore", 1)), "geni": nw.get("geni", []), "formato": SaveMigrations.WORLD}
	if nw.has("casa"):
		m.world_meta["casa"] = nw["casa"]
	if nw.get("nero", false):
		m.world_meta["nero"] = true              # voce 72: il mondo dove cadde il Seme Nero
	if nw.get("primo", false):
		m.world_meta["primo"] = true             # voce 81: il mondo del Seme Primo
	if String(nw.get("sfida", "")) != "":
		Challenges.start(m.world_meta, String(nw["sfida"]), int(nw.get("sfida_livello", 1)))   # voce 82
	if nw.get("giardino", false):
		# voce 62: il Giardino, la casa della partita (il gene del menu andrà nel primo Seme)
		m.world_meta["giardino"] = true
		m.world_meta["vigore"] = 0
		m.world_meta["geni"] = []
		m.world_meta["primo_geni"] = nw.get("geni", [])
	m._show_loading("Il seme germoglia…\ngenerazione del mondo")
	m.world = World.new()
	var sd: int = nw["seme"]
	var params := {"vigore": int(nw.get("vigore", 1)), "geni": nw.get("geni", []), "giardino": nw.get("giardino", false),
		"catene": Chains.pending(m.character),   # voce 69: le cripte delle tappe aperte
		"nero": nw.get("nero", false)}         # voce 72
	var gw := WorldGen.GARDEN_W if params["giardino"] else WorldGen.WIDTH
	var gh := WorldGen.GARDEN_H if params["giardino"] else WorldGen.HEIGHT
	# un thread tutto suo (non il gruppo di thread): così le passate a fasce (`GenBands`) usano tutti i processori
	m._gen_thread = Thread.new()
	m._gen_thread.start(func() -> void: m.gen_times = WorldGen.generate(m.world, sd, gw, gh, params))


## La schermata d'attesa mentre il mondo si carica o nasce.
static func loading_screen(m: Node2D, text: String) -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 50
	m.add_child(layer)
	var bg := ColorRect.new()
	bg.color = Color("#0f0d18")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color("#cfe8a0"))
	l.set_anchors_preset(Control.PRESET_CENTER)
	l.position = Vector2(-200, -40)
	l.size = Vector2(400, 80)
	layer.add_child(l)
	return layer


## Le basi della scena: sfondo, vista a blocchi, effetti, giocatore, luce, camera, spore.
static func build_scene(m: Node2D) -> void:
	m.add_child(Ambience.environment())
	m.background = Background.new()
	m.add_child(m.background)
	m.background.setup(m.world)
	m.view = WorldView.new()
	m.add_child(m.view)
	m.view.setup(m.world)
	m.fx = Node2D.new()
	m.fx.z_index = 6
	m.add_child(m.fx)
	m.player = Player.new()
	m.player.setup(m.world)
	m.player.z_index = 4
	m.player.position = m.cell_to_feet(m.world.spawn)
	m.add_child(m.player)
	m.light = LightMap.new()
	m.light.setup(m.world)
	m.overlay = Sprite2D.new()
	m.overlay.texture = m.light.tex
	m.overlay.centered = false
	m.overlay.scale = Vector2(S, S)
	m.overlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	m.overlay.material = mat
	m.overlay.z_index = 20
	m.overlay.visible = not ("--senza-luce" in OS.get_cmdline_user_args())
	m.add_child(m.overlay)
	m.cam = Camera2D.new()
	m.cam.zoom = Vector2(2, 2)
	m.cam.position_smoothing_enabled = true
	m.cam.position_smoothing_speed = 7.0
	m.cam.limit_left = 0
	m.cam.limit_top = 0
	m.cam.limit_right = m.world.w * S
	m.cam.limit_bottom = m.world.h * S
	m.add_child(m.cam)
	m.cam.make_current()
	m._spores = Ambience.spores()
	m.add_child(m._spores)


## Salva mondo e personaggio (mondo ~15 ms, file ~0,5 MB).
static func save(m: Node2D) -> void:
	m.world_meta["tempo_di_gioco"] = float(m.world_meta.get("tempo_di_gioco", 0.0)) + m._session_time
	m.character.play_time += m._session_time
	m._session_time = 0.0
	var players: Dictionary = m.world_meta.get("giocatori", {})
	var pc: Vector2i = m.player_cell()
	players[m.character.id] = [pc.x, pc.y]
	m.world_meta["giocatori"] = players
	m.world_meta["esplorato"] = m.aiuole.explored_percent()
	if m.aiuole.is_home():
		m.world_meta["aiuole"] = m.aiuole.count()
	var err := WorldSave.save(m.world, m.world_id, m.world_meta)
	if err != OK:
		push_error("salvataggio del mondo non riuscito: %s" % error_string(err))
		m.hud.toast("Salvataggio NON riuscito")
	m.character.hotbar = m.hud.sel
	m.character.last_world = m.world_id
	m.character.hp = maxi(m.vitals.hp, 1)
	m.character.linfa = m.vitals.linfa
	m.character.save()


## Vita e Linfa del personaggio, e la Scorza e l'armatura disegnata che seguono la Bisaccia.
static func make_vitals(m: Node2D) -> Vitals:
	var vitals := Vitals.new()
	var character: Character = m.character
	var player: Player = m.player
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
	return vitals


## I suoni legati agli eventi del Germogliato, degli oggetti e delle creature.
static func link_sounds(m: Node2D) -> void:
	var sfx: Sfx = m.sfx
	m.player.jumped.connect(func() -> void: sfx.play("salto"))
	m.player.landed.connect(func(tiles: float) -> void:
		if tiles > 1.5:
			sfx.play("atterra"))
	m.drops.picked.connect(func(_id: String, _n: int) -> void: sfx.play("raccogli"))
	m.fauna.killed.connect(func(c: Creature) -> void: sfx.play("morte", c.position))
	m.hud.panel.crafting.crafted.connect(func(_id: String, _n: int) -> void: sfx.play("crea"))
