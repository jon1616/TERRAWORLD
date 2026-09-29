class_name TestsMastery
extends RefCounted
## Roadmap 20 «Il motore comune»: la maestria dei pilastri (gruppo `maestria`).

var kit: TestKit
var m: Node


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var saved: Dictionary = m.character.maestria.duplicate(true)
	m.character.maestria = {}
	await points()
	m.character.maestria = saved
	m.gear.refresh()


## Voce 214: i punti arrivano dalle attività (conteggi, creature, fabbricare, blocchi, mappa) e il grado sale.
func points() -> void:
	var ms: Mastery = m.mastery
	var got := {}
	for p in MasteryData.ORDER:
		got[p] = 0.0
	var cb := func(p: String, pts: float) -> void: got[p] = float(got[p]) + pts
	ms.gained.connect(cb)
	var grades := []
	var cg := func(p: String, g: int) -> void: grades.append([p, g])
	ms.graded.connect(cg)
	m.objectives.bump("pesci", 10)                      # 3 punti di pesca
	m.objectives.bump("firme")                          # 45 di esplorazione: grado 1 (38)
	var foe: Creature = m.fauna.add("grumo_muschio", m.player.position + Vector2(200, -20))
	m.fauna.kill(foe)
	var r: Dictionary = RecipesData.making("torcia")[0]
	for k in r["in"]:
		m.character.bisaccia.add(String(k), int(r["in"][k]))
	Crafting.craft(r, m.character.bisaccia)            # la torcia al Ceppo: nessun pilastro
	var pr: Dictionary = RecipesData.making("vena_radice")[0]
	for k in pr["in"]:
		m.character.bisaccia.add(String(k), int(pr["in"][k]))
	Crafting.craft(pr, m.character.bisaccia)           # una vena: la rete
	m.map_reveal.on_new.call(500)                       # 500 celle nuove: 2 punti di esplorazione
	await kit.frames(2)
	ms.gained.disconnect(cb)
	ms.graded.disconnect(cg)
	var ok := is_equal_approx(float(got["pesca"]), 3.0) and float(got["esplorazione"]) >= 47.0
	ok = ok and float(got["combattimento"]) > 0.0 and float(got["rete"]) >= 1.0 and ms.grade("esplorazione") == 1
	ok = ok and ["esplorazione", 1] in grades
	var curve := []
	for g in [1, 5, 10]:
		curve.append("%d→%d" % [g, int(MasteryData.points_for("storia", g))])
	print("maestria: punti %s; gradi saliti %s; curva della storia %s" % [str(got), str(grades), ", ".join(curve)])
	if not ok:
		print("ATTENZIONE: la maestria non raccoglie i punti come deve")
