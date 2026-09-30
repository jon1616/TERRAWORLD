class_name PrimoGarden
extends Node
## Il Giardino oltre il Vuoto (Roadmap 28, voci 263-264): nel mondo del Seme Primo (`world_meta["primo"]`), l'Albero
## Antico (`PassPrimo`). Clic destro sull'Albero: la prima volta sveglia il suo custode, l'ultimo Seminatore
## (`primo_boss` nel pacchetto `primo_pack.gd`); sconfitto, lascia il Seme del Seminatore; portato all'Albero, comincia il
## finale (`Finale`). Stato in `world_meta["primo_luogo"]` = {"sveglio", "vinto", "finale"}.

var m: Node2D
var boss: Creature = null


func setup(main: Node2D) -> void:
	m = main
	m.fauna.killed.connect(_on_kill)


func active() -> bool:
	return bool(m.world_meta.get("primo", false)) and tree().x >= 0


func tree() -> Vector2i:
	for o in m.world.stations:
		if String(m.world.stations[o]) == "albero_antico":
			return o
	return Vector2i(-1, -1)


func state() -> Dictionary:
	if not m.world_meta.has("primo_luogo"):
		m.world_meta["primo_luogo"] = {}
	return m.world_meta["primo_luogo"]


## Clic destro sull'Albero Antico.
func touch(o: Vector2i) -> bool:
	if o != tree():
		return false
	var s := state()
	if s.get("finale", false):
		m.hud.toast("L'Albero Antico dorme, sereno. Il suo racconto l'hai ascoltato.")
		if m.get("finale") != null:
			m.finale.show_epilogue()
		return true
	if s.get("vinto", false):
		if Crafting.have(m.character.bisaccia, "seme_seminatore") > 0:
			Crafting.take(m.character.bisaccia, "seme_seminatore", 1)
			s["finale"] = true
			if m.get("finale") != null:
				m.finale.start()                           # voce 264
		else:
			m.hud.toast("L'Albero Antico aspetta il seme che l'ultimo Seminatore teneva stretto")
		return true
	if boss != null and is_instance_valid(boss) and m.fauna.list.has(boss):
		m.hud.toast("L'ultimo Seminatore è già sveglio")
		return true
	wake()
	return true


func wake() -> Creature:
	var at := (Vector2(tree()) + Vector2(4.5, -6.0)) * 16.0
	for c in m.fauna.list.duplicate():
		if is_instance_valid(c) and (c as Creature).position.distance_to(at) < 30.0 * 16.0 \
				and not CreaturesData.get_data((c as Creature).id).get("boss", false):
			m.fauna.kill_quietly(c)
	boss = m.fauna.add("ultimo_seminatore", at)
	var vm := Portal.vigor_mult(int(m.world_meta.get("vigore", 1)))
	boss.strengthen(vm, vm * DangerData.DAMAGE)
	state()["sveglio"] = true
	m.hud.toast("Dall'Albero Antico si alza l'ultimo Seminatore: «Nessuno toccherà il seme.»")
	m.sfx.play("guardiano")
	return boss


func _on_kill(c: Creature) -> void:
	if not CreaturesData.get_data(c.id).get("primo_boss", false):
		return
	state()["vinto"] = true
	boss = null
	m.objectives.bump("ultimo_seminatore")
	m.hud.toast("L'ultimo Seminatore si spegne come una lanterna. Tra le sue mani, un seme che batte.")
	if m.guardian != null and m.guardian.lore != null:
		m.guardian.lore.show_page("primo_seminatore")


## La scheda dell'Albero Antico (per `StationTip`).
func card() -> TipCard:
	var c := TipCard.new()
	c.title("L'Albero Antico", Color("#ffd24a"))
	c.sub("Più vecchio dell'Albero-Madre, e sveglio. Le sue radici attraversano il Vuoto.")
	var s := state()
	if s.get("finale", false):
		c.line("Ha raccontato ciò che sapeva.", TipCard.GOOD)
	elif s.get("vinto", false):
		c.line("Portagli il Seme del Seminatore.", Color("#ffd24a"))
	else:
		c.line("Qualcuno lo custodisce.", Color("#ff9a6a"))
	c.hint("Clic destro")
	return c
