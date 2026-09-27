extends RefCounted
## Le Colline dei cappelli (voce 92, terre temperate): colline tonde di micelio bruno, funghi alti come alberi e
## funghetti a grappolo, pioggia spesso. I Lumaconi brucano (anche l'orto), gli Spolverini volano e soffiano polline.
## Tutto il bioma sta in questo file (campi in cima a `BiomesData`); disegni: `TreeArtTemperate._cappellone`,
## `TemperateDecorArt` 52-54, le creature con `BodyArt`.

const DATA := {
	"id": "funghi", "name": "Colline dei cappelli", "desc": "Colline di micelio e funghi alti come case, sotto una pioggia tiepida",
	"trees": 0.15, "hills": 1.8, "lift": -6, "tint": Color(1.1, 0.96, 0.8), "color": "#f0c890", "weight": 2,
	"grass": 34,
	"stagni": [1.5, 10, 20, 3, 6],      # voce 118: stagni di superficie (vedi `BiomesData`)
	# voce 120: i pesci degli stagni di questo bioma (campi in cima a `FishData`)
	"fish": {
		"pesce_cappellino": {"name": "Cappellino", "rar": "comune", "size": [8, 16], "color": "fungo", "biomes": ["funghi"], "desc": "Sulla testa ha un cappello di fungo che non si toglie mai."},
		"pesce_micelio": {"name": "Pesce di micelio", "rar": "raro", "size": [20, 40], "color": "fungo", "biomes": ["funghi"], "time": "notte", "desc": "Di notte i suoi fili di micelio si accendono sotto l'acqua."},
	},
	"turf": {"name": "Micelio bruno", "layer": "micelio_bruno", "pal": ["#2a2018", "#443426", "#62503a", "#8a7454", "#c8b088"], "specks": 70},
	"tree": {"id": "cappellone", "name": "Cappellone", "glow": Color(1.7, 1.3, 0.9)},
	"veg": [[0.35, 52], [0.45, 53], [0.5, 54], [0.54, "bagliore"]],
	"decor": {52: {"soft": "erba"}, 53: {"soft": "pianta"}, 54: {"soft": "pianta", "light": Color(0.3, 0.2, 0.08)}},
	"elem": "spora",
	"weather": {"pioggia": 1.5},
	"gene": "cappelli",
	"fauna": ["saltafungo", "pecora_muschio"],
	"lands": [["Colline", true], ["Poggi", false], ["Cappellaie", true]],
	# --- il pacchetto ------------------------------------------------------------------------------------------------
	"creatures": {
		"lumacone": {"name": "Lumacone dei cappelli", "hp": 44, "damage": 6, "defense": 5, "knock": 0.8, "half": [9, 5],
			"speed": 18, "behaviors": ["cammina"], "p": {"sight": 8}, "docile": true,
			"loot": "lumacone", "art": ["lumacone", 0], "strata": [0], "weight": 7, "biomes": ["funghi"], "glow": true,
			"body": {"plan": "lumaca", "w": 22, "h": 14, "pal": ["#3a2a1a", "#5a4028", "#8a6a48", "#b89470", "#e8d0a8"],
				"eye": "#8ef0d8", "mark": "#e0823a", "glow": true},
			"affinity": {"weak": ["brace"], "resist": ["spora"]}, "trophy": "guscio_lumacone"},
		"spolverino": {"name": "Spolverino", "hp": 16, "damage": 6, "defense": 0, "knock": 0.0, "half": [7, 5], "speed": 85,
			"fly": true, "behaviors": ["vola", "spara"],
			"p": {"sight": 22, "hover": 50.0, "wobble": 30.0, "rate": 3.0, "shot_speed": 150.0, "shot_grav": 0.2,
				"shot_damage": 5, "shot_look": "polline"},
			"loot": "spolverino", "art": ["spolverino", 0], "strata": [0], "weight": 6, "biomes": ["funghi"], "glow": true,
			"body": {"plan": "insetto", "w": 18, "h": 14, "pal": ["#3a2418", "#5a3a26", "#8a5a3a", "#c08050", "#f0c890"],
				"eye": "#ffd24a", "wings": "#f0c890", "marks": "macchie", "mark": "#ffd8a0", "glow": true},
			"affinity": {"weak": ["brace"], "resist": ["spora"]}, "trophy": "ala_spolverino"},
	},
	"families": {
		"lumaconi": {"name": "Lumaconi", "members": ["lumacone"], "fem": false, "role": "erbivoro", "pest": true,
			"nest": {"type": "erba", "n": 4}},
		"spolverini": {"name": "Spolverini", "members": ["spolverino"], "fem": false, "role": "volante"},
	},
	"loot": {
		"lumacone": [{"item": "bava_lumacone", "min": 1, "max": 2, "chance": 1.0}, {"item": "fungo_luminoso", "min": 1, "max": 1, "chance": 0.3}],
		"spolverino": [{"item": "polvere_spolverino", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"bava_lumacone": {"name": "Bava di lumacone", "kind": "materiale", "icon": ["polvere", "fungo"], "desc": "Appiccica tutto, e secca diventa un tessuto."},
		"polvere_spolverino": {"name": "Polvere di spolverino", "kind": "materiale", "icon": ["polvere", "ambra"], "desc": "Il polline d'oro delle ali di uno Spolverino."},
		"cappello_fungaio": {"name": "Cappello del fungaio", "kind": "elmo", "icon": ["elmo", "fungo"], "tier": 3, "defense": 2, "acc": {"regen": 1.1}, "desc": "La Vita ricresce +10%."},
		"casacca_fungaio": {"name": "Casacca del fungaio", "kind": "corazza", "icon": ["corazza", "fungo"], "tier": 3, "defense": 4, "desc": "Bava secca di lumacone, morbida e dura."},
		"ghette_fungaio": {"name": "Ghette del fungaio", "kind": "gambali", "icon": ["gambali", "fungo"], "tier": 3, "defense": 3, "desc": "Non scivolano mai, neanche sotto la pioggia."},
		"guscio_lumacone": {"name": "Guscio di lumacone", "kind": "trofeo", "icon": ["essenza", "fungo"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"ala_spolverino": {"name": "Ala di spolverino", "kind": "trofeo", "icon": ["penna", "ambra"], "desc": "La lasciano solo le creature rare di questa specie."},
		"cappello_vecchio": {"name": "Cappello del vecchio fungaio", "kind": "accessorio", "icon": ["corona", "fungo"], "unique": true, "stack": 1,
			"acc": {"luck": 0.25}, "effects": ["caccia_lumini"],
			"story": "Il vecchio fungaio non sapeva contare, ma i Lumini li trovava tutti. Il cappello se lo ricorda.",
			"source": "si fabbrica con i trofei delle creature rare delle Colline dei cappelli",
			"desc": "Più fortuna nel bottino; le creature abbattute lasciano più Lumini."},
		"seme_mondo_cappelli": {"name": "Seme dei cappelli", "kind": "seme_mondo", "icon": ["seme", "fungo"], "species": "cappelli", "stack": 1,
			"desc": "Un Seme di mondo coperto di micelio: dietro il suo portale, colline di funghi."},
	},
	"recipes": [
		{"out": "cappello_fungaio", "qty": 1, "in": {"bava_lumacone": 6, "polvere_spolverino": 3}, "station": "telaio"},
		{"out": "casacca_fungaio", "qty": 1, "in": {"bava_lumacone": 10, "polvere_spolverino": 4}, "station": "telaio"},
		{"out": "ghette_fungaio", "qty": 1, "in": {"bava_lumacone": 8, "polvere_spolverino": 3}, "station": "telaio"},
		{"out": "cappello_vecchio", "qty": 1, "in": {"guscio_lumacone": 1, "ala_spolverino": 1, "polvere_spolverino": 10}, "station": "maglio"},
		{"out": "seme_mondo_cappelli", "qty": 1, "in": {"seme_mondo": 1, "bava_lumacone": 10, "polvere_spolverino": 6}, "station": "altare"},
	],
	"sets": {
		"fungaio": {"name": "Il fungaio", "pieces": ["cappello_fungaio", "casacca_fungaio", "ghette_fungaio"],
			"bonus": {"regen": 1.25, "luck": 0.15}, "desc": "la Vita ricresce +25%, più fortuna"},
	},
	"genes": {
		"cappelli": {"cat": "superficie", "name": "Cappelli", "rar": 1, "dom": 2, "good": true,
			"desc": "colline di micelio e funghi giganti", "item": "seme_mondo_cappelli",
			"gen": {"biomes": {"funghi": 6, "palude": 2, "foresta": 1}}},
	},
}
