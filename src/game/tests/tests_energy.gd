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
