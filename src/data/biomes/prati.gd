extends RefCounted
## I Prati di vento (voce 92, terre temperate): colline basse d'erba argentata, pochi alberi piegati, temporali. Il
## vento vive qui: i Planaventi planano sulle correnti e i Saltagrilli saltano da un ciuffo all'altro. Tutto il bioma
## sta in questo file (campi in cima a `BiomesData`); i disegni: `TreeArtTemperate._ombrello`, `TemperateDecorArt`
## 46-48, le creature con la ricetta di `BodyArt`.

const DATA := {
	"id": "prati", "name": "Prati di vento", "desc": "Erba argentata a perdita d'occhio, e il vento che non smette mai",
	"trees": 0.05, "hills": 0.4, "lift": 4, "tint": Color(0.92, 1.05, 1.0), "color": "#c8ece0", "weight": 2,
	"grass": 32,
	"stagni": [2.0, 12, 28, 2, 5],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_alborella": {"name": "Alborella del vento", "rar": "comune", "size": [6, 12], "color": "seta", "biomes": ["prati"], "desc": "Leggera e argentata: salta fuori dall'acqua quando tira vento."},
		"pesce_saltarello": {"name": "Saltarello d'erba", "rar": "non_comune", "size": [10, 20], "color": "muschio", "biomes": ["prati"], "weather": ["pioggia"], "desc": "Con la pioggia salta di stagno in stagno attraverso l'erba."},
	},
	"turf": {"name": "Erba del vento", "layer": "erba_vento", "pal": ["#1a302c", "#2a4a44", "#44706a", "#7ab8a4", "#c8ece0"], "specks": 60},
	"tree": {"id": "ombrello", "name": "Ombrello del vento", "glow": Color(1.3, 1.5, 1.4)},
	"veg": [[0.4, 46], [0.48, 47], [0.54, 48], [0.58, "fiori"]],
	"decor": {46: {"soft": "erba"}, 47: {"soft": "pianta", "light": Color(0.12, 0.2, 0.18)}, 48: {"soft": "pianta", "light": Color(0.1, 0.14, 0.3)}},
	"elem": "luce",
	"weather": {"temporale": 2.0},
	"gene": "prateria",
	"fauna": ["lepre_linfa", "ape_lume"],
	"lands": [["Prati", false], ["Praterie", true], ["Pascoli del vento", false]],
	# --- il pacchetto ------------------------------------------------------------------------------------------------
	"creatures": {
		"planavento": {"name": "Planavento", "hp": 20, "damage": 8, "defense": 0, "knock": 0.0, "half": [9, 6], "speed": 100,
			"fly": true, "behaviors": ["vola", "scatto"],
			"p": {"sight": 26, "hover": 80.0, "wobble": 30.0, "dash_every": 4.0, "dash_speed": 240.0, "dash_time": 0.5},
			"loot": "planavento", "art": ["planavento", 0], "strata": [0], "weight": 6, "biomes": ["prati"],
			"body": {"plan": "uccello", "w": 24, "h": 16, "pal": ["#1e3a34", "#2e5a50", "#4a8878", "#9ad0bc", "#e8fff8"],
				"eye": "#ffd24a", "wings": "#c8ece0", "tail": true},
			"affinity": {"weak": ["gelo"], "resist": ["luce"]}, "trophy": "coda_vento"},
		"saltagrillo": {"name": "Saltagrillo", "hp": 16, "damage": 7, "defense": 0, "knock": 0.1, "half": [7, 5], "speed": 90,
			"behaviors": ["salta_verso"], "p": {"jump": 300.0, "sight": 18},
			"loot": "saltagrillo", "art": ["saltagrillo", 0], "strata": [0], "weight": 8, "biomes": ["prati"],
			"body": {"plan": "insetto", "w": 18, "h": 12, "pal": ["#2a3a10", "#4a6a1a", "#7a9a2a", "#b0d04a", "#e8ff90"],
				"eye": "#ff7a3a", "marks": "strisce", "mark": "#2a3a10"},
			"affinity": {"weak": ["brace"], "resist": []}, "trophy": "zampa_grillo"},
	},
	"families": {
		"planaventi": {"name": "Planaventi", "members": ["planavento"], "fem": false, "role": "volante"},
		"saltagrilli": {"name": "Saltagrilli", "members": ["saltagrillo"], "fem": false, "role": "neutro", "nest": {"type": "erba", "n": 4}},
	},
	"loot": {
		"planavento": [{"item": "piuma_vento", "min": 1, "max": 3, "chance": 1.0}],
		"saltagrillo": [{"item": "elitra_grillo", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"piuma_vento": {"name": "Piuma del vento", "kind": "materiale", "icon": ["penna", "seta"], "desc": "Da un Planavento: pesa meno dell'aria che sposta."},
		"elitra_grillo": {"name": "Elitra di saltagrillo", "kind": "materiale", "icon": ["scaglia", "muschio"], "desc": "L'ala dura di un Saltagrillo, verde e lucida."},
		"cappuccio_vento": {"name": "Cappuccio del vento", "kind": "elmo", "icon": ["elmo", "seta"], "tier": 3, "defense": 2, "acc": {"run": 1.05}, "desc": "Corsa +5%."},
		"veste_vento": {"name": "Veste del vento", "kind": "corazza", "icon": ["corazza", "seta"], "tier": 3, "defense": 4, "desc": "Piume del vento cucite su elitre verdi."},
		"calzari_vento": {"name": "Calzari del vento", "kind": "gambali", "icon": ["gambali", "seta"], "tier": 3, "defense": 2, "acc": {"jump": 1.06}, "desc": "Salto +6%."},
		"coda_vento": {"name": "Coda del Planavento", "kind": "trofeo", "icon": ["penna", "iride"], "desc": "La lasciano solo le creature rare di questa specie."},
		"zampa_grillo": {"name": "Zampa del Saltagrillo", "kind": "trofeo", "icon": ["artiglio", "muschio"], "desc": "La lasciano solo le creature rare di questa specie."},
		"aquilone_vento": {"name": "Aquilone del vento", "kind": "accessorio", "icon": ["ali", "seta"], "unique": true, "stack": 1,
			"acc": {"jump": 1.15, "glide": true}, "effects": ["cielo_aperto", "slancio"],
			"story": "Un bambino dei Seminatori lo fece volare così alto che il vento se lo tenne. Ogni tanto lo restituisce.",
			"source": "si fabbrica con i trofei delle creature rare dei Prati di vento",
			"desc": "Salto +15%, si plana; sotto il cielo aperto e dopo ogni creatura abbattuta vai più svelto."},
		"seme_mondo_prateria": {"name": "Seme di prateria", "kind": "seme_mondo", "icon": ["seme", "seta"], "species": "prateria", "stack": 1,
			"desc": "Un Seme di mondo che profuma d'erba e di temporale: dietro il suo portale, prati di vento."},
	},
	"recipes": [
		{"out": "cappuccio_vento", "qty": 1, "in": {"piuma_vento": 6, "elitra_grillo": 3}, "station": "telaio"},
		{"out": "veste_vento", "qty": 1, "in": {"piuma_vento": 10, "elitra_grillo": 5}, "station": "telaio"},
		{"out": "calzari_vento", "qty": 1, "in": {"piuma_vento": 8, "elitra_grillo": 4}, "station": "telaio"},
		{"out": "aquilone_vento", "qty": 1, "in": {"coda_vento": 1, "zampa_grillo": 1, "piuma_vento": 10}, "station": "maglio"},
		{"out": "seme_mondo_prateria", "qty": 1, "in": {"seme_mondo": 1, "piuma_vento": 10, "elitra_grillo": 6}, "station": "altare"},
	],
	"sets": {
		"vento": {"name": "Soffio di vento", "pieces": ["cappuccio_vento", "veste_vento", "calzari_vento"],
			"bonus": {"run": 1.15, "jump": 1.15}, "desc": "corsa e salto +15%"},
	},
	"genes": {
		"prateria": {"cat": "superficie", "name": "Prateria", "rar": 1, "dom": 2, "good": true,
			"desc": "prati aperti spazzati dal vento", "item": "seme_mondo_prateria",
			"gen": {"biomes": {"prati": 6, "foresta": 2, "ambra": 1}}},
	},
}
