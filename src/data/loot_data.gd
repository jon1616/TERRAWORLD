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
	"sputaspore": [
		{"item": "sacca_spore", "min": 1, "max": 2, "chance": 1.0},
		{"item": "fungo_luminoso", "min": 1, "max": 1, "chance": 0.3},
	],
}


## Tira il bottino di una tabella: {oggetto: quantità}.
static func roll(table: String, rng: RandomNumberGenerator) -> Dictionary:
	var out := {}
	for e in TABLES.get(table, []):
		if rng.randf() <= float(e["chance"]):
			out[e["item"]] = int(out.get(e["item"], 0)) + rng.randi_range(int(e["min"]), int(e["max"]))
	return out
