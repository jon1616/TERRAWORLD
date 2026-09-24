class_name CreaturesData
extends RefCounted
## Creature: statistiche, comportamenti (voce 5: sistema a comportamenti combinabili), bottino, dove vivono.
## art = [forma, variante] per l'arte generata dal codice; strata = strati di profondità in cui compaiono (voce 5b:
## 0 superficie, 1 sottobosco di radici, 2 caverne d'ardesia, 3 profondità della Linfa, 4 il Fondo).
## I grumi: gocce di muschio, resina o spore che si sono animate e saltellano.

const CREATURES := {
	"grumo_muschio": {"name": "Grumo di muschio", "hp": 14, "damage": 6, "defense": 0, "behaviors": ["salta_verso"],
		"loot": "grumo", "art": ["grumo", 0], "strata": [0, 1]},
	"grumo_resina": {"name": "Grumo di resina", "hp": 22, "damage": 8, "defense": 1, "behaviors": ["salta_verso"],
		"loot": "grumo_resina", "art": ["grumo", 1], "strata": [1, 2]},
	"grumo_spore": {"name": "Grumo di spore", "hp": 30, "damage": 11, "defense": 2, "behaviors": ["salta_verso"],
		"loot": "grumo_spore", "art": ["grumo", 2], "strata": [2, 3]},
}
