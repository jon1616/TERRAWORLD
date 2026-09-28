extends RefCounted
## Il Mare di nuvole (Roadmap 16, voce 156, cielo basso): banchi di nuvola morbida su cui si cammina (attutiscono le cadute), pozze di pioggia, fiori di pioggia.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "mare_nubi", "name": "Mare di nuvole", "desc": "banchi di nuvola morbida su cui si cammina, pozze di pioggia",
	"band": "basso", "color": "#e4eefa", "weight": 4, "floor": 52, "body": 52, "rock": 52, "isle": "nuvola", "isles": 2.0,
	"pools": 0.5, "trees": 0.0, "danger": 1.15, "thin": 0.0, "elem": "gelo", "adj": ["nuvolose", "bianche"],
	"tiles": {
		52: {"name": "Nuvola", "hard": 0.1, "power": 0, "drop": "nuvola",
			"pal": ["#6a7a98", "#9aaccc", "#c4d4ec", "#e4eefa", "#ffffff"], "layer": "nuvola", "specks": 0},
	},
	"veg": [[0.2, 82], [0.28, 83]],
	"decor": {82: {"soft": "erba"}, 83: {"soft": "pianta", "light": Color(0.25, 0.35, 0.5)}},
	"items": {
		"nuvola": {"name": "Nuvola", "kind": "blocco", "icon": ["zolla", "nuvola"], "place": 52,
			"desc": "Si posa come un blocco e si scava in un attimo. Chi ci cade sopra non si fa male."},
	},
}
