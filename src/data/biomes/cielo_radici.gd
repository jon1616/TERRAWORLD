extends RefCounted
## Le Radici sospese (Roadmap 16, voce 156, cielo basso): zolle di terra di cielo tenute insieme dalle radici, felci d'aria e bulbi che brillano; radici che pendono fino a terra.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "radici_sospese", "name": "Radici sospese", "desc": "zolle di terra che galleggiano, tenute insieme dalle radici",
	"band": "basso", "color": "#8ef0c8", "weight": 4, "floor": 50, "body": 51, "rock": 51, "isle": "zolla", "isles": 2.2,
	"pools": 0.25, "trees": 0.5, "danger": 1.2, "thin": 0.0, "elem": "linfa", "adj": ["sospese", "pensili"],
	"tiles": {
		50: {"name": "Erba di cielo", "hard": 0.22, "power": 0, "drop": "terra_cielo", "grass": true,
			"pal": ["#123a3a", "#1f5c58", "#2f8a7c", "#58c0a4", "#a8f0d8"], "layer": "erba_cielo", "specks": 20},
		51: {"name": "Terra di cielo", "hard": 0.24, "power": 0, "drop": "terra_cielo",
			"pal": ["#262238", "#3a3452", "#544c74", "#7a729c", "#b0a8d4"], "layer": "terra_cielo", "specks": 14},
	},
	"veg": [[0.18, 80], [0.26, 81], [0.4, "fronda"], [0.46, "fiori"]],
	"decor": {80: {"soft": "erba"}, 81: {"soft": "pianta", "light": Color(0.2, 0.5, 0.45)}},
	"items": {
		"terra_cielo": {"name": "Terra di cielo", "kind": "blocco", "icon": ["zolla", "cielo"], "place": 51,
			"desc": "Terra leggera delle isole sospese: sta dove la metti, anche nel vuoto accanto a un blocco."},
	},
}
