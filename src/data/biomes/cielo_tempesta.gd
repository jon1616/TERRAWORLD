extends RefCounted
## I Nidi di tempesta (Roadmap 16, voce 156, cielo alto): nuvole scure cariche di fulmini; nella roccia la folgorite.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "nidi_tempesta", "name": "Nidi di tempesta", "desc": "nuvole scure cariche, e fulmini che cercano i punti alti",
	"band": "alto", "color": "#a0b0d8", "weight": 3, "floor": 53, "body": 53, "rock": 53, "isle": "tempesta", "isles": 1.8,
	"pools": 0.2, "trees": 0.0, "danger": 2.0, "thin": 1.2, "elem": "luce", "bolts": 1, "adj": ["tempestose", "folgoranti"],
	"tiles": {
		53: {"name": "Nuvola di tempesta", "hard": 0.3, "power": 0, "drop": "nuvola_tempesta",
			"pal": ["#1a1e2e", "#2c3248", "#434c68", "#66729a", "#a0b0d8"], "layer": "nuvola_tempesta", "specks": 10, "pass": 0.8},
	},
	"veg": [[0.14, 88], [0.2, 89]],
	"decor": {88: {"soft": "erba"}, 89: {"soft": "pianta", "light": Color(0.35, 0.4, 0.7)}},
	"items": {
		"nuvola_tempesta": {"name": "Nuvola di tempesta", "kind": "blocco", "icon": ["zolla", "tempesta"], "place": 53,
			"desc": "Una nuvola scura che ronza appena: si posa come un blocco."},
	},
}
