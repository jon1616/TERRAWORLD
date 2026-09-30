## Roadmap 28, voce 263: il pacchetto del Primo Mondo (il Giardino oltre il Vuoto): l'ultimo Seminatore, custode
## dell'Albero Antico, i suoi guardiani di Linfa e ciò che lascia. Come i file dei biomi, **non nomina altre classi**.
## Il luogo lo costruisce `PassPrimo`, le regole stanno in `PrimoGarden`.

const DATA := {
	"creatures": {
		"guardia_linfa": {"name": "Guardiano di Linfa", "hp": 160, "damage": 22, "defense": 6, "knock": 0.5, "half": [8, 12], "speed": 90,
			"fly": true, "behaviors": ["vola", "spara"], "p": {"sight": 22, "hover": 40.0, "wobble": 30.0, "rate": 2.2, "shot_speed": 190.0},
			"loot": "guardia_linfa", "art": ["guardia_linfa", 0], "strata": [], "weight": 0, "primo": true, "glow": true, "no_trophy": true,
			"body": {"plan": "fluttuante", "w": 20, "h": 26, "pal": ["#0e2a2a", "#1c4a48", "#2f7a70", "#6ff0e0", "#e8fff8"], "eye": "#ffd24a",
				"marks": "strisce", "mark": "#e8fff8", "glow": true},
			"affinity": {"weak": ["vuoto"], "resist": ["linfa"]}},
		"ultimo_seminatore": {"name": "L'ultimo Seminatore", "hp": 4200, "damage": 40, "defense": 14, "knock": 1.0, "half": [16, 24],
			"speed": 95, "fly": true, "behaviors": ["vola", "spara"], "fury": ["ventaglio", "evoca", "teletrasporto"],
			"p": {"sight": 36, "hover": 60.0, "wobble": 30.0, "rate": 1.6, "shot_speed": 230.0, "fan_n": 7, "fan_rate": 2.6,
				"blink_every": 4.0, "tp_range": 10, "summon_every": 9.0, "summon_max": 3, "phase2": 0.5, "summon": "guardia_linfa"},
			"loot": "ultimo_seminatore", "art": ["ultimo_seminatore", 0], "strata": [], "weight": 0, "boss": true, "primo_boss": true,
			"no_trophy": true, "glow": true,
			"body": {"plan": "fluttuante", "w": 40, "h": 54, "pal": ["#12241e", "#244a3a", "#3c7a5c", "#8ef0c0", "#fff6c8"], "eye": "#ffd24a",
				"marks": "strisce", "mark": "#fff6c8", "glow": true},
			"affinity": {"weak": ["vuoto"], "resist": ["linfa", "spora"]}},
	},
	"families": {
		"guardiani_linfa": {"name": "Guardiani di Linfa", "members": ["guardia_linfa"], "fem": false, "role": "volante"},
	},
	"loot": {
		"guardia_linfa": [{"item": "cristallo_linfa", "min": 1, "max": 2, "chance": 0.6}, {"item": "linfa_antica", "min": 1, "max": 1, "chance": 0.15}],
		"ultimo_seminatore": [{"item": "seme_seminatore", "min": 1, "max": 1, "chance": 1.0}, {"item": "linfa_antica", "min": 6, "max": 8, "chance": 1.0},
			{"item": "polvere_iridata", "min": 6, "max": 8, "chance": 1.0}],
	},
	"items": {
		"seme_seminatore": {"name": "Seme del Seminatore", "kind": "ricordo", "icon": ["seme", "stelle"], "stack": 5,
			"desc": "L'ultimo Seminatore lo teneva stretto: un seme che batte come un cuore. L'Albero Antico sa che cosa farne."},
	},
}
