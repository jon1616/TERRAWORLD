class_name Visitors
extends Node
## I visitatori del Giardino (Roadmap 22, voce 229): abitanti di `NpcData` con `visitor` che non vivono qui. Ogni giorno
## del Giardino, se la bellezza più alta raggiunta (`GardenBeauty`) basta per la loro soglia (`requires.bellezza`), uno
## di loro può arrivare (`CHANCE`) e resta fino al giorno dopo, accanto all'Albero-Madre. Non si salvano tra gli
## abitanti: chi c'è oggi sta in `world_meta["visitatore"]` = [id, giorno]. Commerciano e hanno richieste come gli
## altri (`TradePanel`); la Musicista, arrivando, fa festa: +`PARTY` di affetto a tutti gli abitanti.

const CHANCE := 0.6
const PARTY := 5

var m: Node2D
var npc: Npc = null
var _day := -1
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	var v: Variant = m.world_meta.get("visitatore", null)
	if v is Array and (v as Array).size() == 2 and NpcData.NPCS.has(String(v[0])):
		_day = int(v[1])
		_show(String(v[0]))


func _home() -> bool:
	return m.get("beauty") != null and m.beauty.home() and m.giardino.tree_o.x >= 0


func _process(_dt: float) -> void:
	if not m.built or not _home() or m.get("day") == null:
		return
	var day := int(m.day.day)
	if day == _day:
		return
	_day = day
	leave()
	if _rng.randf() < CHANCE:
		var who := eligible()
		if not who.is_empty():
			arrive(String(who[_rng.randi_range(0, who.size() - 1)]))


## I visitatori che la bellezza del Giardino attira adesso.
func eligible() -> Array:
	var out := []
	var best: int = m.beauty.best()
	for nid in NpcData.NPCS:
		var d: Dictionary = NpcData.NPCS[nid]
		if d.get("visitor", false) and best >= int(d["requires"].get("bellezza", 0)):
			out.append(String(nid))
	return out


func arrive(nid: String) -> void:
	leave()
	_show(nid)
	m.world_meta["visitatore"] = [nid, _day]
	m.hud.toast("Oggi nel Giardino c'è %s" % String(NpcData.NPCS[nid]["name"]))
	m.sfx.play("dono")
	m.objectives.bump("visitatori")
	if nid == "musicista":
		for other in m.villagers.present():
			if other != nid:
				NpcBonds.add(m.character, String(other), PARTY)
		m.hud.toast("La Musicista suona: gli abitanti fanno festa (+%d di affetto a tutti)" % PARTY)


func _show(nid: String) -> void:
	var at: Vector2i = m.giardino.tree_o + Vector2i(12, int(StationsData.STATIONS["albero_madre_0"]["size"][1]) - 1) \
		if m.get("giardino") != null and m.giardino.tree_o.x >= 0 else m.player_cell()
	npc = m.villagers._spawn(nid, at)


func leave() -> void:
	if npc != null and is_instance_valid(npc):
		m.villagers.list.erase(npc)
		npc.queue_free()
	npc = null
	m.world_meta.erase("visitatore")


func _exit_tree() -> void:
	npc = null
