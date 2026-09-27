class_name PlayerActions
extends Node
## Quello che il giocatore fa con il mouse, secondo l'oggetto in mano: scavare col piccone (il blocco cade a terra e si
## raccoglie), raccogliere funghi e decorazioni, abbattere alberi con l'ascia, seminare, piazzare blocchi e torce dalla
## Bisaccia. I colpi alle creature e l'arco stanno in `Combat`.
## Con la Bisaccia aperta il mouse serve all'interfaccia e qui non succede nulla.

const S := 16
const REACH := 16.0 * 5.5

var world: World
var view: WorldView
var light: LightMap
var player: Player
var hud: Hud
var drops: Drops
var vitals: Vitals
var bisaccia: Bisaccia
var cursor: MiningCursor
var fx_parent: Node2D
var enabled := true
var dig_mult := 1.0                    # accessori: scavo e taglio più rapidi (Guanti del talpone)
var boon_dig := 1.0                    # Pozione del minatore
## Hook per gli usi che non stanno qui (curare un nodo, piantare un Seme di mondo, toccare il Cuore o il portale):
## `use_hook.call(tipo, id, cella)` e `touch_hook.call(cella)` restituiscono true se hanno fatto qualcosa.
var use_hook: Callable
var no_torches := false                # voce 82: la sfida «Senza torce»
var build: Building                    # stazioni e passerelle
var sfx: Sfx                           # i suoni (può mancare nelle prove senza scena)
var _dig_snd := 0.0
var touch_hook: Callable
## `station_check.call(id_stazione)` → "" se si può piazzare, altrimenti il perché (voce 45, `Aiuole`).
var station_check: Callable
## `dig_hook.call(tessera, cella)` dopo ogni tessera rotta (voce 53: i materiali dei geni).
var dig_hook: Callable
signal boon(name: String, secs: float)
signal decor_picked(c: Vector2i, d: int)   # una decorazione tolta (il giardino vi aggiunge raccolto e semi)
signal too_hard                          # un blocco che questo piccone non scalfisce (i consigli: `Consigli`)
signal dug(t: int, c: Vector2i)            # voce 77: una tessera rotta (la terra viva: ferite e frane)
var _cell := Vector2i(-9999, -9999)
var _t := 0.0
var _chop_t := 0.0
var _tree_hp := {}                     # base dell'albero -> robustezza che resta (non si salva)
var _rng := RandomNumberGenerator.new()


func setup(w: World, v: WorldView, l: LightMap, p: Player, h: Hud, d: Drops, fx: Node2D) -> void:
	world = w
	view = v
	light = l
	player = p
	hud = h
	drops = d
	bisaccia = h.bisaccia
	fx_parent = fx
	cursor = MiningCursor.new()
	cursor.z_index = 27
	fx.add_child(cursor)
	build = Building.new(self)
	h.selected.connect(_on_selected)
	_on_selected(h.current())


func _on_selected(item: Dictionary) -> void:
	var use: String = item["use"]
	var kind := String(ItemsData.get_item(String(item["id"])).get("kind", ""))
	# torce e lanterne si tengono in mano e si vedono sempre; la torcia ha la sua fiamma
	player.carry = kind in ["torcia", "lanterna", "rampino"]
	player.carry_glow = Color(2.2, 1.6, 0.9) if kind == "torcia" else Color.BLACK
	player.tool_tex = item["tex"] if use in ["scava", "colpo", "abbatti", "tira", "incanta", "smura", "evoca", "pesca"] or player.carry else null


func mouse_cell() -> Vector2i:
	var mp := fx_parent.get_global_mouse_position()
	return Vector2i(floori(mp.x / S), floori(mp.y / S))


func in_reach(c: Vector2i) -> bool:
	return (Vector2(c) * S + Vector2(8, 8)).distance_to(player.position) <= REACH


func _active() -> bool:
	return enabled and not hud.is_open()


func _unhandled_input(e: InputEvent) -> void:
	if not _active() or not (e is InputEventMouseButton) or not e.pressed:
		return
	var item := hud.current()
	var kind := String(ItemsData.get_item(item["id"]).get("kind", ""))
	if e.button_index == MOUSE_BUTTON_RIGHT:
		if touch_hook.is_valid() and touch_hook.call(mouse_cell()):
			return
		place_torch(mouse_cell())
	elif e.button_index == MOUSE_BUTTON_LEFT:
		if kind == "torcia":
			place_torch(mouse_cell())
		elif kind == "blocco":
			place_block(mouse_cell(), item["id"])
		elif kind == "seme":
			plant(mouse_cell(), item["id"])
		elif kind == "stazione":
			build.place_station(mouse_cell(), item["id"])
		elif kind == "piattaforma":
			build.place_plat(mouse_cell(), item["id"])
		elif kind == "consumabile":
			drink(item["id"])
		elif use_hook.is_valid():
			use_hook.call(kind, String(item["id"]), mouse_cell())


func _process(dt: float) -> void:
	if not _active():
		player.swinging = false
		cursor.set_state(Vector2i.ZERO, false, 0.0)
		return
	var c := mouse_cell()
	var reach := in_reach(c)
	var item := hud.current()
	var use: String = item["use"]
	var kind := String(ItemsData.get_item(item["id"]).get("kind", ""))
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	player.swinging = down and (use == "scava" or use == "colpo" or use == "abbatti")
	if player.swinging:
		player.facing = 1 if fx_parent.get_global_mouse_position().x >= player.position.x else -1
	var prog := 0.0
	if down and use == "scava" and reach and c.y < world.h - 1 and world.inside(c.x, c.y):
		prog = _dig(c, item, dt)
	else:
		_t = 0.0
	if down and use == "abbatti" and reach:
		_chop(c, item, dt)
	else:
		_chop_t = 0.0
	var tree := world.tree_at(c).x >= 0
	var show := reach and (world.solid(c.x, c.y) or kind in ["torcia", "blocco", "seme", "stazione", "piattaforma"] \
			or world.decor_at(c.x, c.y) != 0 or world.torches.has(c) or world.plat(c.x, c.y) \
			or not world.station_at(c).is_empty() or (use == "abbatti" and tree))
	cursor.set_state(c, show, prog)


## Scava la tessera o raccoglie la decorazione sotto il mouse; restituisce l'avanzamento (0-1) per le crepe.
func _dig(c: Vector2i, item: Dictionary, dt: float) -> float:
	if c != _cell:
		_cell = c
		_t = 0.0
	if not world.solid(c.x, c.y):
		var st := world.station_at(c)
		if not st.is_empty() and StationsData.STATIONS[st["id"]].get("fixed", false):
			return 0.0                         # Cuore e portale non si riprendono
		if not st.is_empty() or world.plat(c.x, c.y):
			_t += dt
			if _t >= 0.3:
				if not st.is_empty():
					build.take_station(st["origin"])
				else:
					build.take_plat(c)
				_t = 0.0
			return _t / 0.3
		if world.torches.has(c):
			_t += dt
			if _t >= 0.15:
				take_torch(c)
				_t = 0.0
			return 0.0
		if world.decor_at(c.x, c.y) == 0:
			return 0.0
		_t += dt
		if _t >= 0.15:
			pick_decor(c)
			_t = 0.0
		return 0.0
	var t := world.tile(c.x, c.y)
	var over := world.tree_at(c + Vector2i(0, -1))
	if over.x == c.x and over.y == c.y - 1:
		if _t == 0.0:
			hud.toast("Prima abbatti l'albero")
		_t = -1.0
		return 0.0
	var power := int(ItemsData.get_item(item["id"]).get("power", 0))
	if power < int(TileDefs.POWER.get(t, 0)):
		# troppo duro per questo piccone: il blocco non cede
		if _t == 0.0:
			hud.toast("Serve un piccone più forte")
			too_hard.emit()
		_t = -1.0
		return 0.0
	if _t < 0.0:
		_t = 0.0
	_t += dt
	_dig_snd -= dt
	if _dig_snd <= 0.0 and sfx:
		_dig_snd = 0.25
		sfx.play("scavo_terra" if t in [TileDefs.DIRT, TileDefs.RADICE] or TileDefs.is_grass(t) else "scavo_roccia")
	# più forza = più veloce (la radicite, forza 35, è il riferimento di TileDefs.HARD)
	var hard: float = float(TileDefs.HARD[t]) * 35.0 / float(maxi(power, 1))
	hard /= float(Gear.stats(item)["dig"]) * dig_mult * boon_dig         # tratto, fascia, trivella (voce 50)
	if _t >= hard:
		break_tile(c)
		_t = 0.0
		return 0.0
	return _t / hard


func break_tile(c: Vector2i) -> void:
	var t := world.tile(c.x, c.y)
	world.set_tile(c.x, c.y, TileDefs.AIR)
	# ciò che poggiava sopra, o pendeva sotto, cade insieme al blocco
	var up := world.decor_at(c.x, c.y - 1)
	if up != 0 and not (up in TileDefs.DECOR_CEILING):
		pick_decor(c + Vector2i(0, -1))
	var down := world.decor_at(c.x, c.y + 1)
	if down in TileDefs.DECOR_CEILING:
		pick_decor(c + Vector2i(0, 1))
	view.refresh_around(c)
	light.dirty = true
	var center := Vector2(c) * S + Vector2(8, 8)
	Fx.dust(fx_parent, center, TileDefs.dust_colors(t))
	drops.spawn(String(TileDefs.DROP.get(t, "")), 1, center)
	if dig_hook.is_valid():
		dig_hook.call(t, c)
	dug.emit(t, c)
	if sfx:
		sfx.play("rompi", center)


## Toglie una decorazione e fa cadere ciò che lascia (funghi…).
func pick_decor(c: Vector2i) -> void:
	var d := world.decor_at(c.x, c.y)
	if d == 0:
		return
	world.set_decor(c.x, c.y, 0)
	world.saplings.erase(c)
	view.refresh_around(c)
	if TileDefs.DECOR_LIGHT.has(d):
		light.dirty = true
	if TileDefs.DECOR_DROP.has(d):
		drops.spawn(String(TileDefs.DECOR_DROP[d]), 1, Vector2(c) * S + Vector2(8, 8))
	decor_picked.emit(c, d)


## Colpi d'ascia a ritmo del gesto: ogni colpo toglie la forza dell'ascia; a zero l'albero cade, lontano dal
## giocatore, e lascia legno e a volte semi.
func _chop(c: Vector2i, item: Dictionary, dt: float) -> void:
	var t := world.tree_at(c)
	if t.x < 0:
		_chop_t = 0.0
		return
	_chop_t -= dt
	if _chop_t > 0.0:
		return
	_chop_t = 0.32
	var base := Vector2i(t.x, t.y)
	var power := int(ItemsData.get_item(item["id"]).get("power", 0))
	power = roundi(power * float(Gear.stats(item)["dig"]) * dig_mult * boon_dig)
	var hp: int = _tree_hp.get(base, int(TreesData.size_of(t.z)["hp"])) - power     # i grandi reggono più colpi
	var hit_at := fx_parent.get_global_mouse_position()
	Fx.dust(fx_parent, hit_at, Px.pal(["#241624", "#362234", "#4c3246", "#62c4a4"]))
	if sfx:
		sfx.play("legno", hit_at)
	if hp > 0:
		_tree_hp[base] = hp
		view.shake_tree(base)
		return
	_tree_hp.erase(base)
	fell_tree(t)


func fell_tree(t: Vector3i) -> void:
	var base := Vector2i(t.x, t.y)
	var dir := 1 if player.position.x < base.x * S + 8 else -1
	world.remove_tree(t)
	view.fell_tree(base, dir)
	if sfx:
		sfx.play("albero_cade", Vector2(base) * S)
	var foot := Vector2(base.x * S + 8, (base.y + 1) * S - 6)
	var wr: Array = TreesData.size_of(t.z)["wood"]                   # più legno dai grandi
	var wood := _rng.randi_range(int(wr[0]), int(wr[1]))
	for k in wood:
		drops.spawn("legno", 1, foot + Vector2(dir * (6 + k * 5), -_rng.randf_range(4.0, 20.0)))
	if _rng.randf() < FloraData.SEED_CHANCE:
		drops.spawn("seme_lanterna", _rng.randi_range(FloraData.SEEDS[0], FloraData.SEEDS[1]), foot + Vector2(dir * 24, -30))


## Pianta un seme d'albero-lanterna: nasce un germoglio che col tempo diventerà albero.
func plant(c: Vector2i, id: String) -> bool:
	if not in_reach(c) or not world.inside(c.x, c.y) or world.solid(c.x, c.y) or world.torches.has(c):
		return false
	var d := world.decor_at(c.x, c.y)
	if d != 0 and not TileDefs.is_soft_decor(d):
		return false
	if not world.tree_fits(c):
		hud.toast("Serve muschio sotto e spazio libero sopra")
		return false
	var slot := hud.sel
	if bisaccia.id_at(slot) != id:
		return false
	world.set_decor(c.x, c.y, TileDefs.DECOR_SPROUT)
	world.saplings[c] = _rng.randf_range(FloraData.GROW[0], FloraData.GROW[1])
	bisaccia.take_one(slot)
	view.refresh_around(c)
	light.dirty = true
	return true


## Piazza un blocco dalla casella in mano: serve un appoggio (un blocco accanto o una parete dietro) e che non si
## sovrapponga al giocatore.
func place_block(c: Vector2i, id: String) -> bool:
	if not in_reach(c) or not world.inside(c.x, c.y) or world.solid(c.x, c.y) or world.torches.has(c):
		return false
	var touches := world.solid(c.x - 1, c.y) or world.solid(c.x + 1, c.y) or world.solid(c.x, c.y - 1) \
			or world.solid(c.x, c.y + 1) or world.wall(c.x, c.y) != 0
	if not touches:
		return false
	var cell_rect := Rect2(Vector2(c) * S, Vector2(S, S))
	var body := Rect2(player.position - Player.HALF, Player.HALF * 2.0)
	if cell_rect.intersects(body):
		return false
	var slot := hud.sel
	if bisaccia.id_at(slot) != id:
		return false
	if world.decor_at(c.x, c.y) != 0:
		pick_decor(c)
	world.set_tile(c.x, c.y, int(ItemsData.get_item(id)["place"]))
	bisaccia.take_one(slot)
	view.refresh_around(c)
	light.dirty = true
	if sfx:
		sfx.play("posa", Vector2(c) * S)
	return true


## Beve una pozione dalla mano: cura, poi bisogna aspettare prima della prossima.
func drink(id: String) -> bool:
	var it := ItemsData.get_item(id)
	var heal := int(it.get("heal", 0))
	if vitals == null or (heal <= 0 and not it.has("boon") and not it.has("linfa")):
		return false
	if it.has("linfa"):
		# la Linfa non ha attesa tra una pozione e l'altra: serve nel mezzo di una lotta
		if vitals.linfa >= vitals.linfa_max:
			hud.toast("La Linfa è già piena")
			return false
		if bisaccia.id_at(hud.sel) != id:
			return false
		bisaccia.take_one(hud.sel)
		if sfx:
			sfx.play("pozione")
		vitals.linfa = mini(vitals.linfa + int(it["linfa"]), vitals.linfa_max)
		vitals.changed.emit()
		return true
	if it.has("boon"):
		var slot0 := hud.sel
		if bisaccia.id_at(slot0) != id:
			return false
		bisaccia.take_one(slot0)
		if sfx:
			sfx.play("pozione")
		boon.emit(String(it["boon"][0]), float(it["boon"][1]))
		return true
	if vitals.potion_wait > 0.0:
		hud.toast("Ancora %d secondi prima di un'altra pozione" % ceili(vitals.potion_wait))
		return false
	if heal > 0 and vitals.hp >= vitals.hp_max:
		hud.toast("Le foglie sono già tutte verdi")
		return false
	var slot := hud.sel
	if bisaccia.id_at(slot) != id:
		return false
	bisaccia.take_one(slot)
	if sfx:
		sfx.play("pozione")
	if it.get("cure", false):
		vitals.poison_t = 0.0
	vitals.heal(heal)
	vitals.potion_wait = Vitals.POTION_COOLDOWN
	return true


## Riprende una torcia piazzata: torna a terra come oggetto da raccogliere.
func take_torch(c: Vector2i) -> void:
	world.remove_torch(c)
	view.remove_torch(c)
	light.dirty = true
	drops.spawn("torcia", 1, Vector2(c) * S + Vector2(8, 8))


func place_torch(c: Vector2i) -> void:
	if not in_reach(c) or not world.inside(c.x, c.y) or world.solid(c.x, c.y) or world.torches.has(c):
		return
	if not world.solid(c.x, c.y + 1) and world.wall(c.x, c.y) == 0:
		return
	if no_torches:
		hud.toast("Sfida «Senza torce»: qui le torce non si accendono")
		return
	if not bisaccia.remove("torcia", 1):
		hud.toast("Nessuna torcia nella Bisaccia")
		return
	world.add_torch(c)
	if sfx:
		sfx.play("torcia", Vector2(c) * S)
	if world.decor_at(c.x, c.y) != 0:
		pick_decor(c)
	view.refresh_around(c)
	view.add_torch(c)
	light.dirty = true
