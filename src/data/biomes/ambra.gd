extends RefCounted
## Le Distese d'ambra. I campi sono spiegati in cima a `BiomesData`.

const DATA := {
	"id": "ambra", "name": "Distese d'ambra", "desc": "Erba dorata, rocce calde, pochi alberi",
	"trees": 0.07, "hills": 1.5, "lift": -8, "tint": Color(1.22, 0.9, 0.6), "color": "#ffd08a", "weight": 3,
	"grass": 14,                  # la tessera (TileDefs.GRASS_AMBRA)
	"stagni": [0.6, 8, 14, 2, 4],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_carpa_ambra": {"name": "Carpa d'ambra", "rar": "comune", "size": [20, 50], "color": "ambra", "biomes": ["ambra"], "desc": "Le squame sono gocce d'ambra: al sole sembra di miele."},
		"pesce_resina": {"name": "Goccia di resina", "rar": "raro", "size": [5, 10], "color": "ambra", "biomes": ["ambra"], "desc": "Minuscolo e appiccicoso: a volte ha dentro un insetto antico."},
	},
	"turf": {"name": "Erba d'ambra", "layer": "erba_ambra", "pal": ["#4a3210", "#6e4c16", "#9a7022", "#c89a3a", "#f0d27a"], "specks": 90},
	"tree": {"id": "acacia", "name": "Acacia d'ambra", "glow": Color(1.7, 1.4, 0.9)},
	# erba dorata, cardi, fiori di resina, sassi caldi, campanule d'ambra
	"veg": [[0.35, 37], [0.43, 38], [0.5, 39], [0.56, "sassi"], [0.6, "fiore_1"]],
	"decor": {37: {"soft": "erba"}, 38: {"soft": "pianta", "light": Color(0.25, 0.17, 0.04)},
		39: {"soft": "pianta", "light": Color(0.22, 0.12, 0.02)}},
	"elem": "luce",
	"gene": "resina",
	"lands": [["Distese", true], ["Dune", true], ["Piani", false]],
	"items": {
		"seme_mondo_resina": {"name": "Seme di resina", "kind": "seme_mondo", "icon": ["seme", "ambra"], "species": "resina", "stack": 1, "desc": "Un Seme di mondo nutrito d'ambra: dietro il suo portale, distese d'ambra calde e aperte."},
	},
	"recipes": [
		{"out": "seme_mondo_resina", "qty": 1, "in": {"seme_mondo": 1, "minerale_ambra": 12, "scaglia_ardesia": 10}, "station": "altare"},
	],
}
