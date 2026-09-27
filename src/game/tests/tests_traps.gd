class_name TestsTraps
extends RefCounted
## Prove delle trappole (voce 88): gli spuntoni feriscono chi ci passa sopra (anche il Germogliato), la runa di brace
## brucia, la rete rallenta, il getto d'acqua spinge via, una trappola disarmata non colpisce, la lama abbatte e il
## bottino cade, il grado più alto fa più danno. Foto 155_trappole.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func _put(id: String, o: Vector2i) -> void:
	m.world.stations[o] = id
	m.view.add_station(o)


func _dummy(o: Vector2i, hp := 900) -> Creature:
	var c: Creature = m.fauna.add("grumo_muschio", (Vector2(o) + Vector2(0.5, 0.5)) * 16.0)
	c.hp_max = hp
	c.hp = hp
	c.calm = true
	c.speed = 0.0
	return c


func run() -> void:
	var w: World = m.world
	var tr: Traps = m.traps
	var res := {}
	var spot := kit.flat_spot(w.spawn + Vector2i(40, 0), 16)
	if spot.x < 0:
		print("ATTENZIONE: trappole, nessun posto piano: provo alla partenza")
		spot = w.spawn
	kit.flatten(spot, 16)
	m.fauna.clear()
	m.snap_to(spot + Vector2i(-12, 0))
	await kit.frames(3)
	var placed: Array[Vector2i] = []
	var at := func(dx: int) -> Vector2i: return Vector2i(spot.x + dx, spot.y)
	var o_sp: Vector2i = at.call(-4)
	var o_br: Vector2i = at.call(0)
	var o_re: Vector2i = at.call(4)
	var o_ac: Vector2i = at.call(9)
	var o_la: Vector2i = at.call(14)
	for pair in [["trappola_spuntoni_1", o_sp], ["trappola_runa_brace_1", o_br], ["trappola_rete_1", o_re],
			["trappola_getto_acqua_1", o_ac], ["trappola_lama_2", o_la]]:
		_put(pair[0], pair[1])
		placed.append(pair[1])
	tr.rebuild()
	var c_sp := _dummy(o_sp)
	var c_br := _dummy(o_br)
	var c_re := _dummy(o_re)
	var c_ac := _dummy(o_ac + Vector2i(3, 0))
	var ac_x0 := c_ac.position.x
	var c_la := _dummy(o_la, 5)
	var kills0 := tr.kills
	await kit.seconds(0.6)
	res["spuntoni"] = is_instance_valid(c_sp) and c_sp.hp < 900
	res["brace"] = is_instance_valid(c_br) and c_br.hp < 900 and (c_br.burn_t > 0.0 or c_br.elem == "brace")
	res["rete"] = is_instance_valid(c_re) and c_re.chill_t > 0.0
	res["getto"] = is_instance_valid(c_ac) and c_ac.position.x - ac_x0 > 12.0
	res["abbatte"] = tr.kills > kills0
	await kit.save("155_trappole")
	# disarmata non colpisce
	tr.toggle(o_sp)
	m.fauna.clear()
	var c_off := _dummy(o_sp)
	await kit.seconds(0.5)
	res["disarmata"] = not tr.armed(o_sp) and is_instance_valid(c_off) and c_off.hp == 900
	tr.toggle(o_sp)
	m.fauna.clear()
	# la leva ferma e riarma tutte quelle vicine
	var o_lv: Vector2i = at.call(2)
	_put("leva_trappole_su", o_lv)
	placed.append(o_lv)
	tr.lever(o_lv)
	var all_off := not tr.armed(o_sp) and not tr.armed(o_br) and not tr.armed(o_ac)
	tr.lever(o_lv)
	res["leva"] = all_off and tr.armed(o_sp) and tr.armed(o_ac) and tr.armed(o_la) and String(w.stations[o_lv]) == "leva_trappole_su"
	# al soffitto e a parete
	var hang := Vector2i(o_sp.x, o_sp.y - 4)
	w.set_tile(hang.x, hang.y - 1, TileDefs.STONE)
	res["soffitto"] = w.station_fits("trappola_spuntoni_1", hang) and not w.station_fits("forziere_ambra", hang)
	w.set_tile(hang.x, hang.y - 1, TileDefs.AIR)
	# ferisce anche il Germogliato
	var god: bool = m.combat.god
	m.combat.god = false
	m.combat.invuln = 0.0
	m.vitals.refill()
	var hp0: int = m.vitals.hp
	m.snap_to(o_sp)
	await kit.seconds(0.4)
	res["ferisce_te"] = m.vitals.hp < hp0
	m.combat.god = god
	m.vitals.refill()
	m.snap_to(spot + Vector2i(-12, 0))
	# il grado conta
	res["gradi"] = roundi(float(TrapsData.TYPES["spuntoni"]["dmg"]) * float(TrapsData.info("trappola_spuntoni_3")["k"])) \
		> int(TrapsData.TYPES["spuntoni"]["dmg"])
	for o in placed:
		w.stations.erase(o)
		m.view.remove_station(o)
	tr.rebuild()
	m.fauna.clear()
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("trappole: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: le trappole non funzionano come dovrebbero")
