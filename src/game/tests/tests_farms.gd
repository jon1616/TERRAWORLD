class_name TestsFarms
extends RefCounted
## Prove delle farm (voce 89): l'esca con la gelatina chiama i grumi (lontano da te, con il segno "farm"), con un
## oggetto che nessuno lascia dice perché no; la tramoggia aspira il bottino nella sua cassa; il nastro spinge gli
## oggetti; la Radice-ancora tiene in vita le creature lontane; il tetto di rendita toglie il bottino oltre il limite.
## Foto 156_farm.

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
	var fa: Farms = m.farms
	var res := {}
	var spot := kit.flat_spot(w.spawn + Vector2i(-70, 0), 16)
	if spot.x < 0:
		print("farm: nessun posto piano, spiano vicino alla partenza")
		spot = w.spawn
	kit.flatten(spot, 16)
	m.fauna.clear()
	var placed: Array[Vector2i] = []
	var o_es := spot
	var o_tr := spot + Vector2i(-6, 0)
	var o_na := spot + Vector2i(-16, 0)
	var o_an := spot + Vector2i(6, -1)
	_put("esca", o_es)
	_put("tramoggia", o_tr)
	_put("nastro_dx", o_na)
	_put("radice_ancora", o_an)
	placed.append_array([o_es, o_tr, o_na, o_an])
	fa.rebuild()
	# un oggetto che nessuno lascia: l'esca dice perché
	w.chest_at(o_es).add("ceppo", 1)
	var why := String(fa.callable_at(o_es)["why"])
	res["perche_no"] = why != "" and (fa.callable_at(o_es)["ok"] as Array).is_empty()
	w.chest_at(o_es).remove("ceppo", 1)
	# la gelatina chiama i grumi, lontano da te
	var c0 := fa.called
	w.chest_at(o_es).add("gelatina", 10)
	res["chi"] = "grumo_muschio" in (fa.callable_at(o_es)["ok"] as Array)
	m.snap_to(Vector2i(spot.x + 22, w.surface[spot.x + 22] - 1))
	await kit.frames(3)
	var t := 0.0
	while fa.called == c0 and t < 4.0:
		await kit.seconds(0.25)
		t += 0.25
	var farmed: Array = m.fauna.list.filter(func(c: Creature) -> bool: return c.has_meta("farm"))
	res["chiama"] = fa.called > c0 and not farmed.is_empty() \
		and (farmed[0] as Creature).position.distance_to(m.player.position) >= (FarmData.AWAY - 1) * 16.0
	if not res["chiama"]:
		print("farm, chiamata: %d → %d, con il segno %d, distanza %s" % [c0, fa.called, farmed.size(),
			str((farmed[0] as Creature).position.distance_to(m.player.position) / 16.0) if not farmed.is_empty() else "-"])
	await kit.save("156_farm")
	# la tramoggia aspira
	m.drops.spawn("gelatina", 4, (Vector2(o_tr) + Vector2(2.5, 0.0)) * 16.0)
	await kit.seconds(0.8)
	res["tramoggia"] = w.chest_at(o_tr).count("gelatina") >= 4
	# il nastro spinge (lontano dalla tramoggia: lo si sposta di là)
	var probe := (Vector2(o_na) + Vector2(0.5, 0.2)) * 16.0
	m.drops.spawn("ardesia", 1, probe)
	await kit.seconds(0.6)
	var moved: Dictionary = m.drops.at(probe + Vector2(24, 0), 40.0)
	res["nastro"] = not moved.is_empty() and (moved["key"] as Node2D).position.x > probe.x + 8.0
	fa.flip_belt(o_na)
	res["verso"] = String(w.stations[o_na]) == "nastro_sx"
	# la Radice-ancora tiene in vita le creature lontane
	var anc: Creature = m.fauna.add("grumo_muschio", (Vector2(o_an) + Vector2(0.5, 0.0)) * 16.0)
	anc.calm = true
	var far_x := clampi(spot.x + CreaturesData.DESPAWN + 20, 10, w.w - 10)
	m.snap_to(Vector2i(far_x, w.surface[far_x] - 1))
	await kit.frames(4)
	res["ancora"] = is_instance_valid(anc) and m.fauna.list.has(anc)
	# il tetto di rendita
	var probe_c: Creature = m.fauna.add("grumo_muschio", Vector2(far_x * 16, 0))
	probe_c.set_meta("farm", "prova")
	var gates := 0
	for k in FarmData.ZONE_CAP + 1:
		gates += fa._gate(probe_c)
	res["tetto"] = gates == FarmData.ZONE_CAP and fa._gate(probe_c) == 0
	m.world_meta.erase("farm_rese")
	# si rimette tutto com'era
	m.snap_to(spot)
	m.fauna.clear()
	for o in placed:
		w.chests.erase(o)
		w.stations.erase(o)
		m.view.remove_station(o)
	fa.rebuild()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("farm: chiamate %d, aspirati %d; %s; non vanno: %s" % [fa.called, fa.pulled, res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: le farm non funzionano come dovrebbero")
