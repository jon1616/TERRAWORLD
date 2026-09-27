extends RefCounted
## Le Caverne del cristallo cantante (voce 94, sottosuolo): nelle Caverne d'ardesia, sale alte con punte di un
## cristallo viola che vibra quando lo tocchi. Le porta il gene «Cristalli cantanti». Cantori di cristallo (volano e
## lanciano schegge sonore) e Grilli d'eco. Campi dei biomi del sottosuolo in cima a `UnderBiomesData`; il pacchetto
## come i biomi di superficie (`BiomesData`). Questo file non nomina altre classi (valori per esteso).

const DATA := {
	"id": "canto", "name": "Caverne del cristallo cantante", "desc": "sale alte con punte di cristallo che vibrano e cantano",
	"stratum": 2, "count": 6, "build": "canto", "floor": 40,
	"tiles": {40: {"name": "Cristallo cantante", "hard": 0.7, "power": 45, "drop": "scheggia_cantante",
		"pal": ["#2a1638", "#4a2a5e", "#7a4a9a", "#b880e0", "#f0d8ff"], "layer": "cristallo_cantante", "specks": 40, "glow": true}},
	"veg": [[0.12, 72]],
	"decor": {72: {"light": Color(0.3, 0.15, 0.45)}},
	"adj": ["cantanti", "cantanti"],                  # l'aggettivo nei nomi dei mondi (`NamesData.ADJ`)
	"creatures": {
		"cantore_cristallo": {"name": "Cantore di cristallo", "hp": 44, "damage": 11, "defense": 3, "knock": 0.1, "half": [8, 8],
			"speed": 70, "fly": true, "behaviors": ["vola", "spara"],
			"p": {"sight": 24, "hover": 50.0, "wobble": 20.0, "rate": 2.4, "shot_speed": 220.0, "shot_grav": 0.0,
				"shot_damage": 9, "shot_look": "scheggia_nera"},
			"loot": "cantore_cristallo", "art": ["cantore_cristallo", 0], "strata": [2], "weight": 0, "under": "canto", "uw": 6, "glow": true,
			"body": {"plan": "fluttuante", "w": 20, "h": 20, "pal": ["#2a1638", "#4a2a5e", "#7a4a9a", "#b880e0", "#f0d8ff"],
				"eye": "#fff0a0", "marks": "punte", "mark": "#f0d8ff", "glow": true},
			"affinity": {"weak": ["vuoto"], "resist": ["luce"]}, "trophy": "nota_cristallo"},
		"grillo_eco": {"name": "Grillo d'eco", "hp": 26, "damage": 9, "defense": 2, "knock": 0.1, "half": [7, 5], "speed": 90,
			"behaviors": ["salta_verso"], "p": {"jump": 320.0, "sight": 18},
			"loot": "grillo_eco", "art": ["grillo_eco", 0], "strata": [2], "weight": 0, "under": "canto", "uw": 8, "glow": true,
			"body": {"plan": "insetto", "w": 18, "h": 12, "pal": ["#1c1030", "#3a2458", "#6a4a8a", "#a080c8", "#e0d0ff"],
				"eye": "#8ef0d8", "marks": "strisce", "mark": "#e0d0ff", "glow": true},
			"affinity": {"weak": ["brace"], "resist": []}, "trophy": "antenna_eco"},
	},
	"families": {
		"cantori": {"name": "Cantori di cristallo", "members": ["cantore_cristallo"], "fem": false, "role": "volante"},
		"grilli_eco": {"name": "Grilli d'eco", "members": ["grillo_eco"], "fem": false, "role": "neutro"},
	},
	"loot": {
		"cantore_cristallo": [{"item": "scheggia_cantante", "min": 1, "max": 3, "chance": 1.0}],
		"grillo_eco": [{"item": "scheggia_cantante", "min": 1, "max": 1, "chance": 0.6}, {"item": "cristallo_linfa", "min": 1, "max": 1, "chance": 0.2}],
	},
	"items": {
		"scheggia_cantante": {"name": "Scheggia cantante", "kind": "materiale", "icon": ["gemma", "iride"], "desc": "Vibra piano in mano: se la batti, canta una nota."},
		"nota_cristallo": {"name": "Nota di cristallo", "kind": "trofeo", "icon": ["gemma", "iride"], "desc": "La lasciano solo le creature rare di questa specie."},
		"antenna_eco": {"name": "Antenna d'eco", "kind": "trofeo", "icon": ["penna", "iride"], "desc": "La lasciano solo le creature rare di questa specie."},
		"diapason_cristallo": {"name": "Diapason di cristallo", "kind": "accessorio", "icon": ["amuleto", "iride"], "unique": true, "stack": 1,
			"acc": {"magic": 1.15, "halo": 1.3}, "effects": ["fulmine_eco"],
			"story": "Suonato una volta, tutte le caverne cantanti rispondono. I Seminatori lo usavano per trovarsi al buio.",
			"source": "si fabbrica con i trofei delle creature rare delle Caverne del cristallo cantante",
			"desc": "Incantesimi +15%, alone più ampio; ogni tanto un colpo rimbomba come un tuono."},
		"lanterna_cantante": {"name": "Lanterna cantante", "kind": "accessorio", "icon": ["lanterna", "iride"], "acc": {"halo": 1.4},
			"desc": "Alone molto più ampio: il cristallo canta e fa luce."},
	},
	"recipes": [
		{"out": "diapason_cristallo", "qty": 1, "in": {"nota_cristallo": 1, "antenna_eco": 1, "scheggia_cantante": 10}, "station": "maglio"},
		{"out": "lanterna_cantante", "qty": 1, "in": {"scheggia_cantante": 8, "lingotto_legnoferro": 3}, "station": "maglio"},
	],
	"genes": {
		"cristalli_cantanti": {"cat": "sottosuolo", "name": "Cristalli cantanti", "rar": 1, "dom": 2, "good": true,
			"desc": "caverne di cristallo che canta, nelle Caverne d'ardesia", "gen": {"under": ["canto"]}},
	},
}
