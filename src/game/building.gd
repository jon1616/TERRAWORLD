class_name Building
extends RefCounted
## Stazioni e passerelle: piazzarle dalla mano e riprenderle. Separato da `PlayerActions` per tenere i file piccoli;
## usa i suoi riferimenti (mondo, vista, luce, Bisaccia…).

const S := 16

var a: PlayerActions


func _init(actions: PlayerActions) -> void:
	a = actions


## Piazza una stazione con il mouse sul bordo in basso, al centro.
func place_station(c: Vector2i, id: String) -> bool:
	var sid := String(ItemsData.get_item(id)["place"])
	var size: Array = StationsData.STATIONS[sid]["size"]
	var o := c - Vector2i(int(size[0]) / 2, int(size[1]) - 1)
	if not a.in_reach(c) or not a.world.station_fits(sid, o):
		a.hud.toast("Serve spazio libero e un pavimento sotto")
		return false
	var slot := a.hud.sel
	if a.bisaccia.id_at(slot) != id:
		return false
	for dy in size[1]:
		for dx in size[0]:
			if a.world.decor_at(o.x + dx, o.y + dy) != 0:
				a.pick_decor(o + Vector2i(dx, dy))
	a.world.stations[o] = sid
	a.bisaccia.take_one(slot)
	a.view.add_station(o)
	a.light.dirty = true
	return true


func take_station(o: Vector2i) -> void:
	var sid: String = a.world.stations[o]
	if a.world.chests.has(o):
		if not (a.world.chests[o] as Bisaccia).is_empty():
			a.hud.toast("Prima svuota la cesta")
			return
		a.world.chests.erase(o)
	var size: Array = StationsData.STATIONS[sid]["size"]
	a.world.stations.erase(o)
	a.view.remove_station(o)
	a.light.dirty = true
	a.drops.spawn(String(StationsData.STATIONS[sid]["item"]), 1, Vector2(o) * S + Vector2(size[0], size[1]) * S * 0.5)


## Passerella di radice: su una cella d'aria accanto a un blocco o a un'altra passerella.
func place_plat(c: Vector2i, id: String) -> bool:
	if not a.in_reach(c) or not a.world.inside(c.x, c.y) or a.world.solid(c.x, c.y) or a.world.plat(c.x, c.y) \
			or a.world.torches.has(c) or not a.world.station_at(c).is_empty():
		return false
	var touches := a.world.solid(c.x - 1, c.y) or a.world.solid(c.x + 1, c.y) or a.world.plat(c.x - 1, c.y) \
			or a.world.plat(c.x + 1, c.y) or a.world.solid(c.x, c.y + 1) or a.world.wall(c.x, c.y) != 0
	if not touches:
		return false
	var slot := a.hud.sel
	if a.bisaccia.id_at(slot) != id:
		return false
	if a.world.decor_at(c.x, c.y) != 0:
		a.pick_decor(c)
	a.world.set_plat(c.x, c.y, true)
	a.bisaccia.take_one(slot)
	a.view.refresh_around(c)
	return true


func take_plat(c: Vector2i) -> void:
	a.world.set_plat(c.x, c.y, false)
	a.view.refresh_around(c)
	a.drops.spawn("passerella", 1, Vector2(c) * S + Vector2(8, 8))
