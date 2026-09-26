class_name Places
extends Node
## I luoghi scritti a mano mentre si gioca (voce 70, dati in `PlacesData`): `world_meta["luoghi"]` (dagli appunti di
## `PassLuoghi`). Entrando in un luogo lo si **trova**: una scritta come per gli strati, il segno sulla mappa, i
## conteggi del personaggio (`stats["luoghi"]`, e quali tipi in `stats["luogo_<id>"]`). Il leggio racconta la sua
## storia. L'enigma che apre la porta del tesoro è della voce 71 (`Mechanisms`).

var m: Node2D
var _t := 1.0


func setup(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("luoghi"):
		var out := []
		for e in m.world.gen_notes.get("luoghi", []):
			var d: Dictionary = (e as Dictionary).duplicate(true)
			var lg: Vector2i = d.get("leggio", Vector2i(-1, -1))
			d["leggio"] = [lg.x, lg.y]
			d["porta"] = (d["porta"] as Array).map(func(v: Vector2i) -> Array: return [v.x, v.y])
			var mc := {}
			for k in d["mecc"]:
				var v: Vector2i = d["mecc"][k]
				mc[k] = [v.x, v.y]
			d["mecc"] = mc
			d["trovato"] = false
			out.append(d)
		m.world_meta["luoghi"] = out


func list() -> Array:
	return m.world_meta.get("luoghi", [])


func at(c: Vector2i) -> Dictionary:
	for e in list():
		if Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"])).has_point(c):
			return e
	return {}


func _process(dt: float) -> void:
	if not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 0.7
	var e := at(m.player_cell())
	if e.is_empty() or e.get("trovato", false):
		return
	e["trovato"] = true
	var pd: Dictionary = PlacesData.PLACES[String(e["id"])]
	m.depth_watch.banner.show_stratum(String(pd["name"]), String(pd["banner"]), Color(String(pd["color"])))
	var st: Dictionary = m.character.stats
	st["luoghi"] = int(st.get("luoghi", 0)) + 1
	if not st.has("luogo_" + String(e["id"])):
		st["luogo_" + String(e["id"])] = 1
		st["luoghi_tipi"] = int(st.get("luoghi_tipi", 0)) + 1
	m.language.add_mark(Vector2i(int(e["x"]) + int(e["w"]) / 2, int(e["y"]) + int(e["h"]) / 2), String(pd["name"]), Color(String(pd["color"])))
	m.sfx.play("dono")


## Il leggio di un luogo: la sua storia. False se il leggio non è di un luogo.
func read(o: Vector2i) -> bool:
	for e in list():
		var lg: Array = e.get("leggio", [-1, -1])
		if int(lg[0]) == o.x and int(lg[1]) == o.y:
			var pd: Dictionary = PlacesData.PLACES[String(e["id"])]
			m.language.panel.show_text(String(pd["name"]), "[i]%s[/i]" % pd["lore"])
			m.sfx.play("dono")
			return true
	return false
