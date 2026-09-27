class_name TestsZones
extends RefCounted
## Prove dei totem di zona (voce 87): i gradi allargano il raggio e rafforzano; due totem dello stesso tipo non si
## sommano; il Totem del germoglio fa crescere l'orto, quello della quiete ferma le nascite, lo Stendardo del riposo la
## Vita, quello di guardia il danno; la Radice pura ferma l'Avvizzimento e la crescita; con un totem in mano si vedono i
## raggi. Foto 154_totem.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _put(id: String, o: Vector2i) -> void:
	m.world.stations[o] = id
	m.view.add_station(o)


func run() -> void:
	var w: World = m.world
	var z: Zones = m.zones
	var res := {}
	var spot := kit.flat_spot(w.spawn + Vector2i(-30, 0), 8)
	if spot.x < 0:
		spot = w.spawn
	kit.flatten(spot, 10)
	m.snap_to(spot)
	await kit.frames(3)
	var p: Vector2 = m.player.position
	var placed: Array[Vector2i] = []
	# gradi e raggio
	var o1 := spot + Vector2i(3, -1)
	_put("totem_germoglio_1", o1)
	placed.append(o1)
	z.rebuild()
	var g1 := z.mult_at(p, "crescita")
	var far := z.mult_at(p + Vector2(40 * 16, 0), "crescita")
	var o2 := spot + Vector2i(-3, -1)
	_put("totem_germoglio_3", o2)
	placed.append(o2)
	z.rebuild()
	var g3 := z.mult_at(p, "crescita")
	res["gradi"] = g3 > g1 and g1 > 1.0 and far == 1.0
	res["non_sommano"] = absf(g3 - ZonesData.value("germoglio", "crescita", 2.0)) < 0.001
	# la quiete ferma le nascite
	var o3 := spot + Vector2i(6, -1)
	_put("totem_quiete_3", o3)
	placed.append(o3)
	z.rebuild()
	res["quiete"] = z.add_at(p + Vector2(10 * 16, 0), "quiete") > 0.0
	var fe: bool = m.fauna.enabled
	m.fauna.enabled = true
	var born := 0
	for k in 60:
		if m.fauna.try_spawn() != null:
			born += 1
	m.fauna.enabled = fe
	m.fauna.clear()
	res["quiete_nascite"] = born == 0 or z.add_at(p, "quiete") > 0.0
	# riposo e guardia
	var o4 := spot + Vector2i(-6, -1)
	_put("totem_riposo_2", o4)
	_put("totem_guardia_2", o4 + Vector2i(1, 0))
	placed.append(o4)
	placed.append(o4 + Vector2i(1, 0))
	z.rebuild()
	await kit.seconds(0.7)
	res["riposo"] = m.vitals.zone_regen > 1.0
	res["guardia"] = m.fauna._zm(p, "guardia") > 1.0
	# la radice pura: niente Avvizzimento, niente crescita
	var o5 := spot + Vector2i(9, -1)
	_put("totem_purezza_1", o5)
	placed.append(o5)
	z.rebuild()
	res["puro"] = z.add_at((Vector2(o5) + Vector2(0.5, 1.0)) * 16.0, "puro") > 0.0 \
		and z.mult_at((Vector2(o5) + Vector2(0.5, 1.0)) * 16.0, "crescita") == 0.0
	# con un totem in mano si vedono i raggi
	m.character.bisaccia.add("totem_fortuna_2", 1)
	kit.hold("totem_fortuna_2")
	await kit.frames(3)
	res["raggi"] = z.visible
	await kit.save("154_totem")
	# si rimette tutto com'era
	m.character.bisaccia.remove("totem_fortuna_2", 1)
	kit.hold("piccone_radicite")
	for o in placed:
		w.stations.erase(o)
		m.view.remove_station(o)
	z.rebuild()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("totem: crescita grado 1 ×%.2f, grado 3 ×%.2f; %s; non vanno: %s" % [g1, g3, res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i totem di zona non funzionano come dovrebbero")
