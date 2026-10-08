extends RefCounted
## Le Fonti sospese (voce 442, cielo medio): isole con laghi che traboccano, felci d'acqua e gigli che brillano; l'acqua
## cade nel vuoto e non arriva mai a terra. Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "fonti_sospese", "name": "Fonti sospese", "desc": "laghi nel cielo, e cascate che non toccano mai terra",
	"band": "medio", "color": "#7ad8f0", "weight": 3, "floor": 121, "body": 51, "rock": 51, "isle": "zolla", "isles": 1.8,
	"pools": 0.85, "trees": 0.25, "danger": 1.45, "thin": 0.0, "elem": "luce", "adj": ["sorgivi", "sorgive"],
	"tiles": {
		121: {"name": "Muschio delle fonti", "hard": 0.22, "power": 0, "drop": "terra_cielo", "grass": true,
			"pal": ["#0e2a3a", "#16506a", "#2a8aa0", "#5ac8d8", "#c8f8ff"], "layer": "erba_fonti", "specks": 14},
	},
	"veg": [[0.3, 108], [0.4, 109]],
	"decor": {108: {"soft": "pianta"}, 109: {"soft": "pianta", "light": Color(0.3, 0.45, 0.55)}},
	"items": {},
	"genes": {
		"cielo_fonti": {"cat": "cielo", "name": "Fonti del cielo", "rar": 2, "dom": 2, "good": true,
			"desc": "nel cielo di mezzo le fonti sospese, con i laghi e le cascate",
			"gen": {"sky": {"fonti_sospese": 5.0}}},
	},
}
