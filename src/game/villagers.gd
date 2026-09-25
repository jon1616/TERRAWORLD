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


func setup(main: Node2D) -> void:
	m = main
	panel = TradePanel.new()
	m.hud.add_child(panel)
	panel.setup(m.hud.panel)
	var saved: Dictionary = m.world_meta.get("abitanti", {})
	for nid in saved:
		if NpcData.NPCS.has(nid):
			var h: Array = saved[nid]
			_spawn(String(nid), Vector2i(int(h[0]), int(h[1])))


func _process(dt: float) -> void:
	if not m.built or paused:
		return
	_t -= dt
	if _t <= 0.0:
		_t = CHECK
		check()


## Chi c'è già (per id).
func present() -> Array:
	return list.map(func(n: Npc) -> String: return n.id)


## Fa arrivare il primo abitante che può: restituisce il suo id o "".
func check() -> String:
	var hearth := _hearth()
	if hearth.x < 0:
		return ""
	var beds := 0
	for o in m.world.stations:
		if m.world.stations[o] == "letto" and Vector2(o - hearth).length() <= NpcData.HOME_RANGE:
			beds += 1
	if beds <= list.size():
		return ""
	for nid in NpcData.NPCS:
		if nid in present() or not _ready_for(String(nid)):
			continue
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
