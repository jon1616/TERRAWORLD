class_name TestsSecretRooms
extends RefCounted
## Prove dei segreti della voce 96: nel mondo di prova ci sono stanze murate, passaggi, tesori e nidi nascosti; la
## parete finta è «ardesia» per la scheda e la mappa e crolla quando ci spingi contro; dietro c'è la stanza (segreto
## trovato); la Mappa del tesoro è in uno scrigno e segna il tesoro sulla mappa; nel nido nascosto si sveglia una
## creatura rara. Foto 168_stanza_murata.

var kit: TestKit
var m: Node2D


func _init(tk: TestKit) -> void:
	kit = tk
	m = tk.m


func run() -> void:
	var res := {}
	var w: World = m.world
	var se: Secrets = m.secrets
	var kinds := {}
	for s in se.list:
		kinds[s["k"]] = int(kinds.get(s["k"], 0)) + 1
	res["tipi"] = kinds.has("stanza_murata") and kinds.has("passaggio") and kinds.has("tesoro_sepolto") and kinds.has("nido_nascosto")
	res["finta_ardesia"] = TileDefs.NAMES[TileDefs.FINTA] == TileDefs.NAMES[TileDefs.STONE] \
		and TileDefs.MAP_COLOR[TileDefs.FINTA] == TileDefs.MAP_COLOR[TileDefs.STONE]
	print("segreti nel mondo di prova: %s" % kinds)
	# una stanza murata: la parete finta accanto, ci si spinge contro
	var room: Dictionary = {}
	for s in se.list:
		if String(s["k"]) == "stanza_murata" and not s.get("f", false):
			room = s
			break
	if room.is_empty():
		print("ATTENZIONE: nessuna stanza murata nel mondo di prova")
	else:
		var r := Secrets.rect_of(room)
		var fake := Vector2i(-1, -1)
		for y in range(r.position.y - 1, r.end.y + 1):
			for x in range(r.position.x - 6, r.end.x + 6):
				if w.inside(x, y) and w.tile(x, y) == TileDefs.FINTA:
					fake = Vector2i(x, y)
		res["parete_c_e"] = fake.x >= 0
		if fake.x >= 0:
			# accanto alla parete, dalla parte della grotta, spingendo verso la stanza
			var side := -1 if fake.x < r.position.x else 1
			var stand := Vector2i(fake.x - 1, fake.y) if side < 0 else Vector2i(fake.x + 1, fake.y)
			while w.inside(stand.x, stand.y) and w.tile(stand.x, stand.y) == TileDefs.FINTA:
				stand.x += -1 if side < 0 else 1
			m.snap_to(stand)
			await kit.seconds(0.6)
			res["crolla"] = w.tile(fake.x, fake.y) == TileDefs.AIR
			m.snap_to(r.get_center())
			m.boons.add("bagliore", 3.0)
			await kit.seconds(0.6)
			res["stanza_trovata"] = room.get("f", false)
			await kit.save("168_stanza_murata")
	# la mappa del tesoro
	var map_at := Vector2i(-1, -1)
	var dati := {}
	for o in w.chests:
		var ch: Bisaccia = w.chests[o]
		for i in ch.slots.size():
			if String(ch.slots[i].get("id", "")) == "mappa_tesoro":
				map_at = o
				dati = ch.data_at(i)
	res["mappa_c_e"] = map_at.x >= 0 and dati.has("x")
	if map_at.x >= 0:
		var b: Bisaccia = m.character.bisaccia
		kit.make_room()
		b.add_stack({"id": "mappa_tesoro", "n": 1, "dati": dati})
		kit.hold("mappa_tesoro")
		var marks0 := (m.world_meta.get("segni", []) as Array).size()
		res["mappa_segna"] = se.use_treasure_map() and (m.world_meta.get("segni", []) as Array).size() > marks0
		var treasure_ok := false
		for s in se.list:
			if String(s["k"]) == "tesoro_sepolto" and Secrets.rect_of(s).grow(2).has_point(Vector2i(int(dati["x"]), int(dati["y"]))):
				treasure_ok = true
		res["mappa_giusta"] = treasure_ok
	# il nido nascosto
	for s in se.list:
		if String(s["k"]) == "nido_nascosto" and not s.get("f", false):
			var n0: int = m.fauna.list.size()
			m.snap_to(Secrets.rect_of(s).get_center())
			await kit.seconds(0.6)
			var rare := false
			for cr in m.fauna.list:
				if cr.ancient != null:
					rare = true
			res["nido"] = s.get("f", false) and m.fauna.list.size() > n0 and rare
			m.fauna.clear()
			break
	m.snap_to(w.spawn)
	var bad := res.keys().filter(func(k: String) -> bool: return not res[k])
	print("stanze e tesori: %s; non vanno: %s" % [res, bad])
	if not bad.is_empty():
		print("ATTENZIONE: i segreti della voce 96 non funzionano come dovrebbero")
