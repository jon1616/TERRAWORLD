class_name Rares
extends Node
## I rari dei nemici (Roadmap 45, voce 395; dati nel pacchetto generato `src/data/vastita/rari.gd`). Ogni specie ha un
## oggetto raro (campo «raro_di» = la specie, «raro_p» = la probabilità, da 1/150 a 1/50): quando la si sconfigge, con
## un po' di fortuna (`Fauna.luck`) lo lascia. La prima volta che cade lo segna l'Erbario come ogni oggetto trovato.

var m: Node2D
var dropped := 0                         # per le prove
var _rng := RandomNumberGenerator.new()
static var _of := {}                     # specie → raro (calcolato una volta)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.fauna.killed.connect(_on_killed)


## Il raro di una specie ("" se non ne ha).
static func of_species(sid: String) -> String:
	if _of.is_empty():
		for id in ItemsData.all():
			var it: Dictionary = ItemsData.all()[id]
			if it.has("raro_di"):
				_of[String(it["raro_di"])] = String(id)
	return String(_of.get(sid, ""))


func _on_killed(c: Creature) -> void:
	if not is_instance_valid(c) or c.tame != null:
		return
	var id := of_species(c.base)
	if id == "":
		return
	var p := float(ItemsData.get_item(id).get("raro_p", 0.01)) * (1.0 + maxf(float(m.fauna.luck), 0.0))
	if _rng.randf() < p:
		m.drops.spawn(id, 1, c.position)
		dropped += 1
