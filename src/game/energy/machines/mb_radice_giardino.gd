class_name MbRadiceGiardino
extends MachineBehavior
## La Radice del Giardino: solo nel Giardino e vicino all'Albero-Madre (a `REACH` tessere dalla sua stazione): 50 pulsi
## per ogni stadio dell'Albero (`AlberoMadre.stage`), fino ai pulsi dei dati.

const REACH := 14
const PER_STAGE := 50.0


func _near_tree(mc: Machine, e: Energy) -> bool:
	if not bool(e.m.world_meta.get("giardino", false)):
		return false
	for o: Vector2i in e.m.world.stations:
		if String(e.m.world.stations[o]).begins_with("albero_madre_"):
			var size: Array = StationsData.STATIONS[e.m.world.stations[o]]["size"]
			var r := Rect2i(o, Vector2i(int(size[0]), int(size[1]))).grow(REACH)
			if r.intersects(mc.rect()):
				return true
	return false


func produce(mc: Machine, e: Energy) -> float:
	if not _near_tree(mc, e) or e.m.get("albero") == null:
		return 0.0
	return minf(PER_STAGE * maxi(int(e.m.albero.stage()), 1), float(mc.d["pulsi"]))


func state_text(mc: Machine, e: Energy) -> String:
	if not _near_tree(mc, e):
		return "a secco: va posata nel Giardino, vicino all'Albero-Madre"
	return "l'Albero dà %s (stadio %d)" % [Energy.pulsi(mc.made), int(e.m.albero.stage())]
