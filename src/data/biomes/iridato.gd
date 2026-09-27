extends RefCounted
## I Prati iridati (voce 94, bioma **raro**): nascono solo da un innesto con mutazione (gene «Iride viva»). Erba che
## cambia colore alla luce, alberi-ombrello pallidi, e il **Cervo iridato**, che si trova solo qui: fugge e, abbattuto,
## lascia la Polvere iridata. Tutto il bioma sta in questo file (campi in cima a `BiomesData`).

const DATA := {
	"id": "iridato", "name": "Prati iridati", "desc": "L'erba cambia colore a ogni passo: qui corre il Cervo iridato",
	"trees": 0.06, "hills": 0.6, "lift": 2, "tint": Color(1.1, 0.95, 1.2), "color": "#ffb0f0", "weight": 0,
	"grass": 44,
	"stagni": [1.5, 10, 22, 3, 6],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_iridino": {"name": "Iridino", "rar": "comune", "size": [8, 16], "color": "iride", "biomes": ["iridato"], "desc": "Cambia colore a seconda di come lo guardi."},
		"pesce_iride": {"name": "Pesce d'iride", "rar": "raro", "size": [20, 40], "color": "iride", "biomes": ["iridato"], "depth": 3, "desc": "Porta tutti i colori del mondo iridato sulle squame."},
	},
	"turf": {"name": "Erba iridata", "layer": "erba_iridata", "pal": ["#2a1a3a", "#4a3a6a", "#8a60a8", "#e0a0d8", "#fff0c0"], "specks": 110},
	"tree": {"id": "ombrello_iridato", "name": "Ombrello iridato", "glow": Color(1.8, 1.4, 1.8), "art": "ombrello"},
	"veg": [[0.35, 74], [0.45, 75], [0.52, "fiori"]],
	"decor": {74: {"soft": "erba"}, 75: {"soft": "pianta", "light": Color(0.35, 0.2, 0.4)}},
	"elem": "luce",
	"gene": "iride_viva",
	"lands": [["Prati iridati", false], ["Arcobaleni", false], ["Terre d'iride", true]],
	"creatures": {
		"cervo_iridato": {"name": "Cervo iridato", "hp": 60, "damage": 0, "defense": 2, "knock": 0.3, "half": [11, 8], "speed": 140,
			"behaviors": ["fugge"], "p": {"flee": 18}, "no_trophy": true,
			"loot": "cervo_iridato", "art": ["cervo_iridato", 0], "strata": [0], "weight": 2, "biomes": ["iridato"], "glow": true,
			"body": {"plan": "quadrupede", "w": 26, "h": 22, "pal": ["#4a2a6a", "#8a4ab0", "#e080d0", "#ffc0a0", "#fff8d0"],
				"eye": "#8ef0d8", "horns": 2, "marks": "macchie", "mark": "#fff8d0", "glow": true},
			"affinity": {"weak": ["vuoto"], "resist": ["luce"]}},
	},
	"families": {
		"cervi_iridati": {"name": "Cervi iridati", "members": ["cervo_iridato"], "fem": false, "role": "erbivoro"},
	},
	"loot": {
		"cervo_iridato": [{"item": "polvere_iridata", "min": 1, "max": 3, "chance": 1.0}, {"item": "palco_iridato", "min": 1, "max": 1, "chance": 0.35}],
	},
	"items": {
		"palco_iridato": {"name": "Palco iridato", "kind": "materiale", "icon": ["artiglio", "iride"], "desc": "Un ramo dei palchi del Cervo iridato: cambia colore girandolo."},
		"corona_iride": {"name": "Corona d'iride", "kind": "accessorio", "icon": ["corona", "iride"], "unique": true, "stack": 1,
			"acc": {"luck": 0.3, "run": 1.1}, "effects": ["caccia_lumini", "slancio"],
			"story": "Chi la porta vede le cose di un colore in più. Nessuno sa dire quale.",
			"source": "si fabbrica con i palchi del Cervo iridato, che vive solo nei Prati iridati",
			"desc": "Molta più fortuna, corsa +10%; più Lumini e più svelto dopo ogni creatura."},
		"seme_mondo_iride": {"name": "Seme d'iride", "kind": "seme_mondo", "icon": ["seme", "iride"], "species": "iride_viva", "stack": 1,
			"source": "nasce solo da un innesto, quando il Seme muta",
			"desc": "Un Seme di mondo che cambia colore: dietro il suo portale, prati iridati."},
	},
	"recipes": [
		{"out": "corona_iride", "qty": 1, "in": {"palco_iridato": 4, "polvere_iridata": 10}, "station": "maglio"},
	],
	"genes": {
		"iride_viva": {"cat": "superficie", "name": "Iride viva", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
			"desc": "prati iridati dove corre il Cervo iridato", "item": "seme_mondo_iride",
			"gen": {"biomes": {"iridato": 6, "prati": 2, "foresta": 1}}},
	},
}
