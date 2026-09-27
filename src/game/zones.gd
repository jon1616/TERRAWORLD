class_name Zones
extends Node2D
## Totem, stendardi e altari (voce 87, dati in `ZonesData`): tiene l'elenco dei totem piazzati nel mondo e risponde a
## «quanto vale questo effetto in questo punto» (`mult_at` per i moltiplicatori, `add_at` per le aggiunte). Due totem
## dello stesso tipo non si sommano: per ogni tipo vale il più forte che copre il punto. Lo chiedono l'orto
## (crescita), la Vita (rigenera), le creature (quiete, fortuna, bottino, rare, pericolo, forza), il combattimento
## (guardia) e l'Avvizzimento (puro). Con un totem in mano si vedono i raggi di tutti quelli vicini e del nuovo.

var m: Node2D
var list: Array = []                   # [centro in px, tipo, raggio in px, forza]
var _count := -1
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	z_as_relative = false
	z_index = 22                           # sopra la luce: i raggi si vedono anche al buio
	m.view.add_child.call_deferred(self)
	m.fauna.zone_mult = mult_at
	m.fauna.zone_add = add_at
	rebuild()


## L'elenco dei totem (si rifà quando cambia il numero delle stazioni).
func rebuild() -> void:
	list.clear()
	for o in m.world.stations:
		var d := ZonesData.info(String(m.world.stations[o]))
		if d.is_empty():
			continue
		list.append([(Vector2(o) + Vector2(0.5, 1.0)) * 16.0, String(d["type"]), float(d["r"]) * 16.0, float(d["k"])])
	_count = m.world.stations.size()


## Per ogni tipo, la forza del totem più forte che copre il punto.
func _best(pos: Vector2) -> Dictionary:
	var best := {}
	for e in list:
		if (e[0] as Vector2).distance_to(pos) <= float(e[2]):
			best[e[1]] = maxf(float(best.get(e[1], 0.0)), float(e[3]))
	return best


## Un moltiplicatore (1 se nessun totem lo dà).
func mult_at(pos: Vector2, key: String) -> float:
	var out := 1.0
	var best := _best(pos)
	for type in best:
		if (ZonesData.TYPES[type]["fx"] as Dictionary).has(key):
			out *= ZonesData.value(type, key, float(best[type]))
	return out


## Un'aggiunta (0 se nessun totem la dà).
func add_at(pos: Vector2, key: String) -> float:
	var out := 0.0
	var best := _best(pos)
	for type in best:
		if (ZonesData.TYPES[type]["fx"] as Dictionary).has(key):
			out += ZonesData.value(type, key, float(best[type]))
	return out


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t <= 0.0:
		_t = 0.5
		if m.world.stations.size() != _count:
			rebuild()
		m.vitals.zone_regen = mult_at(m.player.position, "rigenera")
	var holding := ZonesData.is_totem(String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("place", "")))
	if holding != visible or holding:
		visible = holding
		queue_redraw()


## Con un totem in mano: i raggi dei totem vicini e di quello che si sta per piazzare.
func _draw() -> void:
	if not visible:
		return
	var p: Vector2 = m.player.position
	for e in list:
		if (e[0] as Vector2).distance_to(p) < float(e[2]) + 900.0:
			var col := Color(String(ZonesData.TYPES[e[1]]["color"]))
			draw_arc(e[0], float(e[2]), 0.0, TAU, 96, Color(col, 0.55), 2.0)
			draw_circle(e[0], 4.0, Color(col, 0.8))
	var d := ZonesData.info(String(ItemsData.get_item(String(m.hud.current().get("id", ""))).get("place", "")))
	if not d.is_empty():
		var at: Vector2 = (Vector2(m.actions.mouse_cell()) + Vector2(0.5, 1.0)) * 16.0
		var col2 := Color(String(ZonesData.TYPES[d["type"]]["color"]))
		draw_arc(at, float(d["r"]) * 16.0, 0.0, TAU, 96, Color(col2, 0.9), 2.5)


## Il riassunto per la scheda di un totem: effetto e raggio.
static func describe(id: String) -> String:
	var d := ZonesData.info(id)
	if d.is_empty():
		return ""
	var td: Dictionary = ZonesData.TYPES[d["type"]]
	return "%s · raggio %d tessere%s" % [td["desc"], int(d["r"]), " · scambio: un bonus e un costo" if td.get("cost", false) else ""]
