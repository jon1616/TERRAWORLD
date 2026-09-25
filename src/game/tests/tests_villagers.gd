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
