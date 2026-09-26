class_name TestsStorage
extends RefCounted
## Prove delle casse (26 set 2026): la creazione prende gli ingredienti da una cassa vicina (e non da una con «usa per
## creare» spento), Deposita tutto / simili, Rifornisci, Riordina, «Nelle casse vicine» con il tipo di una cassa, il
## nome scritto sopra la cassa; foto 99_casse con la cassa aperta.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func run() -> void:
	var spot := kit.flat_spot(world.spawn + Vector2i(-40, 0), 6)
	if spot.x < 0:
		print("ATTENZIONE: nessun posto per le prove delle casse")
		return
	kit.flatten(spot, 14)
	m.snap_to(spot)
	await kit.frames(3)
	var st: Storage = m.storage
	var b := kit.bisaccia()
	kit.make_room()
	# due casse accanto al Germogliato
	var o1 := spot + Vector2i(-4, 0)
	var o2 := spot + Vector2i(3, 0)
	for o in [o1, o2]:
		world.stations[o] = "cesta"
		m.view.add_station(o)
	var c1 := world.chest_at(o1)
	var c2 := world.chest_at(o2)
	# una ricetta a mano con un solo ingrediente
	var rec := {}
	for r in RecipesData.all():
		if String(r["station"]) == "" and (r["in"] as Dictionary).size() == 1 and not Bisaccia.is_gear(String(r["out"])):
			rec = r
			break
	var ing := String((rec["in"] as Dictionary).keys()[0])
	var need := int(rec["in"][ing])
	b.remove(ing, b.count(ing))
	c1.add(ing, need * 3)
	await kit.seconds(0.6)
	var in_pool := c1 in Crafting.pool
	var out0 := b.count(String(rec["out"]))
	var total0 := Crafting.have(b, ing)            # nel giro lungo altre casse vicine possono averne: si conta il totale
	var made := Crafting.craft(rec, b)
	var left := c1.count(ing)
	var used := total0 - Crafting.have(b, ing)
	print("creare dalle casse: %s (%d %s nella cassa, 0 nella Bisaccia): fabbricato %s (usati %d), nella cassa ne restano %d, %s nella Bisaccia %d → %d" % [
		"la cassa vicina è tra gli ingredienti" if in_pool else "la cassa NON è tra gli ingredienti", need * 3,
		ItemsData.get_item(ing)["name"], "sì" if made else "NO", used, c1.count(ing), ItemsData.get_item(String(rec["out"]))["name"],
		out0, b.count(String(rec["out"]))])
	# spente tutte le casse vicine (nel giro lungo ce ne sono altre delle prove di prima): la ricetta non si fa più
	var was := {}
	for o in st.chests_near(StorageData.CRAFT_REACH):
		was[o] = st.settings(o)["creare"]
		st.set_setting(o, "creare", false)
	await kit.seconds(0.6)
	var off := not Crafting.can_craft(rec, b)
	print("con «usa per creare» spento: la ricetta %s" % ("non si può fare" if off else "SI PUÒ ANCORA FARE"))
	for o in was:
		st.set_setting(o, "creare", was[o])
	# i pulsanti
	# nelle caselle grandi: i pulsanti non toccano la barra rapida
	_put(b, "legno", 30)
	_put(b, "minerale_radicite", 12)
	_put(b, "gelatina", 5)
	c2.add("gelatina", 1)
	var sim: int = st.deposit_similar(c2)
	var gel_left := b.count("gelatina")
	st.set_setting(o1, "tipo", "minerali")
	c1.remove(ing, c1.count(ing))
	c2.add("legno", 1)
	var qs: Dictionary = st.quick_stack()
	print("pulsanti: Deposita simili ha messo %d gelatine (nella Bisaccia ne restano %d); Nelle casse vicine %s: minerale nella cassa dei minerali %d, legno nella cassa che ne aveva %d" % [
		sim, gel_left, qs, c1.count("minerale_radicite"), c2.count("legno")])
	kit.hold("torcia")
	var t_slot := kit.slot_of("torcia")
	b.slots[t_slot]["n"] = 3
	c2.add("torcia", 50)
	st.restock(c2)
	print("Rifornisci: torce in mano 3 → %d (nella cassa %d)" % [b.count_at(t_slot), c2.count("torcia")])
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		b.slots[i] = {"id": "humus", "n": 5} if i % 3 == 0 else {}
	b.changed.emit()
	var dep: int = st.deposit_all(c2)
	c2.sort_bag(0)
	print("Deposita tutto: %d oggetti; Riordina: prima casella della cassa %s" % [dep, c2.id_at(0)])
	# il nome sopra la cassa, e la cassa aperta
	st.set_setting(o2, "nome", "Dispensa")
	m.interact.touch(o2)
	m.boons.add("bagliore", 5.0)
	await kit.seconds(0.8)
	await kit.save("99_casse")
	m.interact.chest_panel.close()
	if m.hud.panel.visible:
		m.hud.panel.toggle()
	var labelled := false
	for n in m.fx.get_children():
		if n is Label and (n as Label).text == "Dispensa":
			labelled = true
	print("nome sopra la cassa: %s; impostazioni salvate nel mondo: %s" % ["sì" if labelled else "NO", m.world_meta["casse"]])
	if not in_pool or not made or used != need or left > need * 3 - 1 or not off or c1.count("minerale_radicite") < 12 or not labelled \
			or b.count_at(t_slot) <= 3 or dep <= 0:
		print("ATTENZIONE: le casse non funzionano come dovrebbero")
	for o in [o1, o2]:
		world.stations.erase(o)
		world.chests.erase(o)
		m.view.remove_station(o)
	(m.world_meta["casse"] as Dictionary).clear()
	kit.make_room()


func _put(b: Bisaccia, id: String, n: int) -> void:
	for i in range(Bisaccia.HOTBAR, b.slots.size()):
		if b.slots[i].is_empty():
			b.slots[i] = {"id": id, "n": n}
			b.changed.emit()
			return
