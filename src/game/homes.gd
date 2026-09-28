class_name Homes
extends Node
## Le case degli abitanti (voce 143, dati in `HomesData`). Ogni abitante (non quelli «free») prende un letto
## (`world_meta["case"]`, abitante → origine del letto) e la stanza che lo contiene (`Rooms.scan`); ogni tanto se ne
## calcola la **felicità** (`world_meta["felicita"]`), da stanza, comfort, gusti e vicini. Felici: prezzi più bassi
## (`NpcBonds.mood_mult`) e un regalo al giorno; scontenti: prezzi più alti. `nice_house` dice a `Villagers` se c'è una
## casa bella libera (gli abitanti arrivano anche da lontano).

const EVERY := 8.0

var m: Node2D
var _t := 1.0
var gifts := 0                           # (prove)


func setup(main: Node2D) -> void:
	m = main


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = EVERY
	update(EVERY)


## Assegna i letti, calcola la felicità di tutti, distribuisce i regali (dt = secondi passati).
func update(dt := 0.0) -> Dictionary:
	var homes: Dictionary = m.world_meta.get("case", {})
	var happy: Dictionary = m.world_meta.get("felicita", {})
	var w: World = m.world
	var beds := []
	for o in w.stations:
		if StationsData.role(String(w.stations[o])) == "letto":
			beds.append(o)
	var who: Array = m.villagers.present().filter(func(n: String) -> bool: return not NpcData.NPCS[n].get("free", false))
	# i letti che non ci sono più si liberano; chi non ne ha prende il primo libero (il più vicino al suo posto)
	for nid in homes.keys():
		var h: Array = homes[nid]
		if not nid in who or not Vector2i(int(h[0]), int(h[1])) in beds:
			homes.erase(nid)
	for nid in who:
		if homes.has(nid):
			continue
		var taken := homes.values().map(func(h: Array) -> Vector2i: return Vector2i(int(h[0]), int(h[1])))
		for o in beds:
			if not o in taken:
				homes[nid] = [o.x, o.y]
				break
	# le stanze dei letti
	var room_of := {}
	var owners := {}
	for nid in homes:
		var o := Vector2i(int(homes[nid][0]), int(homes[nid][1]))
		var r: Dictionary = m.rooms.scan(o)
		room_of[nid] = r
		if not r.is_empty():
			owners[r["key"]] = int(owners.get(r["key"], 0)) + 1
	for nid in who:
		var h := _happiness(String(nid), homes, room_of, owners)
		happy[nid] = h
		NpcBonds.mood_mult[nid] = float(HomesData.PRICE[HomesData.mood(h)])
	m.world_meta["case"] = homes
	m.world_meta["felicita"] = happy
	_gifts(dt, who, happy)
	return happy


func _happiness(nid: String, homes: Dictionary, room_of: Dictionary, owners: Dictionary) -> int:
	var t: Dictionary = HomesData.TASTES.get(nid, {})
	if not homes.has(nid):
		return 10
	var r: Dictionary = room_of.get(nid, {})
	var h := HomesData.BASE_NO_ROOM
	if not r.is_empty():
		h = HomesData.BASE_ROOM + roundi(float(r["comfort"]) * HomesData.PER_COMFORT)
		if int(owners.get(r["key"], 0)) > 1:
			h -= HomesData.SHARED
		# i gusti: gli arredi e i materiali della stanza
		var forms := {}
		var mats := {}
		var rect := Rect2i(int(r["x"]), int(r["y"]), int(r["w"]), int(r["h"]))
		for o in m.world.stations:
			if rect.has_point(o):
				var sd: Dictionary = StationsData.STATIONS.get(String(m.world.stations[o]), {})
				if sd.has("arredo"):
					forms[sd["arredo"]] = true
					mats[sd["mat"]] = true
		var liked := 0
		for a in t.get("arredi", []):
			if forms.has(a):
				liked += 1
		h += mini(liked, 2) * HomesData.PER_ARREDO
		for mt in t.get("mats", []):
			if mats.has(mt):
				h += HomesData.PER_MAT
				break
	# i vicini
	var me := Vector2i(int(homes[nid][0]), int(homes[nid][1]))
	for other in homes:
		if other == nid:
			continue
		var d := Vector2(Vector2i(int(homes[other][0]), int(homes[other][1])) - me).length()
		if d > HomesData.NEAR:
			continue
		if other in t.get("friends", []):
			h += HomesData.PER_FRIEND
		if other in t.get("rivals", []):
			h -= HomesData.PER_RIVAL
	return clampi(h, 0, 100)


## Un abitante felice lascia un regalo al giorno.
func _gifts(dt: float, who: Array, happy: Dictionary) -> void:
	var t: Dictionary = m.world_meta.get("regali_case", {})
	for nid in who:
		if int(happy.get(nid, 0)) < HomesData.HAPPY:
			continue
		t[nid] = float(t.get(nid, 0.0)) + dt
		if float(t[nid]) < HomesData.GIFT_EVERY:
			continue
		t[nid] = 0.0
		# il primo dono dei suoi livelli d'affetto, o (chi non ne ha) la prima delle sue merci
		var g: Dictionary = NpcData.NPCS[nid].get("gifts", {})
		var goods: Array = NpcData.NPCS[nid].get("goods", [])
		if g.is_empty() and goods.is_empty():
			continue
		var first: Array = g[g.keys().min()] if not g.is_empty() else goods[0]
		var n := _npc(String(nid))
		m.drops.spawn(String(first[0]), maxi(1, int(first[1]) / 2), n.position if n else m.player.position)
		gifts += 1
		m.hud.toast("%s è felice della sua casa e ti ha lasciato un dono" % NpcData.NPCS[nid]["name"])
	m.world_meta["regali_case"] = t


func _npc(nid: String) -> Npc:
	for n in m.villagers.list:
		if n.id == nid:
			return n
	return null


## Un letto libero dentro una casa bella (comfort ≥ `NICE_HOUSE`)? Allora gli abitanti arrivano anche da lontano.
func nice_house() -> bool:
	var taken: Array = (m.world_meta.get("case", {}) as Dictionary).values().map(func(h: Array) -> Vector2i: return Vector2i(int(h[0]), int(h[1])))
	for e in m.rooms.list():
		if String(e["type"]) != "casa" or int(e["comfort"]) < HomesData.NICE_HOUSE:
			continue
		var rect := Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"]))
		for o in m.world.stations:
			if rect.has_point(o) and StationsData.role(String(m.world.stations[o])) == "letto" and not o in taken:
				return true
	return false


## La riga per il pannello del commercio.
func line(nid: String) -> String:
	var h: Dictionary = m.world_meta.get("felicita", {})
	if not h.has(nid) or NpcData.NPCS[nid].get("free", false):
		return ""
	var t: Dictionary = HomesData.TASTES.get(nid, {})
	var mats: Array = (t.get("mats", []) as Array).map(func(x: String) -> String: return String(FurnitureData._mat(x).get("label", x)))
	return "%s (%d) · ama: %s, %s" % [HomesData.mood(int(h[nid])).capitalize(), int(h[nid]), " e ".join(mats), ", ".join(t.get("arredi", []))]
