class_name PlayerActions
extends Node
## Quello che il giocatore fa con il mouse, secondo l'oggetto in mano: scavare col piccone (il blocco cade a terra e si
## raccoglie), raccogliere funghi e decorazioni, piazzare blocchi e torce dalla Bisaccia, colpire (per ora solo il gesto).
## Con la Bisaccia aperta il mouse serve all'interfaccia e qui non succede nulla.

const S := 16
const REACH := 16.0 * 5.5

var world: World
var view: WorldView
var light: LightMap
var player: Player
var hud: Hud
var drops: Drops
var bisaccia: Bisaccia
var cursor: MiningCursor
var fx_parent: Node2D
var enabled := true
var _cell := Vector2i(-9999, -9999)
var _t := 0.0


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
	h.selected.connect(_on_selected)
	_on_selected(h.current())


func _on_selected(item: Dictionary) -> void:
	var use: String = item["use"]
	player.tool_tex = item["tex"] if use == "scava" or use == "colpo" else null


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
		place_torch(mouse_cell())
	elif e.button_index == MOUSE_BUTTON_LEFT:
		if kind == "torcia":
			place_torch(mouse_cell())
		elif kind == "blocco":
			place_block(mouse_cell(), item["id"])


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
	player.swinging = down and (use == "scava" or use == "colpo")
	if player.swinging:
		player.facing = 1 if fx_parent.get_global_mouse_position().x >= player.position.x else -1
	var prog := 0.0
	if down and use == "scava" and reach and c.y < world.h - 1 and world.inside(c.x, c.y):
		prog = _dig(c, item, dt)
	else:
		_t = 0.0
	var show := reach and (world.solid(c.x, c.y) or kind in ["torcia", "blocco"] or world.decor_at(c.x, c.y) != 0 \
			or world.torches.has(c))
	cursor.set_state(c, show, prog)


## Scava la tessera o raccoglie la decorazione sotto il mouse; restituisce l'avanzamento (0-1) per le crepe.
func _dig(c: Vector2i, item: Dictionary, dt: float) -> float:
	if c != _cell:
		_cell = c
		_t = 0.0
	if not world.solid(c.x, c.y):
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
	var power := int(ItemsData.get_item(item["id"]).get("power", 0))
	if power < int(TileDefs.POWER.get(t, 0)):
		# troppo duro per questo piccone: il blocco non cede
		if _t == 0.0:
			hud.toast("Serve un piccone più forte")
		_t = -1.0
		return 0.0
	if _t < 0.0:
		_t = 0.0
	_t += dt
	# più forza = più veloce (la radicite, forza 35, è il riferimento di TileDefs.HARD)
	var hard: float = float(TileDefs.HARD[t]) * 35.0 / float(maxi(power, 1))
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


## Toglie una decorazione e fa cadere ciò che lascia (funghi…).
func pick_decor(c: Vector2i) -> void:
	var d := world.decor_at(c.x, c.y)
	if d == 0:
		return
	world.set_decor(c.x, c.y, 0)
	view.refresh_around(c)
	if TileDefs.DECOR_LIGHT.has(d):
		light.dirty = true
	if TileDefs.DECOR_DROP.has(d):
		drops.spawn(String(TileDefs.DECOR_DROP[d]), 1, Vector2(c) * S + Vector2(8, 8))


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
	if not bisaccia.remove("torcia", 1):
		hud.toast("Nessuna torcia nella Bisaccia")
		return
	world.add_torch(c)
	if world.decor_at(c.x, c.y) != 0:
		pick_decor(c)
	view.refresh_around(c)
	view.add_torch(c)
	light.dirty = true
