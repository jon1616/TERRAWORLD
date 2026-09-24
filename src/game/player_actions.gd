class_name PlayerActions
extends Node
## Quello che il giocatore fa con il mouse: scavare col piccone, colpire (per ora solo l'animazione), piazzare torce.

const S := 16
const REACH := 16.0 * 5.5

var world: World
var view: WorldView
var light: LightMap
var player: Player
var hud: Hud
var cursor: MiningCursor
var fx_parent: Node2D
var enabled := true
var _cell := Vector2i(-9999, -9999)
var _t := 0.0


func setup(w: World, v: WorldView, l: LightMap, p: Player, h: Hud, fx: Node2D) -> void:
	world = w
	view = v
	light = l
	player = p
	hud = h
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


func _unhandled_input(e: InputEvent) -> void:
	if not enabled or not (e is InputEventMouseButton) or not e.pressed:
		return
	if e.button_index == MOUSE_BUTTON_RIGHT or (e.button_index == MOUSE_BUTTON_LEFT and hud.current()["use"] == "torcia"):
		place_torch(mouse_cell())


func _process(dt: float) -> void:
	if not enabled:
		return
	var c := mouse_cell()
	var reach := in_reach(c)
	var use: String = hud.current()["use"]
	var down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	player.swinging = down and (use == "scava" or use == "colpo")
	if player.swinging:
		player.facing = 1 if fx_parent.get_global_mouse_position().x >= player.position.x else -1
	var prog := 0.0
	if down and use == "scava" and reach and world.solid(c.x, c.y) and c.y < world.h - 1:
		if c != _cell:
			_cell = c
			_t = 0.0
		var t := world.tile(c.x, c.y)
		var power := int(ItemsData.get_item(hud.current()["id"]).get("power", 0))
		if power < int(TileDefs.POWER.get(t, 0)):
			# troppo duro per questo piccone: il blocco non cede
			if _t == 0.0:
				hud.toast("Serve un piccone più forte")
			_t = -1.0
		else:
			if _t < 0.0:
				_t = 0.0
			_t += dt
			# più forza = più veloce (la radicite, forza 35, è il riferimento di TileDefs.HARD)
			var hard: float = float(TileDefs.HARD[t]) * 35.0 / float(maxi(power, 1))
			prog = _t / hard
			if _t >= hard:
				break_tile(c)
				_t = 0.0
				prog = 0.0
	else:
		_t = 0.0
	cursor.set_state(c, reach and (world.solid(c.x, c.y) or use == "torcia"), prog)


func break_tile(c: Vector2i) -> void:
	var t := world.tile(c.x, c.y)
	world.set_tile(c.x, c.y, TileDefs.AIR)
	# ciò che poggiava sopra, o pendeva sotto, cade insieme al blocco
	var up := world.decor_at(c.x, c.y - 1)
	if up != 0 and not (up in TileDefs.DECOR_CEILING):
		world.set_decor(c.x, c.y - 1, 0)
	var down := world.decor_at(c.x, c.y + 1)
	if down in TileDefs.DECOR_CEILING:
		world.set_decor(c.x, c.y + 1, 0)
	view.refresh_around(c)
	light.dirty = true
	Fx.dust(fx_parent, Vector2(c) * S + Vector2(8, 8), TileDefs.dust_colors(t))


func place_torch(c: Vector2i) -> void:
	if not in_reach(c) or not world.inside(c.x, c.y) or world.solid(c.x, c.y) or world.torches.has(c):
		return
	if not world.solid(c.x, c.y + 1) and world.wall(c.x, c.y) == 0:
		return
	world.add_torch(c)
	world.set_decor(c.x, c.y, 0)
	view.refresh_around(c)
	view.add_torch(c)
	light.dirty = true
