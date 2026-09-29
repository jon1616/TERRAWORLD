class_name NetContracts
extends Node
## I contratti della rete (Roadmap 27, voce 260): la Tessitrice di vene chiede quattro cose, ognuna con un grado che
## sale (`Character.stats["contratto_<tipo>"]`): la soglia del grado g è `base × STEP^g`. Si guardano ogni `TICK` secondi
## nel mondo in cui si è (la rete che c'è adesso): superata la soglia, premio e grado dopo.
##   KINDS: tipo → [frase con %d, soglia di partenza]

const TICK := 5.0
const STEP := 1.6
const KINDS := {
	"potenza": ["Una rete che dà %d pulsi insieme", 60.0],
	"macchine": ["%d macchine che lavorano insieme", 4.0],
	"riserve": ["%d gocce nelle riserve di una rete", 80.0],
	"centrali": ["%d Centrali dei Seminatori risvegliate", 1.0],
}
const REWARDS := [
	{"cristallo_linfa": 2, "lingotto_legnoferro": 4},
	{"cristallo_linfa": 4, "lingotto_ambra": 4},
	{"polvere_iridata": 2, "linfa_antica": 2},
	{"polvere_iridata": 4, "linfa_antica": 3},
]

var m: Node2D
var _t := 3.0


func setup(main: Node2D) -> void:
	m = main


func grade(kind: String) -> int:
	return int(m.character.stats.get("contratto_" + kind, 0))


func target(kind: String) -> int:
	return ceili(float(KINDS[kind][1]) * pow(STEP, grade(kind)))


func text(kind: String) -> String:
	return String(KINDS[kind][0]) % target(kind)


## Quanto vale adesso, nel mondo in cui si è.
func value(kind: String) -> int:
	if m.get("energy") == null:
		return 0
	match kind:
		"potenza":
			var best := 0.0
			for n in m.energy.nets:
				best = maxf(best, float(n.get("prod", 0.0)))
			return roundi(best)
		"macchine":
			var n := 0
			for mc: Machine in m.energy.machines.values():
				if mc.role() == "macchina" and mc.power >= 0.99 and mc.on():
					n += 1
			return n
		"riserve":
			var best := 0.0
			for n in m.energy.nets:
				best = maxf(best, float(n.get("stored", 0.0)))
			return roundi(best)
		"centrali":
			return int(m.character.stats.get("centrali", 0))
	return 0


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = TICK
	check()


## I contratti compiuti adesso (e i premi).
func check() -> Array:
	var done := []
	for k in KINDS:
		if value(k) < target(k):
			continue
		var g := grade(k)
		m.character.stats["contratto_" + k] = g + 1
		done.append(k)
		m.objectives.bump("contratti")
		var gift := Lineage._give(m, REWARDS[mini(g, REWARDS.size() - 1)])
		m.hud.toast("Contratto della Tessitrice compiuto: %s · %s" % [text_done(k, g), gift])
		m.sfx.play("dono")
	return done


func text_done(kind: String, g: int) -> String:
	return String(KINDS[kind][0]) % ceili(float(KINDS[kind][1]) * pow(STEP, g))


func line() -> String:
	var parts := []
	for k in KINDS:
		parts.append("%s (%d/%d)" % [text(k), value(k), target(k)])
	return "Contratti della Tessitrice: " + "; ".join(parts)
