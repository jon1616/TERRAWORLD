class_name Villagers
extends Node
## Gli abitanti (voce 36, dati in `NpcData`): ogni pochi secondi si guarda se un abitante può arrivare (un Focolare
## piazzato, un Letto di foglie libero entro `HOME_RANGE` tessere, la sua condizione rispettata); arrivato vive attorno
## al Focolare. Clic destro su di lui: il pannello del commercio (`TradePanel`). Salvati in `world_meta["abitanti"]`
## (dove abita ognuno); si rimettono al caricamento.

const S := 16
const CHECK := 5.0

var m: Node2D
var list: Array[Npc] = []
var panel: TradePanel
var paused := false                    # le prove li fanno arrivare a comando (`check`)
var _t := CHECK
var _day_t := 0.0                      # voce 486: ogni secondo si guarda se è ora di stare in casa


func setup(main: Node2D) -> void:
	m = main
	panel = TradePanel.new()
	m.hud.add_child(panel)
	panel.setup(m.hud.panel)
	panel.m = m                               # voce 65: affetto, richieste e consigli (vedi `NpcBonds`)
	var saved: Dictionary = m.world_meta.get("abitanti", {})
	for nid in saved:
		if NpcData.NPCS.has(nid):
			var h: Array = saved[nid]
			_spawn(String(nid), Vector2i(int(h[0]), int(h[1])))


func _process(dt: float) -> void:
	if not m.built:
		return
	_day_t -= dt
	if _day_t <= 0.0:
		_day_t = 1.0
		var why := indoor_reason()
		for n in list:
			n.indoors = why
	if paused:
		return
	_t -= dt
	if _t <= 0.0:
		_t = CHECK
		check()


## Voce 486: perché adesso gli abitanti stanno in casa ("" = escono). L'assedio prima di tutto, poi il tempo che ferisce o
## bagna, poi la notte.
func indoor_reason() -> String:
	if m.get("tides") != null and String(m.tides.active) == "assedio":
		return "assedio"
	if m.get("weather") != null and not m.weather.roofed:
		var st: Dictionary = m.weather.state()
		if st.has("rain") or st.has("snow") or st.has("ash"):
			return "pioggia"
	if m.get("day") != null and m.day.is_night():
		return "notte"
	return ""


## Chi c'è già (per id).
func present() -> Array:
	return list.map(func(n: Npc) -> String: return n.id)


## Fa arrivare il primo abitante che può: restituisce il suo id o "".
func check() -> String:
	# voce 65: chi vive accanto all'Albero-Madre ("free") non vuole Focolare né letto
	if m.giardino.active and m.giardino.tree_o.x >= 0:
		for nid in NpcData.NPCS:
			if NpcData.NPCS[nid].get("free", false) and not nid in present() and _ready_for(String(nid)):
				var at: Vector2i = m.giardino.tree_o + Vector2i(-3, int(StationsData.STATIONS["albero_madre_0"]["size"][1]) - 1)
				_spawn(String(nid), at)
				var sv: Dictionary = m.world_meta.get("abitanti", {})
				sv[nid] = [at.x, at.y]
				m.world_meta["abitanti"] = sv
				m.hud.toast("%s è arrivata accanto all'Albero-Madre" % NpcData.NPCS[nid]["name"])
				m.sfx.play("dono")
				m.objectives.bump("abitanti")
				return String(nid)
	var hearth := _hearth()
	if hearth.x < 0:
		return ""
	var beds := 0
	for o in m.world.stations:
		if StationsData.role(String(m.world.stations[o])) == "letto" and Vector2(o - hearth).length() <= NpcData.HOME_RANGE:
			beds += 1
	# voce 143: una casa bella con un letto libero attira abitanti anche lontano dal Focolare
	if beds <= list.size() and m.homes and m.homes.nice_house():
		beds = list.size() + 1
	if beds <= list.size():
		return ""
	for nid in NpcData.NPCS:
		if nid in present() or not _ready_for(String(nid)) or NpcData.NPCS[nid].get("free", false) \
				or NpcData.NPCS[nid].get("visitor", false):
			continue                                 # voce 229: i visitatori li porta `Visitors`
		_spawn(String(nid), hearth)
		var saved: Dictionary = m.world_meta.get("abitanti", {})
		saved[nid] = [hearth.x, hearth.y]
		m.world_meta["abitanti"] = saved
		m.hud.toast("%s si è fermata al tuo Focolare" % NpcData.NPCS[nid]["name"] if String(NpcData.NPCS[nid]["name"]).begins_with("La") \
			else "%s si è fermato al tuo Focolare" % NpcData.NPCS[nid]["name"])
		m.sfx.play("dono")
		m.objectives.bump("abitanti")
		return String(nid)
	return ""


func _hearth() -> Vector2i:
	for o in m.world.stations:
		if m.world.stations[o] == "focolare":
			return o
	return Vector2i(-1, -1)


func _ready_for(nid: String) -> bool:
	var req: Dictionary = NpcData.NPCS[nid]["requires"]
	if req.has("station") and not String(req["station"]) in m.world.stations.values():
		return false
	if req.has("custodi") and (m.world_meta.get("custodi", {}) as Dictionary).size() < int(req["custodi"]):
		return false
	if req.has("albero") and m.albero.stage() < int(req["albero"]):
		return false
	if req.get("giardino", false) and not m.giardino.active:
		return false
	if req.has("bellezza") and int(m.character.stats.get("bellezza_max", 0)) < int(req["bellezza"]):
		return false                          # voce 229: la bellezza del Giardino
	if req.has("stat") and int(m.character.stats.get(String(req["stat"]), 0)) < int(req["n"]):
		return false                          # voce 124: il Pescatore, dopo i primi pesci
	return true


func _spawn(nid: String, at: Vector2i) -> Npc:
	var n := Npc.new()
	n.setup(nid, m.world, at, m.player)
	# ognuno un po' più in là del Focolare, così non stanno uno sopra l'altro (né dentro il fuoco)
	var side := 1 if list.size() % 2 == 0 else -1
	n.position = Vector2(at.x * S + 16 + side * (3 + list.size()) * S, at.y * S - 8)
	n.z_index = 3
	m.add_child(n)
	list.append(n)
	return n


## L'abitante sotto un punto del mondo (per il clic destro), o null.
func npc_at(p: Vector2) -> Npc:
	for n in list:
		if n.rect().grow(4.0).has_point(p):
			return n
	return null


func open_trade(n: Npc) -> bool:
	if n.position.distance_to(m.player.position) > 6.0 * S:
		return false
	panel.open(n.id)
	m.sfx.play("apri", n.position)
	return true
