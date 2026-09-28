class_name TestsKeepers
extends RefCounted
## Prove della voce 27: una tana per Custode nel suo strato, il Custode si schiude avvicinandosi al bozzolo, sconfitto
## lascia il bozzolo vuoto e il suo bottino, si richiama all'Altare dei Seminatori (solo se già sconfitto); foto
## 51_custode (la Madre dei grumi nella sua tana) e 52_tessitrice.

const S := 16

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


func _count(id: String) -> int:
	var n := 0
	for d in m.drops._items:
		if String(d["id"]) == id:
			n += int(d["n"])
	return n


func run() -> void:
	var ks: Keepers = m.keepers
	var line := "tane dei Custodi:"
	for o in ks.dens:
		line += " %s nello strato %d (profondità %d) ·" % [ks.dens[o], StrataData.at(world, o.x, o.y), world.depth(o.x, o.y)]
	print(line)
	if ks.dens.size() < KeepersData.KEEPERS.size():
		print("ATTENZIONE: %d tane su %d" % [ks.dens.size(), KeepersData.KEEPERS.size()])
	var madre := Vector2i(-1, -1)
	var tess := Vector2i(-1, -1)
	for o in ks.dens:
		if ks.dens[o] == "madre_grumi":
			madre = o
		elif ks.dens[o] == "tessitrice":
			tess = o
	if madre.x < 0:
		print("ATTENZIONE: nessuna tana della Madre dei grumi")
		return
	m.combat.god = true
	m.boons.add("bagliore", 60.0)
	# avvicinandosi al bozzolo il Custode si schiude
	m.snap_to(madre + Vector2i(-7, 2))
	await kit.frames(6)
	var hatched := ks.active != null
	print("Madre dei grumi: si schiude avvicinandosi %s (Vita %d), barra in alto %s" % ["sì" if hatched else "NO",
		ks.active.hp_max if hatched else 0, "sì" if ks.bar.visible else "NO"])
	await kit.seconds(2.0)
	await kit.save("51_custode")
	# la barra del boss sta sotto il filo, non sopra le sue scritte
	var fl: Control = m.filo._label
	if ks.bar.visible and fl.visible and fl.text.strip_edges() != "":
		var below := ks.bar.position.y - 26.0 >= fl.position.y + fl.size.y
		print("barra del Custode sotto il filo: %s (barra %d, filo fino a %d)" % ["sì" if below else "NO",
			int(ks.bar.position.y), int(fl.position.y + fl.size.y)])
		if not below:
			print("ATTENZIONE: la barra del boss copre il filo")
	if hatched:
		var g0 := _count("gelatina_regale")
		m.fauna.kill(ks.active)
		await kit.frames(3)
		print("sconfitta: gelatina regale +%d, bozzolo %s, custodi nel mondo %s" % [_count("gelatina_regale") - g0,
			world.stations.get(madre, "?"), m.world_meta.get("custodi", {})])
		m.guardian.lore.visible = false
	# richiamo all'Altare: la Tessitrice non si richiama (mai sconfitta), la Madre sì
	var spot := kit.flat_spot(world.spawn, 5)
	m.snap_to(spot)
	await kit.frames(2)
	var b: Bisaccia = m.character.bisaccia
	b.add("altare", 1)
	var placed := kit.place_station_near("altare", m.player_cell())
	b.add("richiamo_tessitrice", 1)
	kit.hold("richiamo_tessitrice")
	var no: bool = m.interact._use("richiamo", "richiamo_tessitrice", m.player_cell())
	b.add("richiamo_madre", 1)
	kit.hold("richiamo_madre")
	var yes: bool = m.interact._use("richiamo", "richiamo_madre", m.player_cell())
	print("Altare piazzato %s: richiamo della Tessitrice mai sconfitta %s, della Madre %s" % ["sì" if placed else "NO",
		"rifiutato" if not no else "ACCETTATO (errore)", "sì" if yes and ks.active != null else "NO"])
	if ks.active != null:
		m.fauna.kill_quietly(ks.active)
		ks.active = null
		ks.bar.follow(null)
	m.guardian.lore.visible = false
	# la Tessitrice nella sua tana
	if tess.x >= 0:
		m.snap_to(tess + Vector2i(-7, 2))
		await kit.frames(6)
		await kit.seconds(2.0)
		await kit.save("52_tessitrice")
		if ks.active != null:
			m.fauna.kill_quietly(ks.active)
			ks.active = null
			ks.bar.follow(null)
	m.combat.god = false
	m.snap_to(world.spawn)
	await kit.frames(3)
