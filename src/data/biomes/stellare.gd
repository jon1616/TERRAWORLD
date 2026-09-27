extends RefCounted
## Le Radure stellari (voce 94, bioma **raro**): nascono solo da un innesto con mutazione (gene «Cielo caduto»). Erba
## blu notte punteggiata di luci, alberi di cristallo, e lo **Stellino**, che si trova solo qui: una stella caduta che
## vaga e lascia Frammenti di stella. Tutto il bioma sta in questo file (campi in cima a `BiomesData`).

const DATA := {
	"id": "stellare", "name": "Radure stellari", "desc": "Un pezzo di cielo caduto a terra: l'erba è piena di stelle",
	"trees": 0.1, "hills": 0.8, "lift": 0, "tint": Color(0.7, 0.8, 1.3), "color": "#c0d0ff", "weight": 0,
	"grass": 45,
	"turf": {"name": "Erba stellata", "layer": "erba_stellata", "pal": ["#0a1030", "#141e50", "#243470", "#4a60a8", "#f0f4ff"], "specks": 140},
	"tree": {"id": "cristallo_stellare", "name": "Albero di stelle", "glow": Color(1.6, 1.7, 2.2), "art": "cristallo_gelo"},
	"veg": [[0.3, 76], [0.38, 77]],
	"decor": {76: {"soft": "erba"}, 77: {"light": Color(0.3, 0.35, 0.6)}},
	"elem": "luce",
	"gene": "cielo_caduto",
	"lands": [["Radure", true], ["Cieli caduti", false], ["Prati di stelle", false]],
	"creatures": {
		"stellino": {"name": "Stellino", "hp": 40, "damage": 0, "defense": 1, "knock": 0.0, "half": [7, 7], "speed": 60,
			"fly": true, "behaviors": ["vola", "fugge"], "p": {"sight": 20, "hover": 40.0, "wobble": 30.0, "flee": 10},
			"no_trophy": true,
			"loot": "stellino", "art": ["stellino", 0], "strata": [0], "weight": 3, "biomes": ["stellare"], "glow": true, "night": false,
			"body": {"plan": "fluttuante", "w": 16, "h": 16, "pal": ["#4a4a20", "#8a8a3a", "#e0d060", "#fff0a0", "#ffffff"],
				"eye": "#ffffff", "marks": "punte", "mark": "#fff0a0", "glow": true},
			"affinity": {"weak": ["vuoto"], "resist": ["luce", "brace"]}},
	},
	"families": {
		"stellini": {"name": "Stellini", "members": ["stellino"], "fem": false, "role": "volante"},
	},
	"loot": {
		"stellino": [{"item": "frammento_stella", "min": 1, "max": 2, "chance": 1.0}, {"item": "brillaluce", "min": 1, "max": 1, "chance": 0.3}],
	},
	"items": {
		"frammento_stella": {"name": "Frammento di stella", "kind": "materiale", "icon": ["gemma", "brillaluce"], "desc": "Caldo come una mano, luminoso come la notte che manca."},
		"cuore_stellare_vivo": {"name": "Stella in tasca", "kind": "accessorio", "icon": ["essenza", "brillaluce"], "unique": true, "stack": 1,
			"acc": {"halo": 1.8, "magic": 1.2}, "effects": ["notturno"],
			"story": "Uno Stellino si è addormentato in una tasca e non ha più voluto uscire.",
			"source": "si fabbrica con i Frammenti di stella degli Stellini, che vivono solo nelle Radure stellari",
			"desc": "Alone grandissimo, incantesimi +20%; più forte di notte."},
		"seme_mondo_stelle": {"name": "Seme di stelle", "kind": "seme_mondo", "icon": ["seme", "brillaluce"], "species": "cielo_caduto", "stack": 1,
			"source": "nasce solo da un innesto, quando il Seme muta",
			"desc": "Un Seme di mondo che brilla al buio: dietro il suo portale, radure stellari."},
	},
	"recipes": [
		{"out": "cuore_stellare_vivo", "qty": 1, "in": {"frammento_stella": 12, "brillaluce": 3}, "station": "maglio"},
	],
	"genes": {
		"cielo_caduto": {"cat": "superficie", "name": "Cielo caduto", "rar": 3, "dom": 1, "good": true, "only": "mutazione",
			"desc": "radure stellari dove vagano gli Stellini", "item": "seme_mondo_stelle",
			"gen": {"biomes": {"stellare": 6, "brina": 2, "foresta": 1}}},
	},
}
