extends RefCounted
## Le Scogliere di cristallo (Roadmap 16, voce 156, cielo alto): scogli di cristallo celeste che brillano nel cielo alto; l'aria comincia a mancare.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "scogliere_cristallo", "name": "Scogliere di cristallo", "desc": "scogli di cristallo celeste che brillano nel vuoto",
	"band": "alto", "ores": [[57, 0.05]], "color": "#8ac8f0", "weight": 3, "floor": 55, "body": 55, "rock": 55, "isle": "scoglio", "isles": 1.6,
	"pools": 0.0, "trees": 0.0, "danger": 1.8, "thin": 1.0, "elem": "gelo", "adj": ["cristalline", "celesti"],
	"tiles": {
		55: {"name": "Cristallo celeste", "hard": 0.6, "power": 35, "drop": "cristallo_celeste", "square": true, "glow": true,
			"pal": ["#1a3a5a", "#2a6090", "#4a90c8", "#8ac8f0", "#e0f6ff"], "layer": "cristallo_celeste", "specks": 0, "pass": 0.7,
			"emit": [0.3, 0.55, 0.9]},
	},
	"veg": [[0.12, 86], [0.2, 87]],
	"decor": {86: {"soft": "pianta", "light": Color(0.3, 0.55, 0.8)}, 87: {"soft": "pianta", "light": Color(0.4, 0.6, 0.9)}},
	"items": {
		"cristallo_celeste": {"name": "Cristallo celeste", "kind": "blocco", "icon": ["gemma", "celeste"], "place": 55,
			"desc": "Brilla da sé: un blocco che fa luce, e un materiale per le lenti e le ali."},
	},
}
