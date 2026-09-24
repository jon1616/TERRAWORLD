class_name RecipesData
extends RefCounted
## Ricette di fabbricazione: cosa si ottiene (out, qty), con cosa (in: {oggetto: quantità}) e dove (station: id di
## `StationsData`, "" = a mano, ovunque). Le ricette delle famiglie di metallo sono generate in `all()`.

const RECIPES := [
	{"out": "ceppo", "qty": 1, "in": {"legno": 10}, "station": ""},
	{"out": "torcia", "qty": 3, "in": {"legno": 1, "gelatina": 1}, "station": ""},
	{"out": "torcia", "qty": 4, "in": {"legno": 1, "polvere_brace": 1}, "station": ""},
	{"out": "corazza_scaglie", "qty": 1, "in": {"scaglia_ardesia": 12, "legno": 4}, "station": "ceppo"},
	{"out": "passerella", "qty": 2, "in": {"legno": 1}, "station": "ceppo"},
	{"out": "spada_radice", "qty": 1, "in": {"legno": 7}, "station": "ceppo"},
	{"out": "arco_radice", "qty": 1, "in": {"legno": 10}, "station": "ceppo"},
	{"out": "dardo", "qty": 25, "in": {"legno": 1, "ardesia": 1}, "station": "ceppo"},
	{"out": "baccello_ardente", "qty": 1, "in": {"ardesia": 20, "legno": 4, "torcia": 3}, "station": "ceppo"},
	{"out": "lingotto_radicite", "qty": 1, "in": {"minerale_radicite": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_legnoferro", "qty": 1, "in": {"minerale_legnoferro": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_ambra", "qty": 1, "in": {"minerale_ambra": 4}, "station": "baccello_ardente"},
	{"out": "maglio", "qty": 1, "in": {"lingotto_legnoferro": 5}, "station": "ceppo"},
	{"out": "pozione_rugiada", "qty": 1, "in": {"gelatina": 2, "fungo_brace": 1}, "station": "ceppo"},
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
			out.append({"out": "%s_%s" % [g, m], "qty": 1, "in": needs, "station": "maglio"})
	_all = out
	return _all


## Ricette che producono un oggetto.
static func making(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return r["out"] == id)


## Ricette che usano un oggetto.
static func using(id: String) -> Array:
	return all().filter(func(r: Dictionary) -> bool: return (r["in"] as Dictionary).has(id))
