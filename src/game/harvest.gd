class_name Harvest
extends Node
## I raccolti delle piante (Roadmap 30, voce 300; dati in `HarvestData`): quando una pianta viene tolta
## (`PlayerActions.decor_picked`) lascia il suo raccolto, con la sua probabilità. Il conteggio «piante_raccolte» nutre
## l'esplorazione e l'orto (`MasteryData.STATS`).
## Voce 301: i baccelli dormienti (`PodsData`) si aprono allo stesso modo: il bottino dello strato e del tipo, a volte
## una cosa rara; il conteggio «baccelli_aperti». Voce 304: a volte una curiosità dello strato (`CuriositiesData`).

var m: Node2D
var _rng := RandomNumberGenerator.new()
var last_loot := []                    # il bottino dell'ultimo baccello aperto (per le prove)


func setup(main: Node2D) -> void:
	m = main
	_rng.randomize()
	m.actions.decor_picked.connect(_on_picked)
	if m.get("erbario") != null:
		m.erbario.discovered.connect(_on_discovered)


func _on_picked(c: Vector2i, d: int) -> void:
	if PodsData.KINDS.has(d):
		open_pod(c, d)
		return
	if not HarvestData.DECOR.has(d):
		return
	var e: Array = HarvestData.DECOR[d]
	if _rng.randf() >= float(e[1]):
		return
	m.drops.spawn(String(e[0]), _rng.randi_range(int(e[2]), int(e[3])), Vector2(c) * 16.0 + Vector2(8, 8))
	m.objectives.bump("piante_raccolte")
	if StrataData.at(m.world, c.x, c.y) == 0 and _rng.randf() < CuriositiesData.PLANT_CHANCE:
		m.drops.spawn(CuriositiesData.pick(0, _rng, _known()), 1, Vector2(c) * 16.0 + Vector2(8, 8))   # voce 304


## Un baccello aperto: il suo bottino cade dove stava (con uno sbuffo), il conteggio sale.
func open_pod(c: Vector2i, d: int) -> Array:
	var at := Vector2(c) * 16.0 + Vector2(8, 8)
	var s := StrataData.at(m.world, c.x, c.y)
	var loot := PodsData.roll(d, s, _rng)
	if _rng.randf() < CuriositiesData.POD_CHANCE:
		loot.append([CuriositiesData.pick(s, _rng, _known()), 1])                 # voce 304: una curiosità dello strato
	for e in loot:
		m.drops.spawn(String(e[0]), int(e[1]), at)
	Fx.dust(m.fx, at, [Color("#8a6a4a"), Color("#5a3a30"), Color("#e0c080")])
	m.sfx.play("rompi", at)
	m.objectives.bump("baccelli_aperti")
	last_loot = loot
	return loot


## Le curiosità già trovate (quelle dell'Erbario).
func _known() -> Dictionary:
	return (m.character.erbario.get("oggetti", {}) as Dictionary)


## Voce 304: una curiosità nuova si annuncia con quante se ne sono trovate.
func _on_discovered(section: String, id: String) -> void:
	if section != "oggetti" or String(ItemsData.get_item(id).get("kind", "")) != "curiosita":
		return
	var n := 0
	for k in CuriositiesData.SERIES.size():
		for c in CuriositiesData.of_stratum(k):
			if _known().has(c):
				n += 1
	m.hud.toast("Curiosità trovata: %s (%d di %d) · nel Museo del Giardino ha la sua sala" % [ItemsData.get_item(id)["name"], n,
		CuriositiesData.count_all()])
	m.objectives.bump("curiosita")
