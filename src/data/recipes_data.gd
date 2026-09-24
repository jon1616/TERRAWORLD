class_name RecipesData
extends RefCounted
## Ricette di fabbricazione: cosa si ottiene (out, qty), con cosa (in: {oggetto: quantità}) e dove (station: id di
## `StationsData`, "" = a mano, ovunque). Le ricette delle famiglie di metallo sono generate in `all()`.

const RECIPES := [
	{"out": "banco_lavoro", "qty": 1, "in": {"legno": 10}, "station": ""},
	{"out": "torcia", "qty": 3, "in": {"legno": 1, "gel": 1}, "station": ""},
	{"out": "piattaforma", "qty": 2, "in": {"legno": 1}, "station": "banco_lavoro"},
	{"out": "spada_legno", "qty": 1, "in": {"legno": 7}, "station": "banco_lavoro"},
	{"out": "arco_legno", "qty": 1, "in": {"legno": 10}, "station": "banco_lavoro"},
	{"out": "freccia", "qty": 25, "in": {"legno": 1, "ardesia": 1}, "station": "banco_lavoro"},
	{"out": "fornace", "qty": 1, "in": {"ardesia": 20, "legno": 4, "torcia": 3}, "station": "banco_lavoro"},
	{"out": "lingotto_rame", "qty": 1, "in": {"minerale_rame": 3}, "station": "fornace"},
	{"out": "lingotto_ferro", "qty": 1, "in": {"minerale_ferro": 3}, "station": "fornace"},
	{"out": "lingotto_oro", "qty": 1, "in": {"minerale_oro": 4}, "station": "fornace"},
	{"out": "incudine", "qty": 1, "in": {"lingotto_ferro": 5}, "station": "banco_lavoro"},
	{"out": "pozione_cura", "qty": 1, "in": {"gel": 2, "fungo": 1}, "station": "banco_lavoro"},
]

static var _all: Array = []


static func all() -> Array:
	if not _all.is_empty():
		return _all
	var out := RECIPES.duplicate(true)
	for m in ItemsData.METALS:
		for g in ItemsData.GEAR:
			var gd: Dictionary = ItemsData.GEAR[g]
			var needs := {"lingotto_" + m: gd["bars"]}
			if int(gd["wood"]) > 0:
				needs["legno"] = gd["wood"]
			out.append({"out": "%s_%s" % [g, m], "qty": 1, "in": needs, "station": "incudine"})
	_all = out
	return _all


## Ricette che producono un oggetto.
static func making(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return r["out"] == id)


## Ricette che usano un oggetto.
static func using(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has(id))
