class_name Travel
extends Node
## Il viaggio rapido (voce 38): le **Radici viandanti** sono stazioni che il Germogliato pianta dove vuole; tutte le
## radici dello stesso mondo sono collegate sotto terra. Clic destro su una radice = si apre la mappa in modo viaggio
## (`MapPanel.open_travel`): clic su un'altra radice e ci si arriva. Niente dati propri: le radici sono stazioni del
## mondo, salvate con lui.

const S := 16
const ID := "radice_viandante"

var m: Node2D


func setup(main: Node2D) -> void:
	m = main


## Le radici di questo mondo (angolo in alto a sinistra).
func roots() -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for o in m.world.stations:
		if m.world.stations[o] == ID:
			out.append(o)
	return out


## Clic destro su una radice: la mappa per scegliere dove andare.
func open_from(o: Vector2i) -> bool:
	if roots().size() < 2:
		m.hud.toast("La radice non trova compagne: piantane un'altra lontano da qui")
		return true
	m.hud.map.open_travel(o)
	m.sfx.play("apri", Vector2(o) * S)
	return true


## Il viaggio da una radice a un'altra.
func go(from: Vector2i, to: Vector2i) -> bool:
	if to == from or m.world.stations.get(to, "") != ID:
		return false
	Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.4))
	var size: Array = StationsData.STATIONS[ID]["size"]
	m.snap_to(to + Vector2i(int(size[0]) / 2, int(size[1]) - 1))
	Fx.puff(m.fx, m.player.position, Color(0.8, 1.6, 1.4))
	m.sfx.play("portale", m.player.position)
	m.hud.toast("La radice ti porta: %s" % describe(to))
	m.objectives.bump("radici_viaggi")
	return true


## Dove sta una radice, detto a parole: lo strato e quanto è lontana dalla partenza.
func describe(o: Vector2i) -> String:
	var st := String(StrataData.STRATA[StrataData.at(m.world, o.x, o.y)]["name"])
	var dx: int = o.x - m.world.spawn.x
	var side := "a est" if dx > 0 else "a ovest"
	if absi(dx) < 20:
		return "%s, vicino alla partenza" % st
	return "%s, %d tessere %s della partenza" % [st, absi(dx), side]
