class_name LootData
extends RefCounted
## Tabelle di bottino: ogni voce = oggetto, quantità minima e massima, probabilità (0-1).

const TABLES := {
	"grumo": [
		{"item": "gelatina", "min": 1, "max": 2, "chance": 1.0},
	],
	"grumo_resina": [
		{"item": "gelatina", "min": 2, "max": 3, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.15},
	],
	"grumo_spore": [
		{"item": "gelatina", "min": 2, "max": 4, "chance": 1.0},
		{"item": "fungo_luminoso", "min": 1, "max": 2, "chance": 0.25},
	],
	"falena": [
		{"item": "polvere_brace", "min": 1, "max": 2, "chance": 0.8},
	],
	"strisciaradice": [
		{"item": "legno", "min": 1, "max": 3, "chance": 1.0},
		{"item": "seme_lanterna", "min": 1, "max": 1, "chance": 0.1},
	],
	"scarabeo": [
		{"item": "scaglia_ardesia", "min": 1, "max": 3, "chance": 1.0},
		{"item": "minerale_legnoferro", "min": 1, "max": 2, "chance": 0.3},
	],
	"avvizzito": [
		{"item": "legno", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_brace", "min": 1, "max": 1, "chance": 0.3},
		{"item": "seme_lanterna", "min": 1, "max": 1, "chance": 0.12},
	],
	# scrigni delle rovine dei Seminatori, per strato (1 Sottobosco … 4 il Fondo); `roll_chest` tira più volte
	"rovina_1": [
		{"item": "torcia", "min": 6, "max": 12, "chance": 0.7},
		{"item": "pozione_rugiada", "min": 1, "max": 2, "chance": 0.5},
		{"item": "dardo", "min": 20, "max": 40, "chance": 0.4},
		{"item": "lingotto_radicite", "min": 3, "max": 6, "chance": 0.4},
		{"item": "seme_lanterna", "min": 1, "max": 3, "chance": 0.3},
		{"item": "stivali_radice", "min": 1, "max": 1, "chance": 0.18},
		{"item": "anello_lucciola", "min": 1, "max": 1, "chance": 0.18},
		{"item": "pappo_seme", "min": 1, "max": 1, "chance": 0.12},
	],
	"rovina_2": [
		{"item": "torcia", "min": 8, "max": 15, "chance": 0.5},
		{"item": "lingotto_legnoferro", "min": 3, "max": 6, "chance": 0.45},
		{"item": "pozione_scorza", "min": 1, "max": 2, "chance": 0.4},
		{"item": "pozione_rugiada", "min": 1, "max": 3, "chance": 0.4},
		{"item": "dardo", "min": 30, "max": 60, "chance": 0.35},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.16},
		{"item": "amuleto_corteccia", "min": 1, "max": 1, "chance": 0.16},
		{"item": "stivali_radice", "min": 1, "max": 1, "chance": 0.12},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.1},
	],
	"rovina_3": [
		{"item": "lingotto_ambra", "min": 3, "max": 6, "chance": 0.45},
		{"item": "pozione_bagliore", "min": 1, "max": 2, "chance": 0.45},
		{"item": "cristallo_linfa", "min": 2, "max": 5, "chance": 0.4},
		{"item": "pozione_rugiada", "min": 2, "max": 3, "chance": 0.4},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.15},
		{"item": "pappo_seme", "min": 1, "max": 1, "chance": 0.15},
		{"item": "anello_lucciola", "min": 1, "max": 1, "chance": 0.12},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.12},
	],
	"rovina_4": [
		{"item": "lingotto_ambra", "min": 4, "max": 8, "chance": 0.5},
		{"item": "rugiada_linfa", "min": 1, "max": 2, "chance": 0.45},
		{"item": "dardo_vuoto", "min": 20, "max": 40, "chance": 0.4},
		{"item": "cristallo_linfa", "min": 3, "max": 6, "chance": 0.4},
		{"item": "amuleto_corteccia", "min": 1, "max": 1, "chance": 0.18},
		{"item": "cuore_muschio", "min": 1, "max": 1, "chance": 0.18},
		{"item": "foglia_planante", "min": 1, "max": 1, "chance": 0.15},
	],
	"guardiano": [
		{"item": "frammento_nodo", "min": 30, "max": 30, "chance": 1.0},
		{"item": "scheggia_vuoto", "min": 8, "max": 12, "chance": 1.0},
		{"item": "minerale_ambra", "min": 10, "max": 16, "chance": 1.0},
	],
	"vagavuoto": [
		{"item": "scheggia_vuoto", "min": 1, "max": 3, "chance": 1.0},
		{"item": "minerale_ambra", "min": 1, "max": 2, "chance": 0.25},
	],
	"sputaspore": [
		{"item": "sacca_spore", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_luminoso", "min": 1, "max": 1, "chance": 0.3},
	],
}


## Il bottino di uno scrigno: la tabella tirata `rolls` volte, mai vuoto (si ritira finché esce qualcosa).
static func roll_chest(table: String, rng: RandomNumberGenerator, rolls := 2) -> Dictionary:
	var out := {}
	for k in 12:
		for r in rolls:
			var got := roll(table, rng)
			for id in got:
				out[id] = int(out.get(id, 0)) + int(got[id])
		if not out.is_empty():
			break
	return out


## Tira il bottino di una tabella: {oggetto: quantità}.
static func roll(table: String, rng: RandomNumberGenerator) -> Dictionary:
	var out := {}
	for e in TABLES.get(table, []):
		if rng.randf() <= float(e["chance"]):
			out[e["item"]] = int(out.get(e["item"], 0)) + rng.randi_range(int(e["min"]), int(e["max"]))
	return out
