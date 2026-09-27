extends RefCounted
## I Boschi dei sussurri (voce 94, bioma **raro**): nascono solo da un innesto con mutazione (gene «Sussurri»). Il bosco
## dove i Seminatori piantarono i primi Semi: sequoie pallide, muschio d'argento, e l'**Ombra di Seminatore**, che si
## trova solo qui: vaga senza far male e, sconfitta, lascia Linfa antica e una Cenere di parola. Tutto il bioma sta in
## questo file (campi in cima a `BiomesData`).

const DATA := {
	"id": "sussurri", "name": "Boschi dei sussurri", "desc": "Alberi pallidi e un silenzio pieno di voci: qui camminavano i Seminatori",
	"trees": 0.45, "hills": 1.0, "lift": -2, "tint": Color(0.9, 1.05, 1.05), "color": "#a8f0e0", "weight": 0,
	"grass": 46,
	"turf": {"name": "Muschio d'argento", "layer": "muschio_argento", "pal": ["#1a2a2a", "#2e4444", "#4a6a68", "#8ab0a8", "#e0fff4"], "specks": 80},
	"tree": {"id": "sequoia_pallida", "name": "Sequoia pallida", "glow": Color(1.3, 1.8, 1.7), "art": "sequoia"},
	"veg": [[0.3, 78], [0.38, 79], [0.44, "felce"]],
	"decor": {78: {"soft": "erba"}, 79: {"light": Color(0.15, 0.45, 0.4)}},
	"elem": "linfa",
	"gene": "sussurri",
	"lands": [["Boschi dei sussurri", false], ["Selve antiche", true], ["Radure dei Seminatori", true]],
	"creatures": {
		"ombra_seminatore": {"name": "Ombra di Seminatore", "hp": 70, "damage": 0, "defense": 3, "knock": 0.5, "half": [7, 14],
			"speed": 40, "fly": true, "behaviors": ["vola"], "p": {"sight": 10, "hover": 10.0, "wobble": 15.0}, "docile": true,
			"no_trophy": true,
			"loot": "ombra_seminatore", "art": ["ombra_seminatore", 0], "strata": [0], "weight": 2, "biomes": ["sussurri"], "glow": true,
			"body": {"plan": "fluttuante", "w": 16, "h": 30, "pal": ["#10201e", "#1c3634", "#2e5450", "#6ab0a0", "#c8fff0"],
				"eye": "#6ff0b8", "glow": true, "marks": "strisce", "mark": "#6ff0b8"},
			"affinity": {"weak": ["luce"], "resist": ["vuoto", "spora", "gelo"]}},
	},
	"families": {
		"ombre": {"name": "Ombre di Seminatore", "members": ["ombra_seminatore"], "fem": true, "role": "neutro"},
	},
	"loot": {
		"ombra_seminatore": [{"item": "linfa_antica", "min": 1, "max": 2, "chance": 1.0}, {"item": "cenere_parola", "min": 1, "max": 1, "chance": 0.5}],
	},
	"items": {
		"cenere_parola": {"name": "Cenere di parola", "kind": "materiale", "icon": ["polvere", "sem"], "desc": "Una parola dei Seminatori ridotta in cenere: sussurra ancora."},
		"voce_seminatore": {"name": "Voce del Seminatore", "kind": "accessorio", "icon": ["amuleto", "sem"], "unique": true, "stack": 1,
			"acc": {"luck": 0.2, "regen": 1.2, "magic": 1.1}, "effects": ["seconda_vita"],
			"story": "Dentro c'è l'ultima frase che un Seminatore disse al Giardino. Si sente solo quando sei sul punto di cadere.",
			"source": "si fabbrica con la Cenere di parola delle Ombre di Seminatore, nei Boschi dei sussurri",
			"desc": "Più fortuna, la Vita ricresce +20%, incantesimi +10%; una volta per giorno non appassisci."},
		"seme_mondo_sussurri": {"name": "Seme dei sussurri", "kind": "seme_mondo", "icon": ["seme", "sem"], "species": "sussurri", "stack": 1,
			"source": "nasce solo da un innesto, quando il Seme muta",
			"desc": "Un Seme di mondo che sussurra: dietro il suo portale, i boschi dove camminavano i Seminatori."},
	},
	"recipes": [
		{"out": "voce_seminatore", "qty": 1, "in": {"cenere_parola": 8, "linfa_antica": 4}, "station": "maglio"},
	],
	"genes": {
		"sussurri": {"cat": "superficie", "name": "Sussurri", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
			"desc": "i boschi dei Seminatori, dove vagano le loro ombre", "item": "seme_mondo_sussurri",
			"gen": {"biomes": {"sussurri": 6, "foresta": 2, "rossa": 1}}},
	},
}
