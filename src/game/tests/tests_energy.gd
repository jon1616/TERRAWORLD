class_name TestsEnergy
extends RefCounted
## Roadmap 19 «La Linfa che scorre»: le prove della rete (gruppo `energia`). Un posto spianato vicino alla partenza,
## dove si posano vene e fili con la Pinza, si montano sorgenti, riserve e macchine, e si guarda che il Flusso e
## l'Impulso facciano ciò che devono.

const S := 16

var kit: TestKit
var m: Node
var spot := Vector2i(-1, -1)


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var ctl: bool = m.player.control
	m.player.control = false
	m.fauna.clear()
	m.day.paused = true
	kit.make_room()
	spot = kit.flat_spot(m.world.spawn, 12)
	if spot.x < 0:
		spot = m.world.spawn
		print("ATTENZIONE: energia: nessun posto piano, uso la partenza")
	kit.flatten(spot, 16)
	m.snap_to(spot)
	await kit.frames(4)
	await veins()
	await flux()
	await impulses()
	await panel()
	await sources()
	var more := TestsEnergyMore.new(kit, self)
	await more.special()
	await more.reserves()
	await more.moving()
	await more.garden_light_liquids()
	await more.factory()
	await more.drill()
	m.player.control = ctl
	m.day.paused = false


## Voce 191: posare e riprendere vene e fili; il disegno; il salvataggio.
func veins() -> void:
	var b: Bisaccia = m.character.bisaccia
	var v: Veins = m.veins
	b.add("pinza_vene", 1)
	b.add("vena_radice", 40)
	b.add("vena_legnoferro", 10)
	b.add("filo_turchese", 30)
	b.add("filo_ambra", 30)
	kit.hold("pinza_vene")
	await kit.frames(3)
	var w: World = m.world
	var y := spot.y - 1
	var a := Vector2i(spot.x - 8, y)
	var n1 := v.line(a, Vector2i(spot.x + 8, y), 0)                  # 17 vene di radice in fila
	var n2 := v.line(Vector2i(spot.x, y), Vector2i(spot.x, y - 3), 1)  # un ramo di legnoferro (la cella del bivio cambia grado)
	var n3 := v.line(Vector2i(spot.x - 6, y - 2), Vector2i(spot.x + 6, y - 2), 4)   # un filo turchese sopra
	var n4 := v.line(Vector2i(spot.x - 2, y - 4), Vector2i(spot.x - 2, y + 0), 5)   # un filo d'ambra che lo incrocia
	var tiers_ok := VeinsData.tier(w.vein_at(spot.x - 8, y)) == 1 and VeinsData.tier(w.vein_at(spot.x, y - 3)) == 2
	var cross := w.vein_at(spot.x - 2, y - 2)
	var cross_ok := VeinsData.has_wire(cross, 0) and VeinsData.has_wire(cross, 1)
	var joins_ok := VeinsData.joins(w.vein_at(spot.x - 1, y), w.vein_at(spot.x, y)) and not VeinsData.joins(
		w.vein_at(spot.x - 1, y) | VeinsData.INSULATED, w.vein_at(spot.x, y))
	# riprendere torna nella Bisaccia
	var before := b.count("vena_radice")
	var took := v.take(Vector2i(spot.x + 8, y), 0)
	var back := b.count("vena_radice") == before + 1 and VeinsData.tier(w.vein_at(spot.x + 8, y)) == 0
	# scavare non taglia: una vena nella roccia resta
	w.set_tile(spot.x + 10, y, TileDefs.STONE)
	v.put(Vector2i(spot.x + 10, y), 0)
	m.actions.break_tile(Vector2i(spot.x + 10, y))
	var kept := VeinsData.tier(w.vein_at(spot.x + 10, y)) == 1
	m.view.set_show_wires(true)
	await kit.frames(4)
	await kit.save("230_vene")
	print("vene: posate %d radice, %d legnoferro, fili %d turchese e %d ambra; gradi %s, fili incrociati nella stessa cella %s, collegamenti e isolante %s, ripresa %s, scavando resta %s" % [
		n1, n2, n3, n4, "sì" if tiers_ok else "NO", "sì" if cross_ok else "NO", "sì" if joins_ok else "NO",
		"sì" if took and back else "NO", "sì" if kept else "NO"])
	if not (n1 == 17 and n2 >= 3 and n3 == 13 and n4 == 5 and tiers_ok and cross_ok and joins_ok and took and back and kept):
		print("ATTENZIONE: le vene non si posano come dovrebbero")
	# il salvataggio le tiene
	m.save_game()
	var l := WorldSave.load_world(m.world_id)
	var saved_ok: bool = l != null and l.vein == w.vein
	print("vene salvate e ricaricate: %s" % ("identiche" if saved_ok else "DIVERSE"))
	if not saved_ok:
		print("ATTENZIONE: le vene non si salvano")


## Mette una macchina (come la metterebbe il giocatore) con l'angolo in basso a sinistra sulla cella c.
func place(id: String, c: Vector2i) -> Vector2i:
	var size: Array = StationsData.STATIONS[id]["size"]
	var o := Vector2i(c.x, c.y - int(size[1]) + 1)
	for dy in int(size[1]):
		for dx in int(size[0]):
			m.world.set_tile(o.x + dx, o.y + dy, TileDefs.AIR)
	m.world.stations[o] = id
	m.view.add_station(o)
	return o


func unplace(o: Vector2i) -> void:
	m.view.remove_station(o)
	m.world.stations.erase(o)


## Aspetta qualche conto del Flusso.
func ticks(n: int) -> void:
	var e: Energy = m.energy
	var s0 := e.solved
	var t0 := Time.get_ticks_msec()
	while e.solved < s0 + n and Time.get_ticks_msec() - t0 < 5000:
		await m.get_tree().process_frame


## Voce 192: una Foglia-lanterna al sole, un Otre e una Lampada; di notte la Lampada va con l'Otre; con più Lampade
## dell'energia che c'è si spengono prima quelle a priorità bassa.
func flux() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var v: Veins = m.veins
	var b: Bisaccia = m.character.bisaccia
	var y := spot.y
	var x0 := spot.x + 20
	kit.flatten(Vector2i(x0 + 8, y), 14)
	for x in range(x0 - 6, x0 + 24):
		for yy in range(y - 14, y - 4):
			w.set_tile(x, yy, TileDefs.AIR)              # il cielo libero sopra la foglia
	m.view.refresh_rect(Rect2i(x0 - 6, y - 14, 30, 16))
	b.add("vena_radice", 60)
	m.snap_to(Vector2i(x0 + 10, y))                        # la Pinza arriva a 26 tessere
	await kit.frames(3)
	var leaf := place("foglia_lanterna", Vector2i(x0, y))
	var otre := place("otre_linfa", Vector2i(x0 + 4, y))
	var lamp := place("lampada_baccello", Vector2i(x0 + 7, y))
	m.day.time = 0.5
	m.day.apply(true)
	v.line(Vector2i(x0, y), Vector2i(x0 + 8, y), 0)
	await ticks(8)
	var nt := e.net_at(Vector2i(x0 + 2, y))
	var lm: Machine = e.machines.get(lamp)
	var om: Machine = e.machines.get(otre)
	var lf: Machine = e.machines.get(leaf)
	if lm:
		print("  (diagnosi: lampada rete %d, ingresso %s, portata %.0f, potenza %.2f, avuti %.2f, utenti %d, sorgenti %d, riserve %d)" % [
			lm.net, lm.entry, lm.cap, lm.power, lm.given, (nt.get("users", []) as Array).size(), (nt.get("sources", []) as Array).size(),
			(nt.get("reserves", []) as Array).size()])
	var day_ok: bool = lm != null and lm.lit and lf.made > 10.0 and float(om.st.get("g", 0.0)) > 0.0 and bool(nt.get("flowing", false))
	print("Flusso di giorno: la foglia dà %.1f pulsi, la lampada %s, l'Otre %.0f gocce, la vena scorre %s" % [lf.made if lf else 0.0,
		"accesa" if lm and lm.lit else "SPENTA", float(om.st.get("g", 0.0)) if om else 0.0, "sì" if nt.get("flowing", false) else "NO"])
	# di notte: la foglia tace, la lampada va con l'Otre
	om.st["g"] = 500.0
	m.day.time = 0.0
	m.day.apply(true)
	await ticks(6)
	var night_ok: bool = lf.made < 0.01 and lm.lit and float(om.st["g"]) < 500.0
	await kit.frames(4)
	await kit.save("231_flusso_notte")
	# l'Otre vuoto: la lampada si spegne
	om.st["g"] = 0.0
	await ticks(3)
	var empty_ok: bool = not lm.lit
	print("Flusso di notte: foglia %.1f, lampada %s con l'Otre (%.0f gocce), a Otre vuoto %s" % [lf.made,
		"accesa" if night_ok else "NO", float(om.st["g"]), "spenta" if empty_ok else "ANCORA ACCESA"])
	# la priorità: senza Otre, 13 lampade e una foglia da 12: resta accesa quella ad alta priorità
	unplace(otre)
	m.day.time = 0.5
	m.day.apply(true)
	var extra := []
	for k in 12:
		extra.append(place("lampada_baccello", Vector2i(x0 + 9 + k, y)))
	v.line(Vector2i(x0 + 8, y), Vector2i(x0 + 21, y), 0)
	await ticks(2)
	lm.st["prio"] = 2
	for o in extra:
		(e.machines[o] as Machine).st["prio"] = 0
	await ticks(4)
	var low_off := true
	for o in extra:
		if (e.machines[o] as Machine).lit:
			low_off = false
	var prio_ok: bool = lm.lit and low_off
	print("priorità: la lampada alta %s, le 12 basse %s (la foglia dà %.1f, chiedono 13)" % ["accesa" if lm.lit else "SPENTA",
		"ferme" if low_off else "ACCESE", lf.made])
	# la vena più stretta: una macchina dietro una sola cella di radice prende al più 30
	var cap_ok: bool = absf(lm.cap - 30.0) < 0.01
	if not (day_ok and night_ok and empty_ok and prio_ok and cap_ok):
		print("ATTENZIONE: il Flusso non va come dovrebbe (giorno %s, notte %s, vuoto %s, priorità %s, portata %s)" % [day_ok, night_ok,
			empty_ok, prio_ok, cap_ok])
	for o in extra:
		unplace(o)
	unplace(lamp)
	unplace(leaf)


## Posa una vena o un filo in una cella senza la Pinza (per le prove lontane dal Germogliato).
func lay(c: Vector2i, bits: int) -> void:
	m.world.set_vein(c.x, c.y, m.world.vein_at(c.x, c.y) | bits)
	m.energy._on_vein(c)
	m.view.refresh_vein(c)


func lay_row(x0: int, x1: int, y: int, bits: int) -> void:
	for x in range(mini(x0, x1), maxi(x0, x1) + 1):
		lay(Vector2i(x, y), bits)


func door_open(o: Vector2i) -> bool:
	return m.world.tile(o.x, o.y) == TileDefs.AIR and m.world.tile(o.x, o.y + 1) == TileDefs.AIR


## Aspetta qualche fotogramma (le porte e le piastre si guardano a ogni fotogramma, gli impulsi arrivano subito).
func settle(secs := 0.4) -> void:
	await kit.seconds(secs)


## Voce 193: una leva a 40 tessere apre e chiude una porta; un pulsante la alterna; una piastra la apre finché ci stai
## sopra; una porta senza fili si apre da sola quando arrivi; senza Linfa una porta non si muove.
func impulses() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var y := spot.y
	var dx := spot.x - 30
	kit.flatten(Vector2i(dx + 20, y), 26)
	var TURQ := 1 << VeinsData.WIRE_SHIFT
	# la porta, con un Otre carico accanto e una vena sotto entrambi
	var door := place("porta_viva", Vector2i(dx, y))
	var otre := place("otre_linfa", Vector2i(dx + 1, y))
	lay_row(dx, dx + 1, y, 1)
	var lever := place("leva_radice", Vector2i(dx + 40, y))
	lay_row(dx, dx + 40, y, TURQ)
	await ticks(2)
	(e.machines[otre] as Machine).st["g"] = 3000.0
	await settle()
	var closed0 := not door_open(door)
	e.touch(lever)
	await settle()
	var opened := door_open(door)
	await kit.save("232_impulso")
	e.touch(lever)
	await settle()
	var closed1 := not door_open(door)
	print("Impulso: porta chiusa all'inizio %s, la leva a 40 tessere la apre %s e la chiude %s" % [closed0, opened, closed1])
	# un pulsante: ogni colpo la alterna
	var btn := place("pulsante_radice", Vector2i(dx + 20, y - 1))
	lay(Vector2i(dx + 20, y - 1), TURQ)
	await ticks(2)
	e.touch(btn)
	await settle()
	var p_open := door_open(door)
	e.touch(btn)
	await settle()
	var p_closed := not door_open(door)
	print("pulsante: apre %s, richiude %s" % [p_open, p_closed])
	# una piastra: aperta finché il Germogliato ci sta sopra
	var plate := place("piastra_radice", Vector2i(dx + 10, y))
	await ticks(2)
	m.snap_to(Vector2i(dx + 10, y))
	await settle(0.5)
	var on_plate := door_open(door)
	m.snap_to(Vector2i(dx + 14, y))
	await settle(0.5)
	var off_plate := not door_open(door)
	print("piastra: sopra la porta è aperta %s, sceso si richiude %s" % [on_plate, off_plate])
	# senza Linfa non si muove
	unplace(plate)
	unplace(btn)
	(e.machines[otre] as Machine).st["g"] = 0.0
	await ticks(2)
	e.touch(lever)
	await settle()
	var dry := not door_open(door)
	e.touch(lever)
	# una porta senza fili si apre quando arrivi
	var d2 := place("porta_viva", Vector2i(dx + 44, y))           # oltre la fine del filo turchese
	var o2 := place("otre_linfa", Vector2i(dx + 45, y))
	lay_row(dx + 44, dx + 45, y, 1)
	await ticks(2)
	(e.machines[o2] as Machine).st["g"] = 3000.0
	m.snap_to(Vector2i(dx + 48, y))
	await settle()
	var auto_closed := not door_open(d2)
	m.snap_to(Vector2i(dx + 45, y))
	await settle()
	var auto_open := door_open(d2)
	print("senza Linfa la porta resta chiusa %s; la porta senza fili: chiusa %s, arrivando si apre %s" % [dry, auto_closed, auto_open])
	if not (closed0 and opened and closed1 and p_open and p_closed and on_plate and off_plate and dry and auto_closed and auto_open):
		print("ATTENZIONE: l'Impulso non va come dovrebbe")
	for o in [d2, o2, door, otre, lever]:
		unplace(o)
	await ticks(2)
	var clean := w.tile(door.x, door.y) == TileDefs.AIR and w.tile(d2.x, d2.y) == TileDefs.AIR
	if not clean:
		print("ATTENZIONE: una porta tolta ha lasciato il suo muro")


## Voce 194: il pannello di una macchina e le schede dei suggerimenti.
func panel() -> void:
	var e: Energy = m.energy
	var y := spot.y
	var x0 := spot.x + 60                                   # un posto pulito (niente fili delle prove di prima)
	kit.flatten(Vector2i(x0 + 2, y), 6)
	for x in range(x0 - 2, x0 + 6):
		for yy in range(y - 14, y - 4):
			m.world.set_tile(x, yy, TileDefs.AIR)
	m.snap_to(Vector2i(x0 + 1, y))
	await kit.frames(3)
	var leaf := place("foglia_lanterna", Vector2i(x0, y))
	var lamp := place("lampada_baccello", Vector2i(x0 + 3, y))
	lay_row(x0, x0 + 3, y, 1)
	m.day.time = 0.5
	m.day.apply(true)
	await ticks(4)
	var mc: Machine = e.machines[lamp]
	e.panel.open(mc)
	await kit.frames(6)
	await kit.save("233_pannello_macchina")
	var txt := e.panel._text.get_parsed_text()
	var panel_ok: bool = e.panel.visible and txt.contains("La rete") and txt.contains("pulsi")
	e.panel.close()
	var tip := MachineTip.card(m, lamp, "lampada_baccello").plain()
	var vtip := MachineTip.vein(m, Vector2i(x0 + 1, y)).plain()
	var tips_ok := tip.contains("Adesso") and vtip.contains("Porta al più") and vtip.contains("La rete")
	print("pannello della macchina %s; schede: lampada «%s…», vena «%s…»" % ["sì" if panel_ok else "NO", tip.left(60).replace("\n", " · "),
		vtip.left(60).replace("\n", " · ")])
	if not (panel_ok and tips_ok):
		print("ATTENZIONE: il pannello o le schede della rete non dicono ciò che devono")
	unplace(lamp)
	unplace(leaf)


## Un posto pulito lontano dalle prove di prima, con il cielo libero sopra: la cella del pavimento a sinistra.
func clean_spot(dx: int, width := 14) -> Vector2i:
	var y := spot.y
	var x0 := spot.x + dx
	kit.flatten(Vector2i(x0 + width / 2, y), width / 2 + 2)
	for x in range(x0 - 2, x0 + width + 2):
		for yy in range(y - 16, y - 4):
			m.world.set_tile(x, yy, TileDefs.AIR)
	m.view.refresh_rect(Rect2i(x0 - 2, y - 16, width + 4, 18))
	m.snap_to(Vector2i(x0 + width / 2, y))
	await kit.frames(3)
	return Vector2i(x0, y)


## Voce 195: le sorgenti del mondo, ognuna nel suo posto giusto e a secco dove non deve.
func sources() -> void:
	var e: Energy = m.energy
	var w: World = m.world
	var p := await clean_spot(80, 34)
	var y := p.y
	# il mulino: con il vento pieno quasi tutto, con l'aria ferma un filo, sotto un tetto niente
	var mill := place("mulino_semi", Vector2i(p.x, y))
	await ticks(2)
	var mm: Machine = e.machines[mill]
	var w0: float = m.weather.wind
	m.weather.wind = 160.0
	var windy := mm.bh.produce(mm, e)
	m.weather.wind = 0.0
	var calm := mm.bh.produce(mm, e)
	w.set_tile(p.x, mill.y - 3, TileDefs.STONE)
	var roofed := mm.bh.produce(mm, e)
	w.set_tile(p.x, mill.y - 3, TileDefs.AIR)
	m.weather.wind = w0
	var mill_ok := windy >= 34.0 and calm > 1.0 and calm < 12.0 and roofed == 0.0
	print("mulino: vento pieno %.1f pulsi, aria ferma %.1f, sotto un tetto %.1f" % [windy, calm, roofed])
	# la ruota d'acqua: 4 celle d'acqua accanto = 20 pulsi
	var wheel := place("ruota_acqua", Vector2i(p.x + 5, y))
	await ticks(2)
	var rm: Machine = e.machines[wheel]
	var dry := rm.bh.produce(rm, e)
	for dy in 2:
		w.set_liq(wheel.x - 1, wheel.y + dy, 8, LiquidsData.ACQUA)
		w.set_liq(wheel.x + 2, wheel.y + dy, 8, LiquidsData.ACQUA)
	var wet := rm.bh.produce(rm, e)
	for dy in 2:
		w.set_liq(wheel.x - 1, wheel.y + dy, 0, 0)
		w.set_liq(wheel.x + 2, wheel.y + dy, 0, 0)
	var wheel_ok := dry == 0.0 and wet >= 20.0
	print("ruota d'acqua: asciutta %.1f, con quattro celle d'acqua accanto %.1f" % [dry, wet])
	# il baccello di brace: brucia solo se la rete ne ha bisogno
	var ember := place("baccello_brace", Vector2i(p.x + 10, y))
	var lamp := place("lampada_baccello", Vector2i(p.x + 13, y))
	w.chest_at(ember).add("legno", 3)
	lay_row(p.x + 10, p.x + 13, y, 2)                           # legnoferro: porta 100 (la radice solo 30)
	await ticks(4)
	var em: Machine = e.machines[ember]
	var lm: Machine = e.machines[lamp]
	var burning := em.made > 39.0 and lm.lit and w.chest_at(ember).count("legno") == 2
	lm.st["on"] = false
	lm.st["off_by_hand"] = true
	await ticks(1)
	em.st["burn"] = 0.0
	await ticks(3)
	var idle := em.made == 0.0 and w.chest_at(ember).count("legno") == 2
	print("baccello di brace: con una lampada brucia %s (%.0f pulsi), senza bisogno si ferma %s" % [burning, em.made, idle])
	# il pozzo di Linfa: sopra un lago di Linfa
	var lx := p.x + 18
	for x in range(lx - 3, lx + 5):
		for yy in range(y + 1, y + 5):
			w.set_tile(x, yy, TileDefs.AIR)
			w.set_liq(x, yy, 8, LiquidsData.LINFA)
		w.set_tile(x, y + 5, TileDefs.STONE)
	m.view.refresh_rect(Rect2i(lx - 3, y, 8, 6))
	var fits := w.station_fits("pozzo_linfa", Vector2i(lx, y - 1))
	var well := place("pozzo_linfa", Vector2i(lx, y))
	await ticks(2)
	var wm: Machine = e.machines[well]
	var well_p := wm.bh.produce(wm, e)
	print("pozzo di Linfa: si posa sopra il lago %s, dà %.1f pulsi" % [fits, well_p])
	# il cuore di cristallo: consuma un cristallo
	var heart := place("cuore_cristallo", Vector2i(p.x + 26, y))
	var lamp2 := place("lampada_baccello", Vector2i(p.x + 29, y))
	w.chest_at(heart).add("cristallo_linfa", 2)
	lay_row(p.x + 26, p.x + 29, y, 3)                           # ambra: porta 300
	await ticks(3)
	var hm: Machine = e.machines[heart]
	var heart_ok := hm.made >= 119.0 and w.chest_at(heart).count("cristallo_linfa") == 1
	print("cuore di cristallo: %.0f pulsi, cristalli rimasti %d" % [hm.made, w.chest_at(heart).count("cristallo_linfa")])
	await kit.save("234_sorgenti")
	if not (mill_ok and wheel_ok and burning and idle and fits and well_p >= 79.0 and heart_ok):
		print("ATTENZIONE: le sorgenti del mondo non danno ciò che devono")
	for o in [mill, wheel, ember, lamp, well, heart, lamp2]:
		if w.chests.has(o):
			w.chests.erase(o)
		unplace(o)
	for x in range(lx - 3, lx + 5):
		for yy in range(y + 1, y + 5):
			w.set_liq(x, yy, 0, 0)
