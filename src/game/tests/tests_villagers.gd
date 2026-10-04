class_name TestsVillagers
extends RefCounted
## Prove della voce 36: i Lumini cadono dalle creature; senza Focolare e letto non arriva nessuno, con un Focolare e un
## letto arriva la Viandante, con un secondo letto e l'Alambicco l'Erborista; il commercio (comprare, vendere,
## prezzi); gli abitanti si salvano con il mondo; foto 64_abitanti e 65_commercio.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _place(item: String, at: Vector2i) -> bool:
	m.character.bisaccia.add(item, 1)
	m.snap_to(at + Vector2i(1, 0))
	kit.hold(item)
	return m.actions.build.place_station(at, item)


func run() -> void:
	var v: Villagers = m.villagers
	var b: Bisaccia = m.character.bisaccia
	kit.make_room()
	# i Lumini delle creature
	var l0 := 0
	for d in m.drops._items:
		if d["id"] == "lumino":
			l0 += int(d["n"])
	var cr: Creature = m.fauna.add("scarabeo_ardesia", m.player.position + Vector2(30, -10))
	m.fauna.kill(cr)
	await kit.frames(2)
	var l1 := 0
	for d in m.drops._items:
		if d["id"] == "lumino":
			l1 += int(d["n"])
	print("Lumini da uno scarabeo: +%d; valore di una spada d'ambra %d, di un lingotto d'ambra %d, di una torcia %d" % [
		l1 - l0, ValueData.value("spada_ambra"), ValueData.value("lingotto_ambra"), ValueData.value("torcia")])
	var none := v.check()
	var spot := kit.flat_spot(world.spawn + Vector2i(-110, 0), 4)
	if spot.x < 0:
		print("ATTENZIONE: nessun terreno per gli abitanti")
		return
	kit.flatten(spot, 14)
	var f_ok := _place("focolare", spot)
	var l_ok := _place("letto_foglie", spot + Vector2i(6, 0))
	var first := v.check()
	var ok2 := _place("letto_foglie", spot + Vector2i(-6, 0))
	var second := v.check()
	if not "alambicco" in world.stations.values():
		_place("alambicco", spot + Vector2i(10, 0))
	var third := v.check()
	print("abitanti: senza Focolare «%s»; Focolare %s, letto %s → «%s»; secondo letto %s → «%s»; con l'Alambicco → «%s»" % [
		none, "sì" if f_ok else "NO", "sì" if l_ok else "NO", first, "sì" if ok2 else "NO", second, third])
	print("abitanti salvati nel mondo: %s" % [m.world_meta.get("abitanti", {}).keys()])
	m.snap_to(spot + Vector2i(2, 0))
	await kit.seconds(2.5)
	await kit.save("64_abitanti")
	# il commercio con la Viandante
	var tp: TradePanel = v.panel
	b.add("lumino", 500)
	var npc: Npc = null
	for n in v.list:
		if n.id == "viandante":
			npc = n
	if npc == null:
		print("ATTENZIONE: la Viandante non c'è")
		return
	m.player.position = npc.position + Vector2(20, 0)
	var opened := v.open_trade(npc)
	await kit.frames(3)
	var before := b.count("lumino")
	var bought := tp.buy(0)
	var after_buy := b.count("lumino")
	b.add("scaglia_ardesia", 20)
	var slot := -1
	for i in b.slots.size():
		if b.id_at(i) == "scaglia_ardesia":
			slot = i
	tp._sell_slot(slot)
	print("commercio: aperto %s; comprate 10 torce %s per %d Lumini; vendute 20 scaglie d'ardesia per %d Lumini" % [
		"sì" if opened else "NO", "sì" if bought else "NO", before - after_buy, b.count("lumino") - after_buy])
	await kit.seconds(1.0)
	await kit.save("65_commercio")
	m.hud.panel.toggle()
	await kit.frames(2)
	await services()


## Voce 353: i servizi degli abitanti, pagati in Lumini. Ognuno fa il suo lavoro e paga solo se va; il limite del giorno
## ferma; il pannello del commercio li mostra (foto 353_servizi).
func services() -> void:
	var b: Bisaccia = m.character.bisaccia
	var st0: Dictionary = m.character.stats.duplicate(true)
	var meta0: Variant = m.world_meta.get("servizi", {}).duplicate(true)
	var lum0 := b.count("lumino")
	b.add("lumino", 5000)
	var res := {}
	# la qualità: un attrezzo grezzo in mano diventa buono
	kit.hold("spada_radicite")
	var si: int = m.hud.sel
	b.slots[si]["dati"] = {"q": 0}
	var l0 := b.count("lumino")
	var msg: String = m.services.use("rifinitura")
	res["rifinitura"] = Gear.quality(b.slots[si]) == 1 and b.count("lumino") < l0
	# un Seme su ordinazione dalla Fiala in mano
	var gene := ""
	for g in GenesData.GENES:
		if not GenesData.GENES[g].has("only") and String(GenesData.GENES[g]["cat"]) != "superficie":
			gene = String(g)
			break
	var vial := GenesData.vial_of(gene)
	kit.hold(vial)
	var seeds0 := _seeds_with(gene)
	msg = m.services.use("seme_ordine")
	res["seme_ordine"] = _seeds_with(gene) == seeds0 + 1
	# la lettura del Seme ordinato (in mano)
	for i in b.slots.size():
		if (b.data_at(i) as Dictionary).has("geni") and gene in Genome.genes(b.data_at(i)):
			if i >= Bisaccia.HOTBAR:
				var tmp: Dictionary = b.slots[0]
				b.slots[0] = b.slots[i]
				b.slots[i] = tmp
				i = 0
			m.hud.sel = i
			break
	msg = m.services.use("lettura_seme")
	res["lettura_seme"] = msg.begins_with("Il Seme dice")
	# un effetto a tempo, e il limite del giorno (la tisana: tre al giorno)
	for k in 3:
		m.services.use("tisana")
	res["tisana"] = m.boons.active.has("rigoglio") and m.services.blocked("tisana").contains("domani")
	l0 = b.count("lumino")
	msg = m.services.use("tisana")
	res["limite"] = b.count("lumino") == l0
	# ciò che non si può fare non si paga: la tempra senza niente in mano
	m.hud.sel = 0
	var keep: Dictionary = b.slots[0].duplicate(true)
	b.slots[0] = {}
	l0 = b.count("lumino")
	msg = m.services.use("tempra_mano")
	res["non_paga"] = b.count("lumino") == l0 and msg != ""
	b.slots[0] = keep
	# la pesca, la mappa, la musica
	m.services.use("segreto_stagno")
	res["pesca"] = m.fishing.luck_now("canna_radice") >= 0.6
	m.services.use("mappa_mondo")
	m.services.use("serata_musica")
	res["musica"] = m.boons.active.has("sazio")
	# il pannello
	var tp: TradePanel = m.villagers.panel
	tp.m = m
	tp.open("forgiatore")
	await kit.frames(4)
	var shown := tp._svc_frame.visible and tp._svc_box.get_child_count() >= 4
	await kit.save("353_servizi")
	tp.close()
	m.hud.panel.toggle()
	await kit.frames(2)
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	m.fishing.service_until = 0.0
	m.boons.active.clear()                        # (gli effetti dei servizi non devono restare alle prove dopo)
	if b.count("lumino") > lum0:
		b.remove("lumino", b.count("lumino") - lum0)
	m.character.stats.clear()
	m.character.stats.merge(st0)
	m.world_meta["servizi"] = meta0
	var missing := []
	for id in ServicesData.SERVICES:
		var npc := String(ServicesData.SERVICES[id]["npc"])
		if not NpcData.NPCS.has(npc) or not m.services.has_method("_" + String(ServicesData.SERVICES[id]["kind"])):
			missing.append(id)
	var ok: bool = res.values().all(func(x: bool) -> bool: return x) and shown and missing.is_empty()
	print("servizi: %s; pannello %s; righe senza abitante o funzione %s" % [str(res), shown, str(missing)])
	if not ok:
		print("ATTENZIONE: i servizi degli abitanti non vanno come dovrebbero")


func _seeds_with(gene: String) -> int:
	var n := 0
	for bag in m.character.bisaccia.all_bags():
		for sl in bag.slots:
			if not sl.is_empty() and (sl.get("dati", {}) as Dictionary).has("geni") and gene in Genome.genes(sl["dati"]):
				n += 1
	return n

