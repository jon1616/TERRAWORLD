class_name AnglerBook
extends Node
## Il libro dei record di pesca (Roadmap 27, voce 258). A ogni pesce preso (`Fishing.caught`) guarda la sua misura dentro
## la taglia della specie (`FishData` "size"): oltre `TIERS[k]` della strada dalla più piccola alla più grande è una
## medaglia (bronzo, argento, oro). La medaglia più alta di ogni specie in `Character.stats["record_<pesce>"]` (1-3);
## ogni medaglia nuova ha il suo premio, ogni `GOLD_EVERY` ori un premio grande.

const TIERS := [0.4, 0.7, 0.9]
const NAMES := ["bronzo", "argento", "oro"]
const REWARDS := [{"lumino": 25}, {"cassetta_alga": 1, "lumino": 40}, {"polvere_iridata": 1, "forziere_sommerso": 1}]   # (niente esche: le prove le contano)
const GOLD_EVERY := 10
const GOLD_REWARD := {"linfa_antica": 3, "scrigno_fondo": 1}

var m: Node2D
var paused := false                    # le prove: i premi non devono cambiare i conti delle prove della pesca


func setup(main: Node2D) -> void:
	m = main
	if m.get("fishing") != null:
		m.fishing.fish_caught.connect(_on_caught)


## La medaglia di una misura (0 = nessuna, 1-3).
static func tier_of(id: String, size: int) -> int:
	var span: Array = FishData.info(id).get("size", [1, 2])
	var f := clampf(float(size - int(span[0])) / maxf(float(int(span[1]) - int(span[0])), 1.0), 0.0, 1.0)
	var t := 0
	for k in TIERS.size():
		if f >= float(TIERS[k]) - 0.0001:
			t = k + 1
	return t


func medal(id: String) -> int:
	return int(m.character.stats.get("record_" + id, 0))


func _on_caught(id: String, size: int) -> void:
	if paused:
		return
	var t := tier_of(id, size)
	if t <= medal(id):
		return
	var st: Dictionary = m.character.stats
	var old := medal(id)
	st["record_" + id] = t
	var parts := []
	for k in range(old, t):
		parts.append(Lineage._give(m, REWARDS[k]))
		m.objectives.bump("medaglie_pesca")
	var msg := "Record di pesca: %s, medaglia d'%s" % [String(FishData.info(id).get("name", id)), NAMES[t - 1]] if t >= 2 \
		else "Record di pesca: %s, medaglia di bronzo" % String(FishData.info(id).get("name", id))
	if t == 3:
		m.objectives.bump("ori_pesca")
		if count(3) % GOLD_EVERY == 0:
			parts.append(Lineage._give(m, GOLD_REWARD))
	m.hud.toast(msg + " · " + ", ".join(parts))
	m.sfx.play("dono")


## Quante specie hanno almeno la medaglia t.
func count(t: int) -> int:
	var n := 0
	for id in FishData.all():
		if medal(String(id)) >= t:
			n += 1
	return n


func line() -> String:
	return "Record di pesca: ori %d, argenti %d, bronzi %d su %d specie" % [count(3), count(2), count(1), FishData.all().size()]
