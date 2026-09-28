class_name Masonry
extends Node
## Costruire (voce 35): pareti di fondo da piazzare (clic con la parete in mano) e da togliere con il Martello (tenendo
## premuto), porte che si aprono e si chiudono con il clic destro (chiuse sono tessere `PORTA`: fermano il Germogliato
## e le creature), il letto che diventa il punto di rinascita del personaggio in questo mondo.

const S := 16
const HAMMER_TIME := 0.25

## Ciò che lascia una parete tolta con il martello (le pareti naturali non lasciano nulla).
const WALL_DROP := {TileDefs.WALL_ASSI: "parete_assi", TileDefs.WALL_MATTONI: "parete_mattoni", TileDefs.WALL_SEM: "parete_sem"}

var m: Node2D
var _t := 0.0
var _cell := Vector2i(-9999, -9999)


func setup(main: Node2D) -> void:
	m = main


## Piazza una parete di fondo: su una cella senza parete, accanto a un'altra parete o a un blocco.
func place_wall(c: Vector2i, id: String) -> bool:
	var w: World = m.world
	var wall := int(ItemsData.get_item(id).get("wall", 0))
	if wall == 0 or not m.actions.in_reach(c) or not w.inside(c.x, c.y) or w.wall(c.x, c.y) != 0:
		return false
	var touches := false
	for o in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var q: Vector2i = c + o
		if w.wall(q.x, q.y) != 0 or w.solid(q.x, q.y):
			touches = true
	if not touches or not m.character.bisaccia.remove(id, 1):
		return false
	w.walls[c.y * w.w + c.x] = wall
	m.view.refresh_around(c)
	m.light.dirty = true
	m.sfx.play("posa", Vector2(c) * S)
	return true


## Il martello: tenendo premuto su una parete (dove non c'è un blocco davanti) la si toglie.
func _process(dt: float) -> void:
	if not m.built:
		return
	var item: Dictionary = m.hud.current()
	if String(ItemsData.get_item(String(item["id"])).get("kind", "")) != "martello" or not m.actions.enabled \
			or m.hud.is_open() or not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_t = 0.0
		return
	var c: Vector2i = m.actions.mouse_cell()
	m.player.swinging = true
	if c != _cell:
		_cell = c
		_t = 0.0
	var w: World = m.world
	if not m.actions.in_reach(c) or w.solid(c.x, c.y) or w.wall(c.x, c.y) == 0:
		return
	_t += dt
	if _t >= HAMMER_TIME:
		_t = 0.0
		remove_wall(c)


func remove_wall(c: Vector2i) -> void:
	var w: World = m.world
	var wl := w.wall(c.x, c.y)
	w.walls[c.y * w.w + c.x] = 0
	w.set_tint(c.x, c.y, w.block_tint(c.x, c.y), 0)   # voce 140: il colore se ne va con la parete
	m.view.refresh_around(c)
	m.light.dirty = true
	var at := Vector2(c) * S + Vector2(8, 8)
	if WALL_DROP.has(wl):
		m.drops.spawn(String(WALL_DROP[wl]), 1, at)
	elif wl >= BuildData.WALL_BASE and wl - BuildData.WALL_BASE < BuildData.MATERIALS.size():
		m.drops.spawn("parete_%s" % BuildData.MATERIALS[wl - BuildData.WALL_BASE]["id"], 1, at)   # voce 128
	Fx.dust(m.fx, at, TileDefs.dust_colors(TileDefs.STONE))
	m.sfx.play("scavo_roccia", at)


## Una porta appena piazzata o ripresa: chiusa, le sue celle diventano tessere `PORTA` (solide); ripresa, tornano aria.
func door_placed(o: Vector2i, placed: bool) -> void:
	for dy in door_h():
		m.world.set_tile(o.x, o.y + dy, TileDefs.PORTA if placed else TileDefs.AIR)
		m.view.refresh_around(o + Vector2i(0, dy))
	m.light.dirty = true


## Quante tessere è alta una porta (26 set 2026: due, quanto il Germogliato; erano tre).
static func door_h() -> int:
	return int(StationsData.STATIONS["porta"]["size"][1])


## Clic destro su una porta: si apre o si chiude (non si chiude addosso a qualcuno).
func toggle_door(o: Vector2i) -> bool:
	var w: World = m.world
	if not w.stations.has(o):
		return false
	var id := String(w.stations[o])
	var cells := Rect2(Vector2(o) * S, Vector2(1, door_h()) * S)
	if id == "porta_aperta":
		if cells.intersects(Rect2(m.player.position - Player.HALF, Player.HALF * 2.0)):
			return false
		for c in m.fauna.list:
			if cells.intersects(c.rect()):
				return false
	w.stations[o] = "porta" if id == "porta_aperta" else "porta_aperta"
	for dy in door_h():
		w.set_tile(o.x, o.y + dy, TileDefs.PORTA if id == "porta_aperta" else TileDefs.AIR)
		m.view.refresh_around(o + Vector2i(0, dy))
	m.view.remove_station(o)
	m.view.add_station(o)
	m.light.dirty = true
	m.sfx.play("legno", Vector2(o) * S)
	return true


## Clic destro sul letto: da ora il Germogliato rinasce qui (in questo mondo).
func use_bed(o: Vector2i) -> bool:
	var beds: Dictionary = m.world_meta.get("letti", {})
	# il punto dove si rinasce: al centro del letto, sulla sua riga più bassa (il letto è alto una tessera)
	beds[m.character.id] = [o.x + 1, o.y + int(StationsData.STATIONS["letto"]["size"][1]) - 1]
	m.world_meta["letti"] = beds
	m.hud.toast("Da ora rinasci qui, al tuo letto di foglie")
	m.sfx.play("dono")
	return true


## Dove si rinasce: il letto del personaggio se c'è ancora, altrimenti la partenza del mondo.
func respawn_point() -> Vector2i:
	var b: Array = (m.world_meta.get("letti", {}) as Dictionary).get(m.character.id, [])
	if b.size() == 2:
		var c := Vector2i(int(b[0]), int(b[1]))
		var st: Dictionary = m.world.station_at(c)
		if not st.is_empty() and st["id"] == "letto":
			return c
	return m.world.spawn
