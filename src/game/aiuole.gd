class_name Aiuole
extends Node
## Le Aiuole e la rete dei mondi (voce 45). Il mondo di partenza (quello creato dal menu, senza "ritorno") è il
## **Giardino**: il centro della rete. I Semi di mondo si piantano solo nelle **Aiuole** (stazione 3×4, solo nel
## Giardino, al più `max_aiuole()`): l'Aiuola diventa un portale, e ogni mondo nato da lì porta in `world_meta["casa"]`
## l'id del Giardino. Un mondo si può **chiudere** dal Semenzaio (`close`): il portale torna Aiuola e in mano resta il
## suo **Seme dormiente** (lo stesso genoma più "mondo" = id), che ripiantato riapre lo stesso mondo.
## I portali piantati a terra prima della voce 45 continuano a funzionare.

const BASE_MAX := 3                    # Aiuole all'inizio; l'Albero-Madre (Roadmap 8) ne darà di più

var m: Node2D
var bonus := 0                         # Aiuole in più (in futuro: stadi dell'Albero-Madre)


func setup(main: Node2D) -> void:
	m = main
	m.actions.station_check = _can_place
	# il mondo nato da un portale ricorda il suo Giardino
	if not is_home() and not m.world_meta.has("casa"):
		m.world_meta["casa"] = home_of(m.world_id, _metas())


## Siamo nel Giardino?
func is_home() -> bool:
	# i mondi nati da un Seme ricevono sempre "casa" dal portale (voce 62: prima si guardava "ritorno", che però non
	# arrivava mai nei dati del mondo, e le Aiuole si potevano piazzare ovunque)
	return not m.world_meta.has("casa")


func max_aiuole() -> int:
	return BASE_MAX + bonus


## Quante Aiuole ci sono nel Giardino (anche quelle diventate portale).
func count() -> int:
	var n := 0
	var ps: Dictionary = m.world_meta.get("portali", {})
	for o in m.world.stations:
		var id := String(m.world.stations[o])
		if id == "aiuola" or (id == "portale" and bool((ps.get("%d,%d" % [o.x, o.y], {}) as Dictionary).get("aiuola", false))):
			n += 1
	return n


func _can_place(sid: String) -> String:
	if sid != "aiuola":
		return ""
	if not is_home():
		return "Le Aiuole crescono solo nel Giardino, il tuo mondo di partenza"
	if count() >= max_aiuole():
		return "Il Giardino ha già tutte le sue Aiuole (%d)" % max_aiuole()
	return ""


## L'Aiuola che occupa la cella c, o (-1, -1).
func aiuola_at(c: Vector2i) -> Vector2i:
	var st: Dictionary = m.world.station_at(c)
	if not st.is_empty() and st["id"] == "aiuola":
		return st["origin"]
	return Vector2i(-1, -1)


## Tutti i mondi salvati: id → dati leggibili.
static func _metas() -> Dictionary:
	var out := {}
	for meta in WorldSave.list():
		out[String(meta["id"])] = meta
	return out


## Il Giardino da cui discende un mondo (seguendo i portali di ritorno, per i mondi di prima della voce 45).
static func home_of(id: String, metas: Dictionary) -> String:
	var seen := {}
	while metas.has(id) and not seen.has(id):
		seen[id] = true
		var meta: Dictionary = metas[id]
		if meta.has("casa"):
			return String(meta["casa"])
		if not meta.has("ritorno"):
			return id
		id = String(meta["ritorno"])
	return id


## L'id del Giardino di questo mondo.
func home_id() -> String:
	return m.world_id if is_home() else String(m.world_meta.get("casa", m.world_id))


## I mondi della rete di questo Giardino (il Giardino per primo), con i loro dati leggibili. Il mondo in cui si è
## ha i dati di adesso, non quelli dell'ultimo salvataggio.
func network() -> Array[Dictionary]:
	var metas := _metas()
	var home := home_id()
	var out: Array[Dictionary] = []
	for id in metas:
		if id == m.world_id:
			continue
		if home_of(String(id), metas) == home:
			out.append(metas[id])
	var here: Dictionary = m.world_meta.duplicate()
	here["id"] = m.world_id
	here["esplorato"] = explored_percent()
	out.append(here)
	out.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var ha := String(a["id"]) == home
		var hb := String(b["id"]) == home
		if ha != hb:
			return ha
		return int(a.get("vigore", 1)) < int(b.get("vigore", 1)))
	return out


func explored_percent() -> int:
	var ex: PackedByteArray = m.world.explored
	return roundi(100.0 * ex.count(1) / maxi(ex.size(), 1))


## Il portale di un'Aiuola in questo Giardino che porta al mondo id, o (-1, -1).
func portal_to(id: String) -> Vector2i:
	var ps: Dictionary = m.world_meta.get("portali", {})
	for k in ps:
		var e: Dictionary = ps[k]
		if String(e.get("mondo", "")) == id and bool(e.get("aiuola", false)):
			var p := String(k).split(",")
			return Vector2i(int(p[0]), int(p[1]))
	return Vector2i(-1, -1)


## Chiude il mondo dietro il portale di un'Aiuola: il portale torna Aiuola, il Seme dormiente va nella Bisaccia
## (o a terra, se non c'è posto). Il mondo resta salvato.
func close(o: Vector2i) -> bool:
	var key := "%d,%d" % [o.x, o.y]
	var ps: Dictionary = m.world_meta.get("portali", {})
	var e: Dictionary = ps.get(key, {})
	if e.is_empty() or not bool(e.get("aiuola", false)):
		return false
	var g := {"geni": e.get("geni", []), "vigore": int(e.get("vigore", 0))}
	if String(e.get("mondo", "")) != "":
		g["mondo"] = String(e["mondo"])
		g["nome"] = String(WorldSave.read_meta(String(e["mondo"])).get("nome", ""))
	ps.erase(key)
	m.world.stations[o] = "aiuola"
	m.view.remove_station(o)
	m.view.add_station(o)
	m.light.dirty = true
	var seed_slot := {"id": Genome.item_of(g), "n": 1, "dati": g}
	if m.character.bisaccia.add_stack(seed_slot) > 0:
		m.drops.spawn(seed_slot["id"], 1, m.player.position, g)
	m.hud.toast("Il portale si richiude: il Seme dormiente torna a te")
	m.sfx.play("portale", Vector2(o) * 16.0)
	return true
