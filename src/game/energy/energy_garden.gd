class_name EnergyGarden
extends RefCounted
## Roadmap 19, voce 208: la rete e il Giardino.
##   - **Aiuole alimentate**: un portale (Aiuola con un Seme) del Giardino che tocca una rete viva di almeno `MIN_PULSI`
##     pulsi tiene sveglio il suo mondo: mentre sei via, la rete di quel mondo lavora a piena velocità invece che a metà
##     (`EnergyAway`). Il Giardino lo scrive nel personaggio (`stats["rete_viva_<mondo>"]`, solo numeri), così lo sa
##     anche il mondo dall'altra parte.
##   - Il conteggio delle macchine: `stats["macchine"]` = il massimo di macchine posate in un mondo (per gli obiettivi,
##     la Tessitrice di vene e la Bacheca); sale con `Objectives.bump`, così il diario scrive la prima volta.

const MIN_PULSI := 20.0
const FULL := 1.0


## Il portale (o qualunque stazione) in o tocca una rete viva abbastanza?
static func powered(e: Energy, o: Vector2i) -> bool:
	var ni: int = e.station_net.get(o, -1)
	if ni < 0 or ni >= e.nets.size():
		return false
	var nt: Dictionary = e.nets[ni]
	return bool(nt["flowing"]) and float(nt["prod"]) >= MIN_PULSI


## Ogni secondo, nel Giardino: quali mondi hanno l'Aiuola alimentata.
static func update(e: Energy) -> void:
	var m: Node2D = e.m
	if m.get("aiuole") == null or not m.aiuole.is_home() or not m.world_meta.has("portali"):
		return
	var stats: Dictionary = m.character.stats
	for key in m.world_meta["portali"]:
		var id := String((m.world_meta["portali"][key] as Dictionary).get("mondo", ""))
		if id == "":
			continue
		var xy := String(key).split(",")
		var o := Vector2i(int(xy[0]), int(xy[1]))
		stats["rete_viva_" + id] = 1 if powered(e, o) else 0


## La velocità del lavoro fatto mentre si era via, per questo mondo.
static func away_speed(e: Energy) -> float:
	var id := String(e.m.get("world_id")) if e.m.get("world_id") != null else ""
	if id != "" and int(e.m.character.stats.get("rete_viva_" + id, 0)) == 1:
		return FULL
	return EnergyAway.SPEED


## Dopo ogni ricostruzione: le macchine posate dal giocatore in questo mondo (quelle del generatore non contano).
static func count(e: Energy) -> void:
	var n := 0
	for mc: Machine in e.machines.values():
		if not mc.d.get("gen", false):
			n += 1
	var have := int(e.m.character.stats.get("macchine", 0))
	if n > have and e.m.get("objectives") != null:
		e.m.objectives.bump("macchine", n - have)
