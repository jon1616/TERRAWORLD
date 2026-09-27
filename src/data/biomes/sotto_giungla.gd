extends RefCounted
## Le Giungle di radici (voce 94, sottosuolo): nel Sottobosco, sale larghe di muschio di giungla con radici che pendono
## e felci giganti che fanno luce. Le porta il gene «Giungle di radici». Liane predatrici (aspettano appese al soffitto)
## e Scimmie di radice. Campi in cima a `UnderBiomesData`; questo file non nomina altre classi.

const DATA := {
	"id": "giungla", "name": "Giungle di radici", "desc": "sale di muschio e felci giganti, radici che pendono dal buio",
	"stratum": 1, "count": 8, "build": "giungla", "floor": 41,
	"tiles": {41: {"name": "Muschio di giungla", "hard": 0.25, "power": 0, "drop": "humus", "grass": true,
		"pal": ["#0a2410", "#143a1a", "#22582a", "#3a8040", "#7ac070"], "layer": "muschio_giungla", "specks": 70}},
	"veg": [[0.3, 70], [0.42, 71], [0.5, "felce"], [0.54, "bagliore"]],
	"decor": {70: {"soft": "pianta"}, 71: {"soft": "pianta", "light": Color(0.15, 0.4, 0.2)}},
	"adj": ["selvaggi", "selvagge"],                  # l'aggettivo nei nomi dei mondi (`NamesData.ADJ`)
	"creatures": {
		"liana_predatrice": {"name": "Liana predatrice", "hp": 38, "damage": 12, "defense": 1, "knock": 0.3, "half": [10, 4],
			"speed": 60, "behaviors": ["agguato", "salta_verso"], "p": {"sight": 16, "jump": 200.0},
			"loot": "liana_predatrice", "art": ["liana_predatrice", 0], "strata": [1], "weight": 0, "under": "giungla", "uw": 6,
			"body": {"plan": "serpe", "w": 26, "h": 12, "pal": ["#0a2410", "#143a1a", "#22582a", "#3a8040", "#7ac070"],
				"eye": "#ff7a3a", "marks": "macchie", "mark": "#b0d04a"},
			"affinity": {"weak": ["brace"], "resist": ["spora"]}, "trophy": "cuore_liana"},
		"scimmia_radice": {"name": "Scimmia di radice", "hp": 30, "damage": 9, "defense": 1, "knock": 0.2, "half": [7, 7],
			"speed": 105, "behaviors": ["salta_verso"], "p": {"jump": 330.0, "sight": 22}, "group": [2, 3],
			"loot": "scimmia_radice", "art": ["scimmia_radice", 0], "strata": [1], "weight": 0, "under": "giungla", "uw": 7,
			"body": {"plan": "quadrupede", "w": 18, "h": 16, "pal": ["#2a1810", "#4a2c1a", "#6e4426", "#9a6636", "#d0a070"],
				"eye": "#ffd24a", "tail": true},
			"affinity": {"weak": ["gelo"], "resist": []}, "trophy": "coda_scimmia"},
	},
	"families": {
		"liane": {"name": "Liane predatrici", "members": ["liana_predatrice"], "fem": true, "role": "predatore", "prey": ["scimmie", "saltafunghi"]},
		"scimmie": {"name": "Scimmie di radice", "members": ["scimmia_radice"], "fem": true, "role": "erbivoro", "nest": {"type": "tana", "n": 3}},
	},
	"loot": {
		"liana_predatrice": [{"item": "fibra_liana", "min": 1, "max": 3, "chance": 1.0}],
		"scimmia_radice": [{"item": "fibra_liana", "min": 1, "max": 1, "chance": 0.5}, {"item": "seme_lanterna", "min": 1, "max": 2, "chance": 0.4}],
	},
	"items": {
		"fibra_liana": {"name": "Fibra di liana", "kind": "materiale", "icon": ["seta", "muschio"], "desc": "Forte come una corda, verde come la giungla."},
		"cuore_liana": {"name": "Cuore di liana", "kind": "trofeo", "icon": ["essenza", "muschio"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"coda_scimmia": {"name": "Coda di scimmia", "kind": "trofeo", "icon": ["penna", "legno"], "desc": "La lasciano solo le creature rare di questa specie."},
		"liana_viva": {"name": "Liana viva", "kind": "accessorio", "icon": ["seta", "muschio"], "unique": true, "stack": 1,
			"acc": {"wall": true, "jump": 1.1}, "effects": ["rigenera_fermo"],
			"story": "Una liana che non si è mai staccata dalla sua radice: si allunga da sola verso chi la tiene.",
			"source": "si fabbrica con i trofei delle creature rare delle Giungle di radici",
			"desc": "Ti aggrappi alle pareti e ci salti via; salto +10%; fermo, guarisci più in fretta."},
		"corda_liana": {"name": "Corda di liana", "kind": "materiale", "icon": ["seta", "legno"], "desc": "Fibra di liana intrecciata: tiene qualunque cosa.",
			"used_for": "le corde dei rampini e delle trappole"},
	},
	"recipes": [
		{"out": "liana_viva", "qty": 1, "in": {"cuore_liana": 1, "coda_scimmia": 1, "fibra_liana": 10}, "station": "maglio"},
		{"out": "corda_liana", "qty": 2, "in": {"fibra_liana": 3}, "station": "telaio"},
	],
	"genes": {
		"giungle_radici": {"cat": "sottosuolo", "name": "Giungle di radici", "rar": 1, "dom": 2, "good": true,
			"desc": "giungle di muschio e radici nel Sottobosco", "gen": {"under": ["giungla"]}},
	},
}
