extends RefCounted
## Il Firmamento (Roadmap 16, voce 156, cielo alto): il cielo più alto: polvere di stelle, frammenti caduti, la notte anche di giorno.
## Campi in cima a `SkyData`; questo file non nomina altre classi.

const DATA := {
	"id": "firmamento", "name": "Il Firmamento", "desc": "polvere di stelle e silenzio: qui è notte anche di giorno",
	"band": "alto", "color": "#c8d0ff", "weight": 2, "floor": 56, "body": 56, "rock": 55, "isle": "stelle", "isles": 1.3,
	"pools": 0.0, "trees": 0.0, "danger": 2.3, "thin": 1.6, "dark": 0.85, "elem": "vuoto", "adj": ["stellate", "altissime"],
	"tiles": {
		56: {"name": "Polvere di stelle", "hard": 0.28, "power": 0, "drop": "polvere_stelle", "glow": true,
			"pal": ["#101430", "#1c2450", "#2e3a78", "#6a78c0", "#f0f0ff"], "layer": "polvere_stelle", "specks": 40, "emit": [0.28, 0.28, 0.5]},
	},
	"veg": [[0.16, 90], [0.21, 91]],
	"decor": {90: {"soft": "erba", "light": Color(0.2, 0.2, 0.4)}, 91: {"soft": "pianta", "light": Color(0.6, 0.55, 0.3)}},
	"items": {
		"polvere_stelle": {"name": "Polvere di stelle", "kind": "blocco", "icon": ["polvere", "stelle"], "place": 56,
			"desc": "La sabbia del Firmamento: brilla piano, e nelle ricette dei Seminatori vale oro."},
	},
}
