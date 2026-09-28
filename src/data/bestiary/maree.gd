extends RefCounted
## I premi delle maree del mondo (voce 137): le tabelle di bottino (le unisce `LootData.TABLES`) e il Sigillo della
## marea, l'oggetto che si fa con i premi di tutte e sei. Scritto a mano; non nomina altre classi.

const DATA := {
	"loot": {
		"marea_spore": [{"item": "cuore_spore", "min": 1, "max": 2, "chance": 1.0}, {"item": "pozione_rigoglio", "min": 1, "max": 2, "chance": 0.8},
			{"item": "lumino", "min": 20, "max": 40, "chance": 1.0}, {"item": "sigillo_spore", "min": 1, "max": 1, "chance": 1.0}],
		"marea_migrazione": [{"item": "pelliccia_rossa_antica", "min": 1, "max": 2, "chance": 1.0}, {"item": "palco_iride", "min": 2, "max": 4, "chance": 0.8},
			{"item": "lumino", "min": 20, "max": 40, "chance": 1.0}, {"item": "sigillo_migrazione", "min": 1, "max": 1, "chance": 1.0}],
		"marea_assedio": [{"item": "artiglio_talpone_radici", "min": 1, "max": 2, "chance": 1.0}, {"item": "lingotto_legnoferro", "min": 4, "max": 8, "chance": 1.0},
			{"item": "lumino", "min": 30, "max": 60, "chance": 1.0}, {"item": "sigillo_assedio", "min": 1, "max": 1, "chance": 1.0}],
		"marea_brace": [{"item": "scaglia_drago", "min": 1, "max": 2, "chance": 1.0}, {"item": "lingotto_tizzonite", "min": 2, "max": 4, "chance": 0.8},
			{"item": "lumino", "min": 20, "max": 40, "chance": 1.0}, {"item": "sigillo_brace", "min": 1, "max": 1, "chance": 1.0}],
		"marea_stormo": [{"item": "penna_aquila", "min": 1, "max": 2, "chance": 1.0}, {"item": "piuma_pavoncella", "min": 4, "max": 8, "chance": 0.8},
			{"item": "lumino", "min": 20, "max": 40, "chance": 1.0}, {"item": "sigillo_stormo", "min": 1, "max": 1, "chance": 1.0}],
		"marea_eclissi": [{"item": "piuma_notte", "min": 1, "max": 2, "chance": 1.0}, {"item": "frammento_eclissi", "min": 2, "max": 4, "chance": 0.8},
			{"item": "lumino", "min": 20, "max": 40, "chance": 1.0}, {"item": "sigillo_eclissi", "min": 1, "max": 1, "chance": 1.0}],
	},
	"items": {
		"sigillo_spore": {"name": "Sigillo della Notte delle spore", "kind": "materiale", "icon": ["tavoletta", "fungo"], "desc": "Il ricordo di una marea respinta."},
		"sigillo_migrazione": {"name": "Sigillo della Migrazione", "kind": "materiale", "icon": ["tavoletta", "ambra"], "desc": "Il ricordo di una marea respinta."},
		"sigillo_assedio": {"name": "Sigillo dell'Assedio", "kind": "materiale", "icon": ["tavoletta", "radice"], "desc": "La tua casa ha retto."},
		"sigillo_brace": {"name": "Sigillo della Marea di brace", "kind": "materiale", "icon": ["tavoletta", "brace"], "desc": "Il ricordo di una marea respinta."},
		"sigillo_stormo": {"name": "Sigillo dello Stormo", "kind": "materiale", "icon": ["tavoletta", "seta"], "desc": "Il ricordo di una marea respinta."},
		"sigillo_eclissi": {"name": "Sigillo dell'Eclissi dei mimi", "kind": "materiale", "icon": ["tavoletta", "nottilite"], "desc": "Il ricordo di una marea respinta."},
		"corona_maree": {"name": "Corona delle sei maree", "kind": "accessorio", "icon": ["amuleto", "brillaluce"], "stack": 1,
			"acc": {"damage": 1.12, "defense": 4, "luck": 0.1, "regen": 1.1}, "desc": "Chi ha respinto tutte le maree: danno +12%, +4 Scorza, fortuna +10%, Vita +10%."},
	},
	"recipes": [
		{"out": "corona_maree", "qty": 1, "in": {"sigillo_spore": 1, "sigillo_migrazione": 1, "sigillo_assedio": 1, "sigillo_brace": 1,
			"sigillo_stormo": 1, "sigillo_eclissi": 1, "lingotto_stellare": 4}, "station": "altare"},
	],
}
