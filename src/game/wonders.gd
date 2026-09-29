class_name Wonders
extends RefCounted
## Le meraviglie in partita (Roadmap 23, voce 237; dati in `WondersData`, forme in `PassMeraviglie`/`WonderShapes`).
## `world_meta["meraviglie"]` = [{"k", "c": [x, y], "o": [x, y], "vista": bool, "preso": bool}], dagli appunti del
## generatore. `check` (lo chiama `Atlas` a ogni giro) segna vista una meraviglia quando la mappa ne ha scoperto il centro:
## avviso, Atlante, conteggio «meraviglie» e `Character.stats["mer_<id>"]` (quali tipi ha visto). `touch` sul cuore
## dona il ricordo, una volta per meraviglia.

var m: Node2D


func _init(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("meraviglie"):
		var out := []
		for e in m.world.gen_notes.get("meraviglie", []):
			var d: Dictionary = (e as Dictionary).duplicate(true)
			d["vista"] = false
			d["preso"] = false
			out.append(d)
		m.world_meta["meraviglie"] = out


func list() -> Array:
	return m.world_meta.get("meraviglie", [])


## Le meraviglie appena viste (id).
func check() -> Array:
	var fresh := []
	var ex: PackedByteArray = m.world.explored
	for e in list():
		if e.get("vista", false):
			continue
		var c: Array = e["c"]
		var i: int = int(c[1]) * m.world.w + int(c[0])
		if i >= 0 and i < ex.size() and ex[i] == 1:
			see(e)
			fresh.append(String(e["k"]))
	return fresh


func see(e: Dictionary) -> void:
	e["vista"] = true
	var k := String(e["k"])
	var d: Dictionary = WondersData.WONDERS[k]
	m.character.stats["mer_" + k] = 1
	m.objectives.bump("meraviglie")
	if m.get("atlas") != null and m.atlas.here():
		(m.atlas.entry().get("meraviglie", {}) as Dictionary)[k] = 1
	m.hud.toast("Una meraviglia: %s. %s" % [d["name"], d["desc"]])
	m.sfx.play("portale")
	if m.get("diary") != null:
		m.diary.note("Vista una meraviglia: %s" % d["name"], "meraviglia")


func at(o: Vector2i) -> Dictionary:
	for e in list():
		if Vector2i(int(e["o"][0]), int(e["o"][1])) == o:
			return e
	return {}


## Clic destro sul cuore di una meraviglia: il ricordo, una volta sola.
func touch(o: Vector2i) -> bool:
	var e := at(o)
	if e.is_empty():
		return false
	if not e.get("vista", false):
		see(e)
	var k := String(e["k"])
	if e.get("preso", false):
		m.hud.toast("%s: il suo ricordo l'hai già preso" % WondersData.WONDERS[k]["name"])
		return true
	e["preso"] = true
	var id := WondersData.memento_id(k)
	var rest: int = m.character.bisaccia.add(id, 1)
	if rest > 0:
		m.drops.spawn(id, rest, m.player.position)
	m.objectives.bump("ricordi")
	m.sfx.play("dono")
	m.hud.toast("Il cuore della meraviglia ti dona: %s" % ItemsData.get_item(id).get("name", id))
	return true


## Quanti tipi di meraviglia ha visto il personaggio (in tutti i mondi).
static func kinds_seen(stats: Dictionary) -> int:
	var n := 0
	for k in WondersData.WONDERS:
		if int(stats.get("mer_" + k, 0)) == 1:
			n += 1
	return n
