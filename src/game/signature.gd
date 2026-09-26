class_name Signature
extends Node
## La firma del mondo mentre si gioca (voce 44, dati in `SignaturesData`, luogo costruito da `PassFirma`):
## `world_meta["firma"]` = {"id", "x", "y", "trovata"}. Il mondo appena nato la prende dagli appunti del generatore;
## un mondo salvato prima della voce 44 la riceve adesso (la stessa passata, lontano dalla partenza e dal Cuore).
## Avvicinandosi a meno di `NEAR` tessere dal suo centro la si **trova**: una scritta la presenta, il conteggio
## «firme» del personaggio cresce (obiettivi), la mappa la segna con una stella.

const NEAR := 26.0
const S := 16

var m: Node2D
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("firma"):
		var notes: Dictionary = m.world.gen_notes.get("firma", {})
		if notes.is_empty() and not m.world.gen_notes.has("firma"):
			notes = _retrofit()
		m.world_meta["firma"] = {} if notes.is_empty() else {"id": notes["id"], "x": int(notes["x"]), "y": int(notes["y"]),
			"trovata": false}


## Un mondo salvato prima della voce 44: la sua firma si costruisce adesso, con il seme e i geni del mondo.
func _retrofit() -> Dictionary:
	var c := GenContext.new(m.world.world_seed)
	c.params["geni"] = m.world_meta.get("geni", [])
	for o in m.world.stations:
		if String(m.world.stations[o]).begins_with("cuore"):
			c.notes["cuore"] = o
	PassFirma.new().run(m.world, c)
	return c.notes.get("firma", {})


func info() -> Dictionary:
	return m.world_meta.get("firma", {})


func found() -> bool:
	return bool(info().get("trovata", false))


func center() -> Vector2i:
	return Vector2i(int(info().get("x", -1)), int(info().get("y", -1)))


func _process(dt: float) -> void:
	_t -= dt
	if _t > 0.0 or info().is_empty() or found():
		return
	_t = 0.5
	if (m.player.position / S).distance_to(Vector2(center())) < NEAR:
		discover()


func discover() -> void:
	var d: Dictionary = SignaturesData.SIGNATURES.get(String(info()["id"]), {})
	info()["trovata"] = true
	m.objectives.bump("firme")
	m.sfx.play("portale", m.player.position)
	m.depth_watch.banner.show_stratum("La firma di questo mondo", "%s: %s" % [_cap(String(d.get("name", ""))), d.get("desc", "")],
		Color("#ffd24a"))


static func _cap(s: String) -> String:
	return s.substr(0, 1).to_upper() + s.substr(1)


## Una riga per la scheda del personaggio e per il Semenzaio.
func sheet_line() -> String:
	if info().is_empty():
		return ""
	var d: Dictionary = SignaturesData.SIGNATURES.get(String(info()["id"]), {})
	return "Firma: %s" % (_cap(String(d.get("name", ""))) if found() else "non ancora trovata")
