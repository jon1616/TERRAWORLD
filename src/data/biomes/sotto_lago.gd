extends RefCounted
## I Laghi sotterranei (voce 94, sottosuolo): nelle Caverne d'ardesia, caverne con un lago d'acqua ferma sopra un fondo
## di fango. Li porta il gene «Laghi profondi». Granchi di lago sulle rive, Meduse di grotta sull'acqua (e i pesci delle
## acque di sempre dentro). Campi in cima a `UnderBiomesData`; questo file non nomina altre classi.

const DATA := {
	"id": "lago", "name": "Laghi sotterranei", "desc": "acqua ferma e nera in fondo alle caverne, rive di fango",
	"stratum": 2, "count": 6, "build": "lago", "floor": 42,
	"tiles": {42: {"name": "Fango lacustre", "hard": 0.25, "power": 0, "drop": "fango_lago",
		"pal": ["#1a1c1a", "#2a302a", "#3e4a40", "#5a6a5a", "#8a9a88"], "layer": "fango_lago", "specks": 30}},
	"veg": [[0.2, 73], [0.24, "bagliore"]],
	"decor": {73: {"soft": "pianta", "light": Color(0.1, 0.3, 0.35)}},
	"adj": ["sommersi", "sommerse"],                  # l'aggettivo nei nomi dei mondi (`NamesData.ADJ`)
	"creatures": {
		"granchio_lago": {"name": "Granchio di lago", "hp": 52, "damage": 13, "defense": 6, "knock": 0.6, "half": [10, 6],
			"speed": 55, "behaviors": ["cammina", "carica"],
			"p": {"sight": 16, "charge": 220.0, "charge_range": 6, "charge_time": 0.5, "charge_cool": 2.6},
			"loot": "granchio_lago", "art": ["granchio_lago", 0], "strata": [2], "weight": 0, "under": "lago", "uw": 7,
			"body": {"plan": "insetto", "w": 22, "h": 14, "pal": ["#1a2a30", "#2e4650", "#4a6a78", "#7aa0b0", "#c0e0e8"],
				"eye": "#ffd24a", "marks": "punte", "mark": "#c0e0e8"},
			"affinity": {"weak": ["brace"], "resist": ["gelo"]}, "trophy": "chela_maestra"},
		"medusa_grotta": {"name": "Medusa di grotta", "hp": 28, "damage": 10, "defense": 0, "knock": 0.0, "half": [7, 8],
			"speed": 45, "fly": true, "behaviors": ["vola"], "p": {"sight": 20, "hover": 30.0, "wobble": 30.0},
			"loot": "medusa_grotta", "art": ["medusa_grotta", 0], "strata": [2], "weight": 0, "under": "lago", "uw": 6, "glow": true,
			"body": {"plan": "fluttuante", "w": 18, "h": 20, "pal": ["#0a2a36", "#12566a", "#1f8a9a", "#5cc8cc", "#b8f4f0"],
				"eye": "#5cf0d8", "glow": true},
			"affinity": {"weak": ["gelo"], "resist": ["linfa"]}, "trophy": "campana_medusa"},
	},
	"families": {
		"granchi": {"name": "Granchi di lago", "members": ["granchio_lago"], "fem": false, "role": "neutro"},
		"meduse": {"name": "Meduse di grotta", "members": ["medusa_grotta"], "fem": true, "role": "volante"},
	},
	"loot": {
		"granchio_lago": [{"item": "carapace_lago", "min": 1, "max": 2, "chance": 1.0}],
		"medusa_grotta": [{"item": "gelatina_lago", "min": 1, "max": 2, "chance": 1.0}],
	},
	"items": {
		"fango_lago": {"name": "Fango lacustre", "kind": "materiale", "icon": ["polvere", "humus"], "desc": "Il fondo dei laghi sotterranei: fresco e liscio.",
			"used_for": "le tinture e l'orto (ci crescono le radici d'acqua)"},
		"carapace_lago": {"name": "Carapace di granchio", "kind": "materiale", "icon": ["scaglia", "lagunite"], "desc": "Duro, azzurro, bagnato per sempre."},
		"gelatina_lago": {"name": "Gelatina di medusa", "kind": "materiale", "icon": ["essenza", "linfa"], "desc": "Brilla appena, e punge un poco."},
		"chela_maestra": {"name": "Chela maestra", "kind": "trofeo", "icon": ["artiglio", "lagunite"], "desc": "La lasciano solo le creature rare di questa specie."},
		"campana_medusa": {"name": "Campana di medusa", "kind": "trofeo", "icon": ["essenza", "lagunite"], "desc": "La lasciano solo le creature rare di questa specie."},
		"guscio_abisso": {"name": "Guscio dell'abisso", "kind": "accessorio", "icon": ["amuleto", "lagunite"], "unique": true, "stack": 1,
			"acc": {"respiro": 2.0}, "effects": ["anfibio", "profondo"],
			"story": "Un granchio lo portava sulla schiena da prima che il lago avesse un nome.",
			"source": "si fabbrica con i trofei delle creature rare dei Laghi sotterranei",
			"desc": "Respiro sott'acqua raddoppiato; nell'acqua più svelto; più forte nel profondo."},
		"elmo_carapace": {"name": "Elmo di carapace", "kind": "elmo", "icon": ["elmo", "lagunite"], "tier": 3, "defense": 4, "acc": {"respiro": 1.4},
			"desc": "Respiro sott'acqua +40%."},
	},
	"recipes": [
		{"out": "guscio_abisso", "qty": 1, "in": {"chela_maestra": 1, "campana_medusa": 1, "carapace_lago": 8}, "station": "maglio"},
		{"out": "elmo_carapace", "qty": 1, "in": {"carapace_lago": 6, "gelatina_lago": 3}, "station": "maglio"},
	],
	"genes": {
		"laghi_profondi": {"cat": "sottosuolo", "name": "Laghi profondi", "rar": 1, "dom": 2, "good": true,
			"desc": "laghi d'acqua nelle Caverne d'ardesia", "gen": {"under": ["lago"]}},
	},
}
