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
	m.character.maestria = {}
	await rewards()
	m.character.maestria = {}
	await book()
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


## Voce 215: salire di grado dà gli oggetti del grado e i bonus per sempre (pesca: fortuna di pesca).
func rewards() -> void:
	var ms: Mastery = m.mastery
	var b: Bisaccia = m.character.bisaccia
	var bait0 := b.count("esca_squama")
	var luck0 := float(m.fishing.gear.get("luck", 0.0))
	ms.add("pesca", MasteryData.points_for("pesca", 4))       # dal grado 0 al 4
	await kit.frames(2)
	var grade := ms.grade("pesca")
	var bait := b.count("esca_squama") - bait0
	var luck := float(m.fishing.gear.get("luck", 0.0)) - luck0
	var ok := grade == 4 and bait == 10 and is_equal_approx(luck, 0.06)
	print("premi della maestria: pesca al grado %d, esche avute %d, fortuna di pesca +%.2f" % [grade, bait, luck])
	if not ok:
		print("ATTENZIONE: i premi dei gradi non arrivano come devono")


## Voce 216: il Libro dei pilastri si apre e dice i gradi e i premi; il filo propone il pilastro trascurato.
func book() -> void:
	var ms: Mastery = m.mastery
	ms.add("storia", MasteryData.points_for("storia", 3) + 10.0)
	ms.add("esplorazione", MasteryData.points_for("esplorazione", 1) + 5.0)
	ms.panel.sel = "storia"
	ms.panel.open()
	await kit.frames(4)
	await kit.save("244_pilastri")
	var txt := ms.panel.text_of("storia")
	ms.panel.close()
	var pt0: float = m.character.play_time
	m.character.play_time = pt0 + 7200.0                  # due ore dopo: tutto è fermo, il più fermo è il primo mai cominciato
	var n := ms.neglected()
	m.character.play_time = pt0
	var ok := txt.contains("Grado 3") and txt.contains("✓") and String(n.get("text", "")).contains("grado")
	print("Libro dei pilastri: scheda della storia %s; il filo propone «%s»" % ["sì" if txt.contains("Grado 3") else "NO", n.get("text", "")])
	if not ok:
		print("ATTENZIONE: il Libro dei pilastri o il filo del pilastro trascurato non vanno")
