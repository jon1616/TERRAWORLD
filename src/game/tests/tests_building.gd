class_name TestsBuilding
extends RefCounted
## Prove della voce 35: una casetta costruita come farebbe il giocatore (assi, mattoni, vetro, pareti, porta, lampada,
## tavolo, sedia, letto); la porta chiusa ferma, aperta lascia passare; il martello toglie una parete e la ridà; il
## letto diventa il punto di rinascita; il vetro lascia passare la luce; foto 63_casa.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var b: Bisaccia = m.character.bisaccia
	var ms: Masonry = m.masonry
	kit.make_room()
	var spot := kit.flat_spot(world.spawn + Vector2i(80, 0), 4)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per la casa")
		return
	kit.flatten(spot, 10)
	var fy := spot.y + 1                       # il pavimento
	var x0 := spot.x - 8
	var x1 := spot.x + 8
	# nel giro lungo le prove di prima lasciano stazioni e terra qui attorno: si sgombera tutta la casa (la porta non
	# ci stava e la prova falliva, successo quando i biomi nuovi hanno cambiato la forma del mondo)
	for o in world.stations.keys():
		if Rect2i(x0 - 4, fy - 10, x1 - x0 + 9, 10).has_point(o):
			world.stations.erase(o)
			m.view.remove_station(o)
	for x in range(x0, x1 + 1):
		for y in range(fy - 9, fy):
			world.set_tile(x, y, TileDefs.AIR)
			world.set_decor(x, y, 0)
	# pavimento di assi, muri di mattoni alti 6 con una finestra di vetro, tetto di assi
	for x in range(x0, x1 + 1):
		world.set_tile(x, fy, TileDefs.ASSI)
		world.set_tile(x, fy - 7, TileDefs.ASSI)
	for y in range(fy - 6, fy):
		world.set_tile(x0, y, TileDefs.MATTONI)
		world.set_tile(x1, y, TileDefs.MATTONI if y != fy - 4 else TileDefs.VETRO)
	for x in range(x0, x1 + 1, 2):
		for y in range(fy - 7, fy + 1, 2):
			m.view.refresh_around(Vector2i(x, y))
	# le pareti di fondo, come le metterebbe il giocatore
	m.snap_to(spot)
	await kit.frames(2)
	var walls := 0
	b.add("parete_assi", 99)
	for y in range(fy - 6, fy):
		for x in range(x0 + 1, x1):
			if m.actions.in_reach(Vector2i(x, y)) and ms.place_wall(Vector2i(x, y), "parete_assi"):
				walls += 1
	# la porta nel muro di sinistra: tolti due mattoni, un vano alto quanto la porta (2, quanto il Germogliato)
	for y in range(fy - Masonry.door_h(), fy):
		world.set_tile(x0, y, TileDefs.AIR)
	m.view.refresh_around(Vector2i(x0, fy - 2))
	var placed := {}
	for pair in [["porta_lanterna", Vector2i(x0, fy - 1)], ["lampada_lanterna", Vector2i(x0 + 3, fy - 1)],
			["tavolo_radice", Vector2i(x0 + 7, fy - 1)], ["sedia_radice", Vector2i(x0 + 5, fy - 1)],
			["letto_foglie", Vector2i(x1 - 3, fy - 1)]]:
		b.add(String(pair[0]), 1)
		m.snap_to(pair[1] + Vector2i(1, 0))
		kit.hold(String(pair[0]))
		var sid := String(ItemsData.get_item(String(pair[0]))["place"])
		var size: Array = StationsData.STATIONS[sid]["size"]
		var o: Vector2i = pair[1] - Vector2i(int(size[0]) / 2, int(size[1]) - 1)
		placed[pair[0]] = m.actions.build.place_station(pair[1], String(pair[0]))
		if not placed[pair[0]]:
			print("ATTENZIONE: ", pair[0], " non piazzato; ci sta ", world.station_fits(sid, o), " reach ", m.actions.in_reach(pair[1]), " sel ", m.character.bisaccia.id_at(m.hud.sel))
	print("casa: pareti piazzate %d, arredi %s" % [walls, placed])
	var door := Vector2i(x0, fy - Masonry.door_h())
	var closed := world.solid(door.x, door.y) and world.solid(door.x, door.y + 1)
	# chiusa, il Germogliato che cammina verso fuori si ferma contro la porta
	var inside := Vector2i(x0 + 2, fy - 1)
	var ctl: bool = m.player.control
	m.player.control = false
	m.snap_to(inside)
	m.player.auto_dir = -1.0
	await kit.seconds(1.2)
	var stopped: bool = m.player.position.x > (x0 + 1) * S
	m.player.auto_dir = 0.0
	ms.toggle_door(door)
	var opened := not world.solid(door.x, door.y) and not world.solid(door.x, door.y + 1)
	# aperta, ci passa camminando (il vano è alto due tessere: il Germogliato ci sta giusto)
	m.snap_to(inside)
	m.player.auto_dir = -1.0
	await kit.seconds(1.5)
	var through: bool = m.player.position.x < x0 * S
	m.player.auto_dir = 0.0
	m.player.control = ctl
	await kit.save("63b_porta")
	m.snap_to(inside)
	await kit.frames(2)
	ms.toggle_door(door)
	print("porta (alta %d): chiusa ferma %s (il Germogliato si ferma %s), aperta lascia passare %s (ci passa camminando %s), richiusa %s" % [
		Masonry.door_h(), "sì" if closed else "NO", "sì" if stopped else "NO", "sì" if opened else "NO",
		"sì" if through else "NO", "sì" if world.solid(door.x, door.y + 1) else "NO"])
	if not (closed and stopped and opened and through):
		print("ATTENZIONE: la porta non funziona come dovrebbe")
	# il martello
	m.snap_to(spot)
	var w0 := b.count("parete_assi")
	ms.remove_wall(Vector2i(spot.x, fy - 3))
	await kit.frames(2)
	var got := 0
	for d in m.drops._items:
		if String(d["id"]) == "parete_assi":
			got += int(d["n"])
	print("martello: parete tolta %s, ne cade una %s" % ["sì" if world.wall(spot.x, fy - 3) == 0 else "NO",
		"sì" if got > 0 or b.count("parete_assi") > w0 else "NO"])
	b.add("parete_assi", 1)
	ms.place_wall(Vector2i(spot.x, fy - 3), "parete_assi")
	# il letto
	ms.use_bed(Vector2i(x1 - 4, fy - 2))
	print("letto: si rinasce a %s (partenza %s)" % [ms.respawn_point(), world.spawn])
	# la luce: il vetro la lascia passare, i mattoni no
	m.day.time = 0.95
	m.day.apply(true)
	m.snap_to(Vector2i(spot.x - 2, fy - 1))
	await kit.seconds(1.5)
	await kit.save("63_casa")
	m.day.time = 0.5
	m.day.apply(true)
	var beds: Dictionary = m.world_meta.get("letti", {})
	beds.erase(m.character.id)
	await kit.frames(2)
