class_name Archaeology
extends RefCounted
## L'archeologia (Roadmap 26, voce 254; dati in `ArchaeologyData`). Clic destro su un giacimento (`Interact`): con il
## Pennello in mano, un colpo di spazzola; dopo `BRUSHES` colpi esce un fossile di un animale del suo strato (la parte
## che manca di più al personaggio) e il giacimento si esaurisce (sparisce). I colpi dati in `world_meta["scavi"]`.

var m: Node2D
var _rng := RandomNumberGenerator.new()


func _init(main: Node2D) -> void:
	m = main
	_rng.randomize()


func brush(o: Vector2i) -> bool:
	if ItemsData.get_item(String(m.hud.current().get("id", ""))).get("kind", "") != "pennello":
		m.hud.toast("Un giacimento fossile: serve il Pennello dell'archeologo (al Ceppo)")
		return true
	if not m.world_meta.has("scavi"):
		m.world_meta["scavi"] = {}
	var key := "%d,%d" % [o.x, o.y]
	var n := int(m.world_meta["scavi"].get(key, 0)) + 1
	m.world_meta["scavi"][key] = n
	Fx.puff(m.fx, Vector2(o) * 16.0 + Vector2(8, 10), Color(1.2, 1.1, 0.9))
	m.sfx.play("scavo_terra", Vector2(o) * 16.0)
	if n < ArchaeologyData.BRUSHES:
		m.hud.toast("Spazzoli la roccia… (%d su %d)" % [n, ArchaeologyData.BRUSHES])
		return true
	var id := fossil_for(StrataData.at(m.world, o.x, o.y))
	var rest: int = m.character.bisaccia.add(id, 1)
	if rest > 0:
		m.drops.spawn(id, rest, Vector2(o) * 16.0)
	m.world.stations.erase(o)
	m.world_meta["scavi"].erase(key)
	m.view.refresh_around(o)
	m.objectives.bump("fossili")
	m.hud.toast("Un fossile! %s" % ItemsData.get_item(id).get("name", id))
	m.sfx.play("dono")
	return true


## Il fossile che esce in uno strato: la parte che il personaggio ha di meno (così si completano gli scheletri).
func fossil_for(st: int) -> String:
	var animals := ArchaeologyData.of_stratum(clampi(st, 1, 4))
	var best := ""
	var bn := 1 << 30
	for a in animals:
		for p in ArchaeologyData.PARTS:
			var id := ArchaeologyData.fossil_id(String(a), String(p[0]))
			var have: int = m.character.bisaccia.count(id) + int(m.character.stats.get("museo_" + id, 0)) * 2 + _rng.randi_range(0, 1)
			if have < bn:
				bn = have
				best = id
	return best
