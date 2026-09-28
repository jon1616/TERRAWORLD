class_name Rooms
extends Node
## Le stanze (voce 142, dati e regole in `RoomsData`). Ogni secondo, se il Germogliato è in un posto chiuso, lo si
## riconosce (riempimento dalle sue celle: `scan`), se ne trova il **tipo** dagli arredi e il **comfort**, e lo si
## ricorda in `world_meta["stanze"]` (così serre, stalle, acquari, sale dei trofei e osservatori lavorano anche quando
## sei altrove). Una stanza ricordata che non c'è più si dimentica quando ci ritorni.
## I bonus: casa (`Vitals.room_regen`), laboratorio (`Crafting.room_luck`), cantina (`PlayerActions.room_boon`) mentre
## ci sei dentro; serra (`grow_at`), stalla (`Pens.room_mult`), acquario (`fish_luck`), trofei (`trophy_mult`),
## biblioteca (`Language.extra_words`), osservatorio (`Events.room_mult`) in tutto il mondo.

const S := 16

var m: Node2D
var current := {}                        # la stanza dove sei (vuota se non sei in una stanza)
var _t := 0.0
var _trophy := {}                        # famiglia → moltiplicatore del danno
var _fish := 0.0
var scans := 0                           # (prove)


func setup(main: Node2D) -> void:
	m = main
	if not m.world_meta.has("stanze"):
		m.world_meta["stanze"] = []
	_apply_world()


func list() -> Array:
	return m.world_meta.get("stanze", [])


func _process(dt: float) -> void:
	if m == null or not m.built:
		return
	_t -= dt
	if _t > 0.0:
		return
	_t = 1.0
	refresh()


## Riconosce la stanza dove sei adesso (e aggiorna quelle ricordate).
func refresh() -> Dictionary:
	var pc: Vector2i = m.player_cell()
	var r := scan(pc)
	var rooms := list()
	# le stanze ricordate che contengono questa cella: se ora non c'è una stanza (o è un'altra) si dimenticano
	for i in range(rooms.size() - 1, -1, -1):
		var e: Dictionary = rooms[i]
		if Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"])).has_point(pc) and (r.is_empty() or String(e["key"]) != String(r["key"])):
			rooms.remove_at(i)
	var was := current
	current = r
	if not r.is_empty():
		var found := false
		for e in rooms:
			if String(e["key"]) == String(r["key"]):
				if e.get("ragni", false):
					m.hud.toast("Ragnatele: la stanza è rimasta sola e al buio (una luce le tiene lontane)")   # voce 146
				e.merge(_save_form(r), true)
				e["ragni"] = false
				found = true
		if not found:
			rooms.append(_save_form(r))
		if was.is_empty() or String(was.get("key", "")) != String(r["key"]) or String(was.get("type", "")) != String(r["type"]):
			var td: Dictionary = RoomsData.TYPES[r["type"]]
			m.hud.toast("%s %s · comfort %d" % [td["name"], RoomsData.level(int(r["comfort"])), int(r["comfort"])])
			if String(r["type"]) != "stanza" and not m.character.stats.has("stanza_" + String(r["type"])):
				m.character.stats["stanza_" + String(r["type"])] = 1
				m.objectives.bump("stanze")
	m.world_meta["stanze"] = rooms
	_apply_here()
	_apply_world()
	return r


func _save_form(r: Dictionary) -> Dictionary:
	return {"key": r["key"], "x": r["x"], "y": r["y"], "w": r["w"], "h": r["h"], "type": r["type"], "comfort": r["comfort"],
		"fams": r.get("fams", []), "lights": r.get("lights", 0)}


## Il riempimento: le celle libere raggiungibili da `start`, chiuse da blocchi, ognuna con una parete dietro; una porta
## nel contorno. Restituisce {} se non è una stanza.
func scan(start: Vector2i) -> Dictionary:
	scans += 1
	var w: World = m.world
	if not w.inside(start.x, start.y) or w.solid(start.x, start.y) or w.wall(start.x, start.y) == 0:
		return {}
	var open_doors := {}                         # le celle delle porte aperte (una volta sola, non a ogni cella)
	for o in w.stations:
		if String(w.stations[o]) == "porta_aperta":
			for dy in int(StationsData.STATIONS["porta_aperta"]["size"][1]):
				open_doors[o + Vector2i(0, dy)] = true
	var seen := {start: true}
	var n_in := 1
	var todo := [start]
	var door := false
	var edge_beauty := 0
	var edge_n := 0
	var edge_iso := 0                            # voce 144: quanto isolano i blocchi del contorno (la roccia 1)
	var edge_all := 0
	var lo := start
	var hi := start
	while not todo.is_empty():
		var c: Vector2i = todo.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = c + d
			if seen.has(q):
				continue
			if not w.inside(q.x, q.y):
				return {}
			if w.solid(q.x, q.y):
				var t := w.tile(q.x, q.y)
				if t == TileDefs.PORTA:
					door = true
				var k := w.build_at(q.x, q.y)
				edge_all += 1
				if k > 0:
					edge_beauty += int(BuildData.material_of(k).get("bello", 0))
					edge_iso += int(BuildData.material_of(k).get("iso", 1))
					edge_n += 1
				else:
					edge_iso += 1
				seen[q] = false                      # visto (contorno): non si conta due volte
				continue
			if open_doors.has(q):
				door = true                          # una porta aperta chiude comunque la stanza
				continue
			if w.wall(q.x, q.y) == 0:
				return {}                            # un buco nella parete: non è chiusa
			seen[q] = true
			n_in += 1
			todo.append(q)
			lo = Vector2i(mini(lo.x, q.x), mini(lo.y, q.y))
			hi = Vector2i(maxi(hi.x, q.x), maxi(hi.y, q.y))
			if n_in > RoomsData.MAX_CELLS or hi.x - lo.x > RoomsData.MAX_SIDE or hi.y - lo.y > RoomsData.MAX_SIDE:
				return {}
	var inside := {}
	for c in seen:
		if seen[c]:
			inside[c] = true
	if not door or inside.size() < RoomsData.MIN_CELLS:
		return {}
	var r := {"x": lo.x, "y": lo.y, "w": hi.x - lo.x + 1, "h": hi.y - lo.y + 1, "cells": inside.size(),
		"key": "%d,%d,%d" % [lo.x, lo.y, inside.size()], "iso": float(edge_iso) / maxf(edge_all, 1)}
	_contents(r, inside, edge_beauty, edge_n)
	return r


## Che cosa c'è dentro: il tipo e il comfort.
func _contents(r: Dictionary, cells: Dictionary, edge_beauty: int, edge_n: int) -> void:
	var w: World = m.world
	var roles := {}
	var ids := []
	var beauty := 0
	var lights := 0
	var containers := 0
	var food := 0
	var fish := {}
	var trophies := {}
	for o in w.stations:
		if not cells.has(o):
			continue
		var sid := String(w.stations[o])
		var sd: Dictionary = StationsData.STATIONS.get(sid, {})
		var role := StationsData.role(sid)
		roles[role] = int(roles.get(role, 0)) + 1
		ids.append(sid)
		beauty += int(sd.get("bello", 1 if role in ["tavolo", "sedia", "letto", "lampada"] else 0))
		if sd.get("light", false):
			lights += 1
		if sd.has("slots"):
			containers += 1
			var b: Bisaccia = w.chest_at(o)
			var has_food := false
			for s in b.slots:
				if s.is_empty():
					continue
				var it := ItemsData.get_item(String(s["id"]))
				match String(it.get("kind", "")):
					"pesce":
						fish[s["id"]] = true
					"trofeo":
						trophies[s["id"]] = true
					"consumabile":
						has_food = true
			if has_food:
				food += 1
	var crops := 0
	var liquid := 0
	for c in cells:
		if w.crops.has(c):
			crops += 1
		if w.liq(c.x, c.y) > 0:
			liquid += 1
	r["fire"] = roles.has("camino")                  # voce 144: un camino scalda la stanza
	var benches := 0
	for b in RoomsData.BENCHES:
		benches += int(roles.get(b, 0))
	var above: bool = r["y"] + r["h"] <= w.surface[clampi(int(r["x"]), 0, w.w - 1)] + 2
	var ok := {
		"stalla": roles.has("recinto") or roles.has("incubatrice"),
		"laboratorio": benches >= 2,
		"serra": crops >= 3 or int(roles.get("vaso", 0)) >= 3,
		"acquario": liquid >= 6 and fish.size() >= 2,
		"trofei": trophies.size() >= 3,
		"biblioteca": int(roles.get("scaffale", 0)) >= 2 and roles.has("tavolo") and lights >= 1,
		"osservatorio": int(roles.get("finestra", 0)) >= 2 and roles.has("tavolo") and above,
		"cantina": food >= RoomsData.CONTAINERS_MIN,
		"casa": roles.has("letto"),
	}
	r["type"] = "stanza"
	for t in RoomsData.ORDER:
		if ok[t]:
			r["type"] = t
			break
	if r["type"] == "trofei":
		var fams := {}
		for cid in TrophyItemsData.TROPHY_OF:
			if trophies.has(TrophyItemsData.TROPHY_OF[cid]):
				var f := FamiliesData.family_of(String(cid))
				if f != "":
					fams[f] = true
		r["fams"] = fams.keys()
	r["lights"] = lights                             # voce 146: al buio arrivano i ragni
	var comfort := beauty * 2 + mini(lights * RoomsData.PER_LIGHT, RoomsData.LIGHT_MAX)
	comfort += FurnitureData.series_of(ids).size() * RoomsData.PER_SERIES
	if edge_n > 0:
		comfort += roundi(float(edge_beauty) / edge_n * RoomsData.WALL_BEAUTY)
	if int(r["cells"]) < RoomsData.CRAMPED:
		comfort -= 10
	r["comfort"] = clampi(comfort, 0, 100)


## I bonus di dove sei.
func _apply_here() -> void:
	var t := String(current.get("type", ""))
	var f := 1.0 + float(current.get("comfort", 0)) / 100.0
	m.vitals.room_regen = 1.0 + RoomsData.REGEN * f if t == "casa" else 1.0
	Crafting.room_luck = RoomsData.QUALITY * f if t == "laboratorio" else 0.0
	PlayerActions.room_boon = 1.0 + RoomsData.BOON * f if t == "cantina" else 1.0


## I bonus delle stanze ricordate, in tutto il mondo.
func _apply_world() -> void:
	var herd := 1.0
	var events := 1.0
	var words := 0
	_fish = 0.0
	_trophy = {}
	for e in list():
		var f := 1.0 + float(e.get("comfort", 0)) / 100.0
		match String(e["type"]):
			"stalla":
				herd = maxf(herd, 1.0 + RoomsData.HERD * f)
			"osservatorio":
				events = maxf(events, 1.0 + RoomsData.EVENTS * f)
			"biblioteca":
				words = 1
			"acquario":
				_fish = maxf(_fish, RoomsData.FISH * f)
			"trofei":
				for fam in e.get("fams", []):
					_trophy[fam] = maxf(float(_trophy.get(fam, 1.0)), 1.0 + RoomsData.TROPHY * f)
	Pens.room_mult = herd
	m.events.room_mult = events
	m.language.extra_words = words


## La crescita delle colture in una cella: più in fretta dentro una serra.
func grow_at(c: Vector2i) -> float:
	for e in list():
		if String(e["type"]) == "serra" and Rect2i(int(e["x"]), int(e["y"]), int(e["w"]), int(e["h"])).has_point(c):
			return 1.0 + RoomsData.GROW * (1.0 + float(e.get("comfort", 0)) / 100.0)
	return 1.0


func fish_luck() -> float:
	return _fish


func trophy_mult(family: String) -> float:
	return float(_trophy.get(family, 1.0))


## Voce 144: il riparo di dove sei contro un rigore («freddo», «calore», «sete», «polvere»): moltiplica quanto sale.
## Una stanza ferma metà del rigore, i materiali che isolano (iso 0-3) ancora di più; un camino ferma il freddo.
func shelter(kind: String) -> float:
	if current.is_empty():
		return 1.0
	if kind == "freddo" and bool(current.get("fire", false)):
		return 0.0
	return clampf(RoomsData.SHELTER * (1.0 - RoomsData.PER_ISO * float(current.get("iso", 1.0))), 0.0, 1.0)

