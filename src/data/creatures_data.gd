class_name CreaturesData
extends RefCounted
## Creature: statistiche, comportamenti (voce 5: sistema a comportamenti combinabili), bottino, dove vivono.
## art = [forma, variante] per l'arte generata dal codice; strata = strati di profondità in cui compaiono (voce 5b:
## 0 superficie, 1 sottobosco di radici, 2 caverne d'ardesia, 3 profondità della Linfa, 4 il Fondo).

const CREATURES := {
	"slime_muschio": {"name": "Slime di muschio", "hp": 14, "damage": 6, "defense": 0, "behaviors": ["salta_verso"],
		"loot": "slime", "art": ["slime", 0], "strata": [0, 1]},
	"slime_ambra": {"name": "Slime d'ambra", "hp": 22, "damage": 8, "defense": 1, "behaviors": ["salta_verso"],
		"loot": "slime_ambra", "art": ["slime", 1], "strata": [1, 2]},
	"slime_spore": {"name": "Slime di spore", "hp": 30, "damage": 11, "defense": 2, "behaviors": ["salta_verso"],
		"loot": "slime_spore", "art": ["slime", 2], "strata": [2, 3]},
}
