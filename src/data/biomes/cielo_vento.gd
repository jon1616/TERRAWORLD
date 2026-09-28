extends RefCounted
## I Giardini del vento (Roadmap 16, voce 156, cielo basso): erba dorata piegata dal vento, fiori-girandola, correnti ovunque.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "giardini_vento", "name": "Giardini del vento", "desc": "erba dorata piegata dal vento, e correnti che sollevano",
	"band": "basso", "color": "#ffe070", "weight": 3, "floor": 54, "body": 51, "rock": 51, "isle": "giardino", "isles": 1.8,
	"pools": 0.15, "trees": 0.2, "danger": 1.2, "thin": 0.0, "elem": "luce", "currents": 2, "adj": ["ventose", "dorate"],
	"tiles": {
		54: {"name": "Erba del vento", "hard": 0.22, "power": 0, "drop": "terra_cielo", "grass": true,
			"pal": ["#4a3a14", "#7a6020", "#b08c30", "#e0c050", "#fff0a0"], "layer": "erba_vento", "specks": 18},
	},
	"veg": [[0.3, 84], [0.4, 85], [0.46, "fiori"]],
	"decor": {84: {"soft": "erba"}, 85: {"soft": "pianta", "light": Color(0.35, 0.3, 0.1)}},
	"items": {},
}
