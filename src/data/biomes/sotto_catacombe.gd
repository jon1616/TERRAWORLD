extends RefCounted
## Le Catacombe dei Seminatori (voce 94, sottosuolo): nelle Profondità della Linfa, gallerie squadrate di mattoni con
## le celle ai lati e uno scrigno antico in fondo. Le porta il gene «Catacombe». Sentinelle di pietra che caricano e
## Anime erranti. Campi in cima a `UnderBiomesData`; questo file non nomina altre classi.

const DATA := {
	"id": "catacombe", "name": "Catacombe dei Seminatori", "desc": "gallerie di mattoni antichi, celle chiuse e uno scrigno in fondo",
	"stratum": 3, "count": 4, "build": "catacombe", "floor": 43,
	"tiles": {43: {"name": "Mattone di catacomba", "hard": 0.9, "power": 45, "drop": "mattone_catacomba",
		"pal": ["#2a2a26", "#3e3c34", "#5a5646", "#7a7460", "#a8a088"], "layer": "mattone_catacomba", "specks": 0, "square": true}},
	"adj": ["sepolti", "sepolte"],                  # l'aggettivo nei nomi dei mondi (`NamesData.ADJ`)
	"creatures": {
		"sentinella_sem": {"name": "Sentinella dei Seminatori", "hp": 120, "damage": 20, "defense": 9, "knock": 0.9, "half": [11, 11],
			"speed": 45, "behaviors": ["cammina", "carica"],
			"p": {"sight": 18, "charge": 260.0, "charge_range": 9, "charge_time": 0.8, "charge_cool": 3.5},
			"loot": "sentinella_sem", "art": ["sentinella_sem", 0], "strata": [3], "weight": 0, "under": "catacombe", "uw": 4, "glow": true,
			"body": {"plan": "quadrupede", "w": 26, "h": 24, "pal": ["#2c3a3a", "#405656", "#587270", "#74908c", "#9cb6b0"],
				"eye": "#6ff0b8", "marks": "macchie", "mark": "#6ff0b8", "glow": true, "horns": 1},
			"affinity": {"weak": ["vuoto"], "resist": ["brace", "gelo"]}, "trophy": "nucleo_sentinella"},
		"anima_errante": {"name": "Anima errante", "hp": 34, "damage": 12, "defense": 0, "knock": 0.0, "half": [7, 9],
			"speed": 60, "fly": true, "behaviors": ["vola", "teletrasporto"], "p": {"sight": 26, "hover": 40.0, "wobble": 25.0},
			"loot": "anima_errante", "art": ["anima_errante", 0], "strata": [3], "weight": 0, "under": "catacombe", "uw": 6, "glow": true,
			"body": {"plan": "fluttuante", "w": 18, "h": 22, "pal": ["#1c2a2a", "#2e4848", "#4a7070", "#8ab0a8", "#e0fff4"],
				"eye": "#e0fff4", "glow": true},
			"affinity": {"weak": ["luce"], "resist": ["vuoto", "spora"]}, "trophy": "eco_anima"},
	},
	"families": {
		"sentinelle": {"name": "Sentinelle dei Seminatori", "members": ["sentinella_sem"], "fem": true, "role": "neutro"},
		"anime": {"name": "Anime erranti", "members": ["anima_errante"], "fem": true, "role": "volante"},
	},
	"loot": {
		"sentinella_sem": [{"item": "mattone_catacomba", "min": 2, "max": 4, "chance": 1.0}, {"item": "linfa_antica", "min": 1, "max": 1, "chance": 0.25}],
		"anima_errante": [{"item": "cenere_antica", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"mattone_catacomba": {"name": "Mattone di catacomba", "kind": "materiale", "icon": ["lingotto", "sem"], "desc": "Un mattone dei Seminatori, con un segno inciso che non si legge più."},
		"cenere_antica": {"name": "Cenere antica", "kind": "materiale", "icon": ["polvere", "sem"], "desc": "Quel che resta di un'Anima errante: sa ancora qualche parola."},
		"nucleo_sentinella": {"name": "Nucleo di sentinella", "kind": "trofeo", "icon": ["essenza", "sem"], "desc": "Lo lasciano solo le creature rare di questa specie."},
		"eco_anima": {"name": "Eco d'anima", "kind": "trofeo", "icon": ["occhio", "sem"], "desc": "La lasciano solo le creature rare di questa specie."},
		"sigillo_custode": {"name": "Sigillo del custode", "kind": "accessorio", "icon": ["anello", "sem"], "unique": true, "stack": 1,
			"acc": {"luck": 0.2, "stealth": 0.85}, "effects": ["ombra_ferito", "notturno"],
			"story": "Il sigillo con cui l'ultimo custode chiuse le catacombe. Dentro è rimasto il suo passo leggero.",
			"source": "si fabbrica con i trofei delle creature rare delle Catacombe dei Seminatori",
			"desc": "Più fortuna, le creature ti notano più tardi; ferito ti nascondi nell'ombra; più forte di notte."},
		"lanterna_catacomba": {"name": "Lanterna delle catacombe", "kind": "accessorio", "icon": ["lanterna", "sem"], "acc": {"halo": 1.3, "luck": 0.08},
			"desc": "Alone più ampio, un poco di fortuna."},
	},
	"recipes": [
		{"out": "sigillo_custode", "qty": 1, "in": {"nucleo_sentinella": 1, "eco_anima": 1, "cenere_antica": 10}, "station": "maglio"},
		{"out": "lanterna_catacomba", "qty": 1, "in": {"mattone_catacomba": 6, "cenere_antica": 4, "cristallo_linfa": 1}, "station": "maglio"},
	],
	"genes": {
		"catacombe": {"cat": "sottosuolo", "name": "Catacombe", "rar": 2, "dom": 2, "good": true,
			"desc": "catacombe dei Seminatori nelle Profondità della Linfa", "gen": {"under": ["catacombe"]}},
	},
}
