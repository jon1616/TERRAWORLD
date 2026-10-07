class_name TestsPlaces
extends RefCounted
## Prove dei luoghi scritti a mano (voce 70): un mondo con il gene giusto ha il suo luogo, uno senza no; tutti gli otto
## disegni si costruiscono (leggio, scrigno con l'oggetto unico); entrando in un luogo lo si trova (scritta, conteggio,
## segno sulla mappa); il leggio racconta la storia. Foto 131_luogo e 132_luoghi.

var kit: TestKit
var world: World
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	world = tk.world
	m = tk.m


## Costruisce i luoghi indicati sotto la partenza, in fila; restituisce i loro appunti (come in `world_meta`).
func build_row(ids: Array, depth := 40) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var out := []
	var x0 := world.spawn.x - 60
	for i in ids.size():
		var x := x0 + (i % 4) * 28
		var o := Vector2i(x, world.surface[x] + depth + (i / 4) * 14)
		var e := PassLuoghi.build(world, String(ids[i]), o, rng)
		var lg: Vector2i = e.get("leggio", Vector2i(-1, -1))
		e["leggio"] = [lg.x, lg.y]
		e["porta"] = (e["porta"] as Array).map(func(v: Vector2i) -> Array: return [v.x, v.y])
		var mc := {}
		for k in e["mecc"]:
			var v: Vector2i = e["mecc"][k]
			mc[k] = [v.x, v.y]
		e["mecc"] = mc
		e["trovato"] = false
		out.append(e)
	m.view.refresh_rect(Rect2i(x0 - 2, world.surface[x0] + depth - 2, 4 * 28 + 4, 30))
	m.light.dirty = true
	return out


func run() -> void:
	# la generazione: il luogo solo con il gene giusto
	var ws: Array[World] = await kit.gen_many([[777, 1600, 900, {"geni": ["lanterna", "alveari"], "vigore": 2}], [777, 1600, 900, {"geni": ["lanterna", "cavo"], "vigore": 2}]])      # insieme, in parallelo
	var w1 := ws[0]
	var w2 := ws[1]
	var ids1: Array = (w1.gen_notes.get("luoghi", []) as Array).map(func(e: Dictionary) -> String: return String(e["id"]))
	var n2: int = (w2.gen_notes.get("luoghi", []) as Array).size()
	# gli otto disegni nel mondo di prova
	var all: Array = PlacesData.PLACES.keys().filter(func(k: String) -> bool: return not PlacesData.PLACES[k].get("camera", false) \
		and not PlacesData.PLACES[k].get("struttura", false))   # (le camere-enigma della voce 97 non hanno l'oggetto unico)
	var built := build_row(all)
	var ok := 0
	for e in built:
		var lg: Array = e["leggio"]
		var chest_ok := false
		for o in world.stations:
			if String(world.stations[o]) == "scrigno" and Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"])).has_point(o):
				chest_ok = world.chest_at(o).count(String(PlacesData.PLACES[String(e["id"])]["unique"])) == 1
		if int(lg[0]) >= 0 and world.stations.get(Vector2i(int(lg[0]), int(lg[1])), "") == "leggio" and chest_ok:
			ok += 1
	(m.world_meta["luoghi"] as Array).append_array(built)
	# entrare nel primo: trovato
	var first: Dictionary = built[0]
	var n0 := int(m.character.stats.get("luoghi", 0))
	m.boons.add("bagliore", 20.0)
	m.snap_to(Vector2i(int(first["x"]) + 4, int(first["y"]) + int(first["h"]) - 3))
	await kit.seconds(1.6)
	await kit.save("131_luogo")
	var found: bool = first.get("trovato", false) and int(m.character.stats.get("luoghi", 0)) == n0 + 1
	var read: bool = m.places.read(Vector2i(int(first["leggio"][0]), int(first["leggio"][1])))
	m.language.panel.visible = false
	m.snap_to(Vector2i(int(built[2]["x"]) + 4, int(built[2]["y"]) + int(built[2]["h"]) - 3))
	await kit.seconds(1.2)
	await kit.save("132_luoghi")
	m.snap_to(world.spawn)
	print("luoghi: mondo con Alveari → %s, senza → %d; disegni costruiti bene %d su %d; trovato entrando %s; leggio %s" % [
		ids1, n2, ok, all.size(), "sì" if found else "NO", "sì" if read else "NO"])
	if not "alveare" in ids1 or n2 != 0 or ok != all.size() or not found or not read:
		print("ATTENZIONE: i luoghi scritti a mano non funzionano come dovrebbero")
