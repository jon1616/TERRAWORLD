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
	{"out": "cesta", "qty": 1, "in": {"legno": 8}, "station": "ceppo"},
	{"out": "spada_radice", "qty": 1, "in": {"legno": 7}, "station": "ceppo"},
	{"out": "arco_radice", "qty": 1, "in": {"legno": 10}, "station": "ceppo"},
	{"out": "dardo", "qty": 25, "in": {"legno": 1, "ardesia": 1}, "station": "ceppo"},
	{"out": "baccello_ardente", "qty": 1, "in": {"ardesia": 20, "legno": 4, "torcia": 3}, "station": "ceppo"},
	{"out": "lingotto_radicite", "qty": 1, "in": {"minerale_radicite": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_legnoferro", "qty": 1, "in": {"minerale_legnoferro": 3}, "station": "baccello_ardente"},
	{"out": "lingotto_ambra", "qty": 1, "in": {"minerale_ambra": 4}, "station": "baccello_ardente"},
	{"out": "maglio", "qty": 1, "in": {"lingotto_legnoferro": 5}, "station": "ceppo"},
	{"out": "pozione_rugiada", "qty": 1, "in": {"gelatina": 2, "fungo_brace": 1}, "station": "ceppo"},
	# il primo anello (voce 8)
	{"out": "pozione_bagliore", "qty": 1, "in": {"fungo_luminoso": 2, "gelatina": 1, "sacca_spore": 1}, "station": "ceppo"},
	{"out": "seme_muschio", "qty": 5, "in": {"seme_lanterna": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "pozione_vigore", "qty": 1, "in": {"cenere_avvizzita": 3, "fungo_brace": 1, "gelatina": 1}, "station": "ceppo"},
	{"out": "pozione_scorza", "qty": 1, "in": {"scaglia_ardesia": 3, "fungo_brace": 1}, "station": "ceppo"},
	# voce 21: Linfa e bastoni
	{"out": "pozione_linfa", "qty": 2, "in": {"fungo_luminoso": 1, "gelatina": 2}, "station": "ceppo"},
	{"out": "bastone_brace", "qty": 1, "in": {"legno": 8, "polvere_brace": 10, "fungo_brace": 3}, "station": "ceppo"},
	{"out": "bastone_spore", "qty": 1, "in": {"lingotto_legnoferro": 6, "sacca_spore": 8, "legno": 4}, "station": "maglio"},
	{"out": "bastone_cristallo", "qty": 1, "in": {"lingotto_ambra": 6, "cristallo_linfa": 10}, "station": "maglio"},
	{"out": "bastone_vuoto", "qty": 1, "in": {"lingotto_linfa": 6, "scheggia_vuoto": 12}, "station": "maglio"},
	{"out": "dardo_vuoto", "qty": 20, "in": {"scheggia_vuoto": 1, "legno": 1}, "station": "ceppo"},
	{"out": "lanterna_linfa", "qty": 1, "in": {"cristallo_linfa": 5, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "rugiada_linfa", "qty": 1, "in": {"cristallo_linfa": 2, "fungo_luminoso": 1, "pozione_rugiada": 1}, "station": "ceppo"},
	# voce 22: ciò che si fa con i materiali delle creature nuove
	{"out": "dardo_piumato", "qty": 25, "in": {"penna_corteccia": 1, "legno": 1}, "station": "ceppo"},
	{"out": "dardo_aculeo", "qty": 25, "in": {"aculeo": 2, "legno": 1}, "station": "ceppo"},
	{"out": "mantello_penne", "qty": 1, "in": {"penna_corteccia": 16, "seta_radice": 8}, "station": "ceppo"},
	{"out": "collana_aculei", "qty": 1, "in": {"aculeo": 20, "seta_radice": 4}, "station": "ceppo"},
	{"out": "torcia", "qty": 5, "in": {"legno": 1, "polvere_lucciola": 1}, "station": ""},
	{"out": "anello_lucciola", "qty": 1, "in": {"polvere_lucciola": 12, "lingotto_radicite": 3}, "station": "maglio"},
	{"out": "benda_seta", "qty": 2, "in": {"seta_radice": 3, "gelatina": 1}, "station": "ceppo"},
	{"out": "guanti_talpone", "qty": 1, "in": {"artiglio_talpone": 4, "lingotto_legnoferro": 4}, "station": "maglio"},
	{"out": "pozione_rigoglio", "qty": 1, "in": {"lamella_fungo": 2, "gelatina": 1, "fungo_luminoso": 1}, "station": "ceppo"},
	{"out": "ali_membrana", "qty": 1, "in": {"membrana_ardesia": 14, "lingotto_legnoferro": 3}, "station": "maglio"},
	{"out": "scudo_guscio", "qty": 1, "in": {"guscio_cristallo": 10, "lingotto_ambra": 4}, "station": "maglio"},
	{"out": "anello_geode", "qty": 1, "in": {"cuore_geode": 3, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "stivali_serpe", "qty": 1, "in": {"scaglia_linfa": 12, "lingotto_ambra": 4}, "station": "maglio"},
	{"out": "pozione_linfa", "qty": 3, "in": {"polline_luminoso": 2, "gelatina": 1}, "station": "ceppo"},
	{"out": "pozione_bagliore", "qty": 1, "in": {"polline_luminoso": 2, "gelatina": 1, "fungo_luminoso": 1}, "station": "ceppo"},
	{"out": "specchio_guizzo", "qty": 1, "in": {"occhio_guizzo": 4, "cristallo_linfa": 6, "lingotto_ambra": 2}, "station": "maglio"},
	{"out": "falce_vuoto", "qty": 1, "in": {"lama_vuoto": 6, "lingotto_linfa": 6}, "station": "maglio"},
	{"out": "velo_ombra", "qty": 1, "in": {"seta_vuoto": 12, "scheggia_vuoto": 6}, "station": "maglio"},
	# il grado della Linfa si apre solo dopo il Guardiano: sconfitto o curato, due strade per lo stesso lingotto
	{"out": "lingotto_linfa", "qty": 2, "in": {"cristallo_linfa": 4, "frammento_nodo": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_linfa", "qty": 2, "in": {"cristallo_linfa": 4, "linfa_guardiano": 1}, "station": "baccello_ardente"},
	# i gradi dei mondi oltre i portali (voce 19): la Regina delle Spore e il Colosso d'Ardesia
	{"out": "lingotto_vuoto", "qty": 2, "in": {"vuotite": 6, "velo_spora": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_vuoto", "qty": 2, "in": {"vuotite": 6, "polline_regina": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_stellare", "qty": 2, "in": {"scheggia_vuoto": 4, "cristallo_linfa": 2, "nucleo_colosso": 1}, "station": "baccello_ardente"},
	{"out": "lingotto_stellare", "qty": 2, "in": {"scheggia_vuoto": 4, "cristallo_linfa": 2, "pietra_battente": 1}, "station": "baccello_ardente"},
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
