class_name TestsComfort
extends RefCounted
## Le comodità del 29 set 2026 (gruppo «comodita»): il tasto «Riponi nelle casse» e lo scavo intelligente (l'ordine
## dal più vicino al mouse, mai sotto i piedi, mai ciò che è costruito, mai accanto a un liquido, la vena).

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(70, 0), 10)
	if spot.x < 0:
		spot = Vector2i(floori(m.player.position.x / S), floori(m.player.position.y / S))
		print("ATTENZIONE: nessun posto piano per le comodità, uso la cella del Germogliato")
	kit.flatten(spot, 10)
	m.snap_to(spot)
	await kit.frames(3)
	await _stash(spot)
	await _smart(spot)


func _stash(spot: Vector2i) -> void:
	var b := kit.bisaccia()
	kit.make_room()
	var o := spot + Vector2i(-5, 0)
	world.stations[o] = "cesta"
	m.view.add_station(o)
	var ch := world.chest_at(o)
	ch.add("legno", 1)
	b.slots[Bisaccia.HOTBAR + 2] = {"id": "legno", "n": 40}
	b.slots[Bisaccia.HOTBAR + 5] = {"id": "gelatina", "n": 7}
	b.changed.emit()
	await kit.seconds(0.2)
	var bag0 := b.count("legno")
	var gel0 := b.count("gelatina")
	var ev := InputEventKey.new()
	ev.keycode = int(Settings.keys_of("riponi")[0])
	ev.pressed = true
	m.storage._unhandled_input(ev)
	var ok := ch.count("legno") == 41 and b.count("legno") == bag0 - 40 and b.count("gelatina") == gel0
	print("riponi (tasto %s): legno nella cassa %d, nella Bisaccia %d; gelatina (nessuna cassa la vuole) %d%s" % [
		Keys.label("riponi"), ch.count("legno"), b.count("legno"), b.count("gelatina"), "" if ok else " — ATTENZIONE: riponi non va"])
	world.chests.erase(o)
	world.stations.erase(o)
	m.view.remove_station(o)


func _smart(spot: Vector2i) -> void:
	var pa: PlayerActions = m.actions
	kit.hold("piccone_radicite")
	var item: Dictionary = m.hud.current()
	# un muro di humus a destra (3 × 4), un blocco di mattoni sopra, un'acqua che bagna la colonna più lontana
	var x0 := spot.x + 2
	for x in range(x0, x0 + 3):
		for y in range(spot.y - 3, spot.y + 1):
			world.set_tile(x, y, TileDefs.DIRT)
	world.set_tile(x0, spot.y - 4, TileDefs.MATTONI)
	world.set_tile(x0 + 3, spot.y - 3, TileDefs.AIR)
	world.set_liq(x0 + 3, spot.y - 3, 8, 0)
	m.view.refresh_around(Vector2i(x0 + 1, spot.y - 2))
	var mouse := Vector2(spot.x + 1, spot.y - 2) * S + Vector2(8, 8)
	var sd := pa.smart
	sd.reset()
	var order := []
	var feet := Vector2i(spot.x, spot.y + 1)
	var bad := []
	for i in 14:
		var c := sd.pick(pa, Vector2i(spot.x + 1, spot.y - 2), mouse, item)
		if not world.solid(c.x, c.y):
			break
		order.append(c)
		if c == feet or world.tile(c.x, c.y) == TileDefs.MATTONI or c == Vector2i(x0 + 2, spot.y - 3):
			bad.append(c)
		pa.break_tile(c)
	var first_ok: bool = order.size() > 0 and order[0] == Vector2i(x0, spot.y - 2)
	print("scavo intelligente: %d blocchi, il primo %s (atteso %s), proibiti presi %s; mattoni ancora lì %s, humus accanto all'acqua ancora lì %s" % [
		order.size(), order[0] if order.size() > 0 else "-", Vector2i(x0, spot.y - 2), bad,
		world.tile(x0, spot.y - 4) == TileDefs.MATTONI, world.tile(x0 + 2, spot.y - 3) == TileDefs.DIRT])
	# la vena: solo l'ardesia tra humus e ardesia
	for x in range(x0, x0 + 3):
		for y in range(spot.y - 3, spot.y + 1):
			world.set_tile(x, y, TileDefs.STONE if (x + y) % 2 == 0 else TileDefs.DIRT)
	world.set_liq(x0 + 3, spot.y - 3, 0, 0)
	sd.reset()
	sd._vein_asked = true
	sd.vein = TileDefs.STONE
	var vein_ok := true
	var n := 0
	for i in 10:
		var c := sd.pick(pa, Vector2i(spot.x + 1, spot.y - 2), mouse, item)
		if not world.solid(c.x, c.y):
			break
		if world.tile(c.x, c.y) != TileDefs.STONE:
			vein_ok = false
		pa.break_tile(c)
		n += 1
	sd.reset()
	print("vena d'ardesia: %d blocchi, tutti d'ardesia %s" % [n, vein_ok])
	if not first_ok or not bad.is_empty() or order.size() < 5 or not vein_ok or n < 2:
		print("ATTENZIONE: lo scavo intelligente non rispetta le sue regole")
	await kit.save("211_scavo_intelligente")
	# rimette il posto piano com'era (le prove dopo cercano un tratto piano qui attorno)
	for x in range(x0 - 1, x0 + 5):
		world.set_tile(x, spot.y + 1, TileDefs.STONE)
		for y in range(spot.y - 5, spot.y + 1):
			world.set_tile(x, y, TileDefs.AIR)
			world.set_liq(x, y, 0, 0)
	m.view.refresh_around(Vector2i(x0 + 1, spot.y))
