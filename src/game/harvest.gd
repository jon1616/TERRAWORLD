class_name Harvest
extends Node
## I raccolti delle piante (Roadmap 30, voce 300; dati in `HarvestData`): quando una pianta viene tolta
## (`PlayerActions.decor_picked`) lascia il suo raccolto, con la sua probabilità. Il conteggio «piante_raccolte» nutre
## l'esplorazione e l'orto (`MasteryData.STATS`).

var m: Node2D
var _rng := RandomNumberGenerator.new()


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.actions.decor_picked.connect(_on_picked)


func _on_picked(c: Vector2i, d: int) -> void:
	if not HarvestData.DECOR.has(d):
		return
	var e: Array = HarvestData.DECOR[d]
	if _rng.randf() >= float(e[1]):
		return
	m.drops.spawn(String(e[0]), _rng.randi_range(int(e[2]), int(e[3])), Vector2(c) * 16.0 + Vector2(8, 8))
	m.objectives.bump("piante_raccolte")
