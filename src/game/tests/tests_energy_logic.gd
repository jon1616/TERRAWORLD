class_name TestsEnergyLogic
extends RefCounted
## Roadmap 19, voci 204-205: i sensori e i nodi della logica (gruppo `energia`, chiamate da `TestsEnergy.run`).

var t: TestsEnergy
var kit: TestKit
var m: Node


func _init(tk: TestKit, owner: TestsEnergy) -> void:
	kit = tk
	t = owner
	m = tk.m


func _bit(k: int) -> int:
	return 1 << (VeinsData.WIRE_SHIFT + k)


## Il filo del colore k nella cella c è acceso?
func _on(c: Vector2i, k: int) -> bool:
	return m.energy.impulse.state_at(c, k) == 1


func _lever(o: Vector2i, v: bool) -> void:
	var mc: Machine = m.energy.machines[o]
	if bool(mc.st.get("out", false)) != v:
		m.energy.touch(o)


func _clear(p: Vector2i, width: int) -> void:
	var e: Energy = m.energy
	var w: World = m.world
	for o in e.machines.keys():
		if o.x >= p.x - 2 and o.x <= p.x + width and o.y >= p.y - 12:
			if w.chests.has(o):
				w.chests.erase(o)
			t.unplace(o)
	for x in range(p.x - 2, p.x + width + 1):
		for y in range(p.y - 12, p.y + 1):
			if w.vein_at(x, y) != 0:
				w.set_vein(x, y, 0)
				e._on_vein(Vector2i(x, y))
				m.view.refresh_vein(Vector2i(x, y))


## Voce 204: ogni sensore accende il suo filo quando deve, e lo spegne quando non deve più.
func sensors() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p: Vector2i = await t.clean_spot(-170, 44)
	var y := p.y
	var T := _bit(0)
	var res := {}
	for x in range(p.x - 3, p.x + 42):                  # niente stagni nel posto delle prove (a volte c'è un lago)
		for yy in range(y - 12, y + 1):
			if x == p.x - 3 or x == p.x + 41:
				w.set_tile(x, yy, TileDefs.STONE)
			elif w.liq(x, yy) > 0:
				w.set_liq(x, yy, 0, 0)
	m.view.refresh_rect(Rect2i(p.x - 3, y - 12, 45, 13))
	# l'Occhio di luce: a mezzogiorno acceso, «di notte» spento
	var eye := t.place("occhio_luce", Vector2i(p.x, y))
	t.lay_row(p.x, p.x + 2, y, T)
	await t.ticks(3)
	var day_on := _on(Vector2i(p.x + 2, y), 0)
	(e.machines[eye] as Machine).st["inv"] = true
	await t.ticks(3)
	res["luce"] = day_on and not _on(Vector2i(p.x + 2, y), 0)
	# l'Orecchio di muschio: una creatura ostile vicina
	var ear := t.place("orecchio_muschio", Vector2i(p.x + 5, y))
	t.lay_row(p.x + 5, p.x + 7, y, T)
	await t.ticks(3)
	var quiet := not _on(Vector2i(p.x + 7, y), 0)
	var foe: Creature = m.fauna.spawn_at_nest("grumo_muschio", Vector2i(p.x + 9, y))
	await t.ticks(3)
	var heard := _on(Vector2i(p.x + 7, y), 0)
	if is_instance_valid(foe):
		m.fauna.clear()
	await t.ticks(3)
	res["orecchio"] = quiet and heard and not _on(Vector2i(p.x + 7, y), 0)
	if not res["orecchio"]:
		print("  orecchio: quieto %s, sente %s, dopo %s (creature %d, liquido sotto l'acqua %d)" % [quiet, heard,
			_on(Vector2i(p.x + 7, y), 0), m.fauna.list.size(), w.liq(p.x + 10, y)])
	# il Sensore d'acqua: acceso con l'acqua nella sua tessera, spento con la brace se vuole l'acqua
	var wet := t.place("sensore_acqua", Vector2i(p.x + 10, y))
	t.lay_row(p.x + 10, p.x + 12, y, T)
	await t.ticks(3)
	(e.machines[wet] as Machine).st["tipo"] = LiquidsData.ACQUA
	await t.ticks(2)
	var dry := not _on(Vector2i(p.x + 12, y), 0)
	w.set_tile(p.x + 9, y, TileDefs.STONE)                 # una conca: l'acqua non scappa
	w.set_tile(p.x + 11, y, TileDefs.STONE)
	w.set_liq(p.x + 10, y, 8, LiquidsData.ACQUA)
	await t.ticks(3)
	var water := _on(Vector2i(p.x + 12, y), 0)
	w.set_liq(p.x + 10, y, 8, LiquidsData.BRACE)
	await t.ticks(3)
	res["acqua"] = dry and water and not _on(Vector2i(p.x + 12, y), 0)
	if not res["acqua"]:
		print("  acqua: all'asciutto spento %s, con l'acqua acceso %s (livello %d)" % [dry, water, w.liq(p.x + 10, y)])
	w.set_liq(p.x + 10, y, 0, 0)
	w.set_tile(p.x + 9, y, TileDefs.AIR)
	w.set_tile(p.x + 11, y, TileDefs.AIR)
	# il Sensore di cassa: una cesta a sinistra, acceso se ha qualcosa
	var box_o := t.place("cesta", Vector2i(p.x + 15, y))
	var sz: Array = StationsData.STATIONS["cesta"]["size"]
	var sens := t.place("sensore_cassa", Vector2i(p.x + 15 + int(sz[0]), y))
	t.lay_row(sens.x, sens.x + 2, y, T)
	await t.ticks(3)
	var empty := not _on(Vector2i(sens.x + 2, y), 0)
	w.chest_at(box_o).add("legno", 5)
	await t.ticks(3)
	res["cassa"] = empty and _on(Vector2i(sens.x + 2, y), 0)
	# il Sensore di riserva: sulla rete di un Otre; pieno spento, vuoto acceso
	await t.more.powered("sensore_riserva", Vector2i(p.x + 22, y))
	t.lay(Vector2i(p.x + 22, y), T)
	var otre_o := Vector2i(p.x + 23, y - int(StationsData.STATIONS["otre_linfa"]["size"][1]) + 1)
	await t.ticks(3)
	var full_off := not _on(Vector2i(p.x + 22, y), 0)
	(e.machines[otre_o] as Machine).st["g"] = 0.0
	await t.ticks(3)
	res["riserva"] = full_off and _on(Vector2i(p.x + 22, y), 0)
	# l'Orologio di Linfa: un colpo al secondo su un carillon
	var bell := await t.more.powered("carillon_radice", Vector2i(p.x + 28, y))
	var clock := t.place("orologio_linfa", Vector2i(p.x + 28, y - 1))
	t.lay(Vector2i(p.x + 28, y - 1), T)
	t.lay(Vector2i(p.x + 28, y), T)
	(e.machines[bell] as Machine).st["suoni"] = 0
	await t.ticks(2)
	(e.machines[clock] as Machine).st["periodo"] = 1.0
	await kit.seconds(2.6)
	var rings := int((e.machines[bell] as Machine).st.get("suoni", 0))
	res["orologio"] = rings >= 2 and rings <= 3
	# il Barometro: acceso con la pioggia
	var wp: bool = m.weather.paused
	var w0 := String(m.weather.id)
	m.weather.paused = true
	var baro := t.place("barometro", Vector2i(p.x + 33, y))
	t.lay_row(p.x + 33, p.x + 35, y, T)
	m.weather.set_weather("sereno")
	await t.ticks(3)
	var clear_off := not _on(Vector2i(p.x + 35, y), 0)
	m.weather.set_weather("pioggia")
	await t.ticks(3)
	res["meteo"] = clear_off and _on(Vector2i(p.x + 35, y), 0) and baro.x > 0
	m.weather.set_weather(w0)
	m.weather.paused = wp
	await kit.save("238_sensori")
	print("sensori: %s (orologio: %d colpi in 2,6 s)" % [str(res), rings])
	if false in res.values():
		print("ATTENZIONE: un sensore non fa ciò che deve")
	_clear(p, 40)


## Voce 205: le tavole di verità di E, O, NON; il ritardo; il contatore di 10; la memoria; un giro chiuso che oscilla
## senza fermare il gioco.
func logic() -> void:
	var e: Energy = m.energy
	var p: Vector2i = await t.clean_spot(-230, 30)
	var y := p.y
	var x0 := p.x
	var la := t.place("leva_radice", Vector2i(x0, y))
	t.lay_row(x0, x0 + 4, y, _bit(0))
	var lb := t.place("leva_radice", Vector2i(x0 + 4, y - 3))
	for yy in range(y - 3, y + 1):
		t.lay(Vector2i(x0 + 4, yy), _bit(1))
	t.lay_row(x0 + 4, x0 + 8, y, _bit(2))
	var out_c := Vector2i(x0 + 8, y)
	var node := Vector2i(x0 + 4, y)
	var tables := {"nodo_e": [false, false, false, true], "nodo_o": [false, true, true, true], "nodo_non": [true, false, false, false]}
	var ok := {}
	for id in tables:
		t.place(id, node)
		await t.ticks(2)
		var got := []
		for i in 4:
			_lever(la, (i & 2) != 0)
			_lever(lb, (i & 1) != 0)
			await t.settle(0.3)
			await t.ticks(1)
			got.append(_on(out_c, 2))
		ok[id] = got == tables[id]
		if not ok[id]:
			print("  %s: %s invece di %s" % [id, str(got), str(tables[id])])
		t.unplace(node)
	# il ritardo: un secondo
	_lever(la, false)
	_lever(lb, false)
	t.place("nodo_ritardo", node)
	await t.ticks(2)
	(e.machines[node] as Machine).st["attesa"] = 1.0
	_lever(la, true)
	await kit.seconds(0.5)
	var early := _on(out_c, 2)
	await kit.seconds(0.9)
	ok["ritardo"] = not early and _on(out_c, 2)
	_lever(la, false)
	await kit.seconds(1.2)
	t.unplace(node)
	# il contatore: dieci accensioni, un colpo sul carillon
	var bell := await t.more.powered("carillon_radice", Vector2i(x0 + 9, y))
	t.lay(Vector2i(x0 + 9, y), _bit(2))
	t.place("nodo_contatore", node)
	await t.ticks(2)
	(e.machines[bell] as Machine).st["suoni"] = 0
	for i in 18:                                   # nove accensioni
		_lever(la, i % 2 == 0)
		await kit.frames(3)
	await t.settle(0.3)
	var after9 := int((e.machines[bell] as Machine).st.get("suoni", 0))
	_lever(la, true)
	await t.settle(0.3)
	var after10 := int((e.machines[bell] as Machine).st.get("suoni", 0))
	ok["contatore"] = after9 == 0 and after10 == 1
	if not ok["contatore"]:
		print("  contatore: dopo 9 accensioni %d colpi, dopo 10 %d" % [after9, after10])
	_lever(la, false)
	await t.settle(0.2)
	t.unplace(node)
	# la memoria: la leva A accende, la B spegne; lasciate andare, ricorda
	t.place("nodo_memoria", node)
	await t.ticks(2)
	_lever(la, true)
	await t.settle(0.3)
	_lever(la, false)
	await t.settle(0.3)
	var kept := _on(out_c, 2)
	_lever(lb, true)
	await t.settle(0.3)
	_lever(lb, false)
	await t.settle(0.3)
	ok["memoria"] = kept and not _on(out_c, 2)
	await kit.save("239_logica")
	# un giro chiuso: NON (viola → corallo) e O (corallo → viola) si inseguono
	var yl := y - 6
	var n1 := t.place("nodo_non", Vector2i(x0 + 14, yl))
	var n2 := t.place("nodo_o", Vector2i(x0 + 18, yl))
	t.lay_row(x0 + 14, x0 + 18, yl, _bit(2) | _bit(3))
	await t.ticks(2)
	MbNodo.set_output(e.machines[n1], e, 2)
	MbNodo.set_output(e.machines[n2], e, 3)
	var flips := 0
	var last := _on(Vector2i(x0 + 16, yl), 2)
	var f0 := Engine.get_frames_drawn()
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 1500:
		await m.get_tree().process_frame
		var now := _on(Vector2i(x0 + 16, yl), 2)
		if now != last:
			flips += 1
			last = now
	var frames := Engine.get_frames_drawn() - f0
	ok["giro"] = flips >= 4 and frames >= 30 and e.impulse.queue.size() < 50
	print("nodi: %s (giro chiuso: %d cambi in 1,5 s, %d fotogrammi, %d eventi in coda)" % [str(ok), flips, frames, e.impulse.queue.size()])
	if false in ok.values():
		print("ATTENZIONE: un nodo della logica non fa ciò che deve")
	_clear(p, 30)
