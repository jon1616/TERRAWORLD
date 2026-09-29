class_name Festivals
extends Node
## Le feste di stagione (Roadmap 22, voce 230; dati in `FestivalsData`). Nel Giardino, il primo giorno di ogni
## stagione (`Seasons`), se la bellezza più alta raggiunta arriva a `FestivalsData.NEED`, comincia la festa: la scritta,
## il compito (un conteggio che deve salire di n entro la fine del giorno), e alla fine i premi e l'oggetto della festa
## (la prima volta; poi altri premi). Stato in `world_meta["festa"]` = {"id", "giorno", "base", "fatta"}.

var m: Node2D
var _t := 2.0


func setup(main: Node2D) -> void:
	m = main


func active() -> Dictionary:
	return m.world_meta.get("festa", {})


func _process(dt: float) -> void:
	if not m.built or m.get("beauty") == null or not m.beauty.home() or m.get("seasons") == null:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 2.0
	var day := int(m.day.day)
	var f := active()
	if not f.is_empty() and int(f["giorno"]) != day:
		m.world_meta.erase("festa")                        # il giorno è finito
		f = {}
	var sid := String(m.seasons.info().get("id", ""))
	if f.is_empty() and FestivalsData.FESTIVALS.has(sid) and _first_day() and m.beauty.best() >= FestivalsData.NEED \
			and int(m.world_meta.get("festa_ultima", -1)) != day:
		start(sid)
	elif not f.is_empty() and not bool(f.get("fatta", false)):
		check()


## Il primo giorno della stagione (le stagioni durano `SeasonsData.DAYS` giorni).
func _first_day() -> bool:
	var off := posmod(m.world.world_seed, SeasonsData.SEASONS.size() * SeasonsData.DAYS)
	return (maxi(int(m.day.day), 1) - 1 + off) % SeasonsData.DAYS == 0


func start(sid: String) -> void:
	var d: Dictionary = FestivalsData.FESTIVALS[sid]
	m.world_meta["festa"] = {"id": sid, "giorno": int(m.day.day), "base": int(m.character.stats.get(String(d["stat"]), 0)), "fatta": false}
	m.world_meta["festa_ultima"] = int(m.day.day)
	m.depth_watch.banner.show_stratum(String(d["name"]), String(d["task"]), d["color"])
	m.sfx.play("presenza")


## Quanto manca: [fatto, serve].
func progress() -> Array:
	var f := active()
	if f.is_empty():
		return [0, 0]
	var d: Dictionary = FestivalsData.FESTIVALS[String(f["id"])]
	return [mini(int(m.character.stats.get(String(d["stat"]), 0)) - int(f["base"]), int(d["n"])), int(d["n"])]


func check() -> void:
	var p := progress()
	if int(p[0]) < int(p[1]):
		return
	var f := active()
	f["fatta"] = true
	var sid := String(f["id"])
	var d: Dictionary = FestivalsData.FESTIVALS[sid]
	var names := []
	var gifts: Dictionary = (d["reward"] as Dictionary).duplicate()
	var first := int(m.character.stats.get("festa_" + sid, 0)) == 0
	if first:
		gifts[String(d["unique"])] = 1
	for it in gifts:
		var rest: int = m.character.bisaccia.add(String(it), int(gifts[it]))
		if rest > 0:
			m.drops.spawn(String(it), rest, m.player.position)
		names.append(String(ItemsData.get_item(String(it)).get("name", it)))
	m.character.stats["festa_" + sid] = int(m.character.stats.get("festa_" + sid, 0)) + 1
	m.objectives.bump("feste")
	m.sfx.play("dono")
	m.hud.toast("%s: compiuta! Ti dona: %s" % [d["name"], ", ".join(names)])
