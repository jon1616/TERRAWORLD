extends RefCounted
## Le Paludi di spore. I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "palude", "name": "Paludi di spore", "desc": "Muschio viola e aria pesante di spore che brillano",
	"trees": 0.12, "hills": 0.3, "lift": 12, "tint": Color(0.78, 0.6, 1.12), "color": "#c08aff", "weight": 3,
	"grass": 13,                  # la tessera (TileDefs.GRASS_SPORE)
	"stagni": [4.0, 12, 30, 2, 4],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_gatto_spore": {"name": "Pescegatto di spore", "rar": "comune", "size": [25, 60], "color": "fungo", "biomes": ["palude"], "desc": "Ha i baffi coperti di spore: dove passa l'acqua si intorbida."},
		"pesce_sporangio": {"name": "Sporangio d'acqua", "rar": "non_comune", "size": [8, 15], "color": "fungo", "biomes": ["palude"], "weather": ["pioggia", "temporale"], "desc": "Sale a galla quando piove, a bere le spore che cadono."},
	},
	"turf": {"name": "Muschio di spore", "layer": "muschio_spore", "pal": ["#2a1640", "#43235e", "#633a86", "#8a58b4", "#c49af0"], "specks": 90},
	"tree": {"id": "fungo", "name": "Fungo-albero", "glow": Color(1.5, 1.2, 1.8)},
	# erba di spore bassa, canne, funghetti, sacche di spore, funghi luminosi, campanule viola
	"veg": [[0.28, 34], [0.36, 35], [0.44, 36], [0.5, "spora"], [0.55, "bagliore"], [0.6, "fiore_2"]],
	"decor": {34: {"soft": "erba"}, 35: {"soft": "pianta", "light": Color(0.18, 0.1, 0.28)},
		36: {"soft": "pianta", "light": Color(0.22, 0.1, 0.32)}},
	"elem": "spora",
	"gene": "sporangio",
	"lands": [["Paludi", true], ["Torbiere", true], ["Acquitrini", false]],
	"items": {
		"seme_mondo_sporangio": {"name": "Seme di sporangio", "kind": "seme_mondo", "icon": ["seme", "fungo"], "species": "sporangio", "stack": 1, "desc": "Un Seme di mondo nutrito di spore: dietro il suo portale, paludi di spore quasi ovunque."},
	},
	"recipes": [
		{"out": "seme_mondo_sporangio", "qty": 1, "in": {"seme_mondo": 1, "sacca_spore": 10, "fungo_luminoso": 6}, "station": "altare"},
	],
}
