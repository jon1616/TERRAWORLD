class_name LostGardens
extends Node
## I Giardini perduti mentre si gioca (Roadmap 21, voce 223; dati in `LostGardensData`). Solo nei mondi nati da un Seme
## del cosmo (`world_meta["perduto"]` = {"id", "tree": [x, y], "fatte": {cura: true}, conti}). L'Albero perduto guarisce
## con le sue tre cure:
##   pesci   i pesci del lago pescati in questo mondo (`Fishing.on_catch`)
##   item    gli oggetti portati all'Albero (clic destro, dalla Bisaccia e dalle casse vicine)
##   power   una rete viva di almeno N pulsi che tocca l'Albero (`Energy.station_net`)
##   tame    una creatura di quella famiglia nella mandria
##   words   parole diventate certe in questo mondo (`Language.confirmed`)
##   boss    il Custode del Giardino: lo sveglia il clic destro sull'Albero quando le altre cure sono fatte
## Guarito: la stazione diventa «albero_<id>_vivo», i doni, `stats.perduti` e `stats.perduto_<id>`, una pagina di storia.
## Attorno all'Albero nascono le creature del Giardino (`Fauna.lost_pool`).

const FAUNA_R := 160.0                 # tessere dall'Albero in cui nascono le creature del Giardino
const FAUNA_SHARE := 0.6

var m: Node2D
var id := ""
var _t := 0.0


func setup(main: Node2D) -> void:
	m = main
	var e: Variant = m.world_meta.get("perduto", null)
	if not e is Dictionary:
		return
	id = String(e.get("id", ""))
	if not LostGardensData.GARDENS.has(id):
		id = ""
		return
	if not e.has("tree"):
		var n: Dictionary = m.world.gen_notes.get("perduto", {})
		var o: Vector2i = n.get("tree", Vector2i(-1, -1))
		e["tree"] = [o.x, o.y]
	if not e.has("fatte"):
		e["fatte"] = {}
	var pool := []
	for cid in CreaturesData.CREATURES:
		var cd: Dictionary = CreaturesData.CREATURES[cid]
		if String(cd.get("perduto", "")) == id:
			pool.append([cid, 10])
	m.fauna.lost_pool = pool
	m.fauna.lost_center = Vector2(tree()) * 16.0 + Vector2(72, 200)
	m.fauna.lost_r = FAUNA_R * 16.0
	m.fauna.killed.connect(_on_kill)
	if m.get("fishing") != null:
		m.fishing.on_catch = _on_fish
	if m.get("language") != null:
		m.language.confirmed.connect(func(words: Array, _how: String) -> void: _count("parole", words.size()))


func active() -> bool:
	return id != "" and m.world_meta.get("perduto") is Dictionary


func meta() -> Dictionary:
	return m.world_meta["perduto"]


func tree() -> Vector2i:
	var t: Array = meta().get("tree", [-1, -1])
	return Vector2i(int(t[0]), int(t[1]))


func healed() -> bool:
	return active() and bool(meta().get("guarito", false))


func cures() -> Array:
	return LostGardensData.GARDENS[id]["cures"]


func done(cure: String) -> bool:
	return bool((meta()["fatte"] as Dictionary).get(cure, false))


## [quanto, quanto serve] di una cura.
func progress(cu: Array) -> Array:
	var how: Dictionary = cu[3]
	if done(String(cu[0])):
		return [1, 1]
	if how.has("fish"):
		return [mini(int(meta().get("pesci_" + String(how["fish"][0]), 0)), int(how["fish"][1])), int(how["fish"][1])]
	if how.has("item"):
		return [mini(int(meta().get("dati_" + String(how["item"][0]), 0)), int(how["item"][1])), int(how["item"][1])]
	if how.has("words"):
		return [mini(int(meta().get("parole", 0)), int(how["words"])), int(how["words"])]
	return [0, 1]


func _count(key: String, n: int) -> void:
	if not active():
		return
	meta()[key] = int(meta().get(key, 0)) + n
	_check()


func _on_fish(fish: String) -> void:
	_count("pesci_" + fish, 1)


func _on_kill(c: Creature) -> void:
	if String(CreaturesData.get_data(c.id).get("lost_boss", "")) == id:
		for cu in cures():
			if (cu[3] as Dictionary).has("boss"):
				_mark(String(cu[0]))
		meta().erase("sveglio")


func _process(dt: float) -> void:
	if not active() or healed():
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	_check()


## Controlla le cure che si compiono da sole (pesci, parole, rete, mandria).
func _check() -> void:
	if healed():
		return
	for cu in cures():
		var cid := String(cu[0])
		if done(cid):
			continue
		var how: Dictionary = cu[3]
		var p := progress(cu)
		if (how.has("fish") or how.has("words")) and int(p[0]) >= int(p[1]):
			_mark(cid)
		elif how.has("power") and m.get("energy") != null and _powered(int(how["power"])):
			_mark(cid)
		elif how.has("tame") and _has_tame(String(how["tame"])):
			_mark(cid)


func _powered(need: int) -> bool:
	var ni: int = m.energy.station_net.get(tree(), -1)
	if ni < 0 or ni >= m.energy.nets.size():
		return false
	var nt: Dictionary = m.energy.nets[ni]
	return bool(nt["flowing"]) and float(nt["prod"]) >= need


func _has_tame(fam: String) -> bool:
	for rec in m.character.mandria:
		if FamiliesData.family_of(CreaturesData.base_of(String(rec["specie"]))) == fam:
			return true
	return false


func _mark(cid: String) -> void:
	if done(cid):
		return
	meta()["fatte"][cid] = true
	for cu in cures():
		if String(cu[0]) == cid:
			m.hud.toast("%s: «%s» fatto" % [LostGardensData.name_of(id), cu[1]])
	m.sfx.play("dono")
	var all := true
	for cu in cures():
		all = all and done(String(cu[0]))
	if all:
		_heal()


func _heal() -> void:
	meta()["guarito"] = true
	var o := tree()
	m.world.stations[o] = "albero_%s_vivo" % id
	m.world.stations_changed()
	m.view.remove_station(o)
	m.view.add_station(o)
	m.light.dirty = true
	var gifts: Dictionary = LostGardensData.GARDENS[id]["gifts"]
	var names := []
	for it in gifts.get("items", {}):
		var n := int(gifts["items"][it])
		var rest: int = m.character.bisaccia.add(String(it), n)
		if rest > 0:
			m.drops.spawn(String(it), rest, m.player.position)
		names.append(String(ItemsData.get_item(String(it)).get("name", it)))
	m.character.stats["perduto_" + id] = 1
	m.objectives.bump("perduti")
	Fx.puff(m.fx, Vector2(o) * 16.0 + Vector2(72, 120), Color(1.4, 1.8, 1.5))
	m.sfx.play("portale")
	m.hud.toast("%s è guarito. Ti dona: %s" % [String(StationsData.STATIONS["albero_" + id]["name"]), ", ".join(names)])
	if LoreData.PAGES.has("perduto_" + id):
		m.guardian.lore.show_page("perduto_" + id)


## Clic destro sull'Albero perduto: porta gli oggetti delle cure e, se resta solo il Custode, lo sveglia.
func touch(o: Vector2i) -> bool:
	if not active() or o != tree():
		return false
	if healed():
		m.hud.toast("L'Albero è guarito: il Giardino respira di nuovo")
		return true
	var given := 0
	for cu in cures():
		var how: Dictionary = cu[3]
		if not how.has("item") or done(String(cu[0])):
			continue
		var item := String(how["item"][0])
		var p := progress(cu)
		var k := mini(int(p[1]) - int(p[0]), Crafting.have(m.character.bisaccia, item))
		if k > 0 and Crafting.take(m.character.bisaccia, item, k):
			meta()["dati_" + item] = int(p[0]) + k
			given += k
			if int(p[0]) + k >= int(p[1]):
				_mark(String(cu[0]))
	if given > 0:
		m.sfx.play("dono")
		m.hud.toast("Hai dato all'Albero %d oggetti" % given)
		return true
	var missing := []
	for cu in cures():
		if not done(String(cu[0])) and not (cu[3] as Dictionary).has("boss"):
			missing.append(String(cu[1]))
	if missing.is_empty():
		_wake_boss()
	else:
		m.hud.toast("L'Albero chiede ancora: %s" % "; ".join(missing))
	return true


func _wake_boss() -> void:
	for c in m.fauna.list:
		if is_instance_valid(c) and String(CreaturesData.get_data(c.id).get("lost_boss", "")) == id:
			m.hud.toast("Il Custode del Giardino è già sveglio")
			return
	var boss := ""
	for cid in CreaturesData.CREATURES:
		if String(CreaturesData.CREATURES[cid].get("lost_boss", "")) == id:
			boss = String(cid)
	if boss == "":
		return
	var c: Creature = m.fauna.add(boss, Vector2(tree()) * 16.0 + Vector2(72, 40))
	var v := int(m.world_meta.get("vigore", 1))
	c.strengthen(Portal.boss_mult(v), Portal.vigor_dmg(v) * DangerData.DAMAGE)
	meta()["sveglio"] = true
	m.hud.toast("Dall'Albero esce %s!" % String(CreaturesData.CREATURES[boss]["name"]))
	m.sfx.play("presenza")


## La scheda dell'Albero perduto (per `StationTip`).
func card() -> TipCard:
	var c := TipCard.new()
	var g: Dictionary = LostGardensData.GARDENS[id]
	c.title(String(StationsData.STATIONS["albero_" + id]["name"]), g["color"])
	c.sub(String(g["desc"]))
	if healed():
		c.line("Guarito: il Giardino respira di nuovo.", TipCard.GOOD)
		return c
	for cu in cures():
		var p := progress(cu)
		var ok := done(String(cu[0]))
		c.bar("%s  %s" % [cu[1], "✓" if ok else "%d/%d" % [int(p[0]), int(p[1])] if int(p[1]) > 1 else ""],
			1.0 if ok else float(p[0]) / maxf(float(p[1]), 1.0), TipCard.GOOD if ok else Color("#8ef0d8"))
		if not ok:
			c.line(String(cu[2]), Color("#7a9a94"))
	c.hint("Clic destro: porta ciò che chiede (e, alla fine, sveglia il Custode)")
	return c
