extends RefCounted
## Le Selve pensili (voce 442, cielo medio): foreste sospese di alberi-lanterna, liane che pendono nel vuoto, i fiori che
## fanno luce. Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "selve_pensili", "name": "Selve pensili", "desc": "foreste sospese, e liane che pendono nel vuoto",
	"band": "medio", "color": "#5ad890", "weight": 3, "floor": 120, "body": 51, "rock": 51, "isle": "giardino", "isles": 2.0,
	"pools": 0.2, "trees": 0.75, "danger": 1.4, "thin": 0.0, "elem": "linfa", "adj": ["pensili", "pensili"],
	"tiles": {
		120: {"name": "Muschio pensile", "hard": 0.22, "power": 0, "drop": "terra_cielo", "grass": true,
			"pal": ["#12301e", "#1e5232", "#2e7a48", "#56b070", "#a8f0b8"], "layer": "erba_selve", "specks": 16},
	},
	"veg": [[0.32, 106], [0.44, 107]],
	"decor": {106: {"soft": "pianta"}, 107: {"soft": "pianta", "light": Color(0.25, 0.45, 0.2)}},
	"items": {},
	"genes": {
		"cielo_selve": {"cat": "cielo", "name": "Selve sospese", "rar": 2, "dom": 2, "good": true,
			"desc": "nel cielo di mezzo le selve pensili, con le liane e i tucani-lanterna",
			"gen": {"sky": {"selve_pensili": 5.0}}},
	},
}
