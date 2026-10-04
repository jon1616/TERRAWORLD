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
var albero: AlberoMadre
var powers: Powers
var seasons: Seasons
var game_options: GameOptions
var spesa: Spesa                       # la lista della spesa (Segna, in Esamina)
var filo: Filo                         # il filo da seguire, in alto al centro
var consigli: Consigli                 # i consigli alla prima volta
var liquid_tools: LiquidTools          # voce 119: otre, anfora e fonti (spostare i liquidi)
var fishing: Fishing                   # voce 121: la pesca
var dodge: Dodge                       # voce 127: la schivata
var senses: Senses                     # voce 129: ciò che le creature sentono
var wiles: Wiles                       # voce 130: le astuzie delle creature nel mondo
var tactics: Tactics                   # voce 131: le tattiche di gruppo
var builder: BuilderTools              # voce 140: gli strumenti del costruttore
var veins: Veins                       # Roadmap 19: la Pinza delle vene
var energy: Energy                     # Roadmap 19: la rete del Flusso
var rooms: Rooms                       # voce 142: le stanze
var homes: Homes                       # voce 143: le case degli abitanti
var lords: Lords                       # voce 135: i Signori dei luoghi
var great: GreatGuardians              # voce 136: i tre Guardiani scritti a mano
var tides: Tides                       # voce 137: le maree del mondo
var study: Study                       # voce 138: studiare le creature
var dwellers: Dwellers                 # voce 146: chi abita le costruzioni
var encyclopedia: Encyclopedia
var language: Language
var chains: Chains
var places: Places
var mechanisms: Mechanisms
var liquids: Liquids
var weather: Weather
var gravity: Gravity
var chiome: Chiome
var lexicon: LexiconPanel
var vitals_view: VitalsView
var word_chests: WordChests
var strikes: SkyStrikes
var living: LivingEarth
var vigor: Vigor
var legends: Legends
var challenges: Challenges
var diary: Diary
var mastery: Mastery                   # Roadmap 20: la maestria dei pilastri
var lost_gardens: LostGardens          # Roadmap 21: i Giardini perduti
var beauty: GardenBeauty               # Roadmap 22: la bellezza del Giardino
var garden_islands: GardenIslands      # Roadmap 22: le isole del Giardino
var visitors: Visitors                 # Roadmap 22: i visitatori
var festivals: Festivals               # Roadmap 22: le feste di stagione
var atlas: Atlas                       # Roadmap 23: l'Atlante
var arts: WeaponArts                   # Roadmap 25: la maestria delle armi
var techniques: Techniques             # Roadmap 25: le tecniche
var bounties: Bounties                 # Roadmap 25: le taglie
var services: Services                 # voce 353: i servizi degli abitanti
var trials: Trials                     # Roadmap 25: le prove del Cerchio
var museum: Museum                     # Roadmap 26: il Museo del Giardino
var angler: AnglerBook                 # Roadmap 27: i record e le gare di pesca
var contracts: NetContracts            # Roadmap 27: i contratti della rete
var primo: PrimoGarden                 # Roadmap 28: il Giardino oltre il Vuoto
var finale: Finale                     # Roadmap 28: il finale
var backpack: Backpack                 # Roadmap 30: lo zaino
var harvest: Harvest                   # voce 300: i raccolti delle piante
var encounters: Encounters             # voce 303: i piccoli incontri delle grotte
var water_fx: WaterFx                  # Roadmap 35, voce 336
var weather_cover: WeatherCover        # voce 337
var surface_life: SurfaceLife          # voce 339
var sowers: Sowers                     # Roadmap 36, voce 342
var dreams: Dreams                     # voce 343
var echoes: Echoes                     # voce 344
var truth: Truth                       # voce 345
var void_voice: VoidVoice              # voce 347
var evergreen: Evergreen               # Roadmap 28: il dopo (stelle di maestria, Semi d'oro)
var summons: Summons
var effects: Effects
var zones: Zones
var traps: Traps
var farms: Farms
var flight: Flight
var harsh: Harshness
var secrets: Secrets
var board: Board
var storage: Storage
var herd: Herd
var bonds: BondBag                     # Roadmap 32: la Sacca dei legami
var zone_grade: ZoneGrade              # Roadmap 33: la tinta delle zone
var taming: Taming
var pens: Pens
var _spores: CPUParticles2D
var built := false
var gen_times: Array = []
var _gen_task := -1
var _gen_thread: Thread = null           # la generazione di un mondo nuovo (`MainBoot.new_world`)
var _gen_ready := false                  # il mondo nuovo era già pronto (`WorldPregen`)
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
	Crafting.words = character.lingua                # Roadmap 17: le ricette scritte nella lingua
	if Session.world_id != "":
		world_id = Session.world_id
		world_meta = WorldSave.read_meta(world_id)
		_show_loading("Il mondo si risveglia…")
		_gen_task = WorkerThreadPool.add_task(func() -> void: world = WorldSave.load_world(world_id), false, "carica mondo")
	else:
		MainBoot.new_world(self)


func _show_loading(text: String) -> void:
	_loading = MainBoot.loading_screen(self, text)


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
	MainBoot.build_scene(self)
	vitals = MainBoot.make_vitals(self)
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
	match String(Settings.v("aiuto_tasti")):     # l'aiuto dei tasti: nelle prime ore (venti minuti), sempre o mai
		"sempre":
			hud.help = true
		"mai":
			hud.help = false
		_:
			hud.help = character.play_time < 1200.0
	hud.stations_near = func() -> Dictionary: return Crafting.stations_near(world, player_cell())
	add_child(hud)
	vitals_view = VitalsView.new()             # Vita, Linfa e Respiro sopra la barra rapida (29 set 2026)
	hud.add_child(vitals_view)
	vitals_view.setup(vitals)
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
	MainBoot.link_sounds(self)
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
	giardino = _mount(Giardino.new())      # voce 62: il Giardino sospeso nel Vuoto
	albero = _mount(AlberoMadre.new())     # voce 63: gli stadi dell'Albero-Madre, il motivo della partita
	powers = _mount(Powers.new())          # voce 64: i poteri del Germogliato (Sigilli, Vista, ponte…)
	seasons = _mount(Seasons.new())        # voce 66: le stagioni di ogni mondo
	board = _mount(Board.new())            # voce 67: la Bacheca dei Giardinieri
	language = _mount(Language.new())      # voce 68: la lingua dei Seminatori, le stele e le tavolette
	lexicon = LexiconPanel.new()           # Roadmap 17: il Quaderno delle parole (tasto U)
	hud.add_child(lexicon)
	lexicon.setup(self)
	hud.overlays.append(lexicon)
	word_chests = _mount(WordChests.new())     # Roadmap 17: gli scrigni a parola
	hud.panel.crafting.language = language     # Roadmap 17: le incisioni al Maglio
	chains = _mount(Chains.new())          # voce 69: le catene di ricerca tra i mondi (cripte, Taccuino)
	places = _mount(Places.new())          # voce 70: i luoghi scritti a mano
	mechanisms = _mount(Mechanisms.new())  # voce 71: enigmi e meccanismi dei luoghi (porte dei Seminatori)
	liquids = _mount(Liquids.new())        # voce 73: acqua, Linfa e brace che scorrono; nuoto e respiro
	weather = _mount(Weather.new())        # voce 75: vento, pioggia, nebbia, temporali, cenere, bufere
	gravity = _mount(Gravity.new())        # voce 76: il peso del mondo e le correnti ascensionali
	chiome = _mount(Chiome.new())              # Roadmap 16: le Chiome del cielo (zone, scritte)
	strikes = _mount(SkyStrikes.new())         # Roadmap 16: i fulmini annunciati
	living = _mount(LivingEarth.new())     # voce 77: radici che ricrescono, cristalli che crescono, frane
	vigor = _mount(Vigor.new())            # voce 79: i gradi del vigore, le indoli nuove, la tempra
	legends = _mount(Legends.new())        # voce 81: i Semi leggendari e il Seme Primo
	challenges = _mount(Challenges.new())  # voce 82: le sfide dei Semi e i record
	summons = _mount(Summons.new())        # voce 84: evocare i Guardiani già affrontati
	effects = _mount(Effects.new())        # voce 85: gli effetti speciali degli oggetti
	zones = _mount(Zones.new())            # voce 87: totem, stendardi e altari
	traps = _mount(Traps.new())            # voce 88: le trappole
	farms = _mount(Farms.new())            # voce 89: le farm automatiche
	flight = _mount(Flight.new())          # voce 90: le ali
	harsh = _mount(Harshness.new())        # voce 93: i rigori delle terre estreme
	secrets = _mount(Secrets.new())        # voce 95: i segreti del mondo
	var hb := HarshBar.new()
	hud.add_child(hb)
	hb.setup(harsh)
	gear.refresh()                         # le protezioni dai rigori arrivano a `Harshness`
	diary = _mount(Diary.new())            # voce 83: il diario della partita
	_mount(Juice.new())                    # voce 293: scosse piccole e pause d'impatto brevissime
	_mount(AmbientFx.new())                # voce 286: l'aria viva (polline, lucciole, spore, braci) e la polvere dei passi
	zone_grade = _mount(ZoneGrade.new())   # Roadmap 33, voce 324: la tinta delle zone
	hud.panel.quick_stack = storage.quick_stack
	hud.panel._toast = hud.toast
	interact.chest_panel.storage = storage
	herd = _mount(Herd.new())              # voce 59: la mandria, come si addomestica, recinti e Incubatrice
	bonds = _mount(BondBag.new())          # Roadmap 32: la Sacca dei legami (uno in campo, cinque con te)
	var bbar := BondBar.new()
	hud.add_child(bbar)
	bbar.setup(self)
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
	_mount(TipsHook.new())                 # i suggerimenti: schede degli oggetti e delle cose del mondo
	encyclopedia = _mount(Encyclopedia.new())  # l'Enciclopedia (tasto H, bottone «?», pausa)
	game_options = _mount(GameOptions.new())   # Opzioni in partita: pausa, visuale; menu di pausa (Esc)
	spesa = _mount(Spesa.new())                # la guida del giocatore (28 set 2026): la lista della spesa,
	filo = _mount(Filo.new())                  # il filo da seguire
	consigli = _mount(Consigli.new())          # e i consigli alla prima volta
	liquid_tools = _mount(LiquidTools.new())   # voce 119: spostare i liquidi
	fishing = _mount(Fishing.new())            # voce 121: la pesca
	dodge = _mount(Dodge.new())                # voce 127: la schivata
	senses = _mount(Senses.new())              # voce 129: il cervello delle creature
	wiles = _mount(Wiles.new())                # voce 130: le astuzie
	tactics = _mount(Tactics.new())            # voce 131: le tattiche di gruppo
	builder = _mount(BuilderTools.new())       # voce 140: gli strumenti del costruttore
	rooms = _mount(Rooms.new())                # voce 142: le stanze
	homes = _mount(Homes.new())                # voce 143: le case degli abitanti
	lords = _mount(Lords.new())                # voce 135: i Signori dei luoghi
	great = _mount(GreatGuardians.new())       # voce 136: i tre Guardiani scritti a mano
	tides = _mount(Tides.new())                # voce 137: le maree del mondo
	study = _mount(Study.new())                # voce 138: studiare le creature
	dwellers = _mount(Dwellers.new())          # voce 146: chi abita le costruzioni
	veins = _mount(Veins.new())                # Roadmap 19: la Pinza delle vene
	energy = _mount(Energy.new())              # e la rete del Flusso
	mastery = _mount(Mastery.new())            # Roadmap 20: la maestria dei dieci pilastri
	lost_gardens = _mount(LostGardens.new())   # Roadmap 21: le cure degli Alberi dei Giardini perduti
	beauty = _mount(GardenBeauty.new())        # Roadmap 22: la bellezza del Giardino
	garden_islands = _mount(GardenIslands.new())   # Roadmap 22: le isole del Giardino
	visitors = _mount(Visitors.new())          # Roadmap 22: i visitatori del Giardino
	festivals = _mount(Festivals.new())        # Roadmap 22: le feste di stagione
	atlas = _mount(Atlas.new())                # Roadmap 23: l'Atlante dei mondi
	arts = _mount(WeaponArts.new())            # Roadmap 25: la maestria delle armi e le tecniche
	techniques = _mount(Techniques.new())
	bounties = _mount(Bounties.new())
	trials = _mount(Trials.new())
	museum = _mount(Museum.new())              # Roadmap 26: il Museo del Giardino
	services = _mount(Services.new())          # voce 353: i servizi degli abitanti, pagati in Lumini
	angler = _mount(AnglerBook.new())          # Roadmap 27: i record e le gare di pesca
	contracts = _mount(NetContracts.new())     # Roadmap 27: i contratti della rete
	primo = _mount(PrimoGarden.new())          # Roadmap 28: il Giardino oltre il Vuoto
	finale = _mount(Finale.new())
	backpack = _mount(Backpack.new())
	harvest = _mount(Harvest.new())
	encounters = _mount(Encounters.new())
	evergreen = _mount(Evergreen.new())
	water_fx = _mount(WaterFx.new())           # Roadmap 35, voce 336: increspature, spruzzi, cascate
	weather_cover = _mount(WeatherCover.new())   # voce 337: neve, bagnato e cenere sulle cime
	surface_life = _mount(SurfaceLife.new())     # voce 339: lucciole, polline, foglie, erba che si piega
	sowers = _mount(Sowers.new())                # Roadmap 36, voce 342: i Seminatori nei Cuori
	dreams = _mount(Dreams.new())                # voce 343: i sogni (usando un letto)
	echoes = _mount(Echoes.new())                # voce 344: gli echi negli scrigni delle rovine
	truth = _mount(Truth.new())                  # voce 345: il Taccuino della verità
	void_voice = _mount(VoidVoice.new())         # voce 347: la Bocca, nei luoghi malati
	_mount(PanelButtons.new())                 # voce 101: i pulsanti dei pannelli in basso a sinistra
	hud.select(character.hotbar)
	var start := world.spawn
	var pos: Array = (world_meta.get("giocatori", {}) as Dictionary).get(character.id, [])
	if pos.size() == 2:
		start = Vector2i(int(pos[0]), int(pos[1]))
	if Session.arrive_from != "":
		# arrivati da un portale: davanti al portale che riporta indietro, non dove si era l'ultima volta
		var at := portal.arrival(Session.arrive_from)
		if at.x >= 0:
			start = at
		Session.arrive_from = ""
	snap_to(start)
	_loading.queue_free()
	built = true
	fauna.vigor_mult = Portal.vigor_mult(portal.vigor())
	fauna.vigor = portal.vigor()
	CreaturesData.now_vigor = portal.vigor()     # voce 185: le creature forti della Superficie dal vigore 2
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
		elif _gen_thread != null and not _gen_thread.is_alive():
			_gen_thread.wait_to_finish()
			_gen_thread = null
			_build()
		elif _gen_ready:
			_gen_ready = false
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
		_autosave = float(Settings.v("autosalvataggio"))
		if _autosave <= 0.0:
			_autosave = AUTOSAVE           # «mai»: si riguarda fra un po' se l'opzione è cambiata
		else:
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
	MainBoot.save(self)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_ESCAPE and built:
		game_options.open_menu()           # la pausa: da lì si salva e si torna al menu
		get_viewport().set_input_as_handled()


## Uscendo dalla scena (menu, portale, chiusura) nessun thread deve restare a lavorare su nodi che spariscono.
func _exit_tree() -> void:
	Musica.detach(self)
	if _gen_task >= 0:
		WorkerThreadPool.wait_for_task_completion(_gen_task)
		_gen_task = -1
	if _gen_thread != null:
		_gen_thread.wait_to_finish()
		_gen_thread = null
	if light:
		light.finish()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()
