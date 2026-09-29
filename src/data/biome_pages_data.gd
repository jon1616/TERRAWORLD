class_name BiomePagesData
extends RefCounted
## Le pagine dei biomi dell'Atlante (Roadmap 23, voce 236): una pagina per ogni bioma di superficie, del sottosuolo e
## del cielo, costruita **dai dati** (nessuna riga scritta a mano): le creature che ci nascono (le `MAX_CREATURES` più
## comuni), i pesci che ci vivono (al più `MAX_FISH`) e la visita. Chi è già nell'Erbario è segnato; la pagina completa
## dà `REWARD` e il conteggio «pagine_biomi». Le regole (visite, premi) in `BiomePages`.
##   pagina: {"id": "sup_<bioma>" | "sot_<bioma>" | "cie_<bioma>", "kind", "biome", "name", "where", "creature", "pesci"}

const MAX_CREATURES := 8
const MAX_FISH := 4
const REWARD := {"polvere_iridata": 2, "linfa_antica": 1}
const KINDS := {"sup": "In superficie", "sot": "Nel sottosuolo", "cie": "Nel cielo"}

static var _pages: Array = []


static func pages() -> Array:
	if _pages.is_empty():
		for b in BiomesData.BIOMES:
			_add("sup", b)
		for b in BiomesData.UNDER:
			_add("sot", b)
		for b in BiomesData.SKY:
			_add("cie", b)
	return _pages


static func page(id: String) -> Dictionary:
	for p in pages():
		if String(p["id"]) == id:
			return p
	return {}


static func _add(kind: String, b: Dictionary) -> void:
	var bid := String(b["id"])
	var crs := []
	for cid in CreaturesData.CREATURES:
		var c: Dictionary = CreaturesData.CREATURES[cid]
		if c.get("boss", false) or c.has("lord") or c.has("perduto") or c.has("great") or c.has("season"):
			continue
		if _lives(kind, bid, c) and _weight(kind, c) > 0:
			crs.append([String(cid), _weight(kind, c)])
	crs.sort_custom(func(a: Array, z: Array) -> bool: return int(a[1]) > int(z[1]) or (int(a[1]) == int(z[1]) and String(a[0]) < String(z[0])))
	var cr_ids := []
	for e in crs.slice(0, MAX_CREATURES):
		cr_ids.append(String(e[0]))
	var fish := []
	var all_fish := FishData.all()
	for fid in all_fish:
		var f: Dictionary = all_fish[fid]
		if f.has("perduto") or f.has("gene"):
			continue
		var ok := false
		match kind:
			"sup": ok = bid in (f.get("biomes", []) as Array) and 0 in (f.get("strata", [0]) as Array)
			"cie": ok = bid in (f.get("sky", []) as Array)
			"sot": ok = bid in (f.get("under", []) as Array)
		if ok:
			fish.append(String(fid))
	fish.sort()
	if cr_ids.is_empty() and fish.is_empty():
		return
	_pages.append({"id": kind.substr(0, 3) + "_" + bid, "kind": kind, "biome": bid, "name": String(b.get("name", bid)),
		"where": KINDS[kind], "creature": cr_ids, "pesci": fish.slice(0, MAX_FISH)})


static func _lives(kind: String, bid: String, c: Dictionary) -> bool:
	match kind:
		"sup":
			return bid in (c.get("biomes", []) as Array) and 0 in (c.get("strata", []) as Array)
		"sot":
			return String(c.get("under", "")) == bid
		"cie":
			return str(c.get("sky", "")) == bid
	return false


static func _weight(kind: String, c: Dictionary) -> int:
	match kind:
		"sot":
			return int(c.get("uw", 1))
		"cie":
			return int(c.get("sw", c.get("weight", 1)))
	return int(c.get("weight", 0))


## Dove cercare una creatura, a grandi linee (per la pagina): strati, notte, tempo.
static func hint_of(cid: String) -> String:
	var c: Dictionary = CreaturesData.CREATURES.get(cid, {})
	var parts := []
	var names := []
	for s in c.get("strata", []):
		if int(s) < StrataData.STRATA.size():
			names.append(String(StrataData.STRATA[int(s)]["name"]))
	if not names.is_empty():
		parts.append(", ".join(names))
	if c.get("night", false):
		parts.append("di notte")
	if c.has("weather"):
		parts.append("con il tempo «%s»" % ", ".join(c["weather"]))
	return "; ".join(parts)
