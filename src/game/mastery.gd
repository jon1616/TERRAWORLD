class_name Mastery
extends Node
## La maestria dei pilastri (Roadmap 20, voce 214; dati in `MasteryData`). Raccoglie i punti di ciò che il giocatore fa
## (i conteggi del personaggio, le creature sconfitte, le celle scoperte, ciò che fabbrica e costruisce, le parole dei
## Seminatori) e li scrive in `Character.maestria` = {pilastro: {"p": punti, "t": tempo di gioco dell'ultimo punto}}.
## Salendo di grado: avviso, tappa del diario, premio (`MasteryRewards`), segnale `graded`.

signal graded(pillar: String, grade: int)
signal gained(pillar: String, pts: float)

var m: Node2D


func setup(main: Node2D) -> void:
	m = main
	m.objectives.bumped_n.connect(_on_stat)
	m.fauna.killed.connect(_on_kill)
	m.actions.placed.connect(func(_c: Vector2i, _id: String) -> void: add("giardino", MasteryData.BLOCK_PTS))
	m.map_reveal.on_new = func(n: int) -> void: add("esplorazione", n / MasteryData.CELLS_PER_PT)
	Crafting.crafted = _on_craft
	if m.get("language") != null:
		m.language.confirmed.connect(func(words: Array, _how: String) -> void: add("misteri", MasteryData.WORD_PTS * words.size()))


func _exit_tree() -> void:
	Crafting.crafted = Callable()


func data() -> Dictionary:
	return m.character.maestria


func points(pillar: String) -> float:
	return float((data().get(pillar, {}) as Dictionary).get("p", 0.0))


func grade(pillar: String) -> int:
	return MasteryData.grade_of(pillar, points(pillar))


## Da quanti secondi di gioco il pilastro non riceve punti (-1 = mai).
func idle(pillar: String) -> float:
	var e: Dictionary = data().get(pillar, {})
	if not e.has("t"):
		return -1.0
	return float(m.character.play_time) - float(e["t"])


func add(pillar: String, pts: float) -> void:
	if pts <= 0.0 or not MasteryData.PILLARS.has(pillar):
		return
	var e: Dictionary = data().get(pillar, {})
	var g0 := MasteryData.grade_of(pillar, float(e.get("p", 0.0)))
	e["p"] = float(e.get("p", 0.0)) + pts
	e["t"] = float(m.character.play_time)
	data()[pillar] = e
	gained.emit(pillar, pts)
	var g1 := MasteryData.grade_of(pillar, float(e["p"]))
	for g in range(g0 + 1, g1 + 1):
		_graded(pillar, g)


func _graded(pillar: String, g: int) -> void:
	var name := String(MasteryData.PILLARS[pillar]["name"])
	var gift := MasteryRewards.give(m, pillar, g)
	m.hud.toast("%s: grado %d%s" % [name, g, (" · " + gift) if gift != "" else ""])
	m.sfx.play("dono")
	if m.get("diary") != null:
		m.diary.note("%s: grado %d" % [name, g], "maestria")
	graded.emit(pillar, g)


func _on_stat(stat: String, n: int) -> void:
	for e in MasteryData.STATS.get(stat, []):
		add(String(e[0]), float(e[1]) * n)


func _on_kill(c: Creature) -> void:
	if c.tame != null or c.docile:
		return
	add("combattimento", maxf(0.2, float(c.hp_max) / MasteryData.KILL_HP_PER_PT))


func _on_craft(r: Dictionary) -> void:
	var out := String(r.get("out", ""))
	var it := ItemsData.get_item(out)
	var kind := String(it.get("kind", ""))
	var pillar := String(MasteryData.KIND.get(kind, MasteryData.STATION.get(String(r.get("station", "")), "")))
	if String(it.get("cat", "")) == "rete":
		pillar = "rete"
	if pillar == "" and Bisaccia.is_gear(out):
		add("combattimento", MasteryData.GEAR_PTS)
		return
	if pillar != "":
		add(pillar, MasteryData.CRAFT_PTS)
